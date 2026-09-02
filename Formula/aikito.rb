class Aikito < Formula
  include Language::Python::Shebang

  desc "Durable workspace for governing context across AI agents"
  homepage "https://github.com/lsaint/aikito"
  url "https://github.com/lsaint/aikito/archive/refs/tags/v1.23.0.tar.gz"
  sha256 "696b2718d1ab648098f0e4500d198478a4a173cf1a889b4e419b402b32e68457"
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
    assert_match "aikito 1.23.0", shell_output("#{bin}/aikito --version")
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
