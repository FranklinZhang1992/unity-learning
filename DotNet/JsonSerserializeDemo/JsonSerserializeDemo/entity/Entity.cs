using System;

namespace Entities
{
    class User
    {
        public int Id { get; set; }
        public String UserName { get; set; }
        public int Age { get; set; }
        public String Email { get; set; }
    }

    class UserRole
    {
        public int UserId { get; set; }
        public int RoleId { get; set; }
    }
}
