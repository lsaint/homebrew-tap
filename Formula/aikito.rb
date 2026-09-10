class Aikito < Formula
  include Language::Python::Virtualenv

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://files.pythonhosted.org/packages/bb/0f/d8f77abbdd04f83994d45e0c0c0b382f6dc18f19da3ca4963781d228d428/aikito-1.31.0.tar.gz"
  sha256 "0fdddcd891519d4a13bfeb67f189b952cbf26dc472835898d50839e17b19f4bd"
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
    assert_path_exists pkg/"templates/skills/durable-memory/SKILL.md"
  end
end
