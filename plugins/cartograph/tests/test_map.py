#!/usr/bin/env python3
"""The map script is the only executable the plugin ships, so its five subcommands are the contract.

Nothing exercised them: `validate`, `render`, `frontier`, `ready` and `report` were checked by
hand against the survey templates, which is work a reviewer would have to repeat and nobody would
keep doing. These tests pin the exit codes and the artefacts. The fixture is copied from
`skills/cartograph-survey/templates/`, so it cannot drift from what `/cartograph-survey` emits.

    python3 plugins/cartograph/tests/test_map.py
"""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

try:
    import yaml  # noqa: F401
    HAVE_YAML = True
except ImportError:
    HAVE_YAML = False

PLUGIN = Path(__file__).resolve().parents[1]
SCRIPT = Path(os.environ.get(
    "CARTOGRAPH_MAP_SCRIPT", str(PLUGIN / "skills" / "cartograph-map" / "scripts" / "map.py")
))
TEMPLATES = PLUGIN / "skills" / "cartograph-survey" / "templates"


@unittest.skipUnless(HAVE_YAML, "map.py requires PyYAML")
class MapTests(unittest.TestCase):
    def setUp(self):
        handle = tempfile.TemporaryDirectory()
        self.addCleanup(handle.cleanup)
        self.root = Path(handle.name)

    def invoke(self, *args):
        return subprocess.run(
            [sys.executable, str(SCRIPT), *args], text=True, capture_output=True
        )

    def survey_map(self, name="map"):
        """The template pair, as /cartograph-survey writes it: every area still in fog."""
        destination = self.root / name
        destination.mkdir(parents=True)
        for template in ("map.yaml", "assumptions.yaml"):
            shutil.copy(TEMPLATES / template, destination / template)
        return destination

    def test_validate_accepts_the_shipped_template(self):
        result = self.invoke("validate", str(self.survey_map()))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("0 error(s)", result.stdout)

    def test_validate_rejects_broken_yaml(self):
        broken = self.root / "broken"
        broken.mkdir()
        (broken / "map.yaml").write_text("areas: [\n")
        result = self.invoke("validate", str(broken))
        self.assertEqual(result.returncode, 1)
        self.assertIn("YAML syntax error", result.stdout + result.stderr)

    def test_missing_map_names_the_next_step(self):
        result = self.invoke("validate", str(self.root / "absent"))
        self.assertEqual(result.returncode, 1)
        self.assertIn("cartograph-survey", result.stdout + result.stderr)

    def test_render_writes_map_markdown(self):
        map_dir = self.survey_map()
        result = self.invoke("render", str(map_dir))
        self.assertEqual(result.returncode, 0, result.stderr)
        rendered = map_dir / "MAP.md"
        self.assertTrue(rendered.exists(), "render did not write MAP.md")
        self.assertTrue(rendered.read_text().strip())

    def test_frontier_ranks_uncharted_cells(self):
        result = self.invoke("frontier", str(self.survey_map()))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(result.stdout.strip(), "frontier listed nothing to chart")

    def test_ready_refuses_a_fog_map(self):
        result = self.invoke("ready", str(self.survey_map()), "<area-id>")
        self.assertEqual(result.returncode, 1, "an uncharted area must not be called ready")
        self.assertIn("NOT READY", result.stdout)

    def test_report_writes_a_dated_dossier(self):
        map_dir = self.survey_map()
        result = self.invoke("report", str(map_dir))
        self.assertEqual(result.returncode, 0, result.stderr)
        reports = list((map_dir / "reports").glob("*.md"))
        self.assertEqual(len(reports), 1, f"expected one report, got {reports}")
        self.assertTrue(reports[0].read_text().strip())


if __name__ == "__main__":
    unittest.main(verbosity=2)
