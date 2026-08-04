class Aikito < Formula
  desc "Git-managed workspace and CLI for AI-agent durable memory and config"
  homepage "https://github.com/lsaint/aikito"
  url "https://github.com/lsaint/aikito/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  depends_on "python@3.13"
  depends_on "git"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/aikito"
  end

  test do
    system "#{bin}/aikito", "--help"
  end
end
