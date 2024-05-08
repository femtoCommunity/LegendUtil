using NvAPIWrapper;
using NvAPIWrapper.Display;
using NvAPIWrapper.GPU;
using NvAPIWrapper.Native.Display;
using NvAPIWrapper.Native.Display.Structures;
using Produire;
using System.Linq;

namespace LegendUtil.SharpLibrary
{
	namespace NvAPIWrapperWrapper
	{
		public class NvAPI : IProduireStaticClass
		{
			public Display[] ディスプレイ一覧
			{
				get { return Display.GetDisplays(); }
			}

			public PhysicalGPU[] GPU一覧
			{
				get { return PhysicalGPU.GetPhysicalGPUs(); }
			}

			public string チップセット名
			{
				get { return NVIDIA.ChipsetInfo.ChipsetName; }
			}

			public int チップセットデバイスID
			{
				get { return NVIDIA.ChipsetInfo.DeviceId; }
			}

			public string チップセットベンダー名
			{
				get { return NVIDIA.ChipsetInfo.VendorName; }
			}

			public uint チップセットドライバーバージョン
			{
				get { return NVIDIA.DriverVersion; }
			}
		}

		[対応型(typeof(PhysicalGPU))]
		public class NVIDIA物理GPU : ClassWarpper<PhysicalGPU>
		{
			/// <summary>
			/// GPUの名前 (例: NVIDIA GeForce RTX 3070)
			/// </summary>
			public string 名前 => baseObject.FullName;
			public uint GPUID => baseObject.GPUId;
			/// <summary>
			/// GPUの種類 (例: Discrete)
			/// </summary>
			public object GPUタイプ => baseObject.GPUType;
			/// <summary>
			/// GPUに接続されているディスプレイデバイスの一覧
			/// </summary>
			public DisplayDevice[] ディスプレイデバイス一覧 => baseObject.GetDisplayDevices();
		}

		[対応型(typeof(Display))]
		public class NVIDIAディスプレイ : ClassWarpper<Display>
		{
			/// <summary>
			/// ディスプレイの名前 (例: \\.\DISPLAY1)
			/// </summary>
			public string 名前 => baseObject.Name;
			/// <summary>
			/// ドライバーのビルド情報
			/// </summary>
			public string ドライバービルドタイトル => baseObject.DriverBuildTitle;
			/// <summary>
			/// NVIDIAのディスプレイ情報
			/// </summary>
			public DisplayDevice ディスプレイデバイス => baseObject.DisplayDevice;
		}

		[列挙体(typeof(ColorFormat))]
		public enum NVIDIA色空間
		{
			不明 = ColorFormat.Unknown,
			P8 = ColorFormat.P8,
			R5G6B5 = ColorFormat.R5G6B5,
			A8R8G8B8 = ColorFormat.A8R8G8B8,
			A16B16G16R16F = ColorFormat.A16B16G16R16F
		}

		[対応型(typeof(CustomResolution))]
		public class NVIDIAカスタム解像度 : IProduireClass
		{
			CustomResolution CR;

			public NVIDIAカスタム解像度(uint 幅, uint 高さ, Timing タイミング, [省略] float 横比率 = 1f, [省略] float 縦比率 = 1f, [省略] ColorFormat 色空間 = ColorFormat.Unknown)
			{
				CR = new CustomResolution(幅, 高さ, 色空間, タイミング, 横比率, 縦比率);
			}

			public uint 幅 => CR.Width;
			public uint 高さ => CR.Height;
			public uint 色深度 => CR.ColorDepth;
			public ColorFormat 色空間 => CR.ColorFormat;
			public Timing タイミング => CR.Timing;
			public float 横比率 => CR.XRatio;
			public float 縦比率 => CR.YRatio;
		}

		[対応型(typeof(DisplayDevice))]
		public class NVIDIAディスプレイデバイス : ClassWarpper<DisplayDevice>
		{
			public bool 利用可能 => baseObject.IsAvailable;
			public bool 有効 => baseObject.IsActive;
			public bool 接続済み => baseObject.IsConnected;
			public uint ディスプレイID => baseObject.DisplayId;
			public Timing タイミング => baseObject.CurrentTiming;

			/// <summary>
			/// 保存されているカスタム解像度の一覧
			/// </summary>
			public CustomResolution[] カスタム解像度一覧
			{
				get { return baseObject.GetCustomResolutions().ToArray(); }
			}

			/// <summary>
			/// カスタム解像度のテストを開始する
			/// </summary>
			[自分で]
			public void カスタム解像度テスト開始する([として] float[] 設定)
			{
				CustomResolution CR = new CustomResolution((uint)設定[0], (uint)設定[1], (uint)設定[2], baseObject.CurrentTiming, 設定[3], 設定[4]);
				baseObject.TrialCustomResolution(CR);
			}

			/// <summary>
			/// カスタム解像度のテストを終了する
			/// </summary>
			[自分で]
			public void カスタム解像度テスト終了する()
			{
				baseObject.RevertCustomResolution();
			}

			/// <summary>
			/// テスト中のカスタム解像度を保存する
			/// </summary>
			[自分で]
			public void カスタム解像度解像度保存する([として] float[] 設定)
			{
				baseObject.SaveCustomResolution();
			}

			/// <summary>
			/// 指定されたカスタム解像度を削除する
			/// </summary>
			[自分で]
			public void カスタム解像度削除する([として] CustomResolution カスタム解像度)
			{
				baseObject.DeleteCustomResolution(カスタム解像度);
			}
		}
	}
}
