using System;
using System.Collections.Generic;
using System.Text;
using Entities;
using EntityExtensions;

namespace Events
{
    class UserCreation
    {
        public UserForCreation User { get; set; }
        public UserRoleForCreation UserRole { get; set; }
    }

    class UserNameUpdate
    {
        public UserForUpdateName User { get; set; }
    }
}
