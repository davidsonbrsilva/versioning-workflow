# Versioning Workflow

![GitHub Release](https://img.shields.io/github/v/release/davidsonbrsilva/versioning-workflow)
![License](https://img.shields.io/github/license/davidsonbrsilva/versioning-workflow.svg)
![Code Size](https://img.shields.io/github/languages/code-size/davidsonbrsilva/versioning-workflow)
![Project Status](https://img.shields.io/badge/status-active-green.svg)

[See in English](README.md)

_Versioning Workflow_ é uma ferramenta que permite a geração automática de versões do seu código. Ele se baseia em [_conventional commits_](https://www.conventionalcommits.org/pt-br/v1.0.0/) e padrões de branches para determinar as versões. As versões geradas seguem o [versionamento semântico](https://semver.org/lang/pt-BR/).

## Sumário

- [Versioning Workflow](#versioning-workflow)
  - [Sumário](#sumário)
  - [Instalação](#instalação)
  - [Uso](#uso)
    - [Workflow de criação de release](#workflow-de-criação-de-release)
      - [Usando um nome diferente para a branch principal](#usando-um-nome-diferente-para-a-branch-principal)
      - [O job `upsert_major_version`](#o-job-upsert_major_version)
    - [Workflow de criação de pré-release](#workflow-de-criação-de-pré-release)
      - [Customizando nomes de branches para gerar as versões](#customizando-nomes-de-branches-para-gerar-as-versões)
      - [Usando mais de um nome de branch para gerar as versões](#usando-mais-de-um-nome-de-branch-para-gerar-as-versões)
  - [Contato](#contato)
  - [License](#license)

## Instalação

Copie os arquivos `create-pre-release.yml` e `create-release.yml` do diretório `.github/workflows` para um diretório de mesmo nome na raiz do seu projeto. Isso é tudo!

## Uso

Há dois workflows disponíveis para você usar: o de **criação de release** e o de **criação de pré-release**. Você pode optar por usar apenas o workflow de criação de release ou combiná-lo com o workflow de criação de pré-release.

### Workflow de criação de release

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

Essa é a forma mais básica de uso desse workflow. Ele será disparado sempre que mudanças forem percebidas diretamente na _branch_ principal, por meio de _pull requests_ ou _commits_ diretos. As novas versões são geradas a partir da mensagem dos _commits_ na seguinte ordem de precedência:

1. _Commits_ que iniciam com `BREAKING CHANGE:` ou `<algum_prefixo>!:` (note o uso de `!`) geram novas versões _major_ do código (por exemplo, de `0.1.0` para `1.0.0`).
2. _Commits_ que iniciam com `FIRST RELEASE:` em versões não públicas do código (versão `0`) geram a versão inicial de lançamento do software (versão `1.0.0`).
3. _Commits_ que iniciam com `fix:` geram novas versões _patch_ do código (por exemplo, de `0.1.0` para `0.1.1`).
4. _Commits_ em qualquer outro padrão geram versões _minor_ do cóldigo (por exemplo, de `0.1.0` para `0.2.0`).

#### Usando um nome diferente para a branch principal

Por padrão, `main` é considerada como a branch principal, mas, você pode modificar isso por meio do parâmetro `main_branch`:

```yml
name: Release

on:
  push:
    branches: ["master"]

jobs:
  create_release:
    name: Create release
    uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-release-template.yml@v1
    permissions:
      contents: write
    with:
      main_branch: "master"
```

#### O job `upsert_major_version`

No template do arquivo `create-release.yml`, você notará que há um job chamado `upsert_major_version`:

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

Esse job é opcional e pode ser removido se você quiser. A cada versão de lançamento, ele gera uma tag `v[major_version]` (por exemplo, `v1`) e a mantém atualizada, sempre referenciando a última versão, até que uma nova versão _major_ seja lançada.

### Workflow de criação de pré-release

```yml
name: Pre-release

on:
  pull_request:
    branches: ["main"]
    types: ["opened", "synchronize", "reopened"]

jobs:
  create_release_candidate:
    name: Create release candidate
    uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v1
    permissions:
      contents: write
```

Essa é a forma mais básica de uso do workflow de pré-release. Ele será disparado em eventos de _pull request_: na abertura, durante novos commits e na sua reabertura. Cada nova mudança em uma _pull request_ gerará uma versão _release candidate_ (`-rc-<number>`).

As versões de _release candidate_ são incrementadas a cada nova alteração (por exemplo, de `0.1.0-rc-1` para `0.1.0-rc-2`). Novas versões de _release candidate_ (`-rc-1`) são geradas levando em consideração o nome das _branches_ de origem e o padrão dos commits, na seguinte ordem de precedência:

1. _Commits_ que começam com `BREAKING CHANGE:` ou `<algum_prefixo>!:` gerarão versões _major_.
2. _Commits_ que iniciam com `FIRST RELEASE:` em versões não públicas do código (versão `0`) gerarão a versão inicial de lançamento do software (versão `1.0.0`).
3. _Branches_ que correspondem ao parâmetro `feature_branches` gerarão versões _minor_ do código.
4. _Branches_ que correspondem ao parâmetro `release_branches` também gerarão versões _minor_ do código.
5. _Branches_ que correspondem ao parâmetro `hotfix_branches` gerarão versões _patch_ do código.

> Se a branch não corresponder a nenhum dos padrões anteriores, a versão automática de _pré-release_ não será gerada.

#### Customizando nomes de branches para gerar as versões

Assim como no workflow de criação de release, você também pode informar um nome diferente para a branch principal por meio de `main_branch`. O mesmo vale para branches de feature, release e hotfix:

1. Para gerar versões _minor_, o workflow procurará por branches que correspondam ao padrão dos parâmetros `feature_branches` e `release_branches`. Se algum dos parâmetros não for informado, o valor `feature` será considerado como nome padrão para `feature_branches` e `release` para `release_branches`.
2. Para gerar versões _pacth_, o workflow procurará por branches que correspondam ao padrão do parâmetro `hotfix_branches`. Se o parâmetro não for informado, o valor `hotfix` será considerado como nome padrão.

```yml
name: Pre-release

on:
  pull_request:
    branches: ["main"]
    types: ["opened", "synchronize", "reopened"]

jobs:
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

#### Usando mais de um nome de branch para gerar as versões

Por fim, você também pode usar mais de um nome de branch para os parâmetros `feature_branches`, `release_branches` e `hotfix_branches`, caso queira. Por exemplo:

```yml
jobs:
  create_release_candidate:
    name: Create release candidate
    uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v1
    with:
      feature_branches: "feat feature" # aceitará correspondência da branch de origem tanto para 'feat' quanto para 'feature'
      release_branches: "rel release" # aceitará correspondência da branch de origem tanto para 'rel' quanto para 'release'
      hotfix_branches: "fix hotfix" # aceitará correspondência da branch de origem tanto para 'fix' quanto para 'hotfix'
```

## Contato

Para dúvidas ou sugestões, envie e-mail para <davidsonbruno@outlook.com>.

## License

MIT Copyright (c) 2024 Davidson Bruno
