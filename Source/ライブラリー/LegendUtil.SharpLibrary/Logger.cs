using Produire;
using Produire.CoreLibrary;
using System;
using System.IO;
using System.Text;

namespace LegendUtil.SharpLibrary
{
	class ロガー : IProduireClass
	{
		/// <summary>
		/// ログレベル
		/// </summary>
		public enum LogLevel
		{
			ERROR,
			WARN,
			INFO,
			DEBUG
		}

		[列挙体(typeof(LogLevel))]
		public enum ログレベル
		{
			エラー = LogLevel.ERROR,
			警告 = LogLevel.WARN,
			情報 = LogLevel.INFO,
			デバッグ = LogLevel.DEBUG
		}

		private LogLevel logLevel = LogLevel.INFO;
		private string logFilePath = null;
		private readonly object lockObj = new object();
		private StreamWriter stream = null;

		public LogLevel レベル
		{
			set { logLevel = value; }
			get { return logLevel; }
		}

		/// <summary>
		/// コンストラクター
		/// </summary>
		public ロガー(string ファイル名)
		{
			logFilePath = ファイル名;
			// ログファイルを生成する
			CreateLogfile(new FileInfo(logFilePath));
		}

		[自分で]
		public void 出力する([を] string 内容, [省略][として] LogLevel level = LogLevel.INFO)
		{
			switch (level)
			{
				case LogLevel.ERROR:
					Error(内容); break;
				case LogLevel.WARN:
					Warn(内容); break;
				case LogLevel.INFO:
					Info(内容); break;
				case LogLevel.DEBUG:
					Debug(内容); break;
			}
		}

		/// <summary>
		/// ERRORレベルのログを出力する
		/// </summary>
		/// <param name="msg">メッセージ</param>
		[除外]
		public void Error(string msg)
		{
			if ((int)LogLevel.ERROR <= (int)レベル)
			{
				Out(LogLevel.ERROR, msg);
			}
		}

		/// <summary>
		/// ERRORレベルのスタックトレースログを出力する
		/// </summary>
		/// <param name="ex">例外オブジェクト</param>
		[除外]
		public void Error(エラー情報 ex)
		{
			if ((int)LogLevel.ERROR <= (int)レベル)
			{
				Out(LogLevel.ERROR, ex.メッセージ + Environment.NewLine);
			}
		}

		/// <summary>
		/// WARNレベルのログを出力する
		/// </summary>
		/// <param name="msg">メッセージ</param>
		[除外]
		public void Warn(string msg)
		{
			if ((int)LogLevel.WARN <= (int)レベル)
			{
				Out(LogLevel.WARN, msg);
			}
		}

		/// <summary>
		/// INFOレベルのログを出力する
		/// </summary>
		/// <param name="msg">メッセージ</param>
		[除外]
		public void Info(string msg)
		{
			if ((int)LogLevel.INFO <= (int)レベル)
			{
				Out(LogLevel.INFO, msg);
			}
		}

		/// <summary>
		/// DEBUGレベルのログを出力する
		/// </summary>
		/// <param name="msg">メッセージ</param>
		[除外]
		public void Debug(string msg)
		{
			if ((int)LogLevel.DEBUG <= (int)レベル)
			{
				Out(LogLevel.DEBUG, msg);
			}
		}

		/// <summary>
		/// ログを出力する
		/// </summary>
		/// <param name="level">ログレベル</param>
		/// <param name="msg">メッセージ</param>
		[除外]
		private void Out(LogLevel level, string msg)
		{
			int tid = System.Threading.Thread.CurrentThread.ManagedThreadId;
			string fullMsg = string.Format("[{0}][{1}][{2}] {3}", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff"), tid, level.ToString(), msg);

			lock (this.lockObj)
			{
				this.stream.WriteLine(fullMsg);
			}
		}

		/// <summary>
		/// ログファイルを生成する
		/// </summary>
		/// <param name="logFile">ファイル情報</param>
		[除外]
		private void CreateLogfile(FileInfo logFile)
		{
			if (!Directory.Exists(logFile.DirectoryName))
			{
				Directory.CreateDirectory(logFile.DirectoryName);
			}

			this.stream = new StreamWriter(logFile.FullName, true, Encoding.UTF8)
			{
				AutoFlush = true
			};
		}
	}
}
