cask "ketch" do
  arch arm: "aarch64", intel: "x86_64"

  version "0.3.1"
  sha256 arm:   "5604bce910cc4ec7de744c36d4014c59079e40d303bedbc469f81daab19c0613",
         intel: "a2f6d1f0e0949929f5a3b43149ac3c72366fd97bbcfd76208f2cb27304652005"

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
    # Two flags, both because of where this runs. `--keep-packages` removes the
    # ketch package and nothing else: what ketch installed is not Homebrew's to
    # take, and stays until `zap`. `--no-brew` stops ketch calling
    # `brew uninstall --cask ketch` from inside that very command.
    run "/bin/sh", args:           ["-c",
                                    'eval "r=~$1/.ketch" && KETCH_ROOT="$r" ' \
                                    'exec "$r/bin/ketch" self uninstall -y --keep-packages --no-brew',
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
