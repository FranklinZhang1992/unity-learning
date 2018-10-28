 using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;

namespace DemoService
{
    public partial class DemoService : ServiceBase
    {
        private System.Timers.Timer timer;

        public DemoService()
        {
            InitializeComponent();
            this.ServiceName = "DemoService";
            this.CanStop = true;
            this.CanPauseAndContinue = false;
            this.AutoLog = true;
        }

        protected override void OnStart(string[] args)
        {
            WriteFile("In OnStart");
            // Set up a timer that triggers every minute.
            timer = new System.Timers.Timer();
            timer.Interval = 60000; // 60 seconds
            timer.Elapsed += new System.Timers.ElapsedEventHandler(this.OnTimer);
            timer.Enabled = true;
            timer.Start();
        }

        protected override void OnStop()
        {
            WriteFile("In OnStop");
            timer.Stop();
        }

        public void OnTimer(object sender, System.Timers.ElapsedEventArgs args)
        {
            string content = "Monitoring the System";
            WriteFile(content);
        }

        private void WriteFile(string content)
        {
            string dirPath = "C:\\output";
            if (!System.IO.Directory.Exists(dirPath))
            {
                System.IO.Directory.CreateDirectory(dirPath);
            }

            using (System.IO.StreamWriter file = new System.IO.StreamWriter("C:\\output\\demo.out", true))
            {
                file.WriteLine("[" + DateTime.Now.ToString() + "] " + content);
            }
        }
    }
}
