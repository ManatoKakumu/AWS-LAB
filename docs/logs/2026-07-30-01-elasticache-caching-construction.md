# 2026-07-30: 07-elasticache-caching(AWSコンソール構築〜フェーズC完了)

- 種別: 実装課題(AWSコンソール構築) / 会話・理解度確認
- 内容:
  - VPC(`07-vpc`)・サブネット(ecs/dbの2層×2AZ)・ルートテーブル・SGを構築。確認時に`rds-sg`/`elastic-cache-sg`のInboundルールがポート`0-0`になっているミスを発見(ECSのSGを参照先に指定した際、ポート番号を設定し忘れたもの)
  - 上記の修正を機に、「SGのポート欄は送信元ポートを書くのでは」という誤解が判明。対話を通じて「SG/NACLとも、ポート欄は常に"宛先ポート"を見ている。Inboundは宛先=SGの持ち主自身、Outboundは宛先=接続先の相手」という統一的な理解に整理。ALB・管理用EC2など初見のアクター・新しいプロトコル(HTTPS/SSH)を使った記録を見ない理解度チェック(14問)で全問正解し、定着を確認
  - IAMインラインポリシー(Secrets Managerから`GetSecretValue`)の書き方を確認。ARN末尾のランダムサフィックスの扱いも整理
  - RDS(`database-1`)を構築、Multi-AZ・暗号化・SG・サブネットグループが設計通りであることを確認。転送時暗号化(`require_secure_transport`)は未確認のまま持ち越し
  - ElastiCacheを構築したところ、コンソールでRedisの選択肢が見つからずValkey/Serverlessで作成されていたことが判明(SG・サブネットグループ・保管時暗号化は設計通り)。Terraformでは設計通りRedis/従来型で書く方針に合意
  - お題のスコープ(README記載: アプリケーションコード実装は不要、インフラ設計とキャッシュ戦略の設計判断が主目的)に照らし、ECS/IAMロールの実体構築は行わずここでフェーズCを区切ることに合意
- 発見:
  - 良かった点: SG/NACLの「宛先ポートを見る」というロジックを、既存の知識(`02-nacl-experiment`のエフェメラルポート、`04-ecs-iam-roles`のIAM分類とAPIアクションの区別)と自力で接続し、初見の題材(ALB・管理用EC2・HTTPS・SSH)にも一般化できた
  - 改善が必要な点: SGルールのポート番号未設定(`0-0`のまま)というコピペ実装時の見直し漏れパターンが、`03`/`05`/`06`に続き今回も再発した(累積5回目相当)。ElastiCacheでRedisが見つからずValkey/Serverlessになった件も、コンソール操作時の見直し不足の一種
- CURRENT_LEVELへの反映: なし(このお題のフェーズE完了時にまとめて反映する)
- 次回への持ち越し:
  - RDSの転送時暗号化(`require_secure_transport`)の確認・設定
  - AWSコンソールで構築したRDS・ElastiCacheの削除(破棄)
  - 削除確認後、`projects/README.md`の状態を「Terraform実装中」に更新し、Terraformフェーズ(Redis/従来型で設計通りに実装)へ進む
