using Microsoft.WindowsAPICodePack.Dialogs;
using Produire;

namespace LegendUtil.SharpLibrary
{
	class ファイル選択画面 : IProduireStaticClass
	{
		bool FileDialogCancel = false;
		CommonOpenFileDialog FileDialog = new CommonOpenFileDialog();

		// 手順
		[自分("を")]
		public void 表示()
		{
			var Path = FileDialog.ShowDialog();
			if (Path == CommonFileDialogResult.Cancel)
			{
				FileDialogCancel = true;
			}
			else if (Path == CommonFileDialogResult.Ok)
			{
				FileDialogCancel = false;
			}
		}

		// 設定項目(読み取り専用)
		public string ファイル名 => FileDialog.FileName; // 指定されたファイル名/フォルダー名
		public bool キャンセル => FileDialogCancel; // ダイアログがキャンセルされたかどうか

		// 設定項目
		public string フォルダ名 // 最初に表示されるフォルダー
		{
			get { return FileDialog.InitialDirectory; }
			set => FileDialog.InitialDirectory = value;
		}

		public string 初期フォルダ // 初期フォルダー(フォルダ名で指定されたディレクトリーが存在しない場合の代替えフォルダー)
		{
			get { return FileDialog.DefaultDirectory; }
			set => FileDialog.DefaultDirectory = value;
		}

		public bool フォルダ選択 // フォルダー選択モード
		{
			get { return FileDialog.IsFolderPicker; }
			set => FileDialog.IsFolderPicker = value;
		}

		public string タイトル // ダイアログのタイトル
		{
			get { return FileDialog.Title; }
			set => FileDialog.Title = value;
		}
	}
}
