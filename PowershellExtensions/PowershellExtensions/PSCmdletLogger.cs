using Id.PowershellExtensions.PushDatabaseMigration;
using System.Management.Automation;

namespace Id.PowershellExtensions
{
    public class PsCmdletLogger : IPsCmdletLogger
    {
        private readonly Cmdlet parent;

        public PsCmdletLogger(Cmdlet parent)
        {
            this.parent = parent;
        }

        public void Log(string format, params object[] args)
        {
            Log(string.Format(format, args));
        }

        public void Log(string message)
        {
            parent.WriteVerbose(message);
        }
    }
}
