#include <stdio.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>

// char server_name[] = "http://192.168.234.104";
char server_name[] = "http://localhost:8999/watch";

xmlDocPtr
do_doh_request (char *cmd, char * xml_name) {
  xmlDocPtr doc;
  char *curl_cmd = NULL;
  if (asprintf (&curl_cmd, "curl %s > %s", server_name, xml_name) == -1) {
    perror ("asprintf");
    exit (EXIT_FAILURE);
  }

  int r = system (curl_cmd);
  if (r != 0)
  {
    return NULL;
  }
  printf("r = %d\n", r);
  doc = xmlReadFile (xml_name, NULL, XML_PARSE_NOBLANKS);
  if (NULL == doc)
  {
    printf("fail read xml\n");
  }

  if ( remove (xml_name) != 0 )
      perror ("remove");
  return doc;
}

int main(int argc, char const *argv[])
{
  char cmd[] = "<request id='1' target='supernova'><watch/></request>";
  char file[] = "tmp.xml";
  do_doh_request (cmd, file);
  return 0;
}
