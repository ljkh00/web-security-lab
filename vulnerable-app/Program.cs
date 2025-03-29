using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;
using VulnerableApp.Data;
using VulnerableApp.Services;
using Microsoft.AspNetCore.Identity;

var builder = WebApplication.CreateBuilder(args);

// VULNERABILITY: Configure insecure logging
builder.Logging.ClearProviders();
builder.Logging.AddProvider(new InsecureLoggingServiceProvider());

// Add services to the container
builder.Services.AddControllersWithViews(); // Missing security features

// Add the DataProtection configuration (intentionally insecure)
builder.Services.AddDataProtection()
    // Missing key storage configuration
    // Missing key rotation policy
    // Missing encryption at rest for keys
    ;

// Add the Identity configuration (intentionally weak)
builder.Services.Configure<IdentityOptions>(options =>
{
    // Deliberately weak password settings
    options.Password.RequireDigit = false;
    options.Password.RequireLowercase = false;
    options.Password.RequireUppercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequiredLength = 6;
    
    // No lockout configuration
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(1);
    options.Lockout.MaxFailedAccessAttempts = 100; // Too high
});

// VULNERABILITY: Insecure CORS policy configuration
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader()
              .DisallowCredentials(); // Disabling credentials makes this particularly bad for security
    });
});

// Add database context
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Configure custom authentication (intentionally weak)
builder.Services.AddSingleton<IAuthService, InsecureAuthService>();

// Session configuration (insecure)
builder.Services.AddSession(options =>
{
    // No secure configuration
    options.IdleTimeout = TimeSpan.FromHours(24); // Excessively long timeout
    // No cookie security settings
});

// Missing CSRF protection configuration

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage(); // Leaks sensitive information
}
else
{
    // Missing security headers
    app.UseExceptionHandler("/Home/Error");
    // Missing HTTPS redirection
}

// Missing security headers middleware

app.UseStaticFiles(); // No content security policy

app.UseRouting();

// VULNERABILITY: Enabling overly permissive CORS
app.UseCors("AllowAll");

// Insecure CSP configuration (intentionally vulnerable)
app.Use(async (context, next) =>
{
    // Deliberately weak CSP that allows unsafe practices
    context.Response.Headers.Add("Content-Security-Policy", 
        "default-src 'self' 'unsafe-inline' 'unsafe-eval' https: data:; " +
        "script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; " +
        "style-src 'self' 'unsafe-inline' https:;");
    
    await next();
});

app.UseSession(); // Insecure session

// Authentication and authorization - intentionally in wrong order
app.UseAuthorization(); // Should come after UseAuthentication
// Missing app.UseAuthentication();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();