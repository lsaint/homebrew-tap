class Aikito < Formula
  include Language::Python::Virtualenv

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://files.pythonhosted.org/packages/fa/8f/0e6c76b81824060bd96ef8d3aa6f0a9800a9b7d7382f1b41824e6cb1a2c3/aikito-1.57.7.tar.gz"
  sha256 "85427840d3e8b95f231278389138f6de43fde5f7f51f20effd1a871a49ea3a31"
  license "MIT"

  depends_on "git"
  depends_on "python@3.14"

  def install
    virtualenv_install_with_resources
    generate_completions_from_executable(bin/"aikito", "completion")
  end

  test do
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
