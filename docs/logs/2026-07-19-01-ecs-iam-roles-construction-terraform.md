# 2026-07-19: 04-ecs-iam-roles(AWSコンソール構築〜実機確認〜Terraform実装、フェーズD完了)

- 種別: 実装課題(AWSコンソール構築 + Terraform)
- 内容: `04-ecs-iam-roles`のAWSコンソール構築(IAMロール・SG・ECR・S3・CloudWatch Logs・ECS)、意図的な権限剥奪による実機エラー確認、同構成のTerraformコード化を実施。詳細は[REVIEW.md](../../projects/04-ecs-iam-roles/REVIEW.md)。
- 発見:
  - お題の核心(Task Roleの`s3:PutObject`をDenyにし、CloudWatch Logsのエラーメッセージ(ARN・「explicit deny」の文言)だけからTask Roleが原因と特定)を、ヒントなしで達成した。`01-vpc-network`から続いていたExecution Role/Task Roleの混同という弱点が、実機確認によって解消されたことを示す事例
  - Docker Desktopが起動不能(WSLインストール不備)となった際、AWS CloudShellへの切り替えという実務的な代替手段を自ら選択できた
  - Terraform実装では、設計レビューで指摘した「IAMポリシーのResourceをリソース参照にする」という改善点を、再指摘なしで全箇所に適用できた
  - `variable`/`locals`の使い分け(`02-nacl-experiment`から継続フォロー中)は、今回のお題規模では実践機会がなかった
- CURRENT_LEVELへの反映: フェーズE(振り返り)完了時にまとめて反映する
- 次回への持ち越し: 振り返り(フェーズE)を実施し、CURRENT_LEVEL/ROADMAPを更新する
