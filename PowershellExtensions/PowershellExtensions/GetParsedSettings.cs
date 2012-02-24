using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Management.Automation;
using System.IO;
using Id.PowershellExtensions.ParsedSettings;

namespace Id.PowershellExtensions
{
    [Cmdlet(VerbsCommon.Get, "ParsedSettings", SupportsShouldProcess=true)]
    public class GetParsedSettings : PSCmdlet
    {
        private char _delimiter = ';';

        [Parameter(Mandatory = true, Position = 1, ValueFromPipelineByPropertyName = true)]
        public string Filename { get; set; }

        [Parameter(Mandatory = true, Position = 2, ValueFromPipelineByPropertyName = true)]
        public string DeploymentMode { get; set; }

        [Parameter(Position = 3, ValueFromPipelineByPropertyName = true)]
        public char Delimiter
        {
            get { return _delimiter; }
            set { _delimiter = value; }
        }

        private SettingsFileReader FileReader = null;
        private SettingsParser Parser = new SettingsParser();

        public GetParsedSettings()
        {
            DeploymentMode = null;
            Filename = null;
        }

        protected override void BeginProcessing()
        {
            try
            {                 
                if (ShouldProcess(Filename) && ShouldProcess(DeploymentMode))
                {
                    string currentDirectory = Environment.CurrentDirectory;
                    FileReader = new SettingsFileReader(Filename, currentDirectory);                    
                }
            }
            catch (Exception e)
            {
                ThrowTerminatingError(
                    new ErrorRecord(
                        e,
                        "ParsedSettings",
                        ErrorCategory.NotSpecified,
                        Filename)
                    );
            }
        }        

        protected override void ProcessRecord()
        {
            try
            {
                if (FileReader != null)
                {
                    var settingsLines = FileReader.ReadSettings();
                    var settings = Parser.Parse(settingsLines, DeploymentMode, Delimiter);

                    this.WriteObject(settings);
                }
            }
            catch (Exception e)
            {
                ThrowTerminatingError(
                    new ErrorRecord(
                        e,
                        "ParsedSettings",
                        ErrorCategory.NotSpecified,
                        this)
                    );
            }
        }

        protected override void EndProcessing()
        {
            if (FileReader != null) { FileReader = null; }
        }
    }
}
