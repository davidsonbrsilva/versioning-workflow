# Versioning Workflow

_Versioning Workflow_ is a tool that allows for automatic generation of versions for your code. It is based on the concept of [_trunk-based development_](https://trunkbaseddevelopment.com/) and uses [_conventional commits_](https://www.conventionalcommits.org/en/v1.0.0/) to determine the versions. The generated versions follow the pattern of [semantic versioning](https://www.conventionalcommits.org/en/v1.0.0/).

[Ver em Português](README.pt.md)

## Table of Contents

- [Versioning Workflow](#versioning-workflow)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Using the release workflow only](#using-the-release-workflow-only)
    - [Using the release workflow in combination with the pre-release workflow](#using-the-release-workflow-in-combination-with-the-pre-release-workflow)
  - [Contact](#contact)
  - [License](#license)

## Installation

Copy the `create-pre-release.yml` and `create-release.yml` files from the `.github/workflows` directory to a directory with the same name at the root of your project. That's it!

> The `upsert_major_version` job in the `create-release.yml` file is optional and can be removed if desired. With each release version, it generates a `v[major_version]` tag (e.g., `v1`) and keeps it updated, always referencing the latest version, until a new major version is released.

## Usage

There are two workflows available for you to use: the **release workflow** and the **pre-release workflow**. You can choose to use only the release workflow or combine it with the pre-release workflow.

### Using the release workflow only

The release workflow is triggered whenever changes are detected directly on the main branch, through pull requests or direct commits. The new versions are generated based on the commit messages.

Commits starting with `fix:` generate new patch versions of the code (e.g., from `0.1.0` to `0.1.1`). Commits starting with `BREAKING CHANGE:` or `<some_prefix>!:` (note the use of `!`) generate new major versions of the code (e.g., from `0.1.0` to `1.0.0`). Commits starting with `FIRST RELEASE:` in non-public versions of the code (version `0`) generate the initial release version of the software (version `1.0.0`). Commits in any other pattern generate minor versions of the code (e.g., from `0.1.0` to `0.2.$PLACEHOLDER$0`).

### Using the release workflow in combination with the pre-release workflow

The pre-release workflow is triggered on pull request events: on opening, during new commits, and on reopening. Each new change in a pull request will generate a release candidate version (`-rc-X`). The release candidate versions are incremented with each new change (e.g., from `0.1.0-rc-1` to `0.1.0-rc-2`). New release candidate versions (`-rc-1`) are generated taking into account the name of the source branch. For example, branches starting with `feature/` will generate minor versions of the code. Branches starting with `hotfix/` will generate patch versions of the code. If there is a commit that starts with `BREAKING CHANGE:` or `<some_prefix>!:`, major versions will be generated. If there are commits starting with `FIRST RELEASE:` in non-public versions of the code (version `0`), the initial release version of the software will be generated (version `1.0.0`).

> Automatic pre-release versions will not be generated if the source branch does not follow the mentioned patterns. Remember: Versioning Workflow was created based on the trunk-based development guideline.

## Contact

For questions or suggestions, please email <davidsonbruno@outlook.com>.

## License

MIT Copyright (c) 2024 Davidson Bruno