using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace ResChanger
{
	#region Struct Pointl
	[StructLayout(LayoutKind.Sequential)]
	public struct Pointl
	{
		[MarshalAs(UnmanagedType.I4)]
		public int x;
		[MarshalAs(UnmanagedType.I4)]
		public int y;
	}
	#endregion

	#region Struct Devmode
	[StructLayout(LayoutKind.Sequential,
		CharSet = CharSet.Ansi)]
	public struct Devmode
	{
		// You can define the following constant
		// but OUTSIDE the structure because you know
		// that size and layout of the structure
		// is very important
		// CCHDEVICENAME = 32 = 0x50
		[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
		public string dmDeviceName;
		// In addition you can define the last character array
		// as following:
		//[MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)]
		//public Char[] dmDeviceName;

		// After the 32-bytes array
		[MarshalAs(UnmanagedType.U2)]
		public UInt16 dmSpecVersion;

		[MarshalAs(UnmanagedType.U2)]
		public UInt16 dmDriverVersion;

		[MarshalAs(UnmanagedType.U2)]
		public UInt16 dmSize;

		[MarshalAs(UnmanagedType.U2)]
		public UInt16 dmDriverExtra;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmFields;

		public Pointl dmPosition;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmDisplayOrientation;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmDisplayFixedOutput;

		[MarshalAs(UnmanagedType.I2)]
		public Int16 dmColor;

		[MarshalAs(UnmanagedType.I2)]
		public Int16 dmDuplex;

		[MarshalAs(UnmanagedType.I2)]
		public Int16 dmYResolution;

		[MarshalAs(UnmanagedType.I2)]
		public Int16 dmTTOption;

		[MarshalAs(UnmanagedType.I2)]
		public Int16 dmCollate;

		// CCHDEVICENAME = 32 = 0x50
		[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
		public string dmFormName;
		// Also can be defined as
		//[MarshalAs(UnmanagedType.ByValArray,
		//    SizeConst = 32, ArraySubType = UnmanagedType.U1)]
		//public Byte[] dmFormName;

		[MarshalAs(UnmanagedType.U2)]
		public UInt16 dmLogPixels;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmBitsPerPel;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmPelsWidth;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmPelsHeight;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmDisplayFlags;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmDisplayFrequency;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmICMMethod;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmICMIntent;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmMediaType;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmDitherType;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmReserved1;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmReserved2;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmPanningWidth;

		[MarshalAs(UnmanagedType.U4)]
		public UInt32 dmPanningHeight;
	}
	#endregion

	internal class Resolution
	{
		#region Fields
		private static Devmode _oldDevmode;
		#endregion

		#region Consts
		private const int EnumCurrentSettings = -1;     // Retrieves the current display mode.
		private const int DispChangeSuccessful = 0;     // Indicates that the function succeeded.
		private const int DispChangeBadmode = -2;       // The graphics mode is not supported.
		private const int DispChangeRestart = 1;        // The computer must be restarted 
														// for the graphics mode to work.
		#endregion

		#region DllImport
		[DllImport("User32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		private static extern Boolean EnumDisplaySettings(
			[param: MarshalAs(UnmanagedType.LPTStr)] string lpszDeviceName,
			[param: MarshalAs(UnmanagedType.U4)] int iModeNum,
			[In, Out] ref Devmode lpDevMode);

		[DllImport("User32.dll")]
		[return: MarshalAs(UnmanagedType.I4)]
		private static extern int ChangeDisplaySettings(
			[In, Out] ref Devmode lpDevMode,
			[param: MarshalAs(UnmanagedType.U4)] uint dwflags);
		#endregion

		#region IsDisplayModeSupported
		/// <summary>
		/// Checks if the given display mode is supported
		/// </summary>
		/// <param name="width" />
		/// <param name="height" />
		/// <param name="supportedModes" />
		/// <returns>
		public bool IsDisplayModeSupported(int width, int height, out string supportedModes)
		{
			var mode = new Devmode();
			mode.dmSize = (ushort)Marshal.SizeOf(mode);

			var modeIndex = 0; // 0 = The first mode
			supportedModes = string.Empty;
			var previousSupportedMode = string.Empty;

			while (EnumDisplaySettings(null,
				modeIndex,
				ref mode)) // Mode found
			{
				if (mode.dmPelsWidth == (uint)width && mode.dmPelsHeight == (uint)height)
					return true;

				var newSupportedMode = mode.dmPelsWidth + "x" + mode.dmPelsHeight;
				if (newSupportedMode != previousSupportedMode)
				{
					if (supportedModes == string.Empty)
						supportedModes += newSupportedMode;
					else
						supportedModes += ", " + newSupportedMode;

					previousSupportedMode = newSupportedMode;
				}

				modeIndex++; // The next mode
			}

			return false;
		}
		#endregion

		#region ChangeDisplaySettings
		/// <summary>
		/// Changes the display settings
		/// </summary>
		/// <param name="width" />
		/// <param name="height" />
		public string ChangeDisplaySettings(int width, int height, int frequency)
		{
			_oldDevmode = new Devmode();
			_oldDevmode.dmSize = (ushort)Marshal.SizeOf(_oldDevmode);

			// Retrieving current settings
			// to edit them
			EnumDisplaySettings(null,
				EnumCurrentSettings,
				ref _oldDevmode);

			// Making a copy of the current settings
			// to allow reseting to the original mode
			var newMode = _oldDevmode;

			// Changing the settings
			newMode.dmPelsWidth = (uint)width;
			newMode.dmPelsHeight = (uint)height;
			newMode.dmDisplayFrequency = (uint)frequency;

			// Capturing the operation result, 1 = update registry
			var result =
				ChangeDisplaySettings(ref newMode, 1);

			switch (result)
			{
				case DispChangeSuccessful:
					return "Successful";

				case DispChangeBadmode:
					//MessageBox.Show("Mode not supported.");
					return "Mode not supported.";

				case DispChangeRestart:
					//MessageBox.Show("Restart required.");
					return "Restart required.";

				default:
					//MessageBox.Show("Failed. Error code = " + result);
					return "Failed. Error code = " + result;
			}
		}
		#endregion

		#region RestoreDisplaySettings
		/// <summary>
		/// Restores the old display settings
		/// </summary>
		public void RestoreDisplaySettings()
		{
			ChangeDisplaySettings(ref _oldDevmode, 1);
		}
		#endregion
	}
}
