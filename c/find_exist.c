#include <stdio.h>
#include <stdlib.h>
#include <error.h>
#include <string.h>

int is_exist()
{
    char **array;
    int i, j, len;

    len = 3;

    array = malloc ((1 + len) * sizeof (char *));
    if (array == NULL) {
        printf("out of memory\n");
        exit (EXIT_FAILURE);
    }

    i = 0;
    while (i < len) {
        char *msg;
        if (asprintf (&msg, "%d", 1) == -1) {
            perror ("asprintf");
            exit (EXIT_FAILURE);
        }
        array[i] = msg;
        i++;
    }
    array[i] = NULL;

    printf("source array is:\n");
    for (i = 0; array[i] != NULL; ++i) {
        printf("array[%d] = %s\n", i, array[i]);
    }

    for (i = 0; array[i] != NULL; ++i) {
        for (j = i + 1; array[j] != NULL; ++j) {
            if (strcmp (array[i], array[j]) == 0) {
                return 1;
            }
        }
    }

    free (array);
    return 0;
}

int main(int argc, char const *argv[])
{
    if (is_exist()) {
        printf("exist\n");
    } else {
        printf("not exist\n");
    }
    return 0;
}