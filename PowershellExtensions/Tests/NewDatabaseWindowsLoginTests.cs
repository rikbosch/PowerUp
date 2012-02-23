using System;
using System.Diagnostics;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Id.PowershellExtensions.DatabaseMigrations;
using Id.PowershellExtensions.ParsedSettings;
using NUnit.Framework;
using System.IO;
using Id.PowershellExtensions;
using System.Reflection;
using Moq;
using Migrator.Framework;
using NUnit.Framework.SyntaxHelpers;

namespace Tests
{
    [TestFixture]
    public class NewDatabaseWindowsLoginTests
    {
        private Assembly MigrationsAssembly;
        private StringBuilder Log;
        private StringLogger Logger;
        private DatabaseMigrator DatabaseMigrator;
        private NewWindowsLogin NewWindowsLogin;
        private string TempFile;

        [SetUp]
        public void SetUp()
        {
            string folder = Path.GetDirectoryName(Assembly.GetAssembly(typeof(DatabaseMigratorTests)).CodeBase);
            MigrationsAssembly = Assembly.LoadFrom(new Uri(Path.Combine(folder,
                                         "ExampleMigrationAssemblies\\Id.VisaDebitMicrositeAU.DatabaseMigrations.dll")).LocalPath);
            Log = new StringBuilder();
            Logger = new StringLogger(Log);
            DatabaseMigrator = new DatabaseMigrator(Logger, false, "SqlServer", -1, true/*trace*/);            

            DatabaseMigrator.Execute(MigrationsAssembly);
        }

        [TearDown]
        public void TearDown()
        {
            DatabaseMigrator.CleanUp();
            MigrationsAssembly = null;
            Logger = null;
            TempFile = null;
            DatabaseMigrator = null;
            NewWindowsLogin = null;
        }

        [Test]
        public void NewDatabaseWindowsLogin_Execute_CreatesWindowsLogin()
        {
            NewWindowsLogin = new NewWindowsLogin(Logger, "SqlServer", @"Id\AndrewR");
            NewWindowsLogin.Execute(MigrationsAssembly);

            Assert.That(Log.ToString(), Is.Not.Empty);
            Trace.WriteLine(Log.ToString());
            Console.WriteLine(Log.ToString());
        }
    }
}
