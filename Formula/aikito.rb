class Aikito < Formula
  include Language::Python::Shebang

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://github.com/lsaint/aikito/archive/refs/tags/v1.20.1.tar.gz"
  sha256 "1cd6c96f41ab637a6f22a02a65a858f082955f5e6cd93ca6a3ce76161b885a00"
  license "MIT"

  depends_on "git"
  depends_on "python@3.14"

  def install
    libexec.install "bin"
    libexec.install "web"
    libexec.install "templates"
    rewrite_shebang detected_python_shebang, libexec/"bin/aikito"
    bin.install_symlink libexec/"bin/aikito"

    # Install shell completions (Bash, Zsh, Fish)
    generate_completions_from_executable(bin/"aikito", "completion")
  end

  test do
    assert_match "aikito 1.20.1", shell_output("#{bin}/aikito --version")
    system bin/"aikito", "init", "workspace", testpath/"workspace"
    assert_path_exists testpath/"workspace/agents.toml"
    assert_path_exists testpath/"workspace/skills/aikito/SKILL.md"
    assert_path_exists testpath/"workspace/skills/durable-memory/SKILL.md"
    skills_toml = (testpath/"workspace/skills.toml").read
    assert_match '"aikito"', skills_toml
    assert_match '"durable-memory"', skills_toml
    assert_match "All tasks must follow the `durable-memory` skill", (testpath/"workspace/global/AGENTS.md").read
    assert_path_exists libexec/"web/index.html"
    assert_path_exists libexec/"templates/skills/aikito/SKILL.md"
    assert_path_exists libexec/"templates/skills/durable-memory/SKILL.md"
  end
end
