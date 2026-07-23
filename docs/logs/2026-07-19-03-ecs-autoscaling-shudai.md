# 2026-07-19: 05-ecs-autoscaling(出題)

- 種別: 設計課題
- 内容: `04-ecs-iam-roles`の振り返り完了を受けて次のお題を選定。Phase 1(弱点補強+IaC基礎)が全項目完了したため、ROADMAP.mdのPhase 2(可用性・スケーラビリティの実践)最初の項目である「ECS Auto Scaling」を出題した。Target Tracking Scaling PolicyとStep Scaling Policyという「似た機能の目的差分」を突く題材であり、CURRENT_LEVEL.mdで指摘されているこのユーザーの弱点パターンに合致する。あわせて、Phase 2の2番目の項目であるALBヘルスチェック設計も、スケールイン/アウト時の挙動として同じお題に絡めた。`01-vpc-network`で構築済みのVPC/ALB/ECSクラスターを流用し、ネットワーク再設計の負荷をかけずスケーリング設計に集中させる構成にした
- 発見: (出題時点のため次回のレビューで記録)
- CURRENT_LEVELへの反映: なし(出題のみ)
- 次回への持ち越し: 設計提出後、フェーズB(設計レビュー)を実施する
