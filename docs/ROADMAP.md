# ROADMAP

今後学ぶ予定。**生きたドキュメント。** [CURRENT_LEVEL.md](CURRENT_LEVEL.md) の変化に応じてフェーズ・優先順位を見直すこと。理解できた項目はチェックを入れて残す(消さない。成長履歴として残す)。

優先順位の原則: CURRENT_LEVELで「曖昧」「ほぼ理解できていない」に分類された項目を優先する。「理解できている」項目は基礎確認程度に留め、深追いしない。

## Phase 1: 弱点補強 + IaC基礎(現在地)

ネットワーク・DB・IAMの「目的差分」の弱点を、Terraformで実際に手を動かしながら固める。方針は[MENTOR_RULES.md](MENTOR_RULES.md)のガードレール通り、**plan中心・applyは要所のみ・apply後は必ずdestroy**。

`01`以降は「設計レビュー→AWSコンソールで構築→同じ構成をTerraform化」の順で進める(`/start` Skillのフェーズ B→C→D に対応)。`00`のみアーキテクチャ設計を伴わない構文導入のため、設計レビューとAWS構築の手順を飛ばしてよい(`.claude/skills/start/SKILL.md`の例外規定)。

- [x] `projects/00-terraform-intro`: Terraformの構文に慣れるための最小導入(providerブロック、単一リソース(例: S3バケット1個)、`init/plan/apply/destroy`の一連の流れ)。この回だけは構文をメンターが例示してよい([MENTOR_RULES.md](MENTOR_RULES.md)の切り分けルール参照)。2026-07-11完了。基礎フローに加え、IAM最小権限設計と`apply`長時間ハングの実地トラブルシューティングを経験した
- [x] `projects/01-vpc-network`: 設計済みのVPC(3層分離、2-3AZ、IGW、NAT Gateway、ルートテーブル)をAWSコンソールで構築後、Terraformでコード化。設計判断は本人が行う。2026-07-13完了。ネットワーク基礎に加え、ALB/ECS/RDSを含む構成をTerraform化し、`terraform plan`まで検証した。module化/`for_each`/variable化は次のTerraform課題に持ち越し
- [x] `projects/02-nacl-experiment`: NACLを意図的に構成し、ステートレス挙動(エフェメラルポート)を実機で確認する。`01-vpc-network`で同一パターンのリソース(サブネット10個等)をすべて手打ちした経験を踏まえ、`for_each`/`variable`によるTerraformコードの抽象化もこの回で扱う。2026-07-13完了。NACLのステートレス挙動・エフェメラルポート・SG/NACLの許可拒否モデルの違いを理解し、`variable`/`locals`/`for_each`によるTerraform抽象化も実装。ただし`variable`/`locals`の使い分け自体はまだ曖昧で継続フォロー対象
- [ ] `projects/03-rds-scaling`: RDS Multi-AZ と リードレプリカを両方構築し、フェイルオーバー・レプリケーション遅延を実際に観察する。Multi-AZの目的(高可用性)は`01-vpc-network`で理解済みのため、リードレプリカとの目的差分に焦点を当てる
- [ ] `projects/04-ecs-iam-roles`: ECSのTask Role / Task Execution Roleを意図的に分離し、権限不足のエラーを実際に発生させて切り分ける。`01-vpc-network`で「CloudWatch Logsへの書き込み担当」を2回連続で誤答しているため、この論点は必ず出題に含める

## Phase 2: 可用性・スケーラビリティの実践

- [ ] Auto Scaling(ECSサービス/ASG)の実装とスケーリングポリシー設計
- [ ] ALBのヘルスチェック設計、複数AZでの障害シミュレーション
- [ ] キャッシュ戦略(ElastiCache)、キューイング(SQS)による負荷平準化
- [ ] マルチリージョン・DR設計の基礎(Route53フェイルオーバーの正しい使いどころ含む)

## Phase 3: 可観測性・運用性

- [ ] CloudWatch Logs / Logs Insights でのログ設計
- [ ] CloudWatchアラーム・ダッシュボード設計(アラート疲れを起こさない閾値設計を含む)
- [ ] X-Rayによる分散トレーシング
- [ ] IaCでのCI/CD(Terraform plan/applyのパイプライン化)

## Phase 4: 発展

- [ ] マルチアカウント設計(Organizations、SCP)
- [ ] コスト最適化の実践(Cost Explorer、Savings Plans、リソースの適正サイジング)
- [ ] セキュリティの発展(GuardDuty、Security Hub、WAF)
- [ ] Well-Architected Framework 6本柱での既存プロジェクトの棚卸しレビュー
- [ ] AWS以外のクラウド(GCP/Azureいずれか)で同じ設計思想が通用するか検証する課題

## 更新履歴

- 2026-07-11: 初回評価結果をもとに作成
- 2026-07-11: `00-terraform-intro`完了、チェックを入れた
- 2026-07-13: `01-vpc-network`完了、チェックを入れた。今後のお題(02〜04)に、今回判明した弱点(for_each/variable化の未経験、CloudWatch Logs書き込み担当の混同)を反映
- 2026-07-13: `02-nacl-experiment`完了、チェックを入れた。`variable`/`locals`の使い分けが新たな弱点として判明したため、今後のTerraform課題で継続的に扱う
