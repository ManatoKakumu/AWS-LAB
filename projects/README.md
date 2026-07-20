# projects/

お題ごとにディレクトリを作成する。命名規則: `NN-お題のスラッグ`(例: `01-vpc-network`, `02-nacl-experiment`)。連番はお題を出した順。[docs/ROADMAP.md](../docs/ROADMAP.md)のお題名と一致させること。

## 各お題ディレクトリの基本構成

```
projects/NN-お題名/
├── README.md      # templates/readme-template.md をコピーして使う
├── REVIEW.md       # メンターのレビュー結果。templates/design-review-template.md をコピーして使う
├── RETROSPECTIVE.md # 振り返り。templates/retrospective-template.md をコピーして使う
└── (Terraformコードなど成果物一式)
```

`REVIEW.md`は1回で完結させず、設計レビューとTerraformレビューなど複数回のレビュー結果を追記していくファイルとして使う。

## 状態列の値(`.claude/skills/start/SKILL.md`が読む正本)

`/start` Skillは、下の一覧表の最新行の「状態」列を見て現在のフェーズを判定する。値は以下のいずれかを使うこと。

- 設計中
- 設計レビュー待ち
- 設計差し戻し中
- AWS構築中
- Terraform実装中
- Terraformレビュー待ち
- 振り返り待ち
- 完了

## お題一覧

| # | お題 | 種別 | 状態 |
|---|---|---|---|
| 00 | [00-terraform-intro](00-terraform-intro/README.md) | Terraform構文導入 | 完了 |
| 01 | [01-vpc-network](01-vpc-network/README.md) | VPCネットワーク設計 | 完了 |
| 02 | [02-nacl-experiment](02-nacl-experiment/README.md) | NACLステートレス挙動の実験 | 完了 |
| 03 | [03-rds-scaling](03-rds-scaling/README.md) | RDS Multi-AZ / リードレプリカ設計 | 完了 |
| 04 | [04-ecs-iam-roles](04-ecs-iam-roles/README.md) | ECS Task Role / Task Execution Role分離 | 完了 |
| 05 | [05-ecs-autoscaling](05-ecs-autoscaling/README.md) | ECS Service Auto Scaling / ALBヘルスチェック設計 | AWS構築中 |

新しいお題を開始したら、この表に行を追加すること。
