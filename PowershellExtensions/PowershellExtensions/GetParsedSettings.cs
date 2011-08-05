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
        private string _filename = null;
        private string _deploymentMode = null;
        
        [Parameter(Mandatory = true, Position = 1, ValueFromPipelineByPropertyName = true)]
        public string Filename
        {
            get { return _filename; }
            set { _filename = value; }
        }

        [Parameter(Mandatory = true, Position = 2, ValueFromPipelineByPropertyName = true)]
        public string DeploymentMode
        {
            get { return _deploymentMode; }
            set { _deploymentMode = value; }
        }

        private SettingsFileReader FileReader = null;
        private SettingsParser Parser = new SettingsParser();

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
                    Dictionary<string, string> settings = null;
                    IEnumerable<string> settingsLines = FileReader.ReadSettings();
                    settings = Parser.Parse(settingsLines, DeploymentMode);

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
