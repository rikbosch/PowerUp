using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace Tests.Helpers
{
    internal class ResourceHelpers
    {
        public static Stream GetStreamFromResource(string name)
        {
            return typeof(ResourceHelpers).Assembly.GetManifestResourceStream(name);
        }
    }
}
