using OpenCvSharp;
using Produire;
using System.Drawing;
using System.Linq;

namespace LegendUtil.SharpLibrary
{
	namespace ImageProcessingHelper
	{
		public class 画像処理 : IProduireStaticClass
		{
			[自分で]
			public float 類似度取得する([から] Bitmap[] 対象画像)
			{
				using (var mat1 = OpenCvSharp.Extensions.BitmapConverter.ToMat(対象画像[0]))
				using (var mat2 = OpenCvSharp.Extensions.BitmapConverter.ToMat(対象画像[1]))
				using (var des1 = new Mat())
				using (var des2 = new Mat())
				{
					var akaze = AKAZE.Create();

					akaze.DetectAndCompute(mat1, null, out KeyPoint[] keyPoints1, des1);
					akaze.DetectAndCompute(mat2, null, out KeyPoint[] keyPoints2, des2);

					var matcher = new BFMatcher(NormTypes.Hamming, false);
					var matches = matcher.Match(des1, des2);

					var sum = matches.Sum(x => x.Distance);
					return sum / matches.Length;
				}
			}
		}
	}
}
