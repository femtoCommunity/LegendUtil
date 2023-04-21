using Produire;
using System;
using System.Drawing;
using System.Runtime.InteropServices;

namespace LegendUtil.SharpLibrary
{
	namespace WindowCaptureHelper
	{
		public class ウィンドウキャプチャー : IProduireStaticClass
		{
			[自分で]
			public Bitmap キャプチャーする([を] IntPtr ウィンドウハンドル)
			{
				// ウィンドウのサイズを取得する
				RECT rect;
				GetWindowRect(ウィンドウハンドル, out rect);

				int width = rect.Right - rect.Left;
				int height = rect.Bottom - rect.Top;

				// ウィンドウをキャプチャーする
				Bitmap img = new Bitmap(width, height);
				Graphics g = Graphics.FromImage(img);
				IntPtr dc = g.GetHdc();
				PrintWindow(ウィンドウハンドル, dc, 0);
				g.ReleaseHdc(dc);
				g.Dispose();
				
				// キャプチャーしたビットマップを返す
				return img;
			}
			
			[DllImport("user32.dll")]
			private static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);

			[DllImport("user32.dll")]
			private extern static bool PrintWindow(IntPtr hwnd, IntPtr hDC, uint nFlags);

			[StructLayout(LayoutKind.Sequential)]
			private struct RECT
			{
				public int Left; public int Top; public int Right; public int Bottom;
			}
		}
	}
}
