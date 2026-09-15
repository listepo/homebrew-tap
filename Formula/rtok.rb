class Rtok < Formula
  desc "Token-reduction CLI for AI coding agents: hooks, MCP server and API proxy with pluggable methods"
  homepage "https://listepo.github.io/rtok/"
  version "0.1.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/listepo/rtok/releases/download/v0.1.1/rtok-aarch64-apple-darwin.tar.xz"
      sha256 "2b23ce59c98c2fb3745d97045ca55e04e33b4f02e911d090fd9b11ace1005490"
    end
    if Hardware::CPU.intel?
      url "https://github.com/listepo/rtok/releases/download/v0.1.1/rtok-x86_64-apple-darwin.tar.xz"
      sha256 "9fa9333a12cb4847f977c81c2c51728b627cfc733078c7f4341f867a3e5c2bd2"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/listepo/rtok/releases/download/v0.1.1/rtok-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "646ce3bd8502101b8c3373895f14df8ce870e9bcf7970850cfeb4279bbaebdc1"
    end
  end

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "x86_64-apple-darwin": {},
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
    if OS.mac? && Hardware::CPU.intel?
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
