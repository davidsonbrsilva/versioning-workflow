# Versioning Workflow

![GitHub Release](https://img.shields.io/github/v/release/davidsonbrsilva/versioning-workflow)
![License](https://img.shields.io/github/license/davidsonbrsilva/versioning-workflow.svg)
![Code Size](https://img.shields.io/github/languages/code-size/davidsonbrsilva/versioning-workflow)
![Project Status](https://img.shields.io/badge/status-active-green.svg)

[See in English](README.md)

_Versioning Workflow_ é uma ferramenta que permite a geração automática de versões do seu código. Ele se baseia no conceito de [_trunk-based development_](https://trunkbaseddevelopment.com/) e utiliza [_conventional commits_](https://www.conventionalcommits.org/en/v1.0.0/) para determinar as versões. As versões geradas seguem o padrão de [versionamento semântico](https://www.conventionalcommits.org/en/v1.0.0/).

## Sumário

- [Versioning Workflow](#versioning-workflow)
  - [Sumário](#sumário)
  - [Instalação](#instalação)
  - [Uso](#uso)
    - [Usando somente o workflow de criação de release](#usando-somente-o-workflow-de-criação-de-release)
    - [Usando o workflow de criação de release em conjunto com o de pré-release](#usando-o-workflow-de-criação-de-release-em-conjunto-com-o-de-pré-release)
    - [Habilitando o workflow para lidar com mais de um nome de branch](#habilitando-o-workflow-para-lidar-com-mais-de-um-nome-de-branch)
  - [Contato](#contato)
  - [License](#license)

## Instalação

Copie os arquivos `create-pre-release.yml` e `create-release.yml` do diretório `.github/workflows` para um diretório de mesmo nome na raiz do seu projeto. Isso é tudo!

> O job `upsert_major_version` do arquivo `create-release.yml` é opcional e pode ser removido, caso queira. A cada versão de lançamento, ele gera uma tag `v[major_version]` (por exemplo, `v1`) e a mantém atualizada, sempre referenciando a última versão, até que uma nova versão _major_ seja lançada.

## Uso

Há dois workflows disponíveis para você usar: o de **criação de release** e o de **criação de pré-release**. Você pode optar por usar apenas o workflow de criação de release ou combiná-lo com o workflow de criação de pré-release.

### Usando somente o workflow de criação de release

O workflow de criação de release é disparado sempre que mudanças forem percebidas diretamente na _branch_ principal, por meio de _pull requests_ ou _commits_ diretos. As novas versões são geradas a partir da mensagem dos _commits_.

_Commits_ que iniciam com `fix:` geram novas versões _patch_ do código (por exemplo, de `0.1.0` para `0.1.1`). _Commits_ que iniciam com `BREAKING CHANGE:` ou `<algum_prefixo>!:` (note o uso de `!`) geram novas versões _major_ do código (por exemplo, de `0.1.0` para `1.0.0`). _Commits_ que iniciam com `FIRST RELEASE:` em versões não públicas do código (versão `0`) geram a versão inicial de lançamento do software (versão `1.0.0`) _Commits_ em qualquer outro padrão geram versões _minor_ do cóldigo (por exemplo, de `0.1.0` para `0.2.0`).

### Usando o workflow de criação de release em conjunto com o de pré-release

O workflow de criação de pré-release é disparado em eventos de _pull request_: na abertura, durante novos commits e na sua reabertura. Cada nova mudança em uma _pull request_ gerará uma versão _release candidate_ (`-rc-X`). As versões de _release candidate_ são incrementadas a cada nova alteração (por exemplo, de `0.1.0-rc-1` para `0.1.0-rc-2`). Novas versões de _release candidate_ (`-rc-1`) são geradas levando em consideração o nome das _branches_ de origem. Por exemplo, _branches_ que correspondem ao parâmetro `feature_branches` gerarão versões _minor_ do código. _Branches_ que correspondem ao parâmetro `hotfix_branches` gerarão versões _patch_ do código. Se houver algum _commit_ que comece com `BREAKING CHANGE:` ou `<algum_prefixo>!:`, versões _major_ serão geradas. Se houver _commits_ que iniciam com `FIRST RELEASE:` em versões não públicas do código (versão `0`), a versão inicial de lançamento do software será gerada (versão `1.0.0`).

> Versões automáticas de _pre-release_ não serão geradas se a branch de origem não seguir os padrões mencionados.

### Habilitando o workflow para lidar com mais de um nome de branch

Você pode usar mais de um nome de branch de de feature e hotfix para corresponder às suas branches. Para isso, você precisa separá-los por espaços em branco. Por exemplo:

```
jobs:
  create_release_candidate:
    name: Create release candidate
    uses: davidsonbrsilva/versioning-workflow/.github/workflows/create-pre-release-template.yml@v0
    with:
      main_branch: "main"
      feature_branches: "feat feature" # a branch de origem irá corresponder a ambos os nomes 'feat' e 'feature'
      hotfix_branches: "fix hotfix" # a branch de origem irá corresponder a ambos os nomes 'fix' e 'hotfix'
```

O job `create_release` aceita o parâmetro opcional `main_branch`. Por outro lado, o job `create_release_candidate` aceita os parâmetros opcionals `main_branch`, `feature_branch` e `hotfix_branch`. Se nenhum nome de branch é fornecido, os valores padrões são usados: `main` para nome de branch principal, `feature` para nome de branches de feature e `hotfix` para nome de branches de hotfix.

## Contato

Para dúvidas ou sugestões, envie e-mail para <davidsonbruno@outlook.com>.

## License

MIT Copyright (c) 2024 Davidson Bruno
