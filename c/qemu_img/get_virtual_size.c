#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <regex.h>

int64_t
get_real_vol_size_from_cmd_result (char *cmd_result)
{
  int64_t vol_size = 0;
  int nm = 5;
  regmatch_t pm[nm];
  regex_t preg;
  char *match;
  const char *pattern = "virtual\\s+size:\\s+\\S+[A-Z]\\s+\\(([0-9]+)\\s+bytes\\)";
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
          printf ("match = %s\n", match);
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

int main (int argc, char const *argv[])
{
  char result[] = "image: win7_pro_convertvda_1b915685-012d-4c3d-8002-30f4bab0ca6c_c0a45da1-a06c-4837-a278-b3be2eb9e4e7\nfile format: raw\nvirtual size: 1.0T (1088292913152 bytes)\ndisk size: 0\n";
  char result2[] = "file format: qcow2\nvirtual size: 20G (21054357504 bytes)\ndisk size: 9.4G\ncluster_size: 65536\nFormat specific information:\n    compat: 0.10\n";
  int64_t size;
  size = get_real_vol_size_from_cmd_result (result);
  printf ("virtual size: %ld\n", size);
  return 0;
}
