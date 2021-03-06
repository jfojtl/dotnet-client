﻿using Infinispan.HotRod.Tests;
using Infinispan.HotRod.Tests.Util;
using NUnit.Framework;
using System.Collections;

namespace Infinispan.HotRod.TestSuites
{
    public abstract class RemoteQueryTestBase
    {
        HotRodServer server;

        [OneTimeSetUp]
        public void BeforeSuite()
        {
            server = new HotRodServer("clustered-indexing.xml");
            server.StartHotRodServer();
        }

        [OneTimeTearDown]
        public void AfterSuite()
        {
            server.ShutDownHotrodServer();
        }
    }
}