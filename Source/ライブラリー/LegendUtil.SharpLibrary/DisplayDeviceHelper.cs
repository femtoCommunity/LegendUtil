using Produire;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace LegendUtil.SharpLibrary
{
	namespace DisplayDeviceHelper
	{
		public class ディスプレイ管理器 : IProduireStaticClass
		{
			[自分("で")]
			public DISP_CHANGE 設定する([へ] string デバイス名, [を] int[] 設定, [省略][として] ChangeDisplaySettingsFlags フラグ = ChangeDisplaySettingsFlags.CDS_UPDATEREGISTRY)
			{
				if (設定.Length < 3)
				{
					throw new ProduireException("引数 設定 の値が不正です。\n{幅, 高さ, リフレッシュレート, ディスプレイ固定フラグ} という形式で指定してください。");
				}

				if (設定が存在する(デバイス名, 設定) == false)
				{
					return DISP_CHANGE.BadMode;
				}

				int dw = 設定[0];
				int dh = 設定[1];
				int df = 設定[2];
				int dfx = 0;

				if (設定.Length >= 4)
				{
					dfx = 設定[3];
				}

				// デバイスモード(変数)を作成
				var mode = new DEVMODE();
				mode.dmSize = (short)Marshal.SizeOf(mode);

				// 現在のディスプレイ設定を取得する
				DisplayManager.EnumDisplaySettings(デバイス名, -1, ref mode);

				mode.dmPelsWidth = dw;
				mode.dmPelsHeight = dh;
				mode.dmDisplayFrequency = df;
				mode.dmDisplayFixedOutput = dfx;
				//mode.dmFields = mode.dmPelsWidth | mode.dmPelsHeight | mode.dmDisplayFrequency;

				// ディスプレイ設定の変更を実行
				var result = DisplayManager.ChangeDisplaySettingsEx(デバイス名, ref mode, IntPtr.Zero, フラグ, IntPtr.Zero);

				return result;
			}

			//[自分("で")]
			public bool 設定が存在する([へ] string デバイス名, [という] int[] 設定)
			{
				if (設定.Length < 3)
				{
					throw new ProduireException("引数 設定 の値が不正です。\n{幅, 高さ, リフレッシュレート} という形式で指定してください。");
				}

				int dw = 設定[0];
				int dh = 設定[1];
				int df = 設定[2];

				int modeIndex = 0;
				var supportedModes = string.Empty;
				var previousSupportedMode = string.Empty;

				var mode = new DEVMODE();
				mode.dmSize = (short)Marshal.SizeOf(mode);

				while (DisplayManager.EnumDisplaySettings(デバイス名,
					modeIndex,
					ref mode))
				{
					if (mode.dmPelsWidth == (uint)dw && mode.dmPelsHeight == (uint)dh && mode.dmDisplayFrequency == (uint)df)
						return true;

					var newSupportedMode = mode.dmPelsWidth + "x" + mode.dmPelsHeight + "@" + mode.dmDisplayFrequency + "Hz";
					if (newSupportedMode != previousSupportedMode)
					{
						if (supportedModes == string.Empty)
							supportedModes += newSupportedMode;
						else
							supportedModes += ", " + newSupportedMode;

						previousSupportedMode = newSupportedMode;
					}

					modeIndex++;
				}

				return false;
			}

			public DISPLAY_DEVICE[] 一覧
			{
				get
				{
					var list = new List<DISPLAY_DEVICE>();
					DISPLAY_DEVICE d = new DISPLAY_DEVICE();
					d.cb = Marshal.SizeOf(d);
					try
					{
						for (uint id = 0; DisplayManager.EnumDisplayDevices(null, id, ref d, 0); id++)
						{
							list.Add(new DISPLAY_DEVICE());
							d.cb = Marshal.SizeOf(d);
						}
					}
					catch
					{
						return list.ToArray();
					}
					return list.ToArray();
				}
			}
		}

		/*[対応型(typeof(DEVMODE))]
		public class デバイス情報 : ClassWarpper<DEVMODE>
		{
			public string デバイス名 => baseObject.dmDeviceName;
			public int バージョン番号 => baseObject.dmSpecVersion;
			public int ドライバーバージョン => baseObject.dmDriverVersion;
			public int カラー解像度 => baseObject.dmBitsPerPel;
			public int 幅 => baseObject.dmPelsWidth;
			public int 高さ => baseObject.dmPelsHeight;
			public int 周波数 => baseObject.dmDisplayFrequency;

		}*/

		[対応型(typeof(DISPLAY_DEVICE))]
		public class ディスプレイデバイス : ClassWarpper<DISPLAY_DEVICE>
		{
			public ディスプレイデバイス()
			{

			}
			public string 名前 => baseObject.DeviceName;
			public string デバイス文字列 => baseObject.DeviceString;
			public DisplayDeviceStateFlags 状態 => baseObject.StateFlags;
			public string ID => baseObject.DeviceID;
			public string キー => baseObject.DeviceKey;

			/*[自分("へ")]
			public DISP_CHANGE 設定する([を] int[] 設定)
			{
				DISPLAY_DEVICE d = new DISPLAY_DEVICE();
				DEVMODE dm = new DEVMODE();
				d.cb = Marshal.SizeOf(d);

				dm.dmPelsWidth = 設定[0];
				dm.dmPelsHeight = 設定[1];
				dm.dmDisplayFrequency = 設定[2];

				var result = DisplayManager.ChangeDisplaySettingsEx(baseObject.DeviceName, ref dm, IntPtr.Zero, ChangeDisplaySettingsFlags.CDS_UPDATEREGISTRY, IntPtr.Zero);
				return result;
			}*/
		}
		[StructLayout(LayoutKind.Sequential)]
		public struct DISPLAY_DEVICE
		{
			[MarshalAs(UnmanagedType.U4)]
			public int cb;
			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
			public string DeviceName;
			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
			public string DeviceString;
			[MarshalAs(UnmanagedType.U4)]
			public DisplayDeviceStateFlags StateFlags;
			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
			public string DeviceID;
			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
			public string DeviceKey;
		}

		public class DisplayManager
		{
			[DllImport("user32.dll")]
			public static extern DISP_CHANGE ChangeDisplaySettings(ref DEVMODE devMode, int flags);

			[DllImport("user32.dll")]
			public static extern DISP_CHANGE ChangeDisplaySettingsEx(string lpszDeviceName, ref DEVMODE lpDevMode, IntPtr hwnd, ChangeDisplaySettingsFlags dwflags, IntPtr lParam);

			[DllImport("User32.dll")]
			[return: MarshalAs(UnmanagedType.Bool)]
			public static extern bool EnumDisplaySettings(string lpszDeviceName, [param: MarshalAs(UnmanagedType.U4)] int iModeNum, [In, Out] ref DEVMODE lpDevMode);

			[DllImport("user32.dll")]
			public static extern bool EnumDisplaySettingsEx(string lpszDeviceName, uint iModeNum, out DEVMODE lpDevMode, uint dwFlags);

			[DllImport("user32.dll")]
			public static extern bool EnumDisplayDevices(string lpDevice, uint iDevNum, ref DISPLAY_DEVICE lpDisplayDevice, uint dwFlags);
		}

		public enum DISP_CHANGE : int
		{
			Successful = 0,
			Restart = 1,
			Failed = -1,
			BadMode = -2,
			NotUpdated = -3,
			BadFlags = -4,
			BadParam = -5,
			BadDualView = -6
		}
		[列挙体(typeof(DISP_CHANGE))]
		public enum ディスプレイ設定変更結果
		{
			成功 = DISP_CHANGE.Successful,
			再起動が必要 = DISP_CHANGE.Restart,
			失敗 = DISP_CHANGE.Failed,
			不正な設定 = DISP_CHANGE.BadMode,
			未変更 = DISP_CHANGE.NotUpdated,
			不正なフラグ = DISP_CHANGE.BadFlags,
			不正なパラメーター = DISP_CHANGE.BadParam,
			不正なデュアルビュー = DISP_CHANGE.BadDualView
		}

		[Flags()]
		public enum ChangeDisplaySettingsFlags : uint
		{
			CDS_NONE = 0,
			CDS_UPDATEREGISTRY = 0x00000001,
			CDS_TEST = 0x00000002,
			CDS_FULLSCREEN = 0x00000004,
			CDS_GLOBAL = 0x00000008,
			CDS_SET_PRIMARY = 0x00000010,
			CDS_VIDEOPARAMETERS = 0x00000020,
			CDS_ENABLE_UNSAFE_MODES = 0x00000100,
			CDS_DISABLE_UNSAFE_MODES = 0x00000200,
			CDS_RESET = 0x40000000,
			CDS_RESET_EX = 0x20000000,
			CDS_NORESET = 0x10000000
		}
		[列挙体(typeof(ChangeDisplaySettingsFlags))]
		public enum ディスプレイ設定変更フラグ : uint
		{
			無し = ChangeDisplaySettingsFlags.CDS_NONE,
			レジストリー更新 = ChangeDisplaySettingsFlags.CDS_UPDATEREGISTRY,
			テスト = ChangeDisplaySettingsFlags.CDS_TEST,
			フルスクリーン = ChangeDisplaySettingsFlags.CDS_FULLSCREEN,
			グローバル = ChangeDisplaySettingsFlags.CDS_GLOBAL,
			プライマリー設定 = ChangeDisplaySettingsFlags.CDS_SET_PRIMARY,
			ビデオパラメーター = ChangeDisplaySettingsFlags.CDS_VIDEOPARAMETERS,
			アンセーフモード有効 = ChangeDisplaySettingsFlags.CDS_ENABLE_UNSAFE_MODES,
			アンセーフモード無効 = ChangeDisplaySettingsFlags.CDS_DISABLE_UNSAFE_MODES,
			リセット = ChangeDisplaySettingsFlags.CDS_RESET,
			リセットEX = ChangeDisplaySettingsFlags.CDS_RESET_EX,
			リセット無し = ChangeDisplaySettingsFlags.CDS_NORESET
		}

		[StructLayout(LayoutKind.Sequential)]
		public struct DEVMODE
		{
			private const int CCHDEVICENAME = 0x20;
			private const int CCHFORMNAME = 0x20;
			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 0x20)]
			public string dmDeviceName;
			public short dmSpecVersion;
			public short dmDriverVersion;
			public short dmSize;
			public short dmDriverExtra;
			public int dmFields;
			public int dmPositionX;
			public int dmPositionY;
			public ScreenOrientation dmDisplayOrientation;
			public int dmDisplayFixedOutput;
			public short dmColor;
			public short dmDuplex;
			public short dmYResolution;
			public short dmTTOption;
			public short dmCollate;
			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 0x20)]
			public string dmFormName;
			public short dmLogPixels;
			public int dmBitsPerPel;
			public int dmPelsWidth;
			public int dmPelsHeight;
			public int dmDisplayFlags;
			public int dmDisplayFrequency;
			public int dmICMMethod;
			public int dmICMIntent;
			public int dmMediaType;
			public int dmDitherType;
			public int dmReserved1;
			public int dmReserved2;
			public int dmPanningWidth;
			public int dmPanningHeight;
		}

		[Flags()]
		public enum DisplayDeviceStateFlags : int
		{
			/// <summary>The device is part of the desktop.</summary>
			AttachedToDesktop = 0x1,
			MultiDriver = 0x2,
			/// <summary>The device is part of the desktop.</summary>
			PrimaryDevice = 0x4,
			/// <summary>Represents a pseudo device used to mirror application drawing for remoting or other purposes.</summary>
			MirroringDriver = 0x8,
			/// <summary>The device is VGA compatible.</summary>
			VGACompatible = 0x10,
			/// <summary>The device is removable; it cannot be the primary display.</summary>
			Removable = 0x20,
			/// <summary>The device has more display modes than its output devices support.</summary>
			ModesPruned = 0x8000000,
			Remote = 0x4000000,
			Disconnect = 0x2000000
		}
		[列挙体(typeof(DisplayDeviceStateFlags))]
		public enum ディスプレイデバイス状態
		{
			無効 = 0,
			デスクトップ表示 = DisplayDeviceStateFlags.AttachedToDesktop,
			複数ドライバー = DisplayDeviceStateFlags.MultiDriver,
			メインディスプレイ = DisplayDeviceStateFlags.PrimaryDevice,
			疑似デバイス = DisplayDeviceStateFlags.MirroringDriver,
			VGA対応 = DisplayDeviceStateFlags.VGACompatible,
			取り外し可能 = DisplayDeviceStateFlags.Removable,
			上位表示モード存在 = DisplayDeviceStateFlags.ModesPruned,
			リモート = DisplayDeviceStateFlags.Remote,
			切断 = DisplayDeviceStateFlags.Disconnect
		}

		public enum DisplayFixedFlags : int
		{
			DMDFO_DEFAULT = 0,
			DMDFO_STRETCH = 1,
			DMDFO_CENTER = 2
		}
		[列挙体(typeof(DisplayFixedFlags))]
		public enum ディスプレイ固定フラグ : int
		{
			デフォルト = DisplayFixedFlags.DMDFO_DEFAULT,
			伸縮 = DisplayFixedFlags.DMDFO_STRETCH,
			中央 = DisplayFixedFlags.DMDFO_CENTER
		}
	}
}
