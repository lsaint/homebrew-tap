class Aikito < Formula
  include Language::Python::Shebang

  desc "Git-managed workspace and CLI for AI-agent durable memory and config"
  homepage "https://github.com/lsaint/aikito"
  url "https://github.com/lsaint/aikito/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "a2472771975b85e607bf5a23b387ccb76fa11e350233a860f367349c4fd47168"
  license "MIT"

  depends_on "git"
  depends_on "python@3.14"

  def install
    libexec.install "bin"
    rewrite_shebang detected_python_shebang, libexec/"bin/aikito"
    bin.install_symlink libexec/"bin/aikito"
  end

  test do
    assert_match "aikito 0.2.0", shell_output("#{bin}/aikito --version")
    system bin/"aikito", "init", testpath/"workspace"
    assert_path_exists testpath/"workspace/agents.toml"
  end
end
