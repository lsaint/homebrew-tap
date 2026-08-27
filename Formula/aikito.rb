class Aikito < Formula
  include Language::Python::Shebang

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://github.com/lsaint/aikito/archive/refs/tags/v1.18.1.tar.gz"
  sha256 "91ced6ac3cf30b04e4d5883a69cc1ecaed5b3ad2bcab67fb3fe98d25ba5620cb"
  license "MIT"

  depends_on "git"
  depends_on "python@3.14"

  def install
    libexec.install "bin"
    libexec.install "web"
    (libexec/"skills").install "skills/aikito", "skills/durable-memory"
    rewrite_shebang detected_python_shebang, libexec/"bin/aikito"
    bin.install_symlink libexec/"bin/aikito"

    # Install shell completions (Bash, Zsh, Fish)
    generate_completions_from_executable(bin/"aikito", "completion")
  end

  test do
    assert_match "aikito 1.18.1", shell_output("#{bin}/aikito --version")
    system bin/"aikito", "init", "workspace", testpath/"workspace"
    assert_path_exists testpath/"workspace/agents.toml"
    assert_path_exists testpath/"workspace/skills/aikito/SKILL.md"
    assert_path_exists testpath/"workspace/skills/durable-memory/SKILL.md"
    assert_match 'skills = ["aikito", "durable-memory"]', (testpath/"workspace/skills.toml").read
    assert_match "All tasks must follow the `durable-memory` skill", (testpath/"workspace/global/AGENTS.md").read
    assert_path_exists libexec/"web/index.html"
  end
end
