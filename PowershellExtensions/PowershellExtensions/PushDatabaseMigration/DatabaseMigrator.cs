using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Reflection;
using System.IO;
using Migrator.Framework;
using Migrator.Framework.Loggers;
using Id.DatabaseMigration.SqlServer;
using Id.DatabaseMigration;

namespace Id.PowershellExtensions.PushDatabaseMigration
{
    public class DatabaseMigrator
    {
        public ILogger Logger { get; set; }
        public bool DryRun { get; set; }
        public string Provider { get; set; }
        public string ScriptFile { get; set; }
        public long To { get; set; }
        public bool Trace { get; set; }
        public bool TestMode { get; set; }

        private ISqlServerSettings Settings;
        private SqlServerAdministrator SqlServerAdministrator;

        public bool ScriptChanges
        {
            get
            {
                return !string.IsNullOrEmpty(ScriptFile);
            }
        }

        public DatabaseMigrator(ILogger logger, bool dryRun, string provider, string scriptFile, long to, bool trace)
            : this(logger, dryRun, provider, scriptFile, to, trace, false)
        {  }

        public DatabaseMigrator(ILogger logger, bool dryRun, string provider, string scriptFile, long to, bool trace, bool testMode)
        {
            Logger = logger;            
            DryRun = dryRun;
            Provider = provider;
            ScriptFile = scriptFile;
            To = to;
            Trace = trace;
            TestMode = testMode;
        }

        public void Execute(Assembly asm)
        {
            Settings = new XmlSettingsParser(asm);
            SqlServerAdministrator = new SqlServerAdministrator(Settings);
            
            EnsureDatabaseExists();

            Logger.Log("Running migrations with connection string {0}", new object[] { Settings.DefaultIntegratedSecurityConnectionString });
            var migrator = new Migrator.Migrator(this.Provider, Settings.DefaultIntegratedSecurityConnectionString, asm,
                                                 this.Trace, Logger) {DryRun = this.DryRun};
            if (this.ScriptChanges)
            {
                using (StreamWriter writer = new StreamWriter(this.ScriptFile))
                {
                    migrator.Logger = new SqlScriptFileLogger(migrator.Logger, writer);
                    this.RunMigration(migrator);
                }
            }
            else
            {
                this.RunMigration(migrator);
            }
        }

        public void RunMigration(Migrator.Migrator mig)
        {
            if (mig.DryRun)
            {
                mig.Logger.Log("********** Dry run! Not actually applying changes. **********", new object[0]);
            }
            if (this.To == -1L)
            {
                mig.MigrateToLastVersion();
            }
            else
            {
                mig.MigrateTo(this.To);
            }
        }

        public void CleanUp()
        {
            if (!TestMode)
                return;

            AmbientSettings.Settings = null;

            if (!string.IsNullOrEmpty(Settings.DefaultUserName))
            {
                Logger.Log("Dropping login and user '{0}'", new object[] { Settings.DefaultUserName });
                SqlServerAdministrator.DropDefaultUser();
                SqlServerAdministrator.DropDefaultLogin();                
            }

            Logger.Log("Dropping database '{0}'", new object[] { Settings.DatabaseName });   
            SqlServerAdministrator.DropDatabase();
        }

        private void EnsureDatabaseExists()
        {
            if (TestMode)
            {
                ((XmlSettingsParser)Settings).DatabaseName = string.Format("{0}_{1}", Settings.DatabaseName,
                                                                            Guid.NewGuid().ToString("N").Substring(0, 5));
                AmbientSettings.Settings = Settings;
            }

            Logger.Log("Ensuring database '{0}'", new object[] { Settings.DatabaseName });            
            SqlServerAdministrator.CreateDatabase();

            if (!string.IsNullOrEmpty(Settings.DefaultUserName))
            {
                Logger.Log("Ensuring login and user '{0}'", new object[] { Settings.DefaultUserName });
                SqlServerAdministrator.CreateDefaultLogin();
                SqlServerAdministrator.CreateDefaultUser();
            }
        }
    }
}
