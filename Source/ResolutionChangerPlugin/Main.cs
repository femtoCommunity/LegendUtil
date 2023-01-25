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
		public bool 変更する([へ] int[] 大きさ)
		{
			var res = new Resolution();
			var result = res.ChangeDisplaySettings(大きさ[0], 大きさ[1], 大きさ[2]);
			return result;
		}
	}
}
