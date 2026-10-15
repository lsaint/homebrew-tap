# homebrew-tap

Official Homebrew Tap repository for [@lsaint](https://github.com/lsaint).

## Installation

Add this tap to Homebrew:

```bash
brew tap lsaint/tap
```

## Available Formulas

| Formula | Description | Install Command |
| --- | --- | --- |
| **aikito** | Git-managed workspace and CLI for AI-agent durable memory and config | `brew install lsaint/tap/aikito` |


Aikito installs the Homebrew `cryptography` dependency by default. Its virtualenv
uses the declared Homebrew Python runtime's system site-packages; no separate
Rust build or vendored crypto resources are added to this tap. Formula tests
exercise both AES-GCM and native HPKE through the installed virtualenv Python.
The upstream Python package keeps encryption optional for other installers.
Release updates preserve these dependencies, verify the immutable PyPI archive,
and reset the Formula revision only when the upstream version changes.
