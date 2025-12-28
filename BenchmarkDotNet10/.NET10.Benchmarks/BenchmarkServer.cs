using System.Net.WebSockets;

namespace Benchmarks
{
    public static class BenchmarkServer
    {
        private static IHost? _host;
        private static readonly object _lock = new();

        public static void Start()
        {
            lock (_lock)
            {
                if (_host != null) return;

                var builder = Host.CreateDefaultBuilder()
                    .ConfigureWebHostDefaults(webBuilder =>
                    {
                        webBuilder.UseUrls("http://localhost:5008");
                        webBuilder.Configure(app =>
                        {
                            app.UseWebSockets();
                            app.UseRouting();

                            app.UseEndpoints(endpoints =>
                            {
                                endpoints.Map("/benchmark/ws", async context =>
                                {
                                    if (context.WebSockets.IsWebSocketRequest)
                                    {
                                        using var ws = await context.WebSockets.AcceptWebSocketAsync();
                                        var buffer = new byte[1024 * 64];
                                        while (ws.State == WebSocketState.Open)
                                        {
                                            try 
                                            {
                                                var result = await ws.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                                                if (result.MessageType == WebSocketMessageType.Close)
                                                {
                                                    await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closed", CancellationToken.None);
                                                }
                                                else
                                                {
                                                    // Echo back
                                                    await ws.SendAsync(new ArraySegment<byte>(buffer, 0, result.Count), result.MessageType, result.EndOfMessage, CancellationToken.None);
                                                }
                                            }
                                            catch (Exception)
                                            {
                                                break;
                                            }
                                        }
                                    }
                                    else
                                    {
                                        context.Response.StatusCode = 400;
                                    }
                                });

                                endpoints.MapGet("/benchmark/noop", async context => 
                                {
                                    context.Response.StatusCode = 200;
                                    await context.Response.CompleteAsync();
                                });

                                endpoints.MapPost("/benchmark/upload", async context =>
                                {
                                    if (!context.Request.HasFormContentType)
                                    {
                                        context.Response.StatusCode = 400;
                                        return;
                                    }

                                    var form = await context.Request.ReadFormAsync();
                                    var file = form.Files["file"];
                                    
                                    if (file != null)
                                    {
                                        using var stream = file.OpenReadStream();
                                        await stream.CopyToAsync(Stream.Null);
                                        context.Response.StatusCode = 200;
                                    }
                                    else
                                    {
                                        context.Response.StatusCode = 400;
                                    }
                                });
                            });
                        });
                        
                        webBuilder.ConfigureLogging(logging => logging.ClearProviders());
                    });

                _host = builder.Build();
                _host.Start();
            }
        }

        public static void Stop()
        {
            lock (_lock)
            {
                if (_host != null)
                {
                    _host.StopAsync().Wait();
                    _host.Dispose();
                    _host = null;
                }
            }
        }
    }
}
