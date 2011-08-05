using Id.PowershellExtensions;

namespace Tests
{
    public class PsCmdletLoggerDouble : IPsCmdletLogger
    {
        public void Log(string format, params object[] args)
        {
        }

        public void Log(string message)
        {
        }
    }
}