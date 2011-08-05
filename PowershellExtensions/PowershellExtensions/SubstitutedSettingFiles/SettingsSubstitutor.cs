using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using href.Utils;

namespace Id.PowershellExtensions.SubstitutedSettingFiles
{
    public class SettingsSubstitutor : ISettingsSubstitutor
    {
        private class EncodedFile
        {
            public string Contents { get; set; }
            public Encoding Encoding { get; set; }
        }

        public void CreateSubstitutedDirectory(string templatesDirectory, string targetDirectory, string environment, IDictionary<string, string> settings)
        {
            var fullEnvironmentFolder = Path.Combine(targetDirectory, environment);

            CopyDirectoryRecursively(templatesDirectory, fullEnvironmentFolder);
            SubstituteDirectory(fullEnvironmentFolder, settings);
        }
        

        private static void SubstituteDirectory(string environmentFolder, IDictionary<string, string> settings)
        {
            if (settings.Count == 0)
                return;

            var dirStack = new Stack<string>();
            dirStack.Push(environmentFolder);

            while (dirStack.Count > 0)
            {
                var dir = dirStack.Pop();

                foreach (var file in GetVisibleFiles(dir))
                {
                    SubstituteFile(file.FullName, settings);
                }

                foreach (var dn in GetVisibleDirectories(dir))
                {
                    dirStack.Push(dn.FullName);
                }
            }
        }
        
        private static IEnumerable<FileInfo> GetVisibleFiles(DirectoryInfo directoryInfo)
        {
            return directoryInfo.GetFiles().Where(x => !IsResourceHidden(x));
        }

        private static IEnumerable<FileInfo> GetVisibleFiles(string directory)
        {
            return GetVisibleFiles(new DirectoryInfo(directory));
        }

        private static IEnumerable<DirectoryInfo> GetVisibleDirectories(string directory)
        {
            return GetVisibleDirectories(new DirectoryInfo(directory));
        }

        private static IEnumerable<DirectoryInfo> GetVisibleDirectories(DirectoryInfo directoryInfo)
        {
            return directoryInfo.GetDirectories().Where(x => !IsResourceHidden(x));
        }

        private static bool IsResourceHidden(FileSystemInfo info)
        {
            return (info.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden;
        }

        private static void SubstituteFile(string file, IDictionary<string, string> settings)
        {
            var encodedFile = GetFileWithEncoding(file);
            var content = encodedFile.Contents;

            foreach (var keyValuePair in settings)
            {
                content = content.Replace("${" + keyValuePair.Key + "}", keyValuePair.Value);
            }

            File.WriteAllText( file, content,encodedFile.Encoding);
        }

        private static EncodedFile GetFileWithEncoding(string file)
        {
            using (Stream fs = File.Open(file, FileMode.Open))
            {
                var rawData = new byte[fs.Length];
                fs.Read(rawData, 0, (int)fs.Length);
                var encoding = EncodingTools.DetectInputCodepage(rawData);
                return new EncodedFile { Contents = encoding.GetString(rawData), Encoding = encoding };
            }
        }

        private static void CopyDirectoryRecursively(string source, string destination)
        {
            var sourceDirectoryInfo = new DirectoryInfo(source);

            if (!Directory.Exists(destination))
                Directory.CreateDirectory(destination);

            foreach (var fileInfo in GetVisibleFiles(sourceDirectoryInfo))
                File.Copy(fileInfo.FullName, Path.Combine(destination, fileInfo.Name), true);

            foreach (var sourceSubDirectory in GetVisibleDirectories(sourceDirectoryInfo))
            {
                var destinationSubDirectory = new DirectoryInfo(destination).CreateSubdirectory(sourceSubDirectory.Name);
                CopyDirectoryRecursively(sourceSubDirectory.FullName, destinationSubDirectory.FullName);
            }
        }


       
    }
}