#include <stdio.h>
#include <string.h>

/*
   gcc -o sub_string_test.o sub_string_test.c
*/

void substring(const char *in, unsigned char *out, int start_Index, int end_index)
{
   int total_len;
   int i, j;

   total_len = strlen(in);
   if (end_index > total_len) {
      printf("invalid end index: %d\n", end_index);
      return;
   }
   if (start_Index < 0) {
      printf("invalid start index: %d\n", start_Index);
      return;
   }

   j = 0;
   for (i = start_Index; i < end_index; i++) {
      out[j++] = in[i];
   }
   out[j] = '\0';
}

int main(int argc, char const *argv[])
{
   const unsigned char *in = "161a9d1c6b434e998e52e5be7356e438";
   unsigned char out[512];

   substring(in, out, 0, 16);
   printf("%s, len: %d\n", out, strlen(out));
   return 0;
}
