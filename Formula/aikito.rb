class Aikito < Formula
  include Language::Python::Virtualenv

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://files.pythonhosted.org/packages/01/68/d5f1a50b15e01bb69e4203c6b8613eb3daa767d111f740287467ca33ed8f/aikito-1.61.1.tar.gz"
  sha256 "d31e6a0dd886fe296f1b481cbaac154d5a8c24269499f6568b5d13a48a1ac0ae"
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
