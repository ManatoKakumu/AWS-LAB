# LEARNING_LOG

セッションごとの学習履歴の索引。詳細は `docs/logs/` 配下の各ファイルを参照。**索引・各ログファイルともに追記のみ。過去の記載は書き換えない。** 新しいセッションを一覧の先頭に追加する(新しい順)。

このログは時系列の作業記録。特定のお題(`projects/NN-お題名/`)の理解度に関する振り返りはここではなく、該当お題の`RETROSPECTIVE.md`に書く。

新しいセッションを記録するときの手順:

1. `docs/logs/YYYY-MM-DD-NN-スラッグ.md` を作成する(NNはその日の何セッション目か)。**分割の単位は「話題」ではなく「1回の継続した作業のまとまり」。** 1回の会話の中で複数の話題を扱っても、間が空かずに続いているなら1ファイルにまとめる。日をまたいだ、または大きく間が空いた場合に新しいファイルを作る。内容は以下を目安にする(`templates/retrospective-template.md` も参照)

```
# YYYY-MM-DD: セッションタイトル

- 種別: 設計課題 / 実装課題(Terraform等) / トラブルシューティング / 会話・評価 / 環境構築
- 内容: 何をやったか
- 発見: 良かった点・改善が必要な点
- CURRENT_LEVELへの反映: あれば記載
- 次回への持ち越し: あれば記載
```

2. 下の一覧の先頭に1行追加する

## 一覧

| 日付 | セッション | ログ |
|---|---|---|
| 2026-07-11 | 初回オンボーディング(評価・環境構築・Skill実装・レビュー) | [詳細](logs/2026-07-11-01-onboarding.md) |
| 2026-07-11 | 00-terraform-intro(出題〜構築〜レビュー〜振り返り) | [詳細](logs/2026-07-11-02-terraform-intro-shudai.md) |
| 2026-07-11 | 01-vpc-network(出題) | [詳細](logs/2026-07-11-03-vpc-network-shudai.md) |
| 2026-07-12 | 01-vpc-network(設計レビュー〜AWS構築〜理解度テスト) | [詳細](logs/2026-07-12-01-vpc-network-construction.md) |
| 2026-07-13 | 01-vpc-network(Terraform実装〜レビュー〜フェーズD完了) | [詳細](logs/2026-07-13-01-vpc-network-terraform.md) |
| 2026-07-13 | 02-nacl-experiment(出題) | [詳細](logs/2026-07-13-02-nacl-experiment-shudai.md) |
| 2026-07-13 | 02-nacl-experiment(設計レビュー) | [詳細](logs/2026-07-13-03-nacl-experiment-design-review.md) |
| 2026-07-13 | 02-nacl-experiment(AWSコンソール構築〜実機検証) | [詳細](logs/2026-07-13-04-nacl-experiment-construction.md) |
| 2026-07-13 | 02-nacl-experiment(Terraform実装、public部分まで) | [詳細](logs/2026-07-13-05-nacl-experiment-terraform.md) |
| 2026-07-13 | 02-nacl-experiment(Terraform実装NACL部分〜Terraformレビュー完了) | [詳細](logs/2026-07-13-06-nacl-experiment-terraform-nacl.md) |
| 2026-07-13 | 02-nacl-experiment(振り返り、フェーズE完了) | [詳細](logs/2026-07-13-07-nacl-experiment-retrospective.md) |
| 2026-07-14 | 03-rds-scaling(出題) | [詳細](logs/2026-07-14-01-rds-scaling-shudai.md) |
| 2026-07-14 | 03-rds-scaling(AWSコンソール構築〜実機確認〜フェーズC完了) | [詳細](logs/2026-07-14-02-rds-scaling-construction.md) |
| 2026-07-16 | 03-rds-scaling(Terraform実装〜レビュー〜apply確認〜振り返り、フェーズE完了) | [詳細](logs/2026-07-16-01-rds-scaling-terraform.md) |
| 2026-07-16 | 04-ecs-iam-roles(出題) | [詳細](logs/2026-07-16-02-ecs-iam-roles-shudai.md) |
| 2026-07-17 | 04-ecs-iam-roles(設計レビュー、フェーズB完了) | [詳細](logs/2026-07-17-01-ecs-iam-roles-design-review.md) |
| 2026-07-19 | 04-ecs-iam-roles(AWSコンソール構築〜実機確認〜Terraform実装、フェーズD完了) | [詳細](logs/2026-07-19-01-ecs-iam-roles-construction-terraform.md) |
| 2026-07-19 | 04-ecs-iam-roles(振り返り、フェーズE完了) | [詳細](logs/2026-07-19-02-ecs-iam-roles-retrospective.md) |
| 2026-07-19 | 05-ecs-autoscaling(出題) | [詳細](logs/2026-07-19-03-ecs-autoscaling-shudai.md) |
| 2026-07-20 | 05-ecs-autoscaling(設計レビュー、フェーズB完了) | [詳細](logs/2026-07-20-01-ecs-autoscaling-design-review.md) |
| 2026-07-22 | 05-ecs-autoscaling(AWSコンソール構築〜実機負荷試験〜フェーズC完了) | [詳細](logs/2026-07-22-01-ecs-autoscaling-construction.md) |
| 2026-07-23 | 05-ecs-autoscaling(Terraform実装〜レビュー〜apply確認〜振り返り、フェーズE完了) | [詳細](logs/2026-07-23-01-ecs-autoscaling-terraform.md) |
| 2026-07-23 | 06-multi-az-failure-simulation(出題) | [詳細](logs/2026-07-23-02-multi-az-failure-simulation-shudai.md) |
| 2026-07-25 | 06-multi-az-failure-simulation(設計レビュー、フェーズB完了) | [詳細](logs/2026-07-25-01-multi-az-failure-simulation-design-review.md) |
