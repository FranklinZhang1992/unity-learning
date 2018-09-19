using System;
using System.Collections.Generic;
using System.Text;
using Entities;
using Newtonsoft.Json;
using Assist;

namespace Services
{
    class Service
    {
        public User GetUser(int userId)
        {
            User user = new User();
            user.Id = userId;
            user.UserName = "Mike";
            user.Age = 30;
            user.Email = "abc@123.com";
            return user;
        }

        public UserRole GetUserRole(int userId)
        {
            UserRole userRole = new UserRole();
            userRole.UserId = userId;
            userRole.RoleId = 334455;
            return userRole;
        }

        public void SaveUser(User user)
        {
            Util.printLine("Saving user:");
            Util.printLine(JsonConvert.SerializeObject(user));
            Util.printLine("User saved");
        }

        public void SaveUserRole(UserRole userRole)
        {
            Util.printLine("Saving userRole:");
            Util.printLine(JsonConvert.SerializeObject(userRole));
            Util.printLine("UserRole saved");
        }

        public void UpdateUserName(User user)
        {
            User dbUser = GetUser(user.Id);
            dbUser.UserName = user.UserName;
            Util.printLine("Updating user:");
            Util.printLine(JsonConvert.SerializeObject(user));
            Util.printLine("User updated");
        }

    }
}
