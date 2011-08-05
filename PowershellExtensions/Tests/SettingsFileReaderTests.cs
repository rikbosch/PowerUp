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
    public class SettingsFileReaderTests
    {
        [Test]
        public void SettingsFileReader_ReadSettings_FromSettingsFile_ReturnsExpectedResult()
        {
            SettingsFileReader reader = new SettingsFileReader(Helpers.ResourceHelpers.GetStreamFromResource("Tests.ExampleSettingsFiles.Settings.txt"));
            Assert.AreEqual(9, reader.ReadSettings().Count());
        }
    }
}
