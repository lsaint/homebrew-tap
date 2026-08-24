class Aikito < Formula
  include Language::Python::Shebang

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://github.com/lsaint/aikito/archive/refs/tags/v1.13.0.tar.gz"
  sha256 "5d0b57af370ef771acbe1799675a898e676e5b487d526e44e216968d5187ce24"
  license "MIT"

  depends_on "git"
  depends_on "python@3.14"

  def install
    libexec.install "bin"
    rewrite_shebang detected_python_shebang, libexec/"bin/aikito"
    bin.install_symlink libexec/"bin/aikito"

    # Install shell completions (Bash, Zsh, Fish)
    generate_completions_from_executable(bin/"aikito", "completion")
  end

  test do
    assert_match "aikito 1.13.0", shell_output("#{bin}/aikito --version")
    system bin/"aikito", "init", "workspace", testpath/"workspace"
    assert_path_exists testpath/"workspace/agents.toml"
  end
end
