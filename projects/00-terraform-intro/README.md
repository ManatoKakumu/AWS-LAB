# 00-terraform-intro

## 課題内容(メンターから提示された要件)

Terraformの構文に慣れるための最小導入。以下を一通り経験する。

- `provider`ブロックの記述(AWSプロバイダー、リージョンは`ap-northeast-1`)
- 単一リソースの作成(例: S3バケット1個)
- `terraform init` → `terraform plan` → `terraform apply` → 動作確認 → `terraform destroy` の一連の流れ

この回のみ、アーキテクチャ設計判断を伴わない構文導入のため、設計レビューとAWSコンソールでの構築フェーズは省略する([docs/ROADMAP.md](../../docs/ROADMAP.md)・[.claude/skills/start/SKILL.md](../../.claude/skills/start/SKILL.md)の例外規定)。また、初めて触る構文(providerブロックの書き方や`init/plan/apply`の一連の流れ)は最小サンプルをメンターが例示してよい([docs/MENTOR_RULES.md](../../docs/MENTOR_RULES.md)の「構文と設計判断の切り分け」)。ただし作成するリソースの詳細(バケット名、設定値など)は自分で決めること。

## 前提・制約

- Terraform CLIはローカルにインストール済み(バージョン未確認 → 着手時に`terraform version`で確認しこのファイルの「環境情報」に記録する)
- AWSアカウント: 個人アカウント
- 予算: S3バケット1個程度であれば実質無視できる範囲。あなたの学習用予算(月数千円程度)の範囲内
- `apply`する場合、確認後は必ず`destroy`すること([docs/MENTOR_RULES.md](../../docs/MENTOR_RULES.md)のガードレール参照)
- `tfstate`・`*.tfvars`はコミットしないこと(`.gitignore`で除外済みのはず。念のため確認する)

## 環境情報

- Terraformバージョン: v1.15.4(2026-07-11時点で最新は1.15.8。要更新)
- AWSプロバイダーバージョン: hashicorp/aws v5.100.0
- リージョン: ap-northeast-1(既定のまま)
- AWSリソースの状態(コンソール構築分): 該当なし(このお題は設計・AWSコンソール構築フェーズを省略する例外お題)
- Terraformの状態: apply後destroy済み

## 設計

(この回は設計判断を伴わないため省略)

### 使用サービスとその理由

| 用途 | サービス | 選定理由 |
|---|---|---|
| Terraform構文導入用の単一リソース | S3バケット | 最小構成で作成できるリソースのため |

## 実装

### Terraform実装

- コード: [terraform-intro.tf](terraform-intro.tf)
- `provider`ブロック(AWS、`ap-northeast-1`)+ `resource "aws_s3_bucket" "example"` の単一リソース構成
- `plan`結果: `Plan: 1 to add, 0 to change, 0 to destroy`
- `apply`→動作確認→`destroy`まで実施済み(詳細は下記「わからなかったこと・迷ったこと」参照)

## わからなかったこと・迷ったこと

- `terraform apply`が6分以上「Still creating...」のまま止まり、原因が分からず戸惑った。最初はネットワーク環境(VPN・プロキシ等)を疑ったが、CloudTrailとaws-cliでの直接検証で否定し、最終的にIAMポリシーの権限不足(バケット作成後にTerraformが行う多数のGet系API呼び出しが許可されていなかったこと)が原因と判明した
- 上記の原因究明の過程で、「バケット作成後にaclやタグを自動設定してくれる」という理解をしていたが、正しくは「(何も設定していない)現状を読み取ってstateに反映しているだけ」だった。設定(Write)と読み取り(Read)を混同していた
- 最小権限のIAMポリシーを自力で組んだが、最終的に必要なアクションを個別に洗い出しきれず`s3:*`(対象バケットに限定)まで広げて決着した。CloudTrailの実行履歴から自動でポリシーを生成する仕組み(IAM Access Analyzer)があることを教わり、今後はそちらの活用も検討したい
- tfstateには機密情報が平文で入り得るという原則を教わったが、今回はS3バケットのみだったため実際のファイルを見てもピンとこなかった。次にRDS等パスワードを扱うお題で実感を確認したい
