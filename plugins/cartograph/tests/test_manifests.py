#!/usr/bin/env python3
"""Two manifests describe this plugin, and four agents read its skills from four different roots.

Claude Code reads `.claude-plugin/plugin.json`, Codex reads `.codex-plugin/plugin.json`, and pi
and agy read skill directories rather than manifests, which is why every skill carries an
`agents/openai.yaml` interface block. Nothing kept the two manifests in agreement: name, version,
description and license were copied by hand, so the next edit could ship a plugin whose two
halves disagree about what it is.

    python3 plugins/cartograph/tests/test_manifests.py
"""
import json
from pathlib import Path
import unittest

try:
    import yaml
    HAVE_YAML = True
except ImportError:
    HAVE_YAML = False

PLUGIN = Path(__file__).resolve().parents[1]
MANIFESTS = {
    "claude": PLUGIN / ".claude-plugin" / "plugin.json",
    "codex": PLUGIN / ".codex-plugin" / "plugin.json",
}
SKILLS = PLUGIN / "skills"


@unittest.skipUnless(HAVE_YAML, "the interface checks need PyYAML")
class ManifestTests(unittest.TestCase):
    def test_both_manifests_parse(self):
        for agent, path in MANIFESTS.items():
            with self.subTest(agent=agent):
                self.assertTrue(path.is_file(), f"{agent} manifest is missing")
                self.assertIsInstance(json.loads(path.read_text()), dict)

    def test_manifests_agree_on_identity(self):
        loaded = {agent: json.loads(path.read_text()) for agent, path in MANIFESTS.items()}
        for key in ("name", "version", "description", "license"):
            with self.subTest(key=key):
                values = {agent: data.get(key) for agent, data in loaded.items()}
                self.assertEqual(
                    len(set(values.values())), 1,
                    f"manifests disagree on {key}: {values}",
                )

    def test_codex_manifest_points_at_the_skills_directory(self):
        codex = json.loads(MANIFESTS["codex"].read_text())
        self.assertEqual(codex.get("skills"), "./skills/")
        self.assertTrue((PLUGIN / "skills").is_dir())
        self.assertTrue(codex.get("interface", {}).get("displayName"))
        self.assertTrue(codex.get("interface", {}).get("defaultPrompt"))

    def test_every_skill_declares_frontmatter_and_an_interface(self):
        skills = sorted(p for p in SKILLS.iterdir() if (p / "SKILL.md").is_file())
        self.assertTrue(skills, "no skills found")
        for skill in skills:
            with self.subTest(skill=skill.name):
                text = (skill / "SKILL.md").read_text()
                self.assertTrue(text.startswith("---"), "SKILL.md has no frontmatter")
                front = yaml.safe_load(text[3:text.find("\n---", 3)])
                self.assertEqual(front.get("name"), skill.name)
                self.assertTrue(front.get("description"))

                interface_file = skill / "agents" / "openai.yaml"
                self.assertTrue(interface_file.is_file(), "no agents/openai.yaml")
                interface = yaml.safe_load(interface_file.read_text()).get("interface") or {}
                for key in ("display_name", "short_description", "default_prompt"):
                    self.assertTrue(interface.get(key), f"interface is missing {key}")

    def test_skill_names_are_unique(self):
        names = []
        for skill in SKILLS.iterdir():
            text = (skill / "SKILL.md")
            if text.is_file():
                names.append(yaml.safe_load(text.read_text()[3:text.read_text().find("\n---", 3)])["name"])
        self.assertEqual(len(names), len(set(names)), f"duplicate skill names: {names}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
