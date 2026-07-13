# 2026-07-13: 02-nacl-experiment Terraform実装(public部分、途中まで)

- 種別: 実装課題(Terraform)
- 内容: README(わからなかったこと欄・環境情報・構築記録)を最終化した後、Terraformコード化に着手。VPC/Subnet/ルートテーブル/SG/EC2(public部分)を実装し、`terraform apply`で実際に起動、curlで疎通確認後、`destroy`まで実施した。NACL部分(`experiment-success`/`experiment-fail`相当、`variable`/`for_each`での抽象化)は未完了で次回に持ち越し
- 発見:
  - Terraformコード化の初稿で、実機構築時とは異なる種類のバグが複数見つかった: `map_public_ip_on_launch`の設定漏れ(構築時に踏んだのと同じ問題をコードでも再現しかけた)、SG参照をダブルクォートで囲んでしまい文字列扱いになっていた、AMIの`data`ソースのfilter値にAMI名ではなくAMI IDを入れていた、Terraformの`aws_security_group`がAWSデフォルトの全許可Egressルールを自動的に剥がす仕様に気づけた(ステートフル性の理解と組み合わせて「Egressルールの有無はcurlの成否に影響しない」という正しい指摘ができた一方、DNS(UDP/53)通信の要否は指摘されるまで気づけなかった)
  - `variable`/`for_each`(NACLルールの抽象化)の理解には最後まで苦しみ、本人から「考えることが多すぎて挫折しそう」という発言があった。要素を分解して段階的に説明(単一リソース→繰り返しに気づく→variable+for_each化)する形に切り替えたが、今回のセッション内では完全な理解には至らず、次回に持ち越し
  - 「Terraformのベースを書いてもらい、意図的なバグ探しで学ぶ」という進め方を本人から提案されたが、実装経験がまだ浅い(01-vpc-networkの1回のみ)ことを理由に、メンター側から時期尚早と判断し、従来通り「新しい構文のみ最小サンプルを提示→設計判断と実装は本人」の方針を維持する合意をした
- CURRENT_LEVELへの反映: (NACL部分完了後、振り返り時にまとめて反映予定)
- 次回への持ち越し: NACL(`experiment-success`/`experiment-fail`相当)の`variable`/`for_each`によるTerraform実装から再開する。段階を追った説明(単一リソースの繰り返し→variable化)は有効だったので、次回もその順で再導入するとよい
