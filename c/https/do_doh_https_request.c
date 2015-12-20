/*
 * gcc -o doh.o do_doh_https_request.c -lssl -I /usr/include/libxml2 -lxml2
 */
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <openssl/bio.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/rand.h>
#include <netdb.h>
#include <libxml/xmlreader.h>

#define XML_TEMP_FILE "/etc/snmp/tempxml"
#define INIT_HTTP_RESPONSE_SIZE 100000


int process_doh_request( int , char ** );

int doh_sock = -1;
int http_string_length, xml_string_length;
int sent_bytes, received_bytes;
char http_request[1024];
char *http_response = NULL;
int http_response_size = 0;
struct hostent *http_hostent;
struct sockaddr_in doh_address;
char login_request[1024];
char login_username[256];
char login_password[256];
char current_session_id[256];

#define DOH_LOGIN 1

char *xml_login_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"10\" target=\"session\"><login><username><![CDATA[%s]]></username><password><![CDATA[%s]]></password></login></request></requests>";

int process_doh_request( int request, char **xml_ptr )
{
  int i, status;
  char *xml_request = NULL;
  char *tmp_ptr;
  FILE *filefd;
  char *http_string = NULL;
  SSL *ssl;
  SSL_CTX *ctx;
  int ret;

  char *http_login_string = "POST /doh/ HTTP/1.0\r\nHost: localhost\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11\r\nAccept: text/javascript, text/html, application/xml, text/xml, */*\r\nAccept-Language: en-us,en;q=0.5\r\nAccept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 300\r\nConnection: close\r\nContent-Type: text/xml\r\nContent-Length: %d\r\nPragma: no-cache\r\nCache-Control: no-cache\r\n\r\n";

  switch( request ) {
  case DOH_LOGIN:
    strcpy(login_username, "admin");
    strcpy(login_username, "admin");
    sprintf(login_request, xml_login_request, login_username, login_password);
    break;
  }

  /*
   *  Create a socket.
   */
  doh_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if ( doh_sock < 0 ) {
     printf("Can't open socket for DOH\n");
     return(-1);
  }

  /*
   *  Open a connection to DOH.  THe HTTPS port is 443.
   */
  http_hostent = gethostbyname("localhost");
  if ( http_hostent == NULL ) {
       printf("Can't get localhost information\n");
       close(doh_sock);
       return(-1);
  }

  memset( &doh_address, 0, sizeof(doh_address) );
  char **pptr;
  pptr = http_hostent->h_addr_list;
  // doh_address.sin_addr = *(struct in_addr*) http_hostent->h_addr_list[0];
  doh_address.sin_family = AF_INET;
  doh_address.sin_port = htons(443);

  status = connect( doh_sock, (struct sockaddr *) &doh_address,
                    sizeof(doh_address) );

  if ( status < 0 ) {
    printf("Can't connect to HTTPS port\n");
    close(doh_sock);
    return (-1);
  }

  /* ssl initialize */
  SSL_library_init();
  SSL_load_error_strings();
  ctx = SSL_CTX_new(SSLv23_client_method());
  if ( ctx == NULL ) {
    printf("new SSL CTX error\n");
    SSL_CTX_free(ctx);
    return (-1);
  }
  ssl = SSL_new(ctx);
  if ( ssl == NULL )  {
     printf("new SSL error\n");
     close(doh_sock);
     SSL_free(ssl);
     return (-1);
  }

  /* link ssl to socket */
  ret = SSL_set_fd(ssl, doh_sock);
  if ( ret == 0 ) {
    printf("SL link socket error\n");
    close(doh_sock);
    ret = SSL_shutdown(ssl);
    if ( ret != 1 ) {
      SSL_shutdown(ssl);
    }
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return (-1);
  }

  /* PRNG */
  // RAND_poll();
  // while ( RAND_status() == 0 ) {
  //   unsigned short rand_ret = rand() % 65536;
  //   RAND_seed(&rand_ret, sizeof (rand_ret));
  // }

  /* ssl connect */
  ret = SSL_connect(ssl);
  if ( ret != 1 ) {
    printf("SSL connect failed\n");
    close(doh_sock);
    ret = SSL_shutdown(ssl);
    if ( ret != 1 ) {
      SSL_shutdown(ssl);
    }
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return (-1);
  }

  switch(request) {
  case DOH_LOGIN:
    http_string = http_login_string;
    xml_request = login_request;
    break;
  }

  xml_string_length = strlen(xml_request);


  http_string_length = sprintf(http_request, http_string,
                             xml_string_length, current_session_id);


  strcat(http_request, xml_request);

  /* printf("Request:\n%s\n", http_request); */
  /* send https request */
  sent_bytes = SSL_write (ssl, http_request, strlen(http_request));

  if ( sent_bytes < 0 ) {
     printf("Can't send to HTTPS port\n");
     close(doh_sock);
     ret = SSL_shutdown(ssl);
     if ( ret != 1 ) {
       SSL_shutdown(ssl);
     }
     SSL_free(ssl);
     SSL_CTX_free(ctx);
     return(-1);
  }

  /*
   * Create the buffer if we don't have one.
   */

  if ( http_response == NULL ) {
    http_response = malloc(INIT_HTTP_RESPONSE_SIZE);
    if ( http_response > 0 ) {
      http_response_size = INIT_HTTP_RESPONSE_SIZE;
    }
    else {
      http_response_size = 0;
      http_response = NULL;
      close(doh_sock);
      ret = SSL_shutdown(ssl);
      if ( ret != 1 ) {
        SSL_shutdown(ssl);
      }
      SSL_free(ssl);
      SSL_CTX_free(ctx);
      return(-1);
    }
  }

  memset(http_response, 0, http_response_size);
  received_bytes = http_response_size;

  /*
   *  We're going to write the entire message to a file.
   */

  filefd = fopen(XML_TEMP_FILE, "w+");

  if ( filefd < 0 ) {
    printf("Warning - Unable to open /etc/snmp/tempxml\n");
    close(doh_sock);
    ret = SSL_shutdown(ssl);
    if ( ret != 1 ) {
      SSL_shutdown(ssl);
    }
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return(-1);
  }

  /*
   *  Read the data.  The MSG_WAITALL flag makes us wait until the full
   *  message is received or the sender disconnects.  We're in a while loop
   *  so that we can read the message in manageable chunks.
   */

  while ( received_bytes > 0 ) {
    received_bytes = SSL_read (ssl, http_response, http_response_size);

    if ( received_bytes < 0 ) {
       printf("Can't receive from HTTPS port\n");
       close(doh_sock);
       ret = SSL_shutdown(ssl);
       if ( ret != 1 ) {
         SSL_shutdown(ssl);
       }
       SSL_free(ssl);
       SSL_CTX_free(ctx);
       return(-1);
    }

    /*
     * Save the session ID so DOH doesn't have to create one for every request.
     * This will prevent a good deal of unhelpful xenapi log messages.
     */

    // check_session_id(http_response);

    tmp_ptr = http_response;

    /*
     *  The XML part of the message begins with <?xml, so only start
     *  processing the message from that point.
     */

    *xml_ptr = strstr(http_response, "<?xml");

    if (*xml_ptr != NULL) {
      tmp_ptr = *xml_ptr;
      received_bytes = received_bytes - (*xml_ptr - http_response);
    }

    /*
     *  We're going to write the message to a file.  The XML parser
     *  doesn't like unprintable characters, so filter those out.
     */

    for ( i = 0; i < received_bytes; i++ ) {

      if ( isprint(tmp_ptr[i]) ) {
        fputc( tmp_ptr[i], filefd );
      }
    }
  }

  fclose(filefd);

  close(doh_sock);
  ret = SSL_shutdown(ssl);
  if ( ret != 1 ) {
    SSL_shutdown(ssl);
  }
  SSL_free(ssl);
  SSL_CTX_free(ctx);
}

int main(int argc, char const *argv[])
{
  char *xml_ptr;
  int status;
  status = process_doh_request( DOH_LOGIN, &xml_ptr );
  if ( status == -1 ) {
      printf("Unable to log in to DOH! Some SNMP results may not be updated.\n");
      return -1;
  }
  printf("process_doh_request success\n");
  return 0;
}
