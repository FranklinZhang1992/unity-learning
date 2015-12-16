#include <stdio.h>
#include <sys/statvfs.h>
#include <sys/types.h>

int main(int argc, char const *argv[])
{
    int r;
    struct statvfs statbuf;
    char *path = "/home/franklin/workspace/democ";
    r = statvfs (path, &statbuf);
    if (r != -1)
    {
        printf("%lu\n", statbuf.f_bsize);
        printf("%lu\n", statbuf.f_frsize);
        printf("%lu\n", statbuf.f_blocks);
        printf("%lu\n", statbuf.f_bfree);
        printf("%lu\n", statbuf.f_bavail);
        printf("%lu\n", statbuf.f_files);
        printf("%lu\n", statbuf.f_ffree);
        printf("%lu\n", statbuf.f_favail);
        printf("%lu\n", statbuf.f_fsid);
        printf("%lu\n", statbuf.f_flag);
        printf("%lu\n", statbuf.f_namemax);
    }
    return 0;
}