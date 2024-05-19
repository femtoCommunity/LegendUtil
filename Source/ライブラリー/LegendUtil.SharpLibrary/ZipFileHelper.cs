using Produire;
using System;
using System.IO.Compression;

namespace LegendUtil.SharpLibrary
{
	namespace ZipFileHelper
	{
		class アーカイブ管理器 : IProduireStaticClass
		{
			[自分で]
			public void 解凍する([を] string ファイル名, [へ] string 解凍先)
			{
				try
				{
					ZipFile.ExtractToDirectory(ファイル名, 解凍先);
				}
				catch (Exception ex)
				{
					throw new ProduireException(ex.ToString());
				}
			}
		}
	}
}
