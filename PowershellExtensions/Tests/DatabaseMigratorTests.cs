using System;
using System.Diagnostics;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Id.PowershellExtensions.ParsedSettings;
using NUnit.Framework;
using System.IO;
using Id.PowershellExtensions;
using System.Reflection;
using Moq;
using Migrator.Framework;
using Id.PowershellExtensions.PushDatabaseMigration;
using NUnit.Framework.SyntaxHelpers;

namespace Tests
{
    [TestFixture]
    public class DatabaseMigratorTests
    {
        private Assembly MigrationsAssembly;
        private StringBuilder Log;
        private StringLogger Logger;
        private DatabaseMigrator DatabaseMigrator;
        private string TempFile;

        [SetUp]
        public void SetUp()
        {
            string folder = Path.GetDirectoryName(Assembly.GetAssembly(typeof(DatabaseMigratorTests)).CodeBase);
            MigrationsAssembly = Assembly.LoadFrom(new Uri(Path.Combine(folder,
                                         "ExampleMigrationAssemblies\\Id.VisaDebitMicrositeAU.DatabaseMigrations.dll")).LocalPath);
            Log = new StringBuilder();
            Logger = new StringLogger(Log);
            TempFile = Path.GetTempFileName();
            DatabaseMigrator = new DatabaseMigrator(Logger, true, "SqlServer", TempFile, -1, true, true /*testmode*/);
        }

        [TearDown]
        public void TearDown()
        {
            DatabaseMigrator.CleanUp();
            MigrationsAssembly = null;
            Logger = null;
            TempFile = null;
            DatabaseMigrator = null;
        }

        [Test]        
        public void DatabaseMigrator_Execute_DryRunLogsActions()
        {
            DatabaseMigrator.Execute(MigrationsAssembly);

            Assert.That(Log.ToString(), Is.Not.Empty);
            Trace.WriteLine(Log.ToString());
            Console.WriteLine(Log.ToString());
        }
        
        [Test]        
        public void DatabaseMigrator_Execute_ExecutesActions()
        {
            DatabaseMigrator.DryRun = false;
            DatabaseMigrator.ScriptFile = string.Empty;
            DatabaseMigrator.Execute(MigrationsAssembly);

            Assert.That(Log.ToString(), Is.Not.Empty);
            Trace.WriteLine(Log.ToString());
            Console.WriteLine(Log.ToString());
        }
    }
}
