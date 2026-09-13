class Aikito < Formula
  include Language::Python::Virtualenv

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://files.pythonhosted.org/packages/ed/b7/2f2cd554ebe204ced5f45fd288238edc219c79cdb83a90fa4967f6b0dd6b/aikito-1.34.0.tar.gz"
  sha256 "9cda86b16cd22bcbf3cde2e60dd544d13aa021645e5aa0a2d2d48349e3d4e03c"
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
    assert_path_exists testpath/"workspace/agents.toml"
    assert_path_exists testpath/"workspace/skills/aikito/SKILL.md"
    assert_path_exists testpath/"workspace/skills/durable-memory/SKILL.md"
    skills_toml = (testpath/"workspace/skills.toml").read
    assert_match '"aikito"', skills_toml
    assert_match '"durable-memory"', skills_toml
    assert_match "All tasks must follow the `durable-memory` skill", (testpath/"workspace/global/AGENTS.md").read

    pkg = Pathname.glob(libexec/"lib/python*/site-packages/aikito").first
    assert_path_exists pkg/"web/index.html"
    assert_path_exists pkg/"web/marked.umd.js"
    assert_path_exists pkg/"templates/skills/durable-memory/SKILL.md"
  end
end
