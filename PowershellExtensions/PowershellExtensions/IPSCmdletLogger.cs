namespace Id.PowershellExtensions
{
    public interface IPsCmdletLogger
    {
        void Log(string format, params object[] args);
        void Log(string message);
    }
}
