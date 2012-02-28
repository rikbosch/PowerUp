using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Id.PowershellExtensions.ParsedSettings;
using NUnit.Framework;
using System.IO;
using Id.PowershellExtensions;

namespace Tests
{
    [TestFixture]
    public class SettingsParserTests
    {
        SettingsFileReader BasicSettings;
        SettingsFileReader AdvancedSettings;
        SettingsFileReader InvalidSettings;
        SettingsFileReader TGSettings;
        SettingsFileReader VisaSettings;
        SettingsFileReader ServerSettings;
        SettingsFileReader MultipleSettings;

        [SetUp]
        public void SetUp()
        {
            BasicSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.Settings.txt"));
            AdvancedSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.AdvancedSettings.txt"));
            MultipleSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.MultipleSettings.txt"));
            InvalidSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.InvalidSettings.txt"));
            TGSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.TGSettings.txt"));
            VisaSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.VisaSettings.txt"));
            ServerSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.Servers.txt"));
        }

        [TearDown]
        public void TearDown()
        {
            BasicSettings = null;
            AdvancedSettings = null;
            InvalidSettings = null;
            TGSettings = null;
            VisaSettings = null;
            ServerSettings = null;
            MultipleSettings = null;
        }

        [Test]
        public void SettingsParser_Parse_BasicSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            var settings = sp.Parse(BasicSettings.ReadSettings(), "Dev", '|');

            Assert.IsNotNull(settings);
            Assert.AreEqual(3, settings.Keys.Count);
            Assert.AreEqual("Wotsit", settings.Keys.ElementAt(0));
            Assert.AreEqual("Thing", settings.Keys.ElementAt(1));
            Assert.AreEqual("other", settings.Keys.ElementAt(2));
            Assert.AreEqual("5", settings["Wotsit"][0]);
            Assert.AreEqual("3", settings["Thing"][0]);
            Assert.AreEqual("4", settings["other"][0]);
        }


        [Test]
        public void SettingsParser_Parse_AdvancedSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            var settings = sp.Parse(AdvancedSettings.ReadSettings(), "Dev", '|');

            Assert.IsNotNull(settings);
            Assert.AreEqual(3, settings.Keys.Count);
            Assert.AreEqual("Wotsit", settings.Keys.ElementAt(0));
            Assert.AreEqual("Thing", settings.Keys.ElementAt(1));
            Assert.AreEqual("Other", settings.Keys.ElementAt(2));
            Assert.AreEqual("3 4 5", settings["Wotsit"][0]);
            Assert.AreEqual("3 4", settings["Thing"][0]);
            Assert.AreEqual("4", settings["Other"][0]);
        }

        [Test]
        public void SettingsParser_Parse_TGSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            var settings = sp.Parse(TGSettings.ReadSettings(), "DEV", '|');

            Assert.IsNotNull(settings);
        }

        [Test]
        public void SettingsParser_Parse_VisaSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            var settings = sp.Parse(VisaSettings.ReadSettings(), "Test", '|');

            Assert.IsNotNull(settings);
            Assert.AreEqual(9, settings.Keys.Count);
            Assert.AreEqual(@"VisaDebitMicroSiteAU", settings["ProjectName"][0]);
            Assert.AreEqual(@"\\reliant", settings["DeployServer"][0]);
            Assert.AreEqual(@"e:\temp", settings["DeploymentPath"][0]);
            Assert.AreEqual(@"\\reliant\e$\releasetemp", settings["RemoteReleaseWorkingFolder"][0]);
            Assert.AreEqual(@"e:\releasetemp", settings["LocalReleaseWorkingFolder"][0]);
            Assert.AreEqual(@"VisaDebitMicroSiteAUadmin", settings["AdminSiteFolder"][0]);
            Assert.AreEqual(@"VisaDebitMicroSiteAUadmin.dev.work", settings["AdminSiteUrl"][0]);
            Assert.AreEqual(@"VisaDebitMicroSiteAUweb", settings["WebSiteFolder"][0]);
            Assert.AreEqual(@"VisaDebitMicroSiteAU.dev.work", settings["WebSiteUrl"][0]);
        }

        [Test]
        public void SettingsParser_Parse_DelimitedReturnsMultipleValues()
        {
            SettingsParser sp = new SettingsParser();
            var settings = sp.Parse(MultipleSettings.ReadSettings(), "Live", '|');

            Assert.IsNotNull(settings);
            Assert.AreEqual(4, settings.Keys.Count);
            Assert.AreEqual("Other", settings.Keys.ElementAt(1));
            Assert.AreEqual("2", settings["Other"][0]);
            Assert.AreEqual("3", settings["Other"][1]);
            Assert.AreEqual("2|3", settings["Quoted"][0]);
            Assert.AreEqual("", settings["Nothing"][0]);
        }

        [Test]
        [ExpectedException(typeof(Exception), "Circular dependency detected")]
        public void SettingsParser_Parse_InvalidSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            var settings = sp.Parse(InvalidSettings.ReadSettings(), "Dev", '|');
        }

        [Test]
        public void SettingsParser_Parse_Servers_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            var settings = sp.Parse(ServerSettings.ReadSettings(), "icevm069", '|');

            Assert.IsNotNull(settings);
            Assert.AreEqual(5, settings.Keys.Count);
            Assert.AreEqual(@"icevm069", settings["server.name"][0]);
            Assert.AreEqual(@"d", settings["local.root.drive.letter"][0]);
            Assert.AreEqual(@"_releasetemp", settings["deployment.working.folder"][0]);
            Assert.AreEqual(@"d:\_releasetemp", settings["local.temp.working.folder"][0]);
            Assert.AreEqual(@"\\icevm069\_releasetemp", settings["remote.temp.working.folder"][0]);
        }
    }
}
