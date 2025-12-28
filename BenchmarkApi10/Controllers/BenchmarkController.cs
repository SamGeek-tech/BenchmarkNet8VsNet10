using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;

namespace BenchmarkApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BenchmarkController : ControllerBase
    {
        [HttpGet("noop")]
        public IActionResult NoOp()
        {
            return Ok();
        }

        [HttpGet("cpu")]
        public IActionResult Cpu()
        {
            var data = new byte[1024];
            new Random(42).NextBytes(data);
            using var sha256 = SHA256.Create();
            var hash = sha256.ComputeHash(data);
            return Ok(hash);
        }
    }
}
