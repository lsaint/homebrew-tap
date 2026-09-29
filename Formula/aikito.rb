class Aikito < Formula
  include Language::Python::Virtualenv

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://files.pythonhosted.org/packages/cd/84/ecf53de85670886662a333c43dd65c8c184a74a4c566a5b68e5b972500be/aikito-1.57.0.tar.gz"
  sha256 "b91c44c83a659cc064524c99d311993d85df9755625fdfc882da1857103b8504"
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
