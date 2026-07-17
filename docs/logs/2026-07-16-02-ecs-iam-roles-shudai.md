# 2026-07-16: 04-ecs-iam-roles(出題)

- 種別: 設計課題
- 内容: `03-rds-scaling`の振り返り完了を受けて次のお題を選定。ROADMAP.mdに「必ず出題に含める」と明記されていた、ECS Task Role/Task Execution Roleの役割分担を扱う`04-ecs-iam-roles`を出題した。`01-vpc-network`ではAWS管理ポリシー(`AmazonECSTaskExecutionRolePolicy`)任せだったため権限の境界が意識されずに動いていた点を踏まえ、今回はカスタムポリシーで最小権限を自分で設計させる形にした。スコープはIAMロール設計に集中させるため、ALB/ECS Serviceは不要とし単発の`run-task`で確認する構成に絞った
- 発見: (出題時点のため次回のレビューで記録)
- CURRENT_LEVELへの反映: なし(出題のみ)
- 次回への持ち越し: 設計提出後、フェーズB(設計レビュー)を実施する
