# 2026-07-23: 05-ecs-autoscaling(Terraform実装〜レビュー〜apply確認〜振り返り、フェーズE完了)

- 種別: 実装課題(Terraform)+ 会話・評価(振り返り)
- 内容: `05-ecs-autoscaling`のTerraform実装(VPC/サブネット/ルートテーブル/IGW/NAT Gateway/SG/IAM/ALB/ECS/Application Auto Scaling)を一通り実施。`terraform validate`/`plan`/`apply`まで成功させ、AWS CLIで`curl`・ECS Service状態・ターゲットヘルスを確認後、`destroy`。EIP・NAT Gateway・ALB・ECSクラスター・VPCが残っていないことをCLIで確認した。

## 発見

- 良かった点:
  - ALBサブネットの`for_each`化を、指摘される前に自分から「サブネットは配置目的が同じだから`for_each`にすべきでは」と提起し、`03-rds-scaling`で身につけた判断基準(役割ベース)を新しい題材に自力で正しく適用できた。さらにNAT/ECSサブネットは役割が異なるため`for_each`にすべきでないという判断も自力でできた
  - `variable`/`locals`の使い分け(外部からの値注入が不要なら`locals`)を一度の説明で理解し、以後は自発的に「IAMのトラストポリシーも共通化できるのでは」と提案・実装した。継続フォロー対象だった弱点の実践的な解消
  - ECS Agentの役割(イメージプル・ログ送信の準備)を自分の言葉で説明し、`04-ecs-iam-roles`のTask Execution Roleの知識と結びつけて、SGがタスクのENIに紐づく理由を正しく整理できた
  - `01-vpc-network`で学んだ「ALBを先に作るべき」という制約を、Terraformのコード記述順にも自力で転用できた
  - `apply`後の確認を最小限(curl・ECS Service状態・ターゲットヘルス)に絞り、既にAWSコンソールで確認済みのスケーリング挙動は再実施せず、コストを抑えつつ効率的に検証できた
- 改善が必要な点:
  - 重複リソースラベル(SGルール、IAMロール)、型不一致(`.id`の付け忘れ)、`jsonencode`内のJSON(camelCase)とHCL属性名(snake_case)の混同(`containerPort`)、文字列補間の書き忘れなど、細かい技術的ミスが多数発生した
  - 修正指示に対して、意図した箇所と異なる箇所に修正を適用してしまうミスが2回発生(IAMの`locals`化、Auto Scalingの`resource_id`修正)。新しいミスパターンとして記録
  - コンテナ名が`04-ecs-iam-roles`からのコピペ跡(`"aws-cli"`)のまま残っていた点、`aws_ecs_service`自体の記述を丸ごと忘れていた点は、`01`〜`04`から続く「コピペ・見直し漏れ」「値の見直し漏れ」パターンの継続

## 振り返り(フェーズE)

Terraformレビュー完了後、続けてそのままフェーズEを実施。[projects/05-ecs-autoscaling/RETROSPECTIVE.md](../../projects/05-ecs-autoscaling/RETROSPECTIVE.md)を対話しながら作成した。

- 本人の自己評価「できたことの実感が薄い(EC2ハンズオンで既知の内容が中心)」に対し、メンター視点で「知識の再確認」ではなく「知識を新しい文脈に適用する力」が発揮されていた点(`for_each`/`locals`判断基準の転用、ECS Agentの知識の結びつけ)を補足した
- 「できなかったこと」として本人が挙げた「設定値のミスの多さ」について対話を重ね、当初の「設定値の重要度を軽視している」という自己分析から、実際のミスの内訳(9件中8件が数値選択ではなくコード記述精度の問題)を踏まえて「概念・設計確認後に注意力を使い切り、見返す一手間が抜ける」という、より実態に近い仮説に本人自身で修正できた
- 「自分では理解しているつもりだったが指摘されたこと」として、Fargateのイメージプル順序(ENI→プル→起動)の理解が逆転していた点(結論は正しいが根拠の仕組み理解が誤り)を記録
- 次回への対策として、休憩・ペース配分の工夫(本人発案)と、提出前の読み返し習慣(メンター提案)の両輪が合意された

## CURRENT_LEVELへの反映

[docs/CURRENT_LEVEL.md](../CURRENT_LEVEL.md)を更新済み。格上げ: `for_each`判断基準の新題材への自力転用、`variable`/`locals`の使い分け、ECS Agentとタスクのネットワークの関係。新規曖昧項目: 修正箇所の取り違え、`jsonencode`内camelCase/HCL属性名snake_caseの混同、Fargateタスク起動順序の理解。「コピペ実装時の値の見直し漏れ」(4回目の再発)に本人による原因仮説を追記。[docs/ROADMAP.md](../ROADMAP.md)のAuto Scaling関連項目にチェックを入れた。

## 記録を見ない理解度チェック(10問)

振り返り完了後、本人の希望で同日中に追加実施。スケーリングポリシー選定理由、登録解除の遅延、SG-ENIの関係、`for_each`/`variable`/`locals`の判断基準、Fargateタスク起動順序、ECR利用時のIAM権限構造、Auto Scalingターゲット/ポリシーの役割分担、単一AZ設計のコストトレードオフ、ヘルスチェック閾値のトレードオフを出題し、10問中10問正解。詳細は[docs/CURRENT_LEVEL.md](../CURRENT_LEVEL.md)の追記分を参照。

## 次回への持ち越し

- `projects/README.md`の状態を「完了」に更新済み
- 理解度チェック10問中10問正解。同一セッション内の確認のため、日をまたいだ定着は次回以降で確認する
- 実装ミスへの対策(休憩・ペース配分、読み返し習慣)の効果を次回以降観察する
- 次のお題は本人と相談の上で決定する(強制しない)
