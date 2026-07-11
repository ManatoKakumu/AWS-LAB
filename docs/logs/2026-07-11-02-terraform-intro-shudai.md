# 2026-07-11: 00-terraform-intro(出題〜構築〜レビュー〜振り返り)

`/start` Skill経由でのセッション。出題から、Terraformコードの作成、`apply`長時間ハングの実地トラブルシューティング、Terraformレビュー、振り返りまでを1回の継続した会話で実施した。

## 出題

- 種別: 出題
- 内容:
  - `projects/README.md`の状態(表が空)から「フェーズA: 出題」と判定
  - `docs/CURRENT_LEVEL.md`で「ほぼ理解できていない」に分類されているTerraform全般と、`docs/ROADMAP.md`のPhase 1先頭項目を突き合わせ、`projects/00-terraform-intro`を選定
  - `projects/00-terraform-intro/README.md`を新規作成し、課題内容(providerブロック・単一リソース・init/plan/apply/destroyの一連の流れ)と前提・制約を記入
  - `projects/README.md`に行を追加(種別: Terraform構文導入、状態: Terraform実装中)

## Terraformコード作成・AWS CLI導入

- 種別: 実装課題(Terraform)
- 内容:
  - providerブロック・`resource "aws_s3_bucket"`の構文について質問を受け、How(構文)の範囲として直接回答
  - AWS CLIが未インストールだったため、本人の依頼でwinget経由でインストール(v2.35.20)
  - IAMユーザーのアクセスキー発行について、権限スコープ(最小権限)は本人に考えさせた。本人は「作成したバケットのARNに絞ったCreateBucket/DeleteBucketのみ」という方針を自力で導き、JSON構文の誤り(`Resource`欠落)も自力で修正できた

## `terraform apply`長時間ハングのトラブルシューティング

- 種別: トラブルシューティング(実地)
- 内容:
  - `terraform apply`実行後、`aws_s3_bucket.example`の作成が6分以上「Still creating...」のまま停止する事象が発生
  - 本人が「以前のハンズオンの残骸が悪さをしているのでは」という仮説を提示 → 妥当性の低さを指摘し、CloudTrailでの検証に誘導
  - メンター側で「IAM権限不足によるGet系API群のリトライ」という仮説を提示したが、CloudTrailに追加のS3イベントが見当たらないという証拠と矛盾 → 仮説を一旦撤回し、`aws s3 ls`によるCLI直接検証に誘導(ネットワーク疎通の切り分け)
  - `aws s3 ls`が即座に`AccessDenied`で返ってきたことで通信経路の正常性を確認。最終的に、CloudTrailを対象IAMユーザーで絞り込んだ結果、`GetBucketAcl`/`GetBucketPolicy`/`GetBucketVersioning`等の大量のGet系呼び出しが`AccessDenied`になっていたことが判明し、当初の仮説(IAM権限不足)が正しかったと確定した
  - `s3:*`(対象バケットARNに限定)まで許可を広げて`apply`が2秒で成功、`destroy`も成功
- 発見: 良かった点は本人が複数の仮説を証拠ベースで検証・棄却しながら粘り強く原因究明を続けられたこと(初回評価で確認済みの「症状ベースの障害切り分け」の強みがTerraform/AWS API文脈でも再現)。改善点は、Terraformのリソース属性の「読み取り(Get)」を「設定(Write)」と誤認していた点、および`s3:*`まで許可を広げた後、CloudTrailで判明した個別アクションへの絞り込みまでは詰めなかった点
- CURRENT_LEVELへの反映: 詳細は[projects/00-terraform-intro/RETROSPECTIVE.md](../../projects/00-terraform-intro/RETROSPECTIVE.md)参照。Terraformの基礎フロー・障害切り分け力を格上げ、「読み取りと設定の混同」「tfstateの機密情報リスクの実感不足」を新たに曖昧な項目として追加

## Terraformレビュー・振り返り

- 種別: レビュー・振り返り
- 内容:
  - `projects/00-terraform-intro/REVIEW.md`を新規作成し、Terraformレビュー観点(セキュリティ・運用性・保守性・コスト・Terraform化の改善点・実務ならどう設計するか等)で評価
  - 本人から「自己評価はすべきではない」との申し出があり、`projects/00-terraform-intro/RETROSPECTIVE.md`はメンターによる客観評価として記載
  - `docs/CURRENT_LEVEL.md`・`docs/ROADMAP.md`を更新、`projects/README.md`の状態を「完了」に更新
- 発見: なし
- 次回への持ち越し: 次にmodule/variableを扱うお題(`01-vpc-network`以降)で変数化を意識させる。RDS等パスワードを持つリソースを扱うお題(`03-rds-scaling`)でtfstateの中身を実際に確認する機会を作る
