using System;
using Newtonsoft.Json;
using Entities;
using Services;
using Events;
using EntityExtensions;
using Assist;
using System.Diagnostics;

namespace JsonSerserializeDemo
{
    class Program
    {
        static String TestPublishUserCreation()
        {
            Service service = new Service();

            int mockedUserId = 112233;

            User dbUser = service.GetUser(mockedUserId);
            UserRole dbUserRole = service.GetUserRole(mockedUserId);

            var userCreation = new UserCreation() {
                User = dbUser.ToSerializeObject<UserForCreation>(),
                UserRole = dbUserRole.ToSerializeObject<UserRoleForCreation>()
            };

            String userCreationJson = JsonConvert.SerializeObject(userCreation);

            Util.printLine(userCreationJson);
            return userCreationJson;
        }

        static void TestProcessUserCreation(String json)
        {
            Service service = new Service();

            UserCreation userCreation = JsonConvert.DeserializeObject<UserCreation>(json);

            User user = userCreation.User.ToSerializeObject<User>();
            UserRole userRole = userCreation.UserRole.ToSerializeObject<UserRole>();

            service.SaveUser(user);
            service.SaveUserRole(userRole);
        }

        static String TestPublishUserNameUpdate()
        {
            Service service = new Service();

            int mockedUserId = 112233;

            User dbUser = service.GetUser(mockedUserId);

            var userNameUpdate = new UserNameUpdate()
            {
                User = dbUser.ToSerializeObject<UserForUpdateName>()
            };

            String userNameUpdateJson = JsonConvert.SerializeObject(userNameUpdate);

            Util.printLine(userNameUpdateJson);
            return userNameUpdateJson;
        }

        static void TestProcessUserNameUpdate(String json)
        {
            Service service = new Service();

            UserNameUpdate userNameUpdate = JsonConvert.DeserializeObject<UserNameUpdate>(json);

            User user = userNameUpdate.User.ToSerializeObject<User>();

            service.UpdateUserName(user);
        }

        static void Test()
        {
            Util.printLine("Case A");
            String json = TestPublishUserCreation();
            Util.printLine("==================================");
            TestProcessUserCreation(json);

            Util.printLine("Case B");
            json = TestPublishUserNameUpdate();
            Util.printLine("==================================");
            TestProcessUserNameUpdate(json);
        }

        static void Main(string[] args)
        {
            int N = 100000;
            var sw = new Stopwatch();
            sw.Start();
            for (int i = 0; i < N; i++)
            {
                Test();
            }
            sw.Stop();

            Console.WriteLine("Duration: " + sw.Elapsed);
            Console.ReadLine();
        }
    }
}
