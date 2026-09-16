class Rtok < Formula
  desc "Token-reduction CLI for AI coding agents: hooks, MCP server and API proxy with pluggable methods"
  homepage "https://listepo.github.io/rtok/"
  version "0.1.3"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/listepo/rtok/releases/download/v0.1.3/rtok-aarch64-apple-darwin.tar.xz"
      sha256 "83e2a6405fcdfa5f37c6ce430f625388c3c1600a67d8935385581769079faaab"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/listepo/rtok/releases/download/v0.1.3/rtok-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "50d4ebad998fc4e69f360bc03f3dca1a90761a4fdc7dd34cbfd2d8a6858dc978"
    end
  end

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "x86_64-pc-windows-gnu": {},
    "x86_64-unknown-linux-gnu": {}
  }

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "rtok"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "rtok"
    end

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
