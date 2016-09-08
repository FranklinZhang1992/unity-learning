#include <stdio.h>
#include <string.h>

#define STRPREFIX(a,b) (strncmp((a),(b),strlen((b))) == 0)

/*
 * gcc -o rename_disk.o rename_disk.c
 */

void
rename_disk (char *boot_disk_name, char *disk_name)
{
  printf ("Before: disk name = %s\n", disk_name);
  if (boot_disk_name && STRPREFIX (disk_name, "xvd")) {
    int current_order = disk_name[strlen (disk_name) - 1];
    int boot_disk_order = boot_disk_name[strlen (boot_disk_name) - 1];
    if (current_order > boot_disk_order) {
      disk_name[strlen (disk_name) - 1] = current_order - 1;
    }
  }
  printf ("After: disk name = %s\n", disk_name);
}

int main (int argc, char const *argv[])
{
  char boot_disk[] = "xvdb";
  char disk_name1[] = "xvda";
  char disk_name2[] = "xvdb";
  char disk_name3[] = "xvdc";
  char disk_name4[] = "xvdd";
  rename_disk (boot_disk, disk_name1);
  rename_disk (boot_disk, disk_name2);
  rename_disk (boot_disk, disk_name3);
  rename_disk (boot_disk, disk_name4);
  return 0;
}
