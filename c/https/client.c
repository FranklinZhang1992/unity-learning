/*
 * Use socket to send HTTPS request (default set as baidu)
 * Prepare: sudo apt-get install build-essential flex libelf-dev libc6-dev-amd64 binutils-dev libdwarf-dev
 * Required libs: openssl, libssl-dev
 * You can compile this file with the command below
 * gcc -o client.o client.c -lssl -lcrypto
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <openssl/bio.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/rand.h>

#define BUFSIZE 8
#define MAXLINE 40960

void
print_addr (char *protocol, char *host_addr, int port)
{
  char *addr;
  if (asprintf (&addr, "%s://%s:%d", protocol, host_addr, port) == 0) {
    fprintf(stderr, "print address error: %s\n", strerror (errno));
    exit(1);
  }
  printf("### host address is => %s\n\n", addr);
}

int
main (int argc, char const *argv[])
{
  char host_addr[] = "61.135.169.121";
  char protocol[] = "https";
  int host_port = 443;
  int socket_handle;
  struct sockaddr_in server_addr;
  int con_res;
  int ret;
  char request_header[MAXLINE], *str;
  socklen_t len;

  print_addr (protocol, host_addr, host_port);

  /* create socket */
  socket_handle = socket (AF_INET, SOCK_STREAM, 0);
  if (socket_handle < 0) {
    fprintf (stderr, "socket error: %s\n", strerror (errno));
    exit (1);
  }
  printf("### create socket\n");

  bzero (&server_addr, sizeof (server_addr));
  server_addr.sin_family = AF_INET;
  server_addr.sin_port = htons (host_port);
  if (inet_pton (AF_INET, host_addr, &server_addr.sin_addr) <= 0 ) {
    fprintf (stderr, "set ip address error: %s\n", strerror (errno));
    exit (1);
  };

  /* send connect request to connect to host */
  con_res = connect (socket_handle, (struct sockaddr *) &server_addr, sizeof (server_addr));
  if (con_res < 0) {
    fprintf (stderr, "socket connect error: %s\n", strerror (errno));
    exit (1);
  }
  printf ("### connection setup\n");

  SSL *ssl;
  SSL_CTX *ctx;

  /* ssl initialize */
  SSL_library_init ();
  SSL_load_error_strings ();
  ctx = SSL_CTX_new (SSLv23_client_method ());
  if (ctx == NULL) {
    fprintf (stderr, "new SSL CTX error: %s\n", strerror (errno));
    exit (1);
  }
  ssl = SSL_new (ctx);
  if (ssl == NULL)  {
    fprintf (stderr, "new SSL error: %s\n", strerror (errno));
    exit (1);
  }

  /* link ssl to socket */
  ret = SSL_set_fd (ssl, socket_handle);
  if (ret == 0) {
    fprintf (stderr, "SL link socket error: %s\n", strerror (errno));
    exit (1);
  }

  /* PRNG */
  // RAND_poll ();
  // while (RAND_status () == 0) {
  //   unsigned short rand_ret = rand () % 65536;
  //   RAND_seed (&rand_ret, sizeof (rand_ret));
  // }

  /* ssl connect */
  ret = SSL_connect (ssl);
  if (ret != 1) {
    fprintf (stderr, "SSL connect failed: %s\n", strerror (errno));
    exit (1);
  }

  /* build https request (copied from browser) */
  memset (request_header, 0, MAXLINE);
  strcat (request_header, "GET / HTTP/1.1\n");
  strcat (request_header, "Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\n");
  strcat (request_header, "Accept-Encoding:gzip, deflate, sdch\n");
  strcat (request_header, "Referer: https://61.135.169.121:443/\n");
  strcat (request_header, "Accept-Language:zh-CN,zh;q=0.8\n");
  strcat (request_header, "Cache-Control:max-age=0\n");
  strcat (request_header, "Connection:close\n");
  strcat (request_header, "Cookie:BD_HOME=0; BD_UPN=16314553\n");
  strcat (request_header, "Host:61.135.169.121\n");
  strcat (request_header, "User-Agent:Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.154 Safari/537.36 LBBROWSER\n");
  len = strlen (request_header);
  str = (char *) malloc (len);
  sprintf (str, "Content_Length:%d\n", len);
  strcat (request_header, str);
  strcat (request_header, "\n");
  printf ("### print request content:\n"
    "+=========================================+\n"
    "%s\n"
    "+=========================================+\n", request_header);

  /* send https request */
  int total_send = 0;
  int request_len = strlen (request_header);
  while (total_send < request_len) {
    int send = SSL_write (ssl, request_header + total_send, request_len - total_send);
    if (send == -1) {
      fprintf (stderr, "SSL send failed: %s\n", strerror (errno));
      exit (1);
    }
    total_send += send;
    printf ("### %d bytes send OK!\n", total_send);
  }

  /* receive https response */
  int response_len = 0;
  int i = 0;
  char buffer[BUFSIZE];
  memset (buffer, 0, BUFSIZE);
  char returnBuffer[MAXLINE];
  memset (returnBuffer, 0, MAXLINE);
  int p = 0;
  while ((response_len = SSL_read (ssl, buffer, 1)) == 1 && p < MAXLINE) {
    returnBuffer[p] = buffer[0];
    p++;
    returnBuffer[p] = '\0';
    if (i < 4) {
      if (buffer[0] == '\r' || buffer[0] == '\n')
        i++;
      else
        i = 0;
    }
  }
  printf ("### print response content:\n"
    "+=========================================+\n"
    "%s\n"
    "+=========================================+\n", returnBuffer);

  /* shutdown community */
  close (socket_handle);
  ret = SSL_shutdown (ssl);
  if (ret != 1) {
    SSL_shutdown (ssl);
  }
  SSL_free (ssl);
  SSL_CTX_free (ctx);
  ERR_free_strings ();

  return 0;
}
