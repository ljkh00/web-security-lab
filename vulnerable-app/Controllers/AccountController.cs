using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using VulnerableApp.Models;
using VulnerableApp.Services;
using VulnerableApp.Data;
using System;

namespace VulnerableApp.Controllers
{
    public class AccountController : Controller
    {
        private readonly IAuthService _authService;
        private readonly ApplicationDbContext _context;

        public AccountController(IAuthService authService, ApplicationDbContext context)
        {
            _authService = authService;
            _context = context;
        }

        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Login(string username, string password, bool rememberMe)
        {
            // VULNERABILITY: No rate limiting for brute force protection
            // VULNERABILITY: No account lockout
            
            if (_authService.ValidateCredentials(username, password))
            {
                var user = _authService.GetUserByUsername(username);
                
                // VULNERABILITY: Insecure session management
                HttpContext.Session.SetString("UserId", user.UserId.ToString());
                HttpContext.Session.SetString("Username", username);
                HttpContext.Session.SetString("IsAdmin", user.IsAdmin.ToString());
                
                // VULNERABILITY: Insecure cookie
                if (rememberMe)
                {
                    // No secure flag, no httponly, no expiration
                    Response.Cookies.Append("RememberUser", username);
                }
                
                // Log sensitive information
                Console.WriteLine($"User logged in: {username} with password: {password}");
                
                return RedirectToAction("Index", "Home");
            }
            
            ViewBag.ErrorMessage = "Invalid login attempt";
            return View();
        }

        [HttpPost]
        public IActionResult Register(string username, string password, string email, string fullName)
        {
            // VULNERABILITY: No password complexity requirements
            // VULNERABILITY: No input validation/sanitization
            
            // VULNERABILITY: SQL Injection possible here with user input
            // (Implementation simplified for example)
            var newUser = new User
            {
                Username = username,
                Password = password, // VULNERABILITY: Storing plain text password
                Email = email,
                FullName = fullName,
                IsAdmin = false
            };
            
            _context.Users.Add(newUser);
            _context.SaveChanges();
            
            return RedirectToAction("Login");
        }

        public IActionResult Profile()
        {
            // VULNERABILITY: Missing authentication check
            
            string userId = HttpContext.Session.GetString("UserId");
            if (string.IsNullOrEmpty(userId))
            {
                return RedirectToAction("Login");
            }
            
            int id = int.Parse(userId);
            var user = _context.Users.Find(id);
            
            return View(user);
        }

        [HttpPost]
        public IActionResult Profile(string fullName, string email)
        {
            // VULNERABILITY: Missing authentication check
            
            string userId = HttpContext.Session.GetString("UserId");
            if (string.IsNullOrEmpty(userId))
            {
                return RedirectToAction("Login");
            }
            
            int id = int.Parse(userId);
            var user = _context.Users.Find(id);
            
            // VULNERABILITY: No validation on input
            user.FullName = fullName;
            user.Email = email;
            
            _context.Update(user);
            _context.SaveChanges();
            
            ViewBag.Message = "Profile updated successfully";
            return View(user);
        }

        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            // VULNERABILITY: Not clearing auth cookies
            return RedirectToAction("Index", "Home");
        }
    }
}