using Produire;
using ResChanger;

namespace ResolutionChangerPlugin
{
	// Library: Change Resolution Before Starting Application
	// - Source: https://www.codeproject.com/Tips/702664/Change-Resolution-Before-Starting-Application
	// - License: The Code Project Open License https://www.codeproject.com/info/cpol10.aspx

	public class 画面領域サイズ : IProduireStaticClass
	{
		[自分("を")]
		public string 変更する([へ] int[] 設定)
		{
			var res = new Resolution();
			var result = res.ChangeDisplaySettings(設定[0], 設定[1], 設定[2]);
			return result;
		}

		/*[自分("で")]
		public bool 確認する([を] int[] 設定)
		{
			var res = new Resolution();
			return res.IsDisplayModeSupported(設定[0], 設定[1]);
		}*/
	}
}
