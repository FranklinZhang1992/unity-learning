#include <stdio.h>

// static int
// launch_direct (guestfs_h *g, void *datav, const char *arg)
// {
//     printf("%s\n", "launch_direct");
// }


// static struct backend_ops {
//   .data_size = sizeof (struct backend_direct_data),
//   .launch = launch_direct,
// };

// struct backend_ops {
//     int (*launch) (guestfs_h *g, void *data, const char *arg);
// };

struct guestfs_h
{
    const struct backend_ops *backend_ops;
    char *backend_arg;
    void *backend_data;
};

int main(int argc, char const *argv[])
{
    struct guestfs_h guest = {
        // {},
        "backend_data",
        "backend_arg"
    };
    struct guestfs_h *g;
    g = &guest;
    printf("%s\n", g->backend_arg);
    // g->backend_data = "backend_data";
    // g->backend_arg = "backend_arg";
    // g->backend_ops->launch (g, g->backend_data, g->backend_arg);
    return 0;
}