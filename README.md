<h1 align="center">helpers4 — GitHub Actions</h1>

<p align="center">
  <strong>Custom GitHub Actions published to the GitHub Marketplace.</strong>
</p>

<p align="center">
  <a href="https://github.com/helpers4/action/blob/main/LICENSE"><img src="https://img.shields.io/github/license/helpers4/action?color=blue" alt="license" /></a>
  <a href="https://github.com/helpers4/action"><img src="https://img.shields.io/github/last-commit/helpers4/action" alt="last commit" /></a>
  <a href="https://deepwiki.com/helpers4/action"><img src="https://img.shields.io/badge/DeepWiki-helpers4%2Faction-blue" alt="Ask DeepWiki" /></a>
</p>

---

## Actions

### Conventional Commits Check

Validates that all commit messages in a pull request follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

**Usage:**

```yaml
- uses: helpers4/action/conventional-commits@v1
```

**Features:**
- Validates commit message format against the Conventional Commits spec
- Runs as a lightweight shell-based action (no Node.js runtime required)
- Provides clear error messages for non-compliant commits
- Ideal for enforcing consistent commit history in CI pipelines

📖 [Full documentation](conventional-commits/README.md)

### Setup pnpm

Sets up Node.js + pnpm via corepack, optionally installing dependencies.

**Usage:**

```yaml
- uses: helpers4/action/setup-pnpm@v1
  with:
    node-version: "26"
```

📖 [Full documentation](setup-pnpm/README.md)

### PR Status Comment

Posts or updates a single sticky PR comment summarizing job statuses as a table.

**Usage:**

```yaml
- uses: helpers4/action/pr-status-comment@v1
  with:
    jobs: |
      { "🏗️ Build": "${{ needs.build.result }}" }
```

📖 [Full documentation](pr-status-comment/README.md)

### Trigger Website Update

Dispatches a `repository_dispatch` event to `helpers4/website` via a GitHub App token, with an
optional fallback identity.

**Usage:**

```yaml
- uses: helpers4/action/trigger-website-update@v1
  with:
    event-type: action-release
    payload: '{"version": "${{ github.ref_name }}"}'
    app-id: ${{ vars.TRIGGANATOR_ID }}
    app-private-key: ${{ secrets.TRIGGANATOR_KEY }}
```

📖 [Full documentation](trigger-website-update/README.md)

## Documentation

Visit [**helpers4.dev/action**](https://helpers4.dev/action) for complete documentation.

## Contributing

Contributions are welcome! Please follow [Conventional Commits](https://www.conventionalcommits.org/) for all commit messages.

1. Fork the repository
2. Create your feature branch
3. Test your changes
4. Submit a Pull Request

## License

This project is licensed under the [GNU Lesser General Public License v3.0](LICENSE).

## Contributors

<table>
<tr>
    <td align="center" style="word-wrap: break-word; width: 150.0; height: 150.0">
        <a href="https://github.com/baxyz">
            <img src="https://avatars.githubusercontent.com/u/7852177?v=4" width="100;" alt="Bérenger"/>
            <br />
            <sub style="font-size:14px"><b>Bérenger</b></sub>
        </a>
    </td>
</tr>
</table>
