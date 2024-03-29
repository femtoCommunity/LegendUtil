﻿using Produire;
using NetInfo = System.Net.NetworkInformation;

namespace LegendUtil.SharpLibrary
{
	namespace PingUtil
	{
		public class Ping : IProduireStaticClass
		{
			NetInfo.Ping pingSender = new NetInfo.Ping();
			NetInfo.PingOptions options = new NetInfo.PingOptions();

			[自分で]
			public long レイテンシー取得する([から] string アドレス)
			{
				NetInfo.PingReply reply = pingSender.Send(アドレス);
				if (reply.Status == NetInfo.IPStatus.Success)
				{
					return reply.RoundtripTime;
				}
				else
				{
					return -1;
				}
			}
		}
	}
}
