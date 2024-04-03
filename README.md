<div align="center">
<img src="https://github.com/femtoCommunity/LegendUtil/blob/main/Resources/Logo/LegendUtil_Banner_WithoutText.png?raw=true" alt="LegendUtil Banner" title="LegendUtil">
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
- [**プロデル**](https://produ.irelang.jp/) `2.0.1191`
- **C#** `.NET Framework 4.8`
- **Python 3** (API)

---

> [!IMPORTANT]
> LegendUtil には他のプレイヤーとの競争力を不正に高めるような機能は含まれていませんが、万が一 LegendUtil を使用した影響で EA アカウント が停止されたりしても、[**ライセンス**](#-ライセンス) に基づき、開発者は一切の責任を負いません。

---

## 📥 ダウンロード/インストール

### 📁 インストーラーを使用してインストールする
- [**こちら**](https://github.com/femtoCommunity/LegendUtil/releases)からインストーラーをダウンロードしてインストールできます。
  - **Assets** から `LegendUtil_Setup.exe` をダウンロードして、実行してください。

### 📦 winget を使用してインストールする
- [**winget**](https://learn.microsoft.com/ja-jp/windows/package-manager/winget/) ([Microsoft Store](https://www.microsoft.com/p/app-installer/9nblggh4nns1#activetab=pivot:overviewtab)) が利用できる環境の場合は、コマンドプロンプトやPowerShellで次のコマンドを実行することでインストールできます。
```powershell
winget install --id femtoCommunity.LegendUtil
```

### 💊 開発ビルドをインストールする
- [**インストーラーをダウンロード**](https://releases.api.legendutil.milkeyyy.com/latest/download?release_channel=dev)
  - **開発ビルドには、実装途中の機能や不安定な機能が含まれており、予期せぬ不具合、クラッシュが発生する可能性があります。**
  - 開発ビルドは、通常(Beta/Release)ビルドとは別のアプリケーションとしてインストールされます。**ただし、コンフィグやプロファイルなどは共通です。**

---

## 🔧 機能
- **プロファイル**
  - 解像度や起動引数などの設定を複数保存でき、ランチャーのような形でプロファイルを選んで Apex Legends を起動できます。
   
  ![Main Panel Preview 1](https://github.com/femtoCommunity/LegendUtil/assets/59532514/978b2001-5292-4171-bb0c-2f14914a5173)
  ![Main Panel Preview 2](https://github.com/femtoCommunity/LegendUtil/assets/59532514/2d52e4bd-bd30-44a8-b023-0966431c9e33)


---

- **ゲームの起動前に設定を自動変更**
  - **ゲーム & ディスプレイ解像度の変更 (引き伸ばし)**
    - ゲーム起動後の `Alt` + `Enter` の自動押下 (「黒帯」の削除)

  ![Profile Edit Panel Preview 1](https://github.com/femtoCommunity/LegendUtil/assets/59532514/1dab9f7d-d10f-4078-91c1-23fdafcc4786)


---

  - **起動引数(起動オプション)の変更**
   
  ![Profile Edit Panel Preview 2](https://github.com/femtoCommunity/LegendUtil/assets/59532514/d7990fef-50ed-41fe-87bc-a8b316e17638)
  ![Profile Edit Panel Preview 3](https://github.com/femtoCommunity/LegendUtil/assets/59532514/087566b8-c9dc-44de-b4d3-99e076b1e7e6)


---

  - **Autoexec の編集**
  
  ![Profile Edit Panel Preview 4](https://github.com/femtoCommunity/LegendUtil/assets/59532514/f0122707-e0eb-4099-8ff2-a76042575f26)


---

  - **コンフィグ/ビデオコンフィグの編集**
  
  ![Profile Edit Panel Preview 5](https://github.com/femtoCommunity/LegendUtil/assets/59532514/8dfeca59-ef50-48f6-a10b-2b7a4bbca6fa)
  ![Profile Edit Panel Preview 6](https://github.com/femtoCommunity/LegendUtil/assets/59532514/9ec34109-4b18-4b44-9557-7bbea0b86ea9)


---

## 📒 ライセンス
Copyright (C) 2024 Milkeyyy

LegendUtil は [GNU General Public License 3.0](https://www.gnu.org/licenses/gpl-3.0.ja.html) のもとでライセンスされています。

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
