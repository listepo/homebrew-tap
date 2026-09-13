class Rtok < Formula
  desc "Token-reduction CLI for AI coding agents: hooks, MCP server and API proxy with pluggable methods"
  homepage "https://listepo.github.io/rtok/"
  version "0.1.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/listepo/rtok/releases/download/v0.1.0/rtok-aarch64-apple-darwin.tar.xz"
      sha256 "9c2a95774a3ed0f6a013a104b9b4c338bac52a29b0a32b2c5c89c38d6329d099"
    end
    if Hardware::CPU.intel?
      url "https://github.com/listepo/rtok/releases/download/v0.1.0/rtok-x86_64-apple-darwin.tar.xz"
      sha256 "8cadc2ee899ccd605b8152010a5dd3ae5375c07ec1d603cbe2550760b5c44010"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/listepo/rtok/releases/download/v0.1.0/rtok-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "5457e0f304bb1047a523d0cd80b702332a1fdf6d5f796b38618c9c8f1077e606"
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
