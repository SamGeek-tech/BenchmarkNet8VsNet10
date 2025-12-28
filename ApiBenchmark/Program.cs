using System.Diagnostics;

namespace ApiBenchmark
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var url = args.Length > 0 ? args[0] : "http://localhost:5008/benchmark/noop";
            var client = new HttpClient();
            var sw = Stopwatch.StartNew();
            int requests = 1000;
            var tasks = new List<Task>();
            
            for (int i = 0; i < requests; i++)
            {
                tasks.Add(client.GetAsync(url));
            }
            
            await Task.WhenAll(tasks);
            sw.Stop();
            
            Console.WriteLine($"Requests: {requests}");
            Console.WriteLine($"Time: {sw.ElapsedMilliseconds}ms");
            Console.WriteLine($"RPS: {requests / sw.Elapsed.TotalSeconds}");
        }
    }
}
