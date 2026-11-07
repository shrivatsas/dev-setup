import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(os.environ.get('ATTRIBUTION_SCRIPT', str(Path(__file__).resolve().parents[1] / 'bin' / 'claude-attribution')))
SESSION = '11111111-2222-3333-4444-555555555555'


class AttributionTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.config = Path(self._tmp.name)
        self.environ = dict(os.environ, CLAUDE_CONFIG_DIR=str(self.config))
        for key in ('CLAUDE_CODE_SESSION_ID', 'CLAUDE_CODE_EFFORT_LEVEL', 'ANTHROPIC_MODEL'):
            self.environ.pop(key, None)

    def invoke(self, events, args=(), cwd=None, transcript=True):
        path = self.config / 'session.jsonl'
        path.write_text(''.join(json.dumps(e) + '\n' for e in events))
        extra = ('--transcript', str(path)) if transcript else ()
        return subprocess.run(
            ['python3', str(SCRIPT), *args, *extra],
            text=True, capture_output=True, env=self.environ, cwd=cwd or self.config,
        )

    def turn(self, message_id, model='model-a', effort='medium', usage=None):
        event = {'type': 'assistant', 'perTurnEffort': effort,
                 'message': {'id': message_id, 'model': model}}
        if usage is not None:
            event['message']['usage'] = usage
        return event

    def usage(self, incoming, outgoing, cache_create=0, cache_read=0):
        return {'input_tokens': incoming, 'output_tokens': outgoing,
                'cache_creation_input_tokens': cache_create,
                'cache_read_input_tokens': cache_read}

    def test_sums_turns_and_includes_cache_tokens_in_input(self):
        result = self.invoke([self.turn('a', usage=self.usage(10, 2, 5, 100)),
                              self.turn('b', usage=self.usage(20, 4))])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout,
                         f'<sub>harness: claude-code · model: model-a (medium) · session: session · tokens: 135/6</sub>\n')

    def test_replayed_turns_are_counted_once(self):
        turn = self.turn('a', usage=self.usage(10, 2))
        result = self.invoke([turn, turn])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('tokens: 10/2', result.stdout)

    def test_missing_usage_is_unknown(self):
        result = self.invoke([self.turn('a')])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('tokens: unknown', result.stdout)

    def test_synthetic_turns_do_not_replace_model(self):
        result = self.invoke([self.turn('a', model='model-a', usage=self.usage(1, 1)),
                              self.turn('b', model='<synthetic>', effort='high')])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('model: model-a (high)', result.stdout)

    def test_env_supplies_session_and_effort_fallbacks(self):
        self.environ['CLAUDE_CODE_SESSION_ID'] = 'env-session'
        self.environ['CLAUDE_CODE_EFFORT_LEVEL'] = 'low'
        self.environ['ANTHROPIC_MODEL'] = 'model<b>'
        result = self.invoke([{'type': 'assistant', 'message': {'id': 'a', 'model': '<synthetic>'}}])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('model: model&lt;b&gt; (low)', result.stdout)
        self.assertIn('session: env-session', result.stdout)

    def test_discovers_session_from_project_directory(self):
        work = self.config / 'work-demo'
        work.mkdir()
        slug = '-' + '-'.join(work.parts[1:])
        project = self.config / 'projects' / slug
        project.mkdir(parents=True)
        (project / f'{SESSION}.jsonl').write_text(
            json.dumps(self.turn('a', usage=self.usage(7, 3))) + '\n')
        environ = dict(self.environ, CLAUDE_CODE_SESSION_ID=SESSION)
        result = subprocess.run(['python3', str(SCRIPT)], text=True, capture_output=True,
                                env=environ, cwd=work)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f'session: {SESSION}', result.stdout)
        self.assertIn('tokens: 7/3', result.stdout)

    def test_account_config_dir_listed_once(self):
        # CLUADE_CONFIG_DIR inside ~/.claude-accounts is also matched by the glob;
        # a duplicate would make the single-transcript fallback ambiguous.
        home = Path(self._tmp.name) / 'home'
        config = home / '.claude-accounts' / 'account'
        project = config / 'projects' / '-elsewhere'
        project.mkdir(parents=True)
        (project / f'{SESSION}.jsonl').write_text(
            json.dumps(self.turn('a', usage=self.usage(7, 3))) + '\n')
        environ = dict(self.environ, HOME=str(home), CLAUDE_CONFIG_DIR=str(config),
                       CLAUDE_CODE_SESSION_ID=SESSION)
        result = subprocess.run(['python3', str(SCRIPT)], text=True, capture_output=True,
                                env=environ, cwd=home)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f'session: {SESSION}', result.stdout)
        self.assertIn('tokens: 7/3', result.stdout)

    def test_missing_transcript_degrades_to_unknown_tokens(self):
        result = self.invoke([], args=('--session', 'absent'), transcript=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('session: absent', result.stdout)
        self.assertIn('tokens: unknown', result.stdout)


if __name__ == '__main__':
    unittest.main()
