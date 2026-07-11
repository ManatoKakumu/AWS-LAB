# aws-lab

クラウドネイティブな設計ができるインフラエンジニアを目指すための、個人専用の育成リポジトリ。単なるAWSの使い方の習得ではなく、高可用性・スケーラビリティ・セキュリティ・可観測性・IaC・運用性・保守性・コスト最適化といった、クラウド全般で通用する設計思想を身につけることを目的とする。

## 読む順番

`/start` Skill実行時はClaudeが自動で読み込むため、以下は主に人間が状況を把握したいときの参考順。

1. [docs/PROFILE.md](docs/PROFILE.md) — 目標・経歴・学習環境
2. [docs/CURRENT_LEVEL.md](docs/CURRENT_LEVEL.md) — 現在の理解度(生きたドキュメント、随時更新)
3. [docs/ROADMAP.md](docs/ROADMAP.md) — 今後の学習予定(フェーズ分け)
4. [docs/MENTOR_RULES.md](docs/MENTOR_RULES.md) — メンター(Claude)が守るルール
5. [docs/LEARNING_LOG.md](docs/LEARNING_LOG.md) — 学習セッションの索引(詳細は`docs/logs/`配下)
6. [projects/README.md](projects/README.md) — お題一覧と現在の進行状態

## ディレクトリ構成

```
aws-lab/
├── docs/
│   ├── PROFILE.md / CURRENT_LEVEL.md / ROADMAP.md / MENTOR_RULES.md
│   ├── LEARNING_LOG.md   学習セッションの索引(1行1セッション)
│   └── logs/             セッションごとの詳細ログ
├── projects/    お題ごとの成果物(NN-お題名/)
└── templates/   設計レビュー・README・振り返りのテンプレート
```

`.claude/skills/start/SKILL.md`に`/start` Skillを実装済み。このリポジトリでの学習セッションは`/start`から始める。現在の状態(出題前/設計レビュー待ち/AWS構築中/Terraform実装中/振り返り待ち)を自動判定し、そのフェーズに応じて案内する。Skill本体は再設計コストが高い資産のためGit管理する。

## 学習サイクル

出題 → 自力で設計・構築 → 厳格なレビュー → 改善点の提示 → 次のお題、を繰り返す。詳細は[MENTOR_RULES.md](docs/MENTOR_RULES.md)。
