## FAQ

### How do I avoid github rate limiting?

First login:

```sh
gh auth login
```

Then set `NIX_CONFIG` environment variable

```sh
export NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)"
```

Or even better
```sh
alias nix="NIX_CONFIG=\"extra-access-tokens = github.com=$(gh auth token)\" nix"
```
