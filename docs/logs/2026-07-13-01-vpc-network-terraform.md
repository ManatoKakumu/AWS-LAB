# 2026-07-13: 01-vpc-network(Terraform実装〜レビュー〜フェーズD完了)

- 種別: 実装課題(Terraform) + 会話・評価
- 内容:
  - AWSコンソールで構築済みの01-vpc-networkの構成を、Terraformでコード化(VPC、サブネット10個、IGW、EIP/NAT Gateway×2、ルートテーブル8個、SG4つ+ルール、ALB/ターゲットグループ/リスナー/リスナールール、ECSクラスター/IAMロール2種/タスク定義2つ/サービス2つ、RDS)
  - リソースの種類ごとにメンターが構文の最小サンプルを提示し、値(CIDR・SG設計・ポート番号等)は本人が既存の設計に基づいて記述する形で進行(構文と設計判断の切り分けルールに準拠)
  - 実装中に複数のミスを発見・修正: ルートテーブルアソシエーションの参照名タイポ、SG参照名タイポ(`rdb`→`rds`)、`default_action`内`target_group_arn`の重複記述(HCL文法エラー)、ALB↔Web/AP間・AP↔DB間のポート番号を一律443でコピペしていた点、AP用タスク定義・サービスがWeb用のコピペのまま直っていなかった点。いずれも`terraform validate`/`plan`または見比べによる自己レビューで解消
  - 対話を通じて複数の概念を明確化: EIP/NAT Gatewayが固定IPを必要とする理由(外部のIP許可リスト)、Fargateのターゲットタイプが"ip"になる理由(awsvpcモードでタスクごとに専用ENIを持つため)、ECS Service Auto Scalingが増減させるのは「タスク数」であり「1つのタスク内のコンテナ数」ではないこと、ECSクラスターの役割、tfstateとGitへのコミットは別々のリスクであること
  - RDSのマスターパスワードを`sensitive`変数で扱う実装を行い、その過程で「変数化してもtfstate自体には平文で残る」という、これまで実感の伴っていなかった論点を正確に区別して理解した
  - `terraform plan`はメンターが代行実行(RDS Multi-AZ・NAT Gateway×2などコスト増になる構成のため、コンソールで動作検証済みという判断のもとapplyはせずplan止まりとした)。結果は64 resources追加、エラー0件
  - レビュー指摘を受けて`storage_encrypted = true`の追加、README.mdの環境情報・Terraform実装欄・HTTPS/ACM省略の設計判断・RDS最終スナップショット省略の判断を追記。一方で誤って`skip_final_snapshot`を本番仕様(`false`)に変更してしまった点は、学習環境で確実に`destroy`できることを優先する方針に立ち返り差し戻した
  - `REVIEW.md`にTerraformレビューを追記(前回持ち越しの2項目=Execution/Task Roleの役割分担、ECSクラスターの役割、どちらも解消)、`projects/README.md`の状態を「振り返り待ち」に更新
  - セッション終盤、「AI時代のTerraform学習の意義・実務での進め方」について本人から相談があり、設計は人間主導・実装はAI支援を活用しつつも必ずレビューできる状態を保つ、という方向性を共有した
- 発見:
  - 良かった点: 前回持ち越しだった「ECSクラスターの役割」「Execution/Task Roleの役割分担」が、両方とも自分の言葉で正確に説明できる水準まで到達した。tfstateの機密情報リスクも「変数化とtfstate自体の平文保存は別問題」という正確な理解に到達し、CURRENT_LEVEL.mdで「実感が伴わなかった」とされていた項目を解消できた。CloudWatch Logsのロググループを事前にTerraformリソース化する発想に自力で到達できた点も良い(権限を足すのではなく設計を変える、という発想の転換)
  - 改善が必要な点: ECS Service Auto Scalingが「1つのタスク内のコンテナ数」を増減させると誤解しており、「タスクとコンテナの関係」の曖昧さが再度表面化した(対話で修正)。実装面では、コピペ後の変更漏れ(ポート番号の一律コピペ、参照名の直し忘れ)が複数箇所で発生するパターンが見られ、セルフレビューの重要性を再確認する機会になった
- CURRENT_LEVELへの反映: フェーズE(振り返り)完了時に正式反映予定
- 次回への持ち越し: フェーズE(振り返り)から再開。module化/`for_each`によるリソース定義の抽象化、variable化によるハードコード(region、CIDR等)の解消は、次回以降のTerraform課題で扱う

## 追記: フェーズE(振り返り)

同一セッション内でフェーズEまで継続実施。

- `01-vpc-network`全体を対象に口頭理解度テスト(全8問)を実施。NAT Gateway/IGWの違い、EIPの必要性、RDS Multi-AZの目的、タスク定義/タスク/Auto Scalingの関係は正確に回答できた
- 一方で、Execution Role/Task Roleの「CloudWatch Logs書き込み担当」と、Fargateのターゲットタイプがip指定になる理由(EIPとプライベートIPの混同)は、今回のセッション中に一度説明済みにもかかわらず、テストで再度誤答した。それぞれ再度説明し、最終的には正しく整理できた
- `RETROSPECTIVE.md`を対話しながら作成。「理解できていなかったことの整理ができずごちゃごちゃになっていた」という本人の自己評価があった
- `CURRENT_LEVEL.md`を更新: NAT Gateway/IGW、EIP、ALB用語、ECSクラスター、Auto Scalingとタスクの関係、RDS Multi-AZの目的、tfstateと変数の違いを「理解できている」へ格上げ。ECS Execution/Task Roleのログ担当とFargateのip指定理由は「曖昧」に留め、継続フォロー対象と明記。「コピペ実装時の値の見直し漏れ」を新規の傾向として追加
- `ROADMAP.md`を更新: `01-vpc-network`にチェック。`02`〜`04`の今後のお題に、今回判明した弱点(for_each/variable化の未経験、CloudWatch Logs担当の混同)を反映
- `projects/README.md`の状態を「完了」に更新
- 発見: 「同一セッション内で一度説明を受けて理解した」ことと「後のテストで再現できる」ことの間にギャップがあるという新しい学習傾向が明確になった。単発の説明では不十分で、間隔を空けた復習が必要な項目(Execution/Task Role、Fargateのip指定理由)として`CURRENT_LEVEL.md`に明記した
- 次回への持ち越し: `02-nacl-experiment`から再開予定。次回はNACLに加え、`for_each`/`variable`によるTerraformコードの抽象化も扱う
