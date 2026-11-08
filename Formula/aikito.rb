class Aikito < Formula
  include Language::Python::Virtualenv

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://files.pythonhosted.org/packages/9e/5b/3cb73ed9c6d689d4cfc311c657f6ce3aca1e7b6150d22d4d2a10447a8d49/aikito-1.63.0.tar.gz"
  sha256 "b9dfbbf967a24f935b6b3304f04424a87deafd5deb4236bb582f432b850571e5"
  license "MIT"

  depends_on "cryptography"
  depends_on "git"
  depends_on "python@3.14"

  def install
    virtualenv_install_with_resources system_site_packages: true
    generate_completions_from_executable(bin/"aikito", "completion")
  end

  test do
    ENV["XDG_CONFIG_HOME"] = (testpath/"config").to_s
    (testpath/"encrypted-smoke.py").write <<~PYTHON
      from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey
      from cryptography.hazmat.primitives.ciphers.aead import AESGCM
      from cryptography.hazmat.primitives.hpke import Suite, KEM, KDF, AEAD

      key = AESGCM.generate_key(bit_length=256)
      aes = AESGCM(key)
      nonce = bytes(12)
      sealed = aes.encrypt(nonce, b"homebrew-encrypted", b"aikito-install-check")
      assert aes.decrypt(nonce, sealed, b"aikito-install-check") == b"homebrew-encrypted"
      private = X25519PrivateKey.generate()
      suite = Suite(KEM.X25519, KDF.HKDF_SHA256, AEAD.AES_256_GCM)
      sealed = suite.encrypt(b"scoped-read", private.public_key(), info=b"aikito-install-check")
      assert suite.decrypt(sealed, private, info=b"aikito-install-check") == b"scoped-read"
    PYTHON
    system libexec/"bin/python", testpath/"encrypted-smoke.py"
    assert_match "aikito #{version}", shell_output("#{bin}/aikito --version")
    system bin/"aikito", "init", "workspace", testpath/"workspace"
    assert_path_exists testpath/"workspace/config.toml"
    assert_path_exists testpath/"workspace/layout.toml"
    assert_path_exists testpath/"workspace/agents"
    assert_path_exists testpath/"workspace/skills/aikito/SKILL.md"
    assert_path_exists testpath/"workspace/skills/aikito/references/adoption.md"
    assert_path_exists testpath/"workspace/skills/durable-memory/SKILL.md"
    skills_toml = (testpath/"workspace/skills.toml").read
    assert_match '"aikito"', skills_toml
    assert_match '"durable-memory"', skills_toml
    assert_match "All tasks must follow the `durable-memory` skill", (testpath/"workspace/global/AGENTS.md").read

    pkg = Pathname.glob(libexec/"lib/python*/site-packages/aikito").first
    assert_path_exists pkg/"bundled_skills.py"
    assert_path_exists pkg/"web/index.html"
    assert_path_exists pkg/"web/marked.umd.js"
    assert_path_exists pkg/"templates/agents/codex.toml"
    assert_path_exists pkg/"templates/skills/aikito/references/adoption.md"
    assert_path_exists pkg/"templates/skills/durable-memory/SKILL.md"
  end
end
