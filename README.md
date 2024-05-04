# Versioning Workflow <!-- omit from toc -->

![GitHub Release](https://img.shields.io/github/v/release/davidsonbrsilva/versioning-workflow)
![License](https://img.shields.io/github/license/davidsonbrsilva/versioning-workflow.svg)
![Code Size](https://img.shields.io/github/languages/code-size/davidsonbrsilva/versioning-workflow)
![Project Status](https://img.shields.io/badge/status-active-green.svg)

[Ver em Português](README.pt.md)

_Versioning Workflow_ is a tool that allows automatic versioning of your code. It is based on [_conventional commits_](https://www.conventionalcommits.org/en/v1.0.0/) and branch patterns to determine versions. The generated versions follow [semantic versioning](https://semver.org/).

## Summary <!-- omit from toc -->

- [1. Installation](#1-installation)
- [2. Usage](#2-usage)
  - [2.1. Release creation workflow](#21-release-creation-workflow)
    - [2.1.1. Using a different name for the main branch](#211-using-a-different-name-for-the-main-branch)
    - [2.1.2. The `upsert_major_version` job](#212-the-upsert_major_version-job)
  - [2.2. Pre-release creation workflow](#22-pre-release-creation-workflow)
    - [2.2.1. Customizing branch names to generate versions](#221-customizing-branch-names-to-generate-versions)
    - [2.2.2. Using more than one branch name to generate versions](#222-using-more-than-one-branch-name-to-generate-versions)
  - [2.3. Using the `v` prefix for versions](#23-using-the-v-prefix-for-versions)
  - [2.4. Customizing the release name](#24-customizing-the-release-name)
  - [2.5. Adding a prefix to the release name](#25-adding-a-prefix-to-the-release-name)
- [3. Contact](#3-contact)
- [4. License](#4-license)

## 1. Installation

Copy the `create-pre-release.yml` and `create-release.yml` files from the `.github/workflows` directory to a directory with the same name at the root of your project. That's it!

## 2. Usage

There are two workflows available for you to use: the **release creation** and the **pre-release creation**. You can choose to use only the release creation workflow or combine it with the pre-release creation workflow.

### 2.1. Release creation workflow

```yml
name: Release

on:
  push:
    branches: ["main"]

jobs:
  create_release:
    name: Create release
    uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-release-template.yml@v1
    permissions:
      contents: write
```

This is the most basic way to use this workflow. It will be triggered whenever changes are detected directly on the main branch, through pull requests or direct commits. New versions are generated from the commit messages in the following order of precedence:

1. Commits that start with `BREAKING CHANGE:` or `<some_prefix>!:` (note the use of `!`) generate new major versions of the code (for example, from `0.1.0` to `1.0.0`).
2. Commits that start with `FIRST RELEASE:` in non-public versions of the code (version `0`) generate the initial release version of the software (version `1.0.0`).
3. Commits that start with `fix:` generate new patch versions of the code (for example, from `0.1.0` to `0.1.1`).
4. Commits in any other pattern generate minor versions of the code (for example, from `0.1.0` to `0.2.0`).

#### 2.1.1. Using a different name for the main branch

By default, `main` is considered the main branch, but you can modify this through the `main_branch` parameter:

```yml
create_release:
  name: Create release
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-release-template.yml@v1
  permissions:
    contents: write
  with:
    main_branch: "master"
```

#### 2.1.2. The `upsert_major_version` job

In the `create-release.yml` file template, you will notice that there is a job called `upsert_major_version`:

```yml
upsert_major_version: # Optional
  name: Upsert major version
  needs: create_release
  permissions:
    contents: write
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/upsert-major-version-template.yml@v1
  with:
    version: ${{ needs.create_release.outputs.version }}
```

This job is optional and can be removed if you want. With each release version, it generates a `v[major_version]` tag (for example, `v1`) and keeps it updated, always referencing the latest version, until a new major version is released.

### 2.2. Pre-release creation workflow

```yml
create_release_candidate:
  name: Create release candidate
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v1
  permissions:
    contents: write
```

This is the most basic way to use the pre-release workflow. It will be triggered on pull request events: on opening, during new commits, and on reopening. Each new change in a pull request will generate a release candidate version (`-rc-<number>`).

Release candidate versions are incremented with each new change (for example, from `0.1.0-rc-1` to `0.1.0-rc-2`). New release candidate versions (`-rc-1`) are generated taking into account the name of the source branches and the commit pattern, in the following order of precedence:

1. Commits that start with `BREAKING CHANGE:` or `<some_prefix>!:` will generate major versions.
2. Commits that start with `FIRST RELEASE:` in non-public versions of the code (version `0`) will generate the initial release version of the software (version `1.0.0`).
3. Branches that match the `feature_branches` parameter will generate minor versions of the code.
4. Branches that match the `release_branches` parameter will also generate minor versions of the code.
5. Branches that match the `hotfix_branches` parameter will generate patch versions of the code.

> If the branch does not match any of the previous patterns, the automatic pre-release version will not be generated.

#### 2.2.1. Customizing branch names to generate versions

Just like in the release creation workflow, you can also inform a different name for the main branch through `main_branch`. The same goes for feature, release, and hotfix branches:

1. To generate minor versions, the workflow will look for branches that match the pattern of the `feature_branches` and `release_branches` parameters. If any of the parameters is not informed, the value `feature` will be considered as the default name for `feature_branches` and `release` for `release_branches`.
2. To generate patch versions, the workflow will look for branches that match the pattern of the `hotfix_branches` parameter. If the parameter is not informed, the value `hotfix` will be considered as the default name.

```yml
create_release_candidate:
  name: Create release candidate
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v1
  permissions:
    contents: write
  with:
    main_branch: "main"
    feature_branches: "feature"
    release_branches: "release"
    hotfix_branches: "hotfix"
```

#### 2.2.2. Using more than one branch name to generate versions

Finally, you can also use more than one branch name for the `feature_branches`, `release_branches`, and `hotfix_branches` parameters, if you want. For example:

```yml
create_release_candidate:
  name: Create release candidate
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v1
  with:
    feature_branches: "feat feature" # will accept source branch match for both 'feat' and 'feature'
    release_branches: "rel release" # will accept source branch match for both 'rel' and 'release'
    hotfix_branches: "fix hotfix" # will accept source branch match for both 'fix' and 'hotfix'
```

### 2.3. Using the `v` prefix for versions

Some tools, like Github, suggest using versions that start with `v`, such as `v1.0.0`. You can enable this behavior using the `use_v_prefix` flag:

**Release creation workflow**
```yaml
create_release:
  name: Create release
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-release-template.yml@v1
  permissions:
    contents: write
  with:
    use_v_prefix: true
```

**Pre-release creation workflow**
```yaml
create_release_candidate:
  name: Create release candidate
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v1
  permissions:
    contents: write
  with:
    use_v_prefix: true
```

### 2.4. Customizing the release name

By default, generated release names receive the name used to generate the version. You can override this behavior using the `release_name` property:

**Release creation workflow**
```yaml
create_release:
  name: Create release
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-release-template.yml@v1
  permissions:
    contents: write
  with:
    release_name: "My Amazing Release"
```

**Pre-release creation workflow**
```yaml
create_release_candidate:
  name: Create release candidate
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v1
  permissions:
    contents: write
  with:
    release_name: "My Amazing Release"
```

With this property, all created releases will receive the name "My Amazing Release" instead of the version name.

### 2.5. Adding a prefix to the release name

You can also define a prefix to be adopted in the release name. This is useful in cases where you still want to keep the generated version in the release name but want to add a prefix of your choice. This can be achieved through the `release_name_prefix` property:

**Release creation workflow**
```yaml
create_release:
  name: Create release
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-release-template.yml@v1
  permissions:
    contents: write
  with:
    release_name_prefix: "Github"
```

**Pre-release creation workflow**
```yaml
create_release_candidate:
  name: Create release candidate
  uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v1
  permissions:
    contents: write
  with:
    release_name_prefix: "Github"
```

In this example, the created releases will follow the pattern "Github 1.0.0".

## 3. Contact

For questions or suggestions, send an email to <davidsonbruno@outlook.com>.

## 4. License

MIT Copyright (c) 2024 Davidson Bruno
