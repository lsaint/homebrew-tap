class Aikito < Formula
  include Language::Python::Virtualenv

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://files.pythonhosted.org/packages/12/7a/61820d3be2ae438a0b589e7f8211bd3f73545f0db7c61defa1b5aaefe6f5/aikito-1.35.0.tar.gz"
  sha256 "d1c09b6b40006da289947c2c4f487ec27fe9388e14ddd3fa2d03ed2b8c99fb1d"
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
