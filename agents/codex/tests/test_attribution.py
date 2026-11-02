import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(os.environ.get('ATTRIBUTION_SCRIPT', str(Path(__file__).resolve().parents[1] / 'bin' / 'agent-attribution')))


class AttributionTests(unittest.TestCase):
    def invoke(self, events):
        with tempfile.TemporaryDirectory() as directory:
            log = Path(directory) / 'session.jsonl'
            log.write_text(''.join(json.dumps(e) + '\n' for e in events))
            return subprocess.run(
                ['python3', str(SCRIPT), '--log', str(log), '--session', 'test-session'],
                text=True, capture_output=True,
            )

    def events(self):
        return [
            {'type': 'session_meta', 'payload': {'id': 'test-session'}},
            {'type': 'turn_context', 'payload': {'model': 'model-a', 'effort': 'medium'}},
        ]

    def usage(self, incoming, outgoing):
        return {'type': 'event_msg', 'payload': {'type': 'token_count', 'info': {
            'total_token_usage': {'input_tokens': incoming, 'output_tokens': outgoing}}}}

    def test_uses_latest_totals_without_summing_cumulative_values(self):
        result = self.invoke(self.events() + [self.usage(10, 2), self.usage(25, 4)])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '<sub>harness: codex · model: model-a (medium) · session: test-session · tokens: 25/4</sub>\n')

    def test_missing_usage_is_unknown(self):
        result = self.invoke(self.events())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('tokens: unknown', result.stdout)

    def test_latest_context_and_html_escaping(self):
        result = self.invoke(self.events() + [{'type': 'turn_context', 'payload': {
            'model': 'model<b>', 'effort': 'high'}}])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('model: model&lt;b&gt; (high)', result.stdout)

    def test_missing_model_or_effort_is_an_error(self):
        for context in ({'effort': 'high'}, {'model': 'model-a'}):
            with self.subTest(context=context):
                result = self.invoke(self.events()[:1] + [{'type': 'turn_context', 'payload': context}])
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, '')
                self.assertIn('model or reasoning effort', result.stderr)

    def test_wrong_session_is_rejected(self):
        events = self.events()
        events[0]['payload']['id'] = 'another-session'
        result = self.invoke(events)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('session ID', result.stderr)

    def test_null_usage_does_not_erase_known_totals(self):
        result = self.invoke(self.events() + [self.usage(25, 4),
            {'type': 'event_msg', 'payload': {'type': 'token_count', 'info': None}}])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('tokens: 25/4', result.stdout)


if __name__ == '__main__':
    unittest.main()
