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

        [SetUp]
        public void SetUp()
        {
            BasicSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.Settings.txt"));
            AdvancedSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.AdvancedSettings.txt"));
            InvalidSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.InvalidSettings.txt"));
            TGSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.TGSettings.txt"));
            VisaSettings = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.VisaSettings.txt"));
        }

        [TearDown]
        public void TearDown()
        {
            BasicSettings = null;
            AdvancedSettings = null;
            InvalidSettings = null;
            TGSettings = null;
            VisaSettings = null;
        }

        [Test]
        public void SettingsParser_Parse_BasicSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            Dictionary<string, string> settings = sp.Parse(BasicSettings.ReadSettings(), "Dev");

            Assert.IsNotNull(settings);
            Assert.AreEqual(3, settings.Keys.Count);
            Assert.AreEqual("Wotsit", settings.Keys.ElementAt(0));
            Assert.AreEqual("Thing", settings.Keys.ElementAt(1));
            Assert.AreEqual("Other", settings.Keys.ElementAt(2));
            Assert.AreEqual("5", settings["Wotsit"]);
            Assert.AreEqual("3", settings["Thing"]);
            Assert.AreEqual("4", settings["Other"]);
        }


        [Test]
        public void SettingsParser_Parse_AdvancedSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            Dictionary<string, string> settings = sp.Parse(AdvancedSettings.ReadSettings(), "Dev");

            Assert.IsNotNull(settings);
            Assert.AreEqual(3, settings.Keys.Count);
            Assert.AreEqual("Wotsit", settings.Keys.ElementAt(0));
            Assert.AreEqual("Thing", settings.Keys.ElementAt(1));
            Assert.AreEqual("Other", settings.Keys.ElementAt(2));
            Assert.AreEqual("3 4 5", settings["Wotsit"]);
            Assert.AreEqual("3 4", settings["Thing"]);
            Assert.AreEqual("4", settings["Other"]);
        }

        [Test]
        public void SettingsParser_Parse_TGSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            Dictionary<string, string> settings = sp.Parse(TGSettings.ReadSettings(), "DEV");

            Assert.IsNotNull(settings);
        }

        [Test]
        public void SettingsParser_Parse_VisaSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            Dictionary<string, string> settings = sp.Parse(VisaSettings.ReadSettings(), "Test");

            Assert.IsNotNull(settings);
            Assert.AreEqual(9, settings.Keys.Count);
            Assert.AreEqual(@"VisaDebitMicroSiteAU", settings["ProjectName"]);
            Assert.AreEqual(@"\\reliant", settings["DeployServer"]);
            Assert.AreEqual(@"e:\temp", settings["DeploymentPath"]);
            Assert.AreEqual(@"\\reliant\e$\releasetemp", settings["RemoteReleaseWorkingFolder"]);
            Assert.AreEqual(@"e:\releasetemp", settings["LocalReleaseWorkingFolder"]);
            Assert.AreEqual(@"VisaDebitMicroSiteAUadmin", settings["AdminSiteFolder"]);
            Assert.AreEqual(@"VisaDebitMicroSiteAUadmin.dev.work", settings["AdminSiteUrl"]);
            Assert.AreEqual(@"VisaDebitMicroSiteAUweb", settings["WebSiteFolder"]);
            Assert.AreEqual(@"VisaDebitMicroSiteAU.dev.work", settings["WebSiteUrl"]);
        }

        [Test]
        [ExpectedException(typeof(Exception), "Circular dependency detected")]
        public void SettingsParser_Parse_InvalidSettings_ReturnsExpectedResult()
        {
            SettingsParser sp = new SettingsParser();
            Dictionary<string, string> settings = sp.Parse(InvalidSettings.ReadSettings(), "Dev");
        }
    }
}
