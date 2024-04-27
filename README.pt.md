# Versioning Workflow

_Versioning Workflow_ é uma ferramenta que permite a geração automática de versões do seu código. Ele se baseia no conceito de [_trunk-based development_](https://trunkbaseddevelopment.com/) e utiliza [_conventional commits_](https://www.conventionalcommits.org/en/v1.0.0/) para determinar as versões. As versões geradas seguem o padrão de [versionamento semântico](https://www.conventionalcommits.org/en/v1.0.0/).

[See in English](README.md)

## Sumário

- [Versioning Workflow](#versioning-workflow)
  - [Sumário](#sumário)
  - [Instalação](#instalação)
  - [Uso](#uso)
    - [Usar somente o workflow de criação de release](#usar-somente-o-workflow-de-criação-de-release)
    - [Usar o workflow de criação de release em combinação com o de pré-release](#usar-o-workflow-de-criação-de-release-em-combinação-com-o-de-pré-release)
  - [Contato](#contato)
  - [License](#license)

## Instalação

Copie os arquivos `create-pre-release.yml` e `create-release.yml` do diretório `.github/workflows` para um diretório de mesmo nome na raiz do seu projeto. Isso é tudo!

> O job `upsert_major_version` do arquivo `create-release.yml` é opcional e pode ser removido, caso queira. A cada versão de lançamento, ele gera uma tag `v[major_version]` (por exemplo, `v1`) e a mantém atualizada, sempre referenciando a última versão, até que uma nova versão _major_ seja lançada.

## Uso

Há dois workflows disponíveis para você usar: o de **criação de release** e o de **criação de pré-release**. Você pode optar por usar apenas o workflow de criação de release ou combiná-lo com o workflow de criação de pré-release.

### Usar somente o workflow de criação de release

O workflow de criação de release é disparado sempre que mudanças forem percebidas diretamente na _branch_ principal, por meio de _pull requests_ ou _commits_ diretos. As novas versões são geradas a partir da mensagem dos _commits_.

_Commits_ que iniciam com `fix:` geram novas versões _patch_ do código (por exemplo, de `0.1.0` para `0.1.1`). _Commits_ que iniciam com `BREAKING CHANGE:` ou `<algum_prefixo>!:` (note o uso de `!`) geram novas versões _major_ do código (por exemplo, de `0.1.0` para `1.0.0`). _Commits_ que iniciam com `FIRST RELEASE:` em versões não públicas do código (versão `0`) geram a versão inicial de lançamento do software (versão `1.0.0`) _Commits_ em qualquer outro padrão geram versões _minor_ do cóldigo (por exemplo, de `0.1.0` para `0.2.0`).

### Usar o workflow de criação de release em combinação com o de pré-release

O workflow de criação de pré-release é disparado em eventos de _pull request_: na abertura, durante novos commits e na sua reabertura. Cada nova mudança em uma _pull request_ gerará uma versão _release candidate_ (`-rc-X`). As versões de _release candidate_ são incrementadas a cada nova alteração (por exemplo, de `0.1.0-rc-1` para `0.1.0-rc-2`). Novas versões de _release candidate_ (`-rc-1`) são geradas levando em consideração o nome da _branch_ de origem. Por exemplo, _branches_ que iniciam com `feature/` gerarão versões _minor_ do código. _Branches_ que iniciam com `hotfix/` gerarão versões _patch_ do código. Se houver algum _commit_ que comece com `BREAKING CHANGE:` ou `<algum_prefixo>!:`, versões _major_ serão geradas. Se houver _commits_ que iniciam com `FIRST RELEASE:` em versões não públicas do código (versão `0`), a versão inicial de lançamento do software será gerada (versão `1.0.0`).

> Versões automáticas de _pre-release_ não serão geradas se a branch de origem não respeitar os padrões mencionados anteriormente. Lembre-se: _Versioning Workflow_ foi criado sobre a diretriz do _trunk-based-development_.

## Contato

Para dúvidas ou sugestões, envie e-mail para <davidsonbruno@outlook.com>.

## License

MIT Copyright (c) 2024 Davidson Bruno
