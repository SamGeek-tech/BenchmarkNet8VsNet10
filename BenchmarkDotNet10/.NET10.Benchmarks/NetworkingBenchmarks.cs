using BenchmarkDotNet.Attributes;
using System.Net;
using System.Net.Http.Headers;
using System.Net.WebSockets;
using System.Text;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class NetworkingBenchmarks
    {
        private HttpClient _httpClient;
        private byte[] _uploadPayload;
        private const string BaseUrl = "http://localhost:5008"; // Using .NET 8 API for consistency in this test

        [GlobalSetup]
        public void Setup()
        {
            BenchmarkServer.Start(); // Ensure server is running
            
            _httpClient = new HttpClient { BaseAddress = new Uri(BaseUrl) };
            _httpClient.DefaultRequestVersion = HttpVersion.Version20;
            
            _uploadPayload = new byte[10 * 1024 * 1024]; // 10MB
            new Random(42).NextBytes(_uploadPayload);
        }

        [GlobalCleanup]
        public void Cleanup()
        {
            _httpClient.Dispose();
            BenchmarkServer.Stop();
        }

        [Benchmark]
        public async Task Http2Requests()
        {
            var tasks = new Task[100];
            for (int i = 0; i < 100; i++)
            {
                tasks[i] = _httpClient.GetAsync("/benchmark/noop");
            }
            await Task.WhenAll(tasks);
        }

        [Benchmark]
        public async Task WebSocketEcho()
        {
            using var ws = new ClientWebSocket();
            await ws.ConnectAsync(new Uri(BaseUrl.Replace("http", "ws") + "/benchmark/ws"), CancellationToken.None);

            var buffer = new byte[1024];
            var segment = new ArraySegment<byte>(buffer);
            
            for (int i = 0; i < 10; i++)
            {
                await ws.SendAsync(segment, WebSocketMessageType.Binary, true, CancellationToken.None);
                await ws.ReceiveAsync(segment, CancellationToken.None);
            }

            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Done", CancellationToken.None);
        }

        [Benchmark]
        public async Task FileUpload()
        {
            using var content = new MultipartFormDataContent();
            var fileContent = new ByteArrayContent(_uploadPayload);
            fileContent.Headers.ContentType = MediaTypeHeaderValue.Parse("application/octet-stream");
            content.Add(fileContent, "file", "test.bin");

            var response = await _httpClient.PostAsync("/benchmark/upload", content);
            response.EnsureSuccessStatusCode();
        }

        [Benchmark]
        public async Task DnsResolution()
        {
            await Dns.GetHostEntryAsync("localhost");
        }
    }
}
