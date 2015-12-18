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

int process_doh_request( int , char ** );

int doh_sock = -1;
struct hostent *http_hostent;
struct sockaddr_in doh_address;
char login_username[256];
char login_password[256];

#define DOH_LOGIN 1

char *xml_login_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"10\" target=\"session\"><login><username><![CDATA[%s]]></username><password><![CDATA[%s]]></password></login></request></requests>";

int process_doh_request( int request, char **xml_ptr )
{
  int i, status;
  char *xml_request = NULL;
  char *tmp_ptr;
  FILE *filefd;
  char *http_string = NULL;

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
  doh_address.sin_addr = *(struct in_addr*) http_hostent->h_addr_list[0];
  doh_address.sin_family = AF_INET;
  doh_address.sin_port = htons(443);

  status = connect( doh_sock, (struct sockaddr *) &doh_address,
                    sizeof(doh_address) );

  if ( status < 0 ) {
     printf("Can't connect to HTTPS port\n");
     close(doh_sock);
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

  sent_bytes = send (doh_sock, http_request, strlen(http_request), 0);

  if ( sent_bytes < 0 ) {
     printf("Can't send to HTTP port\n");
     close(doh_sock);
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
    return(-1);
  }

  /*
   *  Read the data.  The MSG_WAITALL flag makes us wait until the full
   *  message is received or the sender disconnects.  We're in a while loop
   *  so that we can read the message in manageable chunks.
   */

  while ( received_bytes > 0 ) {

    received_bytes = recv(doh_sock, http_response, http_response_size, MSG_WAITALL);

    if ( received_bytes < 0 ) {
       printf("Can't receive from HTTP port\n");
       close(doh_sock);
       return(-1);
    }

    /*
     * Save the session ID so DOH doesn't have to create one for every request.
     * This will prevent a good deal of unhelpful xenapi log messages.
     */

    check_session_id(http_response);

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
}