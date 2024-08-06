<div align="center">
<img src="./Resources/Images/Splash/SplashImage.jpg?raw=true" alt="LegendUtil Banner" title="LegendUtil">
<h1>LegendUtil</h1>
<p>Apex Legends のプレイをより快適にするランチャーアプリケーション</p>
</div>

---

[![Licence](https://img.shields.io/github/license/femtoCommunity/LegendUtil?style=for-the-badge)](#-ライセンス)

[![Downloads](https://img.shields.io/github/downloads/femtoCommunity/LegendUtil/total?style=for-the-badge)](https://github.com/femtoCommunity/LegendUtil/releases)

[![Discord](https://img.shields.io/badge/Discord-%235865F2.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/Y5FrzPft3M)
[![Twitter](https://img.shields.io/badge/Twitter-%231DA1F2.svg?style=for-the-badge&logo=Twitter&logoColor=white)](https://twitter.com/Milkeyyy_53)
[![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/milkeyyy)

## 📃 概要
Apex Legends のプレイをより快適にするランチャーアプリケーションです。
引き伸ばしを行うための解像度の変更や、軽量化のための起動オプションの変更などを、GUIで視覚的に行うことができます。

### 🖥️ 対応環境
- **Windows 11**
- **Windows 10 (64-bit)**

### 🎮 対応プラットフォーム
- [**EA app**](https://www.ea.com/ja-jp/ea-app)
- [**Steam**](https://store.steampowered.com)

### 📝 プログラミング言語
- [**プロデル**](https://produ.irelang.jp/) - `2.0.1262`
- **C#** - `.NET Framework 4.8`
- **Python**

---

> [!IMPORTANT]
> LegendUtil には他のプレイヤーとの競争力を不正に高めるような機能は含まれていませんが、万が一 LegendUtil を使用した影響で EA アカウント が停止されたりしても、[**ライセンス**](#-ライセンス) に基づき、開発者は一切の責任を負いません。

---

## 📥 ダウンロード/インストール

### 📁 インストーラーを使用してインストールする
- [**こちら**](https://github.com/femtoCommunity/LegendUtil/releases)からインストーラーをダウンロードしてインストールできます。
  - **Assets** から `LegendUtil_Setup.exe` をダウンロードして、実行してください。

### 📦 WinGet を使用してインストールする
- [**WinGet**](https://learn.microsoft.com/ja-jp/windows/package-manager/winget/) ([Microsoft Store](https://www.microsoft.com/p/app-installer/9nblggh4nns1#activetab=pivot:overviewtab)) が利用できる環境の場合は、コマンドプロンプトやPowerShellで次のコマンドを実行することでインストールできます。
```powershell
winget install --id femtoCommunity.LegendUtil
```

### 💊 開発ビルドをインストールする
- [**インストーラーをダウンロード**](https://releases.api.legendutil.milkeyyy.com/latest/download?release_channel=dev)
  - **開発ビルドには、実装途中の機能や不安定な機能が含まれており、予期せぬ不具合、クラッシュが発生する可能性があります。**
  - 開発ビルドは、通常(Beta/Release)ビルドとは別のアプリケーションとしてインストールされます。**ただし、コンフィグやプロファイルなどは共通です。**

---

## 🔧 機能
- **EA app と Steam 両方のプラットフォームに対応**

- **プロファイル機能**

  解像度や起動引数などの設定を複数保存でき、ランチャー形式でプロファイルを選んで Apex Legends を起動できます。

- **サーバーステータス/マップローテーション/ニュースの表示**
  - サーバーステータスとマップローテーションはゲームのプレイ中も常に表示できます。

  ![Main Panel Preview 1](https://github.com/femtoCommunity/LegendUtil/assets/59532514/eed9211e-1b44-405f-bbdf-c31e1bebc91e)
  ![Profile Manage Panel Preview 1](https://github.com/femtoCommunity/LegendUtil/assets/59532514/ec2e96cc-726f-4b38-91f2-5e8292da7335)

---

- **ゲームの起動前に設定を自動変更**
  - **ゲーム & ディスプレイ解像度の変更 (引き伸ばし)**
    - ゲーム起動後の `Alt` + `Enter` の自動押下 (「黒帯」の削除)

  ![Profile Edit Panel Preview 1](https://github.com/femtoCommunity/LegendUtil/assets/59532514/b0f3e7f4-4e6a-4e8b-9403-ab8feaa76ad9)

---

- **起動引数(起動オプション)の設定**
  - 一覧にない起動引数も手動で指定することができます。
  - 今まで使用していた起動引数を「追加引数」へ入力すると LegendUtil が自動的に解析して読み込むため、そのまま引き継ぐ事ができます。

  ![Profile Edit Panel Preview 2](https://github.com/femtoCommunity/LegendUtil/assets/59532514/0b447778-4c94-492a-ba4b-a7a74d6b995d)
  ![Profile Edit Panel Preview 3](https://github.com/femtoCommunity/LegendUtil/assets/59532514/b1604e42-4c00-4662-92e0-50217e42538c)

---

- **Autoexec の編集**

  ![Profile Edit Panel Preview 4](https://github.com/femtoCommunity/LegendUtil/assets/59532514/b7ec912d-e8e0-4bd1-bfea-67dfedbd1188)

---

- **コンフィグの自動切り替え**

  Apex Legends の各コンフィグファイルをプロファイルごとに自動で切り替えます。

  プロファイルごとに別々の設定(グラフィック設定やキー設定など)を使用してプレイすることが可能です。

  - プロファイルの設定から「プロファイル固有の設定」か「共通の設定」のどちらを使用するかを切り替えられます。

  ![Profile Edit Panel Preview 4](https://github.com/femtoCommunity/LegendUtil/assets/59532514/3054d0ff-2566-4026-959c-537733c72011)

---

## 📒 ライセンス

LegendUtil は [GNU General Public License 3.0](https://www.gnu.org/licenses/gpl-3.0.ja.html) のもとでライセンスされています。

Copyright (C) 2024 Milkeyyy

---

### Rel1cStyle Logo Typography

- [`Rel1cStyle_Logo_TypographyDeth_1.png`](./Resources/Logo/Rel1cStyle_Logo_TypographyDeth_1.png)
- [`Rel1cStyle_Logo_TypographyDeth_1_White.png`](./Resources/Logo/Rel1cStyle_Logo_TypographyDeth_1_White.png)

Copyright (C) 2024 Rel1cStyle

---

## 開発者
- **ソフトウェア**
  - **Milkeyyy** - [@Ezolys](https://github.com/Ezolys) / [@femto Community](https://github.com/femtoCommunity)
    - [GitHub](https://github.com/Milkeyyy)
    - [Twitter](https://twitter.com/Milkeyyy_53)
    - [Ko-fiで開発をサポートする](https://ko-fi.com/milkeyyy)
- **ロゴデザイン**
  - **Rel1c** (Rel1cStyle) - [@Ezolys](https://github.com/Ezolys) / [@femto Community](https://github.com/femtoCommunity)
    - [GitHub](https://github.com/Rel1c393)
    - [Twitter](https://twitter.com/Apex_tyaneko)
