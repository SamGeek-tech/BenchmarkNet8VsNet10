using BenchmarkDotNet.Attributes;
using System.Numerics;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class FftBenchmarks
    {
        private Complex[] _data;
        
        [Params(1024)] 
        public int N;

        [GlobalSetup]
        public void Setup()
        {
            _data = new Complex[N];
            var random = new Random(42);
            for (int i = 0; i < N; i++)
            {
                _data[i] = new Complex(random.NextDouble(), random.NextDouble());
            }
        }

        [Benchmark]
        public Complex[] NaiveDFT()
        {
            var result = new Complex[N];
            for (int k = 0; k < N; k++)
            {
                Complex sum = 0;
                for (int n = 0; n < N; n++)
                {
                    double angle = -2 * Math.PI * k * n / N;
                    sum += _data[n] * Complex.FromPolarCoordinates(1, angle);
                }
                result[k] = sum;
            }
            return result;
        }

        [Benchmark]
        public Complex[] CooleyTukeyFFT()
        {
            var data = (Complex[])_data.Clone();
            FFT(data);
            return data;
        }

        private void FFT(Complex[] buffer)
        {
            int n = buffer.Length;
            if (n <= 1) return;

            var even = new Complex[n / 2];
            var odd = new Complex[n / 2];
            for (int i = 0; i < n / 2; i++)
            {
                even[i] = buffer[2 * i];
                odd[i] = buffer[2 * i + 1];
            }

            FFT(even);
            FFT(odd);

            for (int k = 0; k < n / 2; k++)
            {
                Complex t = Complex.FromPolarCoordinates(1, -2 * Math.PI * k / n) * odd[k];
                buffer[k] = even[k] + t;
                buffer[k + n / 2] = even[k] - t;
            }
        }
    }
}
