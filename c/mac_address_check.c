#include <stdio.h>
#include <regex.h>

// gcc -o mac_address_check.o mac_address_check.c

int
is_valid_mac (char *mac_addr)
{
  regmatch_t subs[1024];
  regex_t preg;
  int result = 0;
  const char *pattern = "^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$";

  if (regcomp (&preg, pattern, REG_EXTENDED) == 0) {
    if (regexec (&preg, mac_addr, 1024, subs, 0) == 0) {
      result = 1;
    }
  }
  regfree (&preg);
  return result;
}

int main(int argc, char const *argv[])
{
  char mac1[] = "123";
  printf("%s is valid? => %d\n", mac1, is_valid_mac(mac1));
  char mac2[] = "00:04:fc:40:c3:01";
  printf("%s is valid? => %d\n", mac2, is_valid_mac(mac2));
  char mac3[] = "00:04:FC:40:C3:01";
  printf("%s is valid? => %d\n", mac3, is_valid_mac(mac3));
  char mac4[] = "00:04:FC:40:C3:011";
  printf("%s is valid? => %d\n", mac4, is_valid_mac(mac4));

  return 0;
}
