#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libvirt/libvirt.h>
#include <libvirt/virterror.h>

// gcc -o get_domains.o get_domains.c -lvirt

int get_domains() {

  virConnectPtr conn = 0;
  char *conn_string = NULL;
  int n;

  conn_string = strdup("qemu:///system");

  /* open libvirt connection */
  conn = virConnectOpenReadOnly(conn_string);
  free (conn_string);

  n = virConnectNumOfDomains(conn);
  if (n < 0) {
    printf("error reading number of domains\n");
    return -1;
  } else {
    printf("find %d domians\n", n);
  }

  if (n > 0) {
    int *domids;

    /* Get list of domains. */
    domids = malloc(sizeof(*domids) * (n + 1));
    if (domids == NULL) {
      printf("malloc failed for domids\n");
      return -1;
    }

    n = virConnectListDomains(conn, domids, n);
    if (n < 0) {
      printf("error reading list of domains\n");
      free(domids);
      return -1;
    }
    printf("virConnectListDomains with return value %d\n", n);

    /* Fetch each domain and add it to the list, unless ignore. */
    int i = 0;
    for (i = 0; i < n; ++i) {
      virDomainPtr dom = NULL;
      const char *name;

      printf("i = %d\n", i);
      dom = virDomainLookupByID(conn, domids[i]);
      if (dom == NULL) {
        printf("error virDomainLookupByID\n");
        /* Could be that the domain went away -- ignore it anyway. */
        continue;
      }
      printf("virDomainLookupByID\n");

      name = virDomainGetName(dom);
      if (name == NULL) {
        printf("error virDomainGetName\n");
      }
      printf("virDomainGetName\n");

      printf("get domain %s with id %d.\n", name, domids[i]);

      free(domids);
    }
  }
}

int main(int argc, char const *argv[])
{
  printf("begin#####\n");
  if (get_domains() < 0) {
    printf("failed to get domain ids.\n");
  }
  printf("end#####\n");
  return 0;
}
