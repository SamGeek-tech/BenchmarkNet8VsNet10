using BenchmarkDotNet.Attributes;
using System.Threading.Tasks;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class ImageProcessingBenchmarks
    {
        private byte[] _source;
        private byte[] _destination;
        private const int Width = 3840;
        private const int Height = 2160;

        [GlobalSetup]
        public void Setup()
        {
            _source = new byte[Width * Height];
            _destination = new byte[Width * Height];
            new Random(42).NextBytes(_source);
        }

        [Benchmark]
        public void Convolution3x3() => Convolve(3);

        [Benchmark]
        public void Convolution5x5() => Convolve(5);

        [Benchmark]
        public void Convolution7x7() => Convolve(7);

        private void Convolve(int kernelSize)
        {
            int offset = kernelSize / 2;
            Parallel.For(offset, Height - offset, y =>
            {
                for (int x = offset; x < Width - offset; x++)
                {
                    int sum = 0;
                    for (int ky = -offset; ky <= offset; ky++)
                    {
                        for (int kx = -offset; kx <= offset; kx++)
                        {
                            sum += _source[(y + ky) * Width + (x + kx)];
                        }
                    }
                    _destination[y * Width + x] = (byte)(sum / (kernelSize * kernelSize));
                }
            });
        }
    }
}
