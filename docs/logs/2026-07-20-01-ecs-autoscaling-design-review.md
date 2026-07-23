# 2026-07-20: 05-ecs-autoscaling(設計レビュー、フェーズB完了)

- 種別: 設計課題
- 内容: `05-ecs-autoscaling`の設計(構成図、使用サービス、スケーリングポリシー、ヘルスチェック、ルートテーブル、SG、IAM、可用性、コスト見積もり)を全項目レビューした。Target Tracking/Step Scalingの使い分け、ALBのクロスゾーンロードバランシング挙動、ECSのAZ配置、ECS Exec用のTask Role/Task Execution Role判断など、複数の論点を扱った。詳細は[REVIEW.md](../../projects/05-ecs-autoscaling/REVIEW.md)参照
- 発見:
  - 良かった点: `04`で身につけたTask Role/Task Execution Roleの判断軸を、ECS Execという新しい題材に自力で転用しようとした。メンターの誤った指摘(ALBがAZをまたぐ通信を避けるという説明)に対しても、最終的には正しい理解に修正できた
  - 改善が必要な点: コスト計算の見直し漏れ(`01`〜`03`から続く既存パターン)が今回も発生。ALBの複数AZが「制約」であることと「意図した設計」であることの区別に、複数回の説明を要した
  - セッション運営上の課題: 1つのお題に多くの論点(スケーリング・ヘルスチェック・AZ設計・IAM・コスト)を含めたため、1回のレビューセッションの密度が高くなりすぎ、本人から「混乱して良くない時間を過ごすことが多い」というフィードバックがあった。詳細は[[feedback_session_pacing_and_wellbeing]]memoryに追記済み
- CURRENT_LEVELへの反映: なし(フェーズE振り返り時にまとめて反映する)
- 次回への持ち越し: `projects/README.md`の状態を「AWS構築中」に更新。次はAWSコンソールでの構築(フェーズC)に進む
