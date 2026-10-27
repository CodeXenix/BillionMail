<div align="center">
  <a name="readme-top"></a>
  <img src="core/frontend/src/assets/images/logo.svg" width="88" alt="Xenix Mail logo" />
  <h1>Xenix Mail</h1>

## オープンソースのメールサーバー／メールマガジン／Eメールマーケティングプラットフォーム

[![][license-shield]][license-link] [![][github-release-shield]][github-release-link] [![][github-stars-shield]][github-stars-link]

[English](README.md) | [简体中文](README-zh_CN.md) | 日本語 | [Türkçe](README-tr.md)
</div>
<br/>

## Xenix Mailとは？

Xenix Mailは、ビジネスや個人がメールキャンペーンを簡単に運用できるよう支援する**オープンソースのメールサーバー兼Eメールマーケティングプラットフォーム**です。ニュースレター、プロモーションメール、取引通知のいずれを送信する場合でも、メールマーケティングを**完全にコントロール**できます。**高度な分析機能**と**顧客管理機能**により、プロフェッショナルのようにメールを作成、送信、トラッキングできます。

## 3ステップで始める

### Step 1: Xenix Mailのインストール
インストールから最初のメール送信成功まで**約8分**で完了します。
```shell
cd /opt && git clone https://github.com/CodeXenix/XenixMail && cd XenixMail && bash install.sh
```

### Step 2: ドメインを接続する
- 送信ドメインを追加
- DNSレコードを検証
- 無料SSLを自動有効化

### Step 3: キャンペーンを構築する
- メールを作成または貼り付け
- リストとタグを選択
- 送信日時を設定または今すぐ送信

## Dockerでインストール
Dockerとdocker-composeプラグインを各自でインストールし、`.env`ファイルを編集してください。
```shell
cd /opt && git clone https://github.com/CodeXenix/XenixMail && cd XenixMail && cp env_init .env && docker compose up -d || docker-compose up -d
```

## 管理スクリプト
- 管理ヘルプ

  `bm help`

- デフォルトログイン情報を表示

  `bm default`

- ドメインのDNSレコードを表示

  `bm show-record`

- Xenix Mailを更新

  `bm update`

## Webメール

Xenix Mailには**RoundCube**が含まれており、`/roundcube/`からWebメールを開けます。

## なぜXenix Mailを選ぶのか？

ほとんどのEメールマーケティングプラットフォームは**高価**、**クローズドソース**、または**基本機能が不足**しています。Xenix Mailはこれらと異なります：

✅ **完全オープンソース** – 隠れたコストなし、ベンダーロックインなし。  
📊 **高度な分析機能** – 配信、開封率、クリック率などを追跡。  
📧 **送信数無制限** – 送信メール数に制限なし。  
🎨 **カスタマイズ可能なテンプレート** – 再利用可能なプロフェッショナルなマーケティングテンプレート。  
🔒 **プライバシーファースト** – データは手元に残り、サードパーティによる追跡なし。  
🚀 **セルフホスト** – 自分のサーバーで実行し、完全にコントロール可能。  

## Issues

問題が発生したり機能リクエストがある場合は、[Issueを作成](https://github.com/CodeXenix/XenixMail/issues)してください。以下を含めてください：

- 問題またはリクエストの明確な説明。
- 再現手順（該当する場合）。
- スクリーンショットやエラーログ（該当する場合）。

## ライセンス

Xenix Mailは**AGPLv3ライセンス**のもとで公開されています。これにより以下が可能です：

✅ ソフトウェアを無料で使用する。  
✅ コードを改変・再配布する。  
✅ プライベートで制限なく使用する。

Xenix Mailは、aaPanelによる[BillionMail](https://github.com/aaPanel/BillionMail)の改変版であり、同じくAGPLv3ライセンスのもとで公開されています。詳細は[LICENSE](LICENSE)ファイルをご覧ください。

---

[license-link]: https://www.gnu.org/licenses/agpl-3.0.html
[github-release-link]: https://github.com/CodeXenix/XenixMail/releases/latest
[github-stars-link]: https://github.com/CodeXenix/XenixMail

[github-release-shield]: https://img.shields.io/github/v/release/CodeXenix/XenixMail
[github-stars-shield]: https://img.shields.io/github/stars/CodeXenix/XenixMail?color=%231890FF&style=flat-square
[license-shield]: https://img.shields.io/github/license/CodeXenix/XenixMail
