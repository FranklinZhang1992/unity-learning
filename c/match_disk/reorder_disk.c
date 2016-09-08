#include <stdio.h>
#include <string.h>

/*
 * gcc -o reorder_disk.o reorder_disk.c
 */

void
reorder_disk (char *disk_name, int order)
{
  printf ("Before: disk name = %s\n", disk_name);
  if (disk_name) {
    int disk_name_len = strlen (disk_name);
    int disk_order = disk_name[disk_name_len - 1];
    if (disk_order > order) {
      disk_name[disk_name_len - 1] = order;
    }
  }
  printf ("After: disk name = %s\n", disk_name);
}

int main (int argc, char const *argv[])
{
  char disk_name1[] = "xvda";
  char disk_name2[] = "xvdb";
  char disk_name3[] = "xvdc";
  char disk_name4[] = "xvdd";
  int order = 98;
  reorder_disk (disk_name1, order);
  reorder_disk (disk_name2, order);
  reorder_disk (disk_name3, order);
  reorder_disk (disk_name4, order);
  return 0;
}
