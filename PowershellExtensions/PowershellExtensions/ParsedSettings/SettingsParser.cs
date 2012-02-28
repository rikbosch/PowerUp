using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using Microsoft.VisualBasic.FileIO;

namespace Id.PowershellExtensions.ParsedSettings
{
    public class SettingsParser
    {
        private const string KEYREGEXPATTERN = @"\${(?<KEY>[^>]*?)}";
        private const string COMMENTPATTERN = @"^\s{0,}#";
        private readonly Regex KeyRegex = new Regex(KEYREGEXPATTERN, RegexOptions.IgnoreCase);
        private readonly Regex CommentRegex = new Regex(COMMENTPATTERN);

        public Dictionary<string, string[]> Parse(IEnumerable<string> settingsLines, string deploymentMode, char settingDelimiter)
        {            
            var output = ReadSettingsForDeploymentMode(settingsLines, deploymentMode);

            if (ContainsDependentSettings(output))
                output = ResolveDependentSettings(output, null, null);
           
            return ParseSettings(output, settingDelimiter);
        }


        private static Dictionary<string, string[]> ParseSettings(Dictionary<string, string> output, char settingDelimiter)
        {
            return output.ToDictionary(setting => setting.Key, setting => ParseSetting(setting.Value, settingDelimiter));
        }

        private static string [] ParseSetting(string setting, char settingDelimiter)
        {
            var textReader = new StringReader(setting);
            var parser = new TextFieldParser(textReader)
                             {
                                 Delimiters = new[] {settingDelimiter.ToString()},
                                 TextFieldType = FieldType.Delimited,
                                 HasFieldsEnclosedInQuotes = true,
                                 TrimWhiteSpace = true
                             };

            var fields = parser.ReadFields();

            return fields ?? new[]{""};
        }


        private Dictionary<string, string> ReadSettingsForDeploymentMode(IEnumerable<string> settingsLines, string deploymentMode)
        {
            var output = new Dictionary<string, string>();
            bool isSetting = false;

            foreach (var line in settingsLines.Where(x => !CommentRegex.IsMatch(x)))
            {               
                if (!char.IsWhiteSpace(line[0]))
                {
                    isSetting = line.Equals(deploymentMode, StringComparison.InvariantCultureIgnoreCase) ||
                                line.Equals("default", StringComparison.InvariantCultureIgnoreCase);
                }
                else if (isSetting)
                {
                    string[] setting =
                        line.Split(new char[] {'\t'}, StringSplitOptions.RemoveEmptyEntries).Where(
                            x => !string.IsNullOrEmpty(x.Trim())).ToArray();
                    if (setting.Length > 0)
                    {
                        string key = setting[0].Trim();
                        string value = setting.Length == 1 ? string.Empty : setting[1].Trim();

                        if (output.Keys.Any(x => x.ToLowerInvariant() == key.ToLowerInvariant()))
                        {
                            string oldKey = output.Keys.First(x => x.ToLowerInvariant() == key.ToLowerInvariant());
                            output[oldKey] = value;
                        }
                        else
                        {
                            output.Add(key, value);
                        }
                    }
                }
            }

            return output;
        }

        private bool ContainsDependentSettings(Dictionary<string, string> settings)
        {
            if (settings.Values.Any(x => KeyRegex.IsMatch(x)))
            {
                //Validate all keys that need to be resolved, can be resolved
                foreach (string key in settings.Keys)
                {
                    MatchCollection matches = KeyRegex.Matches(settings[key]);
                    if (matches.Count > 0)
                    {
                        foreach (Match match in matches)
                        {
                            if (!settings.ContainsKey(match.Groups["KEY"].Value))
                                throw new KeyNotFoundException("The setting " + key + " has a dependency on the unknown setting " + match.Groups["KEY"].Value);
                        }
                    }
                }

                return true;
            }

            return false;
        }

        private Dictionary<string, string> ResolveDependentSettings(Dictionary<string, string> settings, string keyToResolve, string rootKeyToResolve)
        {
            while (settings.Values.Any(x => KeyRegex.IsMatch(x)))
            {
                if (keyToResolve == null)
                {
                    string setting = settings.Values.First(x => KeyRegex.IsMatch(x));
                    keyToResolve = KeyRegex.Match(setting).Groups["KEY"].Value;

                    if (rootKeyToResolve == null)
                        rootKeyToResolve = keyToResolve;
                }
                else if (rootKeyToResolve == keyToResolve)
                    throw new Exception("Circular dependency detected");

                string value = settings[keyToResolve];
                MatchCollection matches = KeyRegex.Matches(value);
                
                if (matches.Count > 0)
                {
                    return ResolveDependentSettings(settings, matches[0].Groups["KEY"].Value, rootKeyToResolve);
                }

                string[] keys = settings.Keys.ToArray();
                foreach (string key in keys.Where(key => settings[key].Contains("${" + keyToResolve + "}")))
                {
                    settings[key] = settings[key].Replace("${" + keyToResolve + "}", settings[keyToResolve]);
                }

                rootKeyToResolve = null;
                keyToResolve = null;
            }

            return settings;
        }
    }
}
