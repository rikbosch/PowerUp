using System;
using Id.PowershellExtensions.UmbracoResources;
using NUnit.Framework;
using NUnit.Framework.SyntaxHelpers;
using Umbraco.Courier.RepositoryProviders;

namespace Tests
{
    [TestFixture]
    public class CourierWebServiceInitializerTests
    {
        [Test]
        public void WhenCalledWithValidUri_Succeeds()
        {
            var logger = new PsCmdletLoggerDouble();
            var initializer = new CourierWebServiceInitializer("http://www.webservicex.net/stockquote.asmx", logger);

            initializer.WarmUpWebService();

            Assert.That(logger.ExceptionsLogged.Equals(0));
        }

        [Test]
        public void WhenCalledWithInvalidUri_FailsAndLogs()
        {
            var logger = new PsCmdletLoggerDouble();
            var initializer = new CourierWebServiceInitializer("Invalid Uri", logger);

            initializer.WarmUpWebService();

            Assert.That(logger.ExceptionsLogged.Equals(1));
        }
    }
}