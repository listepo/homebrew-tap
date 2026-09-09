cask "ketch" do
  arch arm: "aarch64", intel: "x86_64"

  version "0.1.0"
  sha256 arm:   "7c1d078baa0dd24ff8d8917bdafec3720ae865dec315cc361f2360914473e0d0",
         intel: "b35777d9b82cd0a6b24503b7655df985e0c5d7b2b627b9a1acbe7b1fea826cfa"

  url "https://github.com/listepo/ketch/releases/download/v#{version}/ketch-#{arch}-apple-darwin.tar.gz"
  name "ketch"
  desc "Catch releases straight from GitHub"
  homepage "https://github.com/listepo/ketch"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  # ketch installs itself into ~/.ketch as one of its own packages; Homebrew
  # only delivers the binary that does so. Nothing is linked into the prefix.
  stage_only true

  postflight_steps do
    # The staged binary runs exactly once, to install a copy that ketch
    # downloads and verifies itself. Gatekeeper would refuse the quarantined
    # bootstrap otherwise, as it refuses any command-line binary that is not
    # notarised; install.sh lifts the same attribute.
    run "/usr/bin/xattr", args: ["-d", "com.apple.quarantine", "{{staged_path}}/ketch"], must_succeed: false
    # The steps run with a throwaway HOME and the DSL has no token for the
    # real one, so the shell asks the user database instead: `~user` expands
    # from there, not from HOME. ~/.ketch is the one path under the home
    # directory a step may write, and the only one ketch touches.
    if_path_exists ".ketch/store/ketch", base: :home do
      run "/bin/sh", args:           ["-c", 'eval "r=~$1/.ketch" && KETCH_ROOT="$r" exec "$2" self update',
                                      "ketch", "{{user}}", "{{staged_path}}/ketch"],
                     network_access: true,
                     writable_paths: [".ketch"],
                     writable_base:  :home
    end
    unless_path_exists ".ketch/store/ketch", base: :home do
      run "/bin/sh", args:           ["-c", 'eval "r=~$1/.ketch" && KETCH_ROOT="$r" exec "$2" self install',
                                      "ketch", "{{user}}", "{{staged_path}}/ketch"],
                     network_access: true,
                     writable_paths: [".ketch"],
                     writable_base:  :home
    end
  end

  uninstall_postflight_steps do
    # Removes the ketch package and nothing else; what ketch installed stays
    # until `zap`.
    run "/bin/sh", args:           ["-c",
                                    'eval "r=~$1/.ketch" && KETCH_ROOT="$r" exec "$r/bin/ketch" self uninstall -y',
                                    "ketch", "{{user}}"],
                   must_succeed:   false,
                   writable_paths: [".ketch"],
                   writable_base:  :home
  end

  zap trash: "~/.ketch"

  caveats do
    path_environment_variable "#{Dir.home}/.ketch/bin"
  end
end
