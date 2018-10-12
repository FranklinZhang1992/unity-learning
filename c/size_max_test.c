#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <assert.h>

/* Minimum and maximum values for an integer type under the usual assumption.
   Return an unspecified value if BITS == 0, adding a check to pacify
   picky compilers.  */

#define _STDINT_MIN(signed, bits, zero) \
  ((signed) ? (- ((zero) + 1) << ((bits) ? (bits) - 1 : 0)) : (zero))

#define _STDINT_MAX(signed, bits, zero) \
  ((signed) \
   ? ~ _STDINT_MIN (signed, bits, zero) \
   : /* The expression for the unsigned case.  The subtraction of (signed) \
        is a nop in the unsigned case and avoids "signed integer overflow" \
        warnings in the signed case.  */ \
     ((((zero) + 1) << ((bits) ? (bits) - 1 - (signed) : 0)) - 1) * 2 + 1)





/* Given an unsigned 32-bit argument X, return the value corresponding to
   X with reversed byte order.  */
#define bswap_32(x) ((((x) & 0x000000FF) << 24) | \
                     (((x) & 0x0000FF00) << 8) | \
                     (((x) & 0x00FF0000) >> 8) | \
                     (((x) & 0xFF000000) >> 24))

#ifndef le32toh
#define le32toh(x) (x)
#endif
#ifndef le32toh
#define le32toh(x) bswap_32 (x)
#endif

typedef size_t hive_node_h;

struct ntreg_nk_record {
  int32_t seg_len;              /* length (always -ve because used) */
  char id[2];                   /* "nk" */
  uint16_t flags;               /* bit 1: HiveExit
                                   bit 2: HiveEntry == root key
                                   bit 3: NoDelete
                                   bit 4: SymbolicLink
                                   bit 5: CompressedName: Name is encoded
                                          in ASCII (actually: Latin-1)
                                          rather than UTF-16.
                                   bit 6: PredefinedHandle
                                   bit 7: VirtMirrored
                                   bit 8: VirtTarget
                                   bit 9: VirtualStore */
  /* Information from: Peter Norris: The Internal Structure of the
     Windows Registry, 2008, p.220 ff. */
  int64_t timestamp;
  uint32_t unknown1;
  uint32_t parent;              /* offset of owner/parent */
  uint32_t nr_subkeys;          /* number of subkeys */
  uint32_t nr_subkeys_volatile;
  uint32_t subkey_lf;           /* lf record containing list of subkeys */
  uint32_t subkey_lf_volatile;
  uint32_t nr_values;           /* number of values */
  uint32_t vallist;             /* value-list record */
  uint32_t sk;                  /* offset of sk-record */
  uint32_t classname;           /* offset of classname record */
  uint16_t max_subkey_name_len; /* maximum length of a subkey name in bytes
                                   if the subkey was reencoded as UTF-16LE */
  uint16_t unknown2;
  uint32_t unknown3;
  uint32_t max_vk_name_len;     /* maximum length of any vk name in bytes
                                   if the name was reencoded as UTF-16LE */
  uint32_t max_vk_data_len;     /* maximum length of any vk data in bytes */
  uint32_t unknown6;
  uint16_t name_len;            /* length of name */
  uint16_t classname_len;       /* length of classname */
  char name[1];                 /* name follows here */
} __attribute__((__packed__));

int main(int argc, char const *argv[])
{
    // uint32_t i;
    // for (i = 0; i < 50; i++) {
    //     printf("%zu\n", le32toh(i));
    // }
    struct ntreg_nk_record *nk =
    (struct ntreg_nk_record *) ((char *) h->addr + node);

    return 0;
}
