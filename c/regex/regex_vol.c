#include <regex.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int64_t
get_real_vol_size_from_cmd_result (char *cmd_result)
{
  int64_t vol_size = 0;
  int nm = 5;
  regmatch_t pm[nm];
  regex_t preg;
  char *match;
  const char *pattern = "virtual\\s+size:\\s+\\S+G\\s+\\(([0-9]+)\\s+bytes\\)";
  if (cmd_result == NULL) {
    return vol_size;
  }

  if (regcomp (&preg, pattern, REG_EXTENDED | REG_NEWLINE) == 0) {
    if (regexec (&preg, cmd_result, nm, pm, REG_NOTEOL) == 0) {
      int i;
      for(i = 0; i < nm && pm[i].rm_so != -1; i++) {
        int len = pm[1].rm_eo - pm[1].rm_so;
        if (len) {
          match = (char*) malloc ((sizeof (char) * len + 1));
          memset (match, '\0', (sizeof (char) * len + 1));
          memcpy (match, cmd_result + pm[1].rm_so, len);
          sscanf (match, "%ld", &vol_size);
          free (match);
          if (vol_size > 0) {
            break;
          }
        }
      }
    }
  }
  regfree (&preg);
  return vol_size;
}

int main(int argc, char const *argv[])
{
  char *cmd_result = "image: mali5convertvda_d610e2d8-8e2b-45f8-83e1-19e522fd266e_c44e8d76-f97b-482a-af71-3af04df10b49\n"
                     "file format: raw\n"
                     "virtual size: 9.8G (10498342912 bytes)\n"
                     "disk size: 3.6G\n";
  int64_t r = get_real_vol_size_from_cmd_result (cmd_result);
  printf("size is %ld\n", r);
  return 0;
}
