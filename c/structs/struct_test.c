#include <stdio.h>
#include <string.h>

const int LEN = 3;

struct config1
{
    char **disks;
};

struct disk_config
{
    char *name;
    char *storage_group_name;
};

struct config2
{
    struct disk_config *disks;
};

void print_config1 (struct config1 *config)
{
    printf("Output config1:\n");
    int i;
    for (i = 0; i < LEN; i++)
    {
        printf("%s\n", config->disks[i]);
    }
}

void print_config2 (struct config2 *config)
{
    printf("Output config2:\n");
    int i;
    for (i = 0; i < LEN; i++)
    {
        printf("%s\n", config->disks[i].name);
    }
}

void init_config1()
{
    struct config1 config;
    char *disk_array[] = {"sda", "sdb", "sdc"};

    config.disks = disk_array;
    print_config1(&config);
}

void init_config2()
{
    struct config2 config;
    struct disk_config disks[] = {{"sda", "Initial Storage Group"}, {"sdb", "Initial Storage Group"}, {"sdc", "Initial Storage Group"}};
    config.disks = disks;
    print_config2(&config);
}

int main(int argc, char const *argv[])
{
    init_config1();
    init_config2();
    return 0;
}