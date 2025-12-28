using BenchmarkDotNet.Attributes;
using System.Net.WebSockets;
using System.Text;

namespace Benchmarks
{
    [MemoryDiagnoser]
    public class WebSocketBenchmarks
    {
        private const string WsUrl = "ws://localhost:5008/benchmark/ws";
        private byte[] _smallPayload;
        private byte[] _mediumPayload;
        private byte[] _largePayload;
        private string _textMessage;

        [GlobalSetup]
        public void Setup()
        {
            BenchmarkServer.Start();
            
            _smallPayload = new byte[256];        // 256 bytes
            _mediumPayload = new byte[4096];      // 4 KB
            _largePayload = new byte[65536];      // 64 KB
            
            new Random(42).NextBytes(_smallPayload);
            new Random(42).NextBytes(_mediumPayload);
            new Random(42).NextBytes(_largePayload);
            
            _textMessage = new string('A', 1024); // 1 KB text
        }

        [GlobalCleanup]
        public void Cleanup()
        {
            BenchmarkServer.Stop();
        }

        [Benchmark]
        public async Task SmallMessageEcho()
        {
            using var ws = new ClientWebSocket();
            await ws.ConnectAsync(new Uri(WsUrl), CancellationToken.None);

            var segment = new ArraySegment<byte>(_smallPayload);
            var receiveBuffer = new byte[_smallPayload.Length];
            var receiveSegment = new ArraySegment<byte>(receiveBuffer);

            for (int i = 0; i < 100; i++)
            {
                await ws.SendAsync(segment, WebSocketMessageType.Binary, true, CancellationToken.None);
                await ws.ReceiveAsync(receiveSegment, CancellationToken.None);
            }

            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Done", CancellationToken.None);
        }

        [Benchmark]
        public async Task MediumMessageEcho()
        {
            using var ws = new ClientWebSocket();
            await ws.ConnectAsync(new Uri(WsUrl), CancellationToken.None);

            var segment = new ArraySegment<byte>(_mediumPayload);
            var receiveBuffer = new byte[_mediumPayload.Length];
            var receiveSegment = new ArraySegment<byte>(receiveBuffer);

            for (int i = 0; i < 50; i++)
            {
                await ws.SendAsync(segment, WebSocketMessageType.Binary, true, CancellationToken.None);
                await ws.ReceiveAsync(receiveSegment, CancellationToken.None);
            }

            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Done", CancellationToken.None);
        }

        [Benchmark]
        public async Task LargeMessageEcho()
        {
            using var ws = new ClientWebSocket();
            await ws.ConnectAsync(new Uri(WsUrl), CancellationToken.None);

            var segment = new ArraySegment<byte>(_largePayload);
            var receiveBuffer = new byte[_largePayload.Length];
            var receiveSegment = new ArraySegment<byte>(receiveBuffer);

            for (int i = 0; i < 10; i++)
            {
                await ws.SendAsync(segment, WebSocketMessageType.Binary, true, CancellationToken.None);
                await ws.ReceiveAsync(receiveSegment, CancellationToken.None);
            }

            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Done", CancellationToken.None);
        }

        [Benchmark]
        public async Task TextMessageEcho()
        {
            using var ws = new ClientWebSocket();
            await ws.ConnectAsync(new Uri(WsUrl), CancellationToken.None);

            var bytes = Encoding.UTF8.GetBytes(_textMessage);
            var segment = new ArraySegment<byte>(bytes);
            var receiveBuffer = new byte[bytes.Length];
            var receiveSegment = new ArraySegment<byte>(receiveBuffer);

            for (int i = 0; i < 100; i++)
            {
                await ws.SendAsync(segment, WebSocketMessageType.Text, true, CancellationToken.None);
                await ws.ReceiveAsync(receiveSegment, CancellationToken.None);
            }

            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Done", CancellationToken.None);
        }

        [Benchmark]
        public async Task ConnectionOverhead()
        {
            // Measure connection/disconnection overhead
            for (int i = 0; i < 10; i++)
            {
                using var ws = new ClientWebSocket();
                await ws.ConnectAsync(new Uri(WsUrl), CancellationToken.None);
                await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Done", CancellationToken.None);
            }
        }

        [Benchmark]
        public async Task FragmentedMessage()
        {
            using var ws = new ClientWebSocket();
            await ws.ConnectAsync(new Uri(WsUrl), CancellationToken.None);

            var chunk1 = new ArraySegment<byte>(_smallPayload, 0, 128);
            var chunk2 = new ArraySegment<byte>(_smallPayload, 128, 128);
            var receiveBuffer = new byte[_smallPayload.Length];
            var receiveSegment = new ArraySegment<byte>(receiveBuffer);

            for (int i = 0; i < 50; i++)
            {
                // Send fragmented message
                await ws.SendAsync(chunk1, WebSocketMessageType.Binary, false, CancellationToken.None);
                await ws.SendAsync(chunk2, WebSocketMessageType.Binary, true, CancellationToken.None);
                
                // Receive complete message
                await ws.ReceiveAsync(receiveSegment, CancellationToken.None);
            }

            await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Done", CancellationToken.None);
        }

        [Benchmark]
        public async Task ConcurrentConnections()
        {
            var tasks = new Task[10];
            
            for (int i = 0; i < 10; i++)
            {
                tasks[i] = Task.Run(async () =>
                {
                    using var ws = new ClientWebSocket();
                    await ws.ConnectAsync(new Uri(WsUrl), CancellationToken.None);

                    var segment = new ArraySegment<byte>(_smallPayload);
                    var receiveBuffer = new byte[_smallPayload.Length];
                    var receiveSegment = new ArraySegment<byte>(receiveBuffer);

                    for (int j = 0; j < 10; j++)
                    {
                        await ws.SendAsync(segment, WebSocketMessageType.Binary, true, CancellationToken.None);
                        await ws.ReceiveAsync(receiveSegment, CancellationToken.None);
                    }

                    await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Done", CancellationToken.None);
                });
            }

            await Task.WhenAll(tasks);
        }
    }
}
