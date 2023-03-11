using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using LegendUtil_DisplayDeviceHelper;

namespace ExDisplayPlugin_Test
{
	internal class Program
	{
		[DllImport("User32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern Boolean EnumDisplaySettings(
			string lpszDeviceName,
			[param: MarshalAs(UnmanagedType.U4)] int iModeNum,
			[In, Out] ref DEVMODE lpDevMode);

		static void Main(string[] args)
		{
			//PrintDisplayResolutions();
			//PrintDisplays();
			PrintDisplaySettings();
			Console.ReadKey();
		}

		static void PrintDisplaySettings()
		{
			var mode = new DEVMODE();
			mode.dmSize = (short)Marshal.SizeOf(mode);
			DisplayManager.EnumDisplaySettings(@"\\.\DISPLAY1", -1, ref mode);

			Type type = typeof(DEVMODE);
			System.Reflection.FieldInfo[] fi = type.GetFields();

			foreach (var f in fi)
			{
				Console.WriteLine($"{f.Name}:{f.GetValue(mode)}");
			}
		}

		static void PrintDisplayResolutions(){
			Console.WriteLine("Display Resolutions");

			var mode = new DEVMODE();
			mode.dmSize = (short)Marshal.SizeOf(mode);

			string deviceName = null; 
			deviceName = @"\\.\DISPLAY1";
			var modeIndex = 0; // 0 = The first mode
			var supportedModes = string.Empty;
			var previousSupportedMode = string.Empty;

			while (EnumDisplaySettings(deviceName,
				modeIndex,
				ref mode)) // Mode found
			{
				Console.WriteLine(mode.dmPelsWidth + "x" + mode.dmPelsHeight + " - " + mode.dmDisplayFrequency + " Hz");
				/*if (mode.dmPelsWidth == (uint)width && mode.dmPelsHeight == (uint)height)
					return true;

				var newSupportedMode = mode.dmPelsWidth + "x" + mode.dmPelsHeight;
				if (newSupportedMode != previousSupportedMode)
				{
					if (supportedModes == string.Empty)
						supportedModes += newSupportedMode;
					else
						supportedModes += ", " + newSupportedMode;

					previousSupportedMode = newSupportedMode;
				}*/

				modeIndex++; // The next mode
			}
		}

		static void PrintDisplays(){
			Console.WriteLine("Display Devices");

			var list = new List<DISPLAY_DEVICE>();
			DISPLAY_DEVICE d = new DISPLAY_DEVICE();
			d.cb = Marshal.SizeOf(d);
			try
			{
				for (uint id = 0; DisplayManager.EnumDisplayDevices(null, id, ref d, 0); id++)
				{
					list.Add(d);
					d.cb = Marshal.SizeOf(d);
				}
			}
			catch
			{
				for (int i = 0; i < list.Count; i++)
				{
					Console.WriteLine("ID: " + i);
					Console.WriteLine("- DeviceName: " + list[i].DeviceName);
					Console.WriteLine("- DeviceString: " + list[i].DeviceString);
					Console.WriteLine("- DeviceKey: " + list[i].DeviceKey);
					Console.WriteLine("- DeviceID: " + list[i].DeviceID);
					Console.WriteLine("- StateFlags: " + list[i].StateFlags);
				}
			}
			for (int i = 0; i < list.Count; i++)
			{
				Console.WriteLine("ID: " + i);
				Console.WriteLine("- DeviceName: " + list[i].DeviceName);
				Console.WriteLine("- DeviceString: " + list[i].DeviceString);
				Console.WriteLine("- DeviceKey: " + list[i].DeviceKey);
				Console.WriteLine("- DeviceID: " + list[i].DeviceID);
				Console.WriteLine("- StateFlags: " + list[i].StateFlags);
			}
		}
	}

	static class Extensions
	{
		public static byte[] ToLPTStr(this string str)
		{
			var lptArray = new byte[str.Length + 1];

			var index = 0;
			foreach (char c in str.ToCharArray())
				lptArray[index++] = Convert.ToByte(c);

			lptArray[index] = Convert.ToByte('\0');

			return lptArray;
		}
	}
}
