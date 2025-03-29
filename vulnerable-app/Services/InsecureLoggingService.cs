using Microsoft.Extensions.Logging;
using System;
using System.IO;

namespace VulnerableApp.Services
{
    public class InsecureLoggingService : ILogger
    {
        private readonly string _categoryName;

        public InsecureLoggingService(string categoryName)
        {
            _categoryName = categoryName;
        }

        public IDisposable BeginScope<TState>(TState state) => null;
        
        public bool IsEnabled(LogLevel logLevel) => true;
        
        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            // VULNERABILITY: Logging sensitive information without redaction
            var message = formatter(state, exception);
            
            // VULNERABILITY: Writing logs to insecure location
            File.AppendAllText("C:\\logs\\app_log.txt", $"{DateTime.Now} - {_categoryName} - {logLevel}: {message}\n");
            
            // VULNERABILITY: No structured logging, making security monitoring difficult
            Console.WriteLine($"{DateTime.Now} - {_categoryName} - {logLevel}: {message}");
        }
    }

    public class InsecureLoggingServiceProvider : ILoggerProvider
    {
        public ILogger CreateLogger(string categoryName)
        {
            return new InsecureLoggingService(categoryName);
        }

        public void Dispose() { }
    }
}