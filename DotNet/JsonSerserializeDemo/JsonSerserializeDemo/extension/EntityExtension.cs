
using System;
using System.Collections.Generic;
using System.Text;

namespace EntityExtensions
{
    class UserForCreation
    {
        public String UserName { get; set; }
        public int Age { get; set; }
        public String Email { get; set; }
    }

    class UserRoleForCreation
    {
        public int UserId { get; set; }
        public int RoleId { get; set; }
    }

    class UserForUpdateName
    {
        public String UserName { get; set; }
    }
}
