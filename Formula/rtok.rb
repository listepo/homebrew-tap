class Rtok < Formula
  desc "Token-reduction CLI for AI coding agents: hooks, MCP server and API proxy with pluggable methods"
  homepage "https://listepo.github.io/rtok/"
  version "0.1.6"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/listepo/rtok/releases/download/v0.1.6/rtok-aarch64-apple-darwin.tar.xz"
      sha256 "ac955add22a693cc827632ba006b9d4376a3190724bf27e5a01535bf82075ce7"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/listepo/rtok/releases/download/v0.1.6/rtok-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "b7dc73cb3d3f06b3643740230ae009d9c1f8babe797c59b4d69508bd91726e49"
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
