# 2026-07-13: 02-nacl-experiment Terraform実装(NACL部分)〜Terraformレビュー完了

- 種別: 実装課題(Terraform)+ レビュー
- 内容: 前回持ち越しだったNACL部分(`experiment-success`/`experiment-fail`相当)を`variable`+`locals`+`for_each`で実装。`variable`にはリソース参照を書けない制約に気づかせるところから始め、単一リソース→繰り返しに気づく→`variable`/`locals`+`for_each`化、という段階的な説明でようやく実装に至った。`apply`して`success`状態でcurl成功、`subnet_ids`を`fail`側に切り替えて再`apply`しcurlタイムアウト、を実機で確認後`destroy`。Terraformコード全体のレビューを実施し合格、`REVIEW.md`に追記した
- 発見:
  - `variable`と`locals`の役割の違い(リソース参照の可否)、`for_each`のループ変数の参照方法は、今回のセッション内で複数回の説明を要した。一方で、一度実装できてからは「NACLのIDと`for_each`のキーの対応が崩れると何が起きるか」を自力で正確に説明できており(「両方の表でキー名を揃える必要がある」という指摘)、実装できた後の理解の深さは十分だった
  - Terraformの`aws_security_group`がAWSデフォルトの全許可Egressルールを自動的に取り除く仕様に自力で気づき、SGのステートフル性の理解と組み合わせて正確な指摘ができた。一方でDNS通信の要否やTCP/UDPの区別は、指摘されるまで気づけなかった
  - セッション中盤に「考えることが多すぎて挫折しそう」という発言があり、翌ラウンド以降は説明を小さく分解する形に切り替えた。本人から「今日はここまで」という区切りの申し出があり、素直に応じて記録を残してセッションを終えた回があった(次回同じ続きから再開)
- CURRENT_LEVELへの反映: (振り返り(フェーズE)で反映予定)
- 次回への持ち越し: `projects/README.md`の状態を「振り返り待ち」に更新済み。次はフェーズE(振り返り・記録更新)
