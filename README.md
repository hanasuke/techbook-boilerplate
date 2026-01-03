# Boilerplate of Techbook
## Overview

このスクリプトは、[TechBoosterさまの "ReVIEW-Template"](https://github.com/TechBooster/ReVIEW-Template)、をベースとした執筆レポジトリです。

Grantやnpmなど不要な処理を削除し、Rakeのみで出力できるよう変更しています。

また、PDF出力のみを対象としています。

## Requirements

* Ruby 4.0.0
* uplatex


## 執筆の流れ
### 初期設定

`article/config.yml`を編集し、必要な情報を変更します。

必要そうな変更点については `# TODO` を記入しています。

### 執筆

執筆は、 `article/` 配下に、Markdown(.md)もしくはreview(.re)で行います。

### PDFの生成
#### 紙版
紙版のPDFを出力する場合、 `rake pdf` を行います。

PDFは、`output`配下に `<bookname>.<build datetime>.pdf`という名前で保存されます。

紙版は、章が必ず右ページから開始されるように調整されます。

#### 電子版

電子版PDFを出力する場合は、 `confib-ebook.yml`設定を利用して出力します。

```
REVIEW_CONFIG_FILE=article/config-ebook.yml rake pdf
```

出力ファイルは、紙版と同様に  `<bookname>.<build datetime>.pdf`という形式で保存されます。

## License
This project is licensed under the MIT License - see the LICENSE file for details.

This tool includes code from  (Copyright (c) 2006-2020 Minero Aoki, Kenshi Muto, Masayoshi Takahashi, Masanori Kado), used under the MIT License.

Additionally, files located in `sty/` are licensed used under each licenses.

* review-jsbook.cls, review-base.sty, review-style.sty, review-custom.sty: MIT License
* jumoline.sty: The LaTeX Project Public License
* plistings.sty: MIT License
* gentombow.sty: BSD License
* jsbook.cls: BSD License
