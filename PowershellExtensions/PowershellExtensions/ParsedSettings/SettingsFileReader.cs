using System;
using System.Collections.Generic;
using System.IO;

namespace Id.PowershellExtensions.ParsedSettings
{
    public class SettingsFileReader
    {
        public string Filename { get; private set; }
        public string CurrentDirectory { get; private set; }
        private Stream File { get; set; }

        public SettingsFileReader(string fileName, string currentDirectory)
        {
            Filename = fileName;
            CurrentDirectory = currentDirectory;
            File = GetStream();
        }

        public SettingsFileReader(Stream file)
        {
            File = file;
        }

        private Stream GetStream()
        {
            string fullPathAndFilename = Filename;
            if (!Path.IsPathRooted(fullPathAndFilename))
                fullPathAndFilename = Path.Combine(CurrentDirectory, fullPathAndFilename);

            return new FileStream(fullPathAndFilename, FileMode.Open);
        }

        public IEnumerable<string> ReadSettings()
        {
            using (StreamReader sr = new StreamReader(File))
            {
                return sr.ReadToEnd().Replace("\n", "\r\n").Replace("\r\r\n", "\r\n").Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
            }
        }
    }
}
