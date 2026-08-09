class Aikito < Formula
  include Language::Python::Shebang

  desc "Git-managed workspace and CLI for AI-agent durable memory and config"
  homepage "https://github.com/lsaint/aikito"
  url "https://github.com/lsaint/aikito/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "47ae9fc1d1846567493a1bc112269fa2d0ce51592297b96f7d621e21b2414eeb"
  license "MIT"

  depends_on "git"
  depends_on "python@3.14"

  def install
    libexec.install "bin"
    rewrite_shebang detected_python_shebang, libexec/"bin/aikito"
    bin.install_symlink libexec/"bin/aikito"
  end

  test do
    assert_match "aikito 0.3.1", shell_output("#{bin}/aikito --version")
    system bin/"aikito", "init", testpath/"workspace"
    assert_path_exists testpath/"workspace/agents.toml"
  end
end
