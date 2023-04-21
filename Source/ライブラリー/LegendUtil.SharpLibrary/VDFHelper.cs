using Gameloop.Vdf;
using Gameloop.Vdf.JsonConverter;
using Gameloop.Vdf.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Produire;

namespace LegendUtil.SharpLibrary
{
	namespace VDFHelper
	{
		public class VDF形式 : IProduireStaticClass
		{
			[自分("として")]
			public string 読み取る([を] string 内容)
			{
				var vo = new VObject();
				var p = VdfConvert.Deserialize(内容);
				vo.Add(p);
				return vo.ToJson().ToString();
			}

			[自分("として")]
			public string 書き出す([を] string 内容)
			{
				var t = "";
				var j = JsonConvert.DeserializeObject<JToken>(内容);
				foreach (var item in j.ToVdf().Children())
				{
					t = t + item.ToString();
				}
				return t;
			}
		}
	}

}
