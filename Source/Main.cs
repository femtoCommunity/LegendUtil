using Produire;
using System;
using static ClipCursor.ClipCursor_Main;

namespace LockCursorInWindowPlugin
{
	public class カーソルロッカー : IProduireStaticClass
	{
		bool IsLocked = false;

		// 手順
		[自分("で")]
		public void ロックする([として] int ウィンドウハンドル)
		{
			IntPtr i = new IntPtr(ウィンドウハンドル);
			try
			{
				LockCursor(i);
				IsLocked = true;
			}
			catch (Exception ex)
			{
				throw new ProduireException(ex);
			}
		}

		[自分("で")]
		public void ロック解除する()
		{
			try
			{
				Locked = false;
				IsLocked = false;
			}
			catch (Exception ex)
			{
				throw new ProduireException(ex);
			}
		}

		public bool ロック中
		{
			get
			{
				return IsLocked;
			}
		}
	}
}
