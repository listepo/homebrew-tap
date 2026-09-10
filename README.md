# listepo/homebrew-tap

Homebrew tap for listepo tools.

```bash
brew tap listepo/tap
brew install --cask ketch   # existing
brew install rtok           # formula synced from listepo/rtok releases
```

`Casks/ketch.rb` is updated by ketch's release workflow.
`Formula/rtok.rb` is updated by [.github/workflows/sync-rtok.yml](.github/workflows/sync-rtok.yml):
it downloads the formula artifact from the latest `listepo/rtok` GitHub Release and opens a PR.
No `HOMEBREW_TAP_TOKEN` — the workflow runs in this repo with `GITHUB_TOKEN`.
