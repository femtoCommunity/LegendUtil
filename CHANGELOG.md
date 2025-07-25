# LegendUtil Changelog

## 🚀 Version 0.4.0-beta

### ⚡ このバージョンの主な変更点
- メインメニューのニュースをプロファイルリストに置き換える機能を実装 (実験的機能)
- 多数の不具合の修正

---

### 🟢 追加
- [メインメニュー] ニュースをプロファイルリストに置き換える機能を実装 (実験的機能)
  > この機能を利用するには、アプリケーション設定の「実験的機能」から「メインメニュー プロファイルリスト」を有効化し、アプリケーション設定から「ニュースの表示」を無効化する必要があります。
- [メインメニュー] マップローテーションへ常時表示される残り時間表記を追加
- [プロファイル編集パネル] 解像度変更に関する警告文を追加
- [アプリケーション情報画面] コミットハッシュの表記を追加
- ウィンドウ上部のバージョンラベルをクリックするとバージョン情報をコピーする機能を実装
- 初回起動時に言語を選択する機能を実装
- シーズン24 および ビーストモードイベントで追加された新たな起動引数へ対応
  - `+mat_wide_pillarbox` - 有効にすると、ゲーム画面が引き伸ばされず、画面に黒い余白が表示されるようになります。ウルトラワイドモニターなど、アスペクト比が 16:9 ではないディスプレイを使用している場合に 16:9 でプレイするための引数です。
  - `+mat_minimize_on_alt_tab` - フルスクリーン時に <kbd>Alt</kbd>+<kbd>Tab</kbd> で移動したり、ウィンドウ外をクリックしてゲームからフォーカスを外すと、**ウィンドウが最小化される** という DirectX 11 と同様の動作が可能になります。
  - `+lobby_max_fps` - ロビーとメニューにおけるFPSの上限値を設定します。
  - `-no_render_on_input_thread` - 有効にすると、マルチスレッドレンダリングの処理に入力処理と同じCPUコアを使用しなくなります。
  - `+mat_no_stretching` - すべての解像度の引き伸ばしを無効化し、常にモニターをゲームの解像度に合わせてレターボックスまたはピラーボックス化します。 (黒帯が表示されます) この機能は、一部のプレイヤーがカスタム解像度で DirectX 11 の設定を再現するのに便利です。
  - `+clip_mouse_to_letterbox` - 有効にすると、ゲーム内で「マウスカーソルをゲームウィンドウに固定」オプションを有効にしている場合に、カーソルが黒帯の内側の領域に固定されないようになります。

### 🔁 変更
- [モザンビークAPI] ゲームモードの一覧をAPIから取得した情報を元にするように改良
- [モザンビークAPI] 新しいドメイン/エンドポイントに対応
- [実験的機能管理画面] 実験的機能を無効化する機能を実装
- [実験的機能管理画面] 詳細テキストを追加
- [アプリ設定パネル] 設定項目の文字サイズを調整
- [アップデーター] アップデート確認画面の変更履歴ビューの改良
- 初回起動時に生成されるデフォルトのプロファイルの名称を言語によって変更されるよう改善
- DirectX 11 のサポート終了に伴う変更および修正
  - DirectX 12 で起動するための起動引数を削除
  - DirectX 12 の起動引数を削除する機能を実装
- ナイトリービルドへの対応

### 🔧 修正
- [アプリ設定パネル] ウィンドウサイズに応じて各項目のレイアウト調整が正常に行われるように修正
- [アプリ設定パネル] Crowdin のリンクボタンのサイズを修正
- [プロファイル編集パネル] 起動引数の項目がウィンドウサイズに応じて各項目のレイアウト調整が正常に行われるように修正
- [プロファイル編集パネル] 起動引数解析時に「全般」タブに戻される問題を修正
- [プロセス監視] プロセス待機とビデオコンフィグ編集時の例外処理の修正
- EA app (EABackgroundService) の再起動を行う機能が正常に機能しない (#65)
- 初回起動時のメッセージが言語データの読み込み前に表示されてしまい、正常に表示されない問題を修正
- ウィンドウを最小化した状態でアプリケーションを終了すると、ウィンドウの位置が画面外に移動してしまう問題を修正


## 🚀 Version 0.3.2-beta

### ⚡ このバージョンの主な変更点
- ビーストモードイベント以降、起動時のインストール先チェックでエラーが発生してゲームが起動できない問題を修正しました。

---

### 🔁 変更
- DirectX 11 の実行ファイル削除 (サポート終了) に伴う変更/修正

### 🔧 修正
- ゲーム起動時のインストール先チェックでエラーが発生してゲームが起動できない問題を修正
- 英語と韓国語の一部言語データの欠落を修正


## 🚀 Version 0.3.1-beta

### ⚡ このバージョンの主な変更点
- ゲーム起動時にプロセスの追跡が正常に開始されず、「時間内に Apex Legends のプロセスを取得出来ませんでした。」というエラーが発生する問題を修正しました。

---

### 🔁 変更
- バックエンドAPIのドメインを変更
- プロデルのバージョンを `2.0.1271` へ更新 (一部のパフォーマンスが向上しました)

### 🔧 修正
- DirectX 12 での起動がデフォルトになったことによる影響で、ゲーム起動時にプロセスの追跡が正常に開始されず「時間内に Apex Legends のプロセスを取得出来ませんでした。」というエラーが発生する問題を修正


## 🚀 Version 0.3.0-beta

### ⚡ このバージョンの主な変更点
- UIの多言語対応
  - 英語 (English)
  - 韓国語 (한국어)
- プロファイルごとの 最終プレイ日時/総プレイ時間 を記録する機能を実装
- Discord Rich Presence に対応

---

### 🟢 追加
- UIの表示言語に英語と韓国語を追加
- マップローテーションにマップの残り時間表記を追加 (試験的機能)
- ゲームの起動処理中またはプレイ中にウィンドウを閉じようとした時に警告ダイアログを表示する機能を実装
- プロファイルごとの最終プレイ日時と総プレイ時間を記録する機能を実装
- プロファイルコンフィグ (`profile.cfg`) の切り替えに対応
- Discord Rich Presence に対応

### 🔁 変更
- スプラッシュ画面のデザインを変更 (Image by [**Rel1c**](https://twitter.com/Apex_tyaneko))
- インストーラーを 64-bit へ変更
- ウィンドウのタイトルバーの色を設定されたテーマに合わせて変更するよう改良
- ゲーム終了時に発生したエラーの内容をより詳細に表示するように改良
- サーバーステータス/マップローテーションのレイアウトを改良
- マップローテーションのゲームモード コントロール/チームデスマッチ/ガンゲーム が正しく表示されるよう改良
- アップデートのリリースチャンネルの選択肢を更新
  - 各リリースチャンネルの説明を追加
- [プロセス監視] Alt+Enter 自動押下の画像認識試行回数を60回へ変更
- その他細かい調整/内部処理の改良

### 🔧 修正
- [メインメニュー] ニュースのサムネイル画像が切り替わるたびにメモリーの使用量が増加し続ける問題を修正
- [プロファイル編集パネル] 画像処理の追加ファイル存在確認が正常に行われず、毎回ダウンロード確認ダイアログが表示される問題を修正
- タブ切り替え時の読み込み中表示がすぐに消えてしまう問題を修正
- ゲーム起動時の各コンフィグファイル切り替え処理が正常に行われず、コンフィグの変更内容が保存されないことがある問題を修正
- ゲーム終了時にエラーが発生すると、メインメニューに戻らず操作を受け付けなくなる問題を修正


## 🚀 Version 0.2.4-beta

### ⚡ このバージョンの主な変更点
- **シーズン 21 への対応**
  - 新しい DirectX 12 の起動引数への対応
  - EAC のバージョンアップに伴う実行ファイル名の変更への対応
  - 一部UIテキストの修正

---

### 🟢 追加
- アプリケーションの起動時に DirectX 12 で起動するための起動引数の古い値を自動的に置き換える機能を実装 (アプリの起動時にダイアログが表示されます)

### 🔁 変更
- 起動時のインストール先チェックで `EasyAntiCheat_launcher.exe` の存在を無視するように変更
- DirectX 12 で起動するための新しい起動引数への対応
- [プロファイル編集パネル] DirectX 12 の詳細情報へのURLを更新
- [プロセス監視] Alt+Enter 自動押下の画像認識試行回数を30回へ変更

### 🔧 修正
- [プロファイル編集パネル] Apex Legends の実行ファイルパスのツールチップを修正


## 🚀 Version 0.2.3-beta

### 🔧 修正
- 1つのアカウントでしかログインしていない環境でゲームを起動する際、コンフィグファイルを取得できずにエラーが発生する問題の修正
  > ゲームの起動時に EA app で設定されている Apex Legends の起動引数を削除する機能の影響


## 🚀 Version 0.2.2-beta

### 🟢 追加
- ゲームの起動時に EA app で設定されている Apex Legends の起動引数を削除する機能を実装
  > これは LegendUtil 側で設定していない起動引数が適用されるのを防ぐための機能です。
      EA app で起動引数が設定されているのを LegendUtil が検知すると、ゲームの起動時に削除確認ダイアログが表示されます。
- EA app のコンフィグフォルダーを指定する設定項目を再追加

### 🔧 修正
- ゲームの起動時の一部ログ出力を修正


## 🚀 Version 0.2.1-beta

### 🔧 修正
- **[プロファイル]** ビデオコンフィグの「読み込むファイル」を「プロファイル」に設定するとビデオコンフィグが保存されない


## 🚀 Version 0.2.0-beta

### 🟢 追加
- **[プロファイル]** カーソルロックの有効/無効を設定する項目を追加
- **[プロファイル]** プロファイル固有のコンフィグ/ビデオコンフィグを読み込む機能を実装 (読み込むコンフィグ/ビデオコンフィグを指定する項目を追加)
- **[メインメニュー]** サーバーステータスを表示するパネルを追加
- **[メインメニュー]** ニュースを表示するパネルを追加
- **[メインメニュー]** マップローテーションを表示するパネルを追加
- **[プロファイル編集パネル]** 解像度テスト機能を追加
- **[プロファイル編集パネル]** 解像度のプリセット項目にディスプレイが対応している設定一覧を表示するよう改良
- **[プロファイル管理パネル]** 右クリックメニューを再実装

### 🔁 変更
- **UIのデザインを刷新**
- 起動時間を短縮
- スプラッシュ画面のデザインを変更 (by [**Rel1c**](https://twitter.com/Apex_tyaneko))
- EA app でのゲーム起動方法を変更 (起動時間の短縮)
  - この変更に伴い、ゲームの起動時に EA app が再起動されなくなりました。
- コンフィグからディスプレイと EA app 関連の項目を削除
- EA app コンフィグファイル検出ツールを削除
- システムのディスプレイ設定変更時、変更前のディスプレイ設定を自動的に取得してゲーム終了時に復元するように変更
- Alt+Enter 自動押下の画像比較処理実行時、LegendUtil のウィンドウが選択されていなくても Apex Legends のウィンドウへフォーカスが移るように改良
- 起動時のコンフィグ読み込みタイミングを変更

### 🔧 修正
- プロファイル名に Windows のファイル名に使用できない文字が含まれていると、ショートカットを作成できない


## 🚀 Version 0.1.0-beta.11
### 🔁 変更
- **ライセンスを MIT License から GNU General Public License 3.0 へ変更**


## 🚀 Version 0.1.0-beta.10
### 🔧 修正
- アップデートチェックでエラーが発生した際の動作を修正


## 🚀 Version 0.1.0-beta.9
### 🔧 修正
- プラットフォームが Steam に設定されているプロファイルでゲームを起動すると引数が渡されない


## 🚀 Version 0.1.0-beta.8
### 🟢 追加
- EA app のコンフィグファイルが保存されているフォルダーを手動で選択する機能を追加
### 🔁 変更
- ヘルプ機能を再実装
- その他細かい調整


## 🚀 Version 0.1.0-beta.7
### 🔁 変更
- EA app のコンフィグファイル名が設定されていない場合に表示されるダイアログを初回起動時のみ表示するように変更
- スプラッシュ画面のバナー画像を差し替え
### 🔧 修正
- ショートカットから起動した際の終了時に実行されるアップデートチェック機能が正常に機能しない
- 引数 `/Play` にIDが指定されていない場合に表示されるエラーメッセージを修正


## 🚀 Version 0.1.0-beta.6
### 🟢 追加
- **[メインメニュー / プロファイル管理パネル]** プロファイルの並び替え機能を実装
- **[メインメニュー]** 解像度の変更が有効になっているプロファイルの解像度表記にアスペクト比を追加
- **[プロファイル編集パネル]** 実際の起動引数文字列のテキストを追加
- **[プロセス監視]** Alt+Enter の自動押下を画像認識で実行する機能を追加
- EA app を Steam 経由で起動する機能を追加
- プリセットからプロファイルを作成できるプロファイル新規作成ウィンドウを追加
- ショートカットから起動した際、終了時にアップデートチェックを行う機能を追加
- 解析可能起動引数を追加
  - `+autoexec`
- autoexec の編集機能を実装 (仮)
- スプラッシュウィンドウを追加
- 旧(v1)プロファイルからの変換機能を実装

### 🔁 変更
- **[プロファイル]** プロファイルの形式を刷新 (v2)
  > この変更により `0.1.0-beta.5` 以前のプロファイルは使用できなくなります。
  ただし、旧バージョンのプロファイルが見つかった場合、起動時に自動的に変換されるため、旧バージョンのプロファイルを引き継いで使用することができます。
- **[メインメニュー]** プロファイル項目のレイアウトを変更 (プレイボタンを追加)
- **[メインメニュー]** 解像度の変更が有効になっていないプロファイルの解像度表記を「ネイティブ」に変更
- **[プロファイル編集パネル]** 読み込み時のパフォーマンスを改善
- **[プロファイル編集パネル]** 項目を別々のタブに分割
- **[プロファイル編集パネル]** カテゴリー名の文字サイズを変更
- **[プロファイル編集パネル]** タブ移動順を修正
- **[プロファイル管理パネル]** プロファイルリストに詳細情報を追加
- **[プロファイル管理パネル]** コンテキストメニューを削除
- **[プロファイル管理パネル]** ショートカット作成ボタンのアイコンを更新 / ボタンのマウスカーソルを変更
- **[EAapp コンフィグファイル検出ツール]** ガイドテキストを改善 / ボタンのマウスカーソルを変更
- **[プロセス監視]** 元のビデオコンフィグが「読み取り専用」に設定されている場合は、監視終了時に「読み取り専用」に設定し直すよう改良
- **[プロセス監視]** 起動時のプロセスチェックを厳格化
- 起動中パネルを別ウィンドウに分離
- パネル切り替え時のパフォーマンス(読み込み速度)を大幅に改善
- ライブラリーを更新
- コードを整理

### 🔧 修正
- 読み込み中の表示が正常に表示されないことがある (#8)


## 🚀 Version 0.1.0-beta.5
### 🟢 追加
- [プロファイル編集パネル] ディスプレイスケーリングモードの項目を追加
- プロファイルの読み込み時に各項目をチェックする機能を実装

### 🔁 変更
- プロファイル名称変更手順を改良
- ゲーム起動処理時のインストールパスチェックで `r5apex.exe` の存在を確認するように改良
- ディスプレイ解像度プラグインを更新
- カーソルロックプラグインを更新
- [プロファイル編集パネル] UIのレイアウトを調整

### 🔧 修正
- [プロファイル管理パネル] 項目選択時にエラーが発生する
- プロセス監視終了時に解像度が元に戻せない (#6)


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
