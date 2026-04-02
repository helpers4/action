<h1 align="center">helpers4 — GitHub Actions</h1>

<p align="center">
  <strong>Custom GitHub Actions published to the GitHub Marketplace.</strong>
</p>

<p align="center">
  <a href="https://github.com/helpers4/action/blob/main/LICENSE"><img src="https://img.shields.io/github/license/helpers4/action?color=blue" alt="license" /></a>
  <a href="https://github.com/helpers4/action"><img src="https://img.shields.io/github/last-commit/helpers4/action" alt="last commit" /></a>
</p>

---

## Actions

### Conventional Commits Check

Validates that all commit messages in a pull request follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

**Usage:**

```yaml
- uses: helpers4/action/conventional-commits@main
```

**Features:**
- Validates commit message format against the Conventional Commits spec
- Runs as a lightweight shell-based action (no Node.js runtime required)
- Provides clear error messages for non-compliant commits
- Ideal for enforcing consistent commit history in CI pipelines

📖 [Full documentation](conventional-commits/README.md)

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
