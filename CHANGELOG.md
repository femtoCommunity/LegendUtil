# LegendUtil Changelog

## 🚀 Version 0.1.0-beta.4
### 🔁 変更
- [メインメニュー] プロファイル項目の詳細ラベルのフォントサイズを変更
- [アプリケーション情報ウィンドウ] レイアウトを調整
### 🔧 修正
- ゲーム起動時、プラットフォームを Steam に設定していても EA app のコンフィグ読み込み処理が行われてしまう (EA app がインストールされていない環境ではエラーが発生してゲームを起動できない)

## 🚀 Version 0.1.0-beta.3
### 🟢 追加
- 起動引数をカテゴリー分けし、わかりやすいように改良
- 解析可能起動引数を追加
  - `+cl_liveapi_allow_requests`
  - `+cl_liveapi_pretty_print_log`
  - `+cl_liveapi_use_protobuf`
  - `+cl_liveapi_ws_keepalive`
  - `+cl_liveapi_ws_retry_count`
  - `+cl_liveapi_ws_retry_time`
  - `+cl_liveapi_ws_timeout`

### 🔧 修正
- ゲームの起動処理時、EACパスの `\` が多く含まれた状態で保存される

## 🚀 Version 0.1.0-beta.2
### 🔁 変更
- [プロファイル管理パネル] プロファイル情報を表示するためのウェブビューを削除 (メモリー使用量の削減)

### 🔧 修正
- 起動中パネルのプロファイル名が更新されない
- アップデートチェックが機能しない

## 🚀 Version 0.1.0-beta.1
- 初回リリースバージョン🎉