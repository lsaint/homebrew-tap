"""Release updates retain encryption dependencies and immutable archive identity."""

import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "update_aikito", ROOT / "scripts/update_aikito.py"
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
OLD_URL = "https://files.pythonhosted.org/packages/archive/aikito-1.2.3.tar.gz"
NEW_URL = "https://files.pythonhosted.org/packages/archive/aikito-1.2.4.tar.gz"
BODY = f'''class Aikito < Formula
  url "{OLD_URL}"
  sha256 "{"a" * 64}"
  revision 1
  depends_on "cryptography"
  depends_on "python@3.14"
  def install
    virtualenv_install_with_resources system_site_packages: true
  end
  resource "example" do
    url "https://files.pythonhosted.org/packages/example.tar.gz"
    sha256 "{"c" * 64}"
  end
end
'''


class FormulaTests(unittest.TestCase):
    def test_new_release_preserves_dependencies_resources_and_resets_revision(self):
        result = MODULE.update_formula(BODY, "1.2.4", NEW_URL, "b" * 64)
        self.assertIn(NEW_URL, result)
        self.assertIn('depends_on "cryptography"', result)
        self.assertIn("system_site_packages: true", result)
        self.assertNotIn("revision", result)
        self.assertIn('    sha256 "' + "c" * 64 + '"', result)
        self.assertIn("https://files.pythonhosted.org/packages/example.tar.gz", result)

    def test_same_immutable_release_is_idempotent(self):
        self.assertEqual(MODULE.update_formula(BODY, "1.2.3", OLD_URL, "a" * 64), BODY)

    def test_changed_published_archive_or_downgrade_is_refused(self):
        for version, url, checksum in (
            ("1.2.3", OLD_URL, "b" * 64),
            ("1.2.3", OLD_URL.replace("archive", "replacement"), "a" * 64),
            ("1.2.2", OLD_URL.replace("1.2.3", "1.2.2"), "a" * 64),
        ):
            with self.subTest(version=version, url=url), self.assertRaises(ValueError):
                MODULE.update_formula(BODY, version, url, checksum)

    def test_malformed_ambiguous_or_untrusted_archive_is_refused(self):
        for content, version, url, checksum in (
            (BODY, "bad", NEW_URL, "b" * 64),
            (BODY, "1.2.4", NEW_URL.replace("https", "http"), "b" * 64),
            (
                BODY,
                "1.2.4",
                NEW_URL.replace("files.pythonhosted.org", "example.invalid"),
                "b" * 64,
            ),
            (BODY, "1.2.4", NEW_URL, "bad"),
            (BODY + f'  url "{OLD_URL}"\n', "1.2.4", NEW_URL, "b" * 64),
        ):
            with self.subTest(version=version, url=url), self.assertRaises(ValueError):
                MODULE.update_formula(content, version, url, checksum)

    def test_formula_contains_default_encryption_runtime_check(self):
        formula = (ROOT / "Formula/aikito.rb").read_text()
        self.assertIn('depends_on "cryptography"', formula)
        self.assertIn(
            "virtualenv_install_with_resources system_site_packages: true", formula
        )
        self.assertIn("cryptography.hazmat.primitives.hpke", formula)
        self.assertIn("suite.decrypt", formula)
        self.assertIn('system libexec/"bin/python"', formula)


if __name__ == "__main__":
    unittest.main()
