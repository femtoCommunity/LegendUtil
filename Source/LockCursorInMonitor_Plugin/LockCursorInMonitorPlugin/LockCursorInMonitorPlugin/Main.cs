using Produire; // utopiat.Host.dllを参照すること

/*
========== Source: https://github.com/Eliasyoussef47/LockCursorInMonitor ==========
*/

namespace LockCursorInMonitorPlugin
{
	// 静的種類の例
	public class マウスカーソルロッカー : IProduireStaticClass // これを実装しないとプロデルから利用できない
	{
		// 手順
		[自分("で")]
		public void ロックする()
		{
			LockCursorInMonitor.CursorLock.LockCursor();
		}

		[自分("で")]
		public void ロック解除する()
		{
			LockCursorInMonitor.CursorLock.UnlockCursor();
		}

		public bool ロック中
		{
			get
			{
				return LockCursorInMonitor.CursorLock.Locked;
			}
		}
	}
}