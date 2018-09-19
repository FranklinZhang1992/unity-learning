using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;

namespace Assist
{
    static class Helper
    {
        public static string ToJsonString<TOut>(this Object obj) where TOut : class
        {
            return JsonConvert.SerializeObject(JsonConvert.DeserializeObject<TOut>(JsonConvert.SerializeObject(obj)));
        }

        public static T ToSerializeObject<T>(this Object obj)
        {
            return JsonConvert.DeserializeObject<T>(JsonConvert.SerializeObject(obj));
        }
    }

    class Util
    {
        public static void printLine(String str)
        {
            var verbose = false;
            if (verbose)
            {
                Console.WriteLine(str);
            }
        }
    }
}
