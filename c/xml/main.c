/*
 * gcc -o main.o main.c -lssl -I /usr/include/libxml2 -lxml2
 */
#include <stdio.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>

xmlXPathObjectPtr
get_nodeset (xmlDocPtr doc, xmlChar *xpath)
{
  xmlXPathContextPtr context;
  xmlXPathObjectPtr result;
  context = xmlXPathNewContext (doc);
  if (context == NULL) {
    printf ("Error in xmlXPathNewContext\n");
    return NULL;
  }
  result = xmlXPathEvalExpression (xpath, context);
  xmlXPathFreeContext (context);
  if (result == NULL) {
    printf ("Error in xmlXPathEvalExpression\n");
    return NULL;
  }
  if (xmlXPathNodeSetIsEmpty (result->nodesetval)) {
    xmlXPathFreeObject (result);
    printf ("No result\n");
    return NULL;
  }
  return result;
}

void
parse_xml (char *xml_name)
{
  int i;
  xmlDocPtr doc;
  xmlNodeSetPtr nodeset;
  xmlXPathObjectPtr result;
  xmlNodePtr cur;
  xmlChar *id = NULL;
  xmlChar *name = NULL;

  // Load XML file
  doc = xmlReadFile (xml_name, NULL, XML_PARSE_NOBLANKS);

  xmlChar *xpath = (xmlChar*) "/demo/node";
  result = get_nodeset (doc, xpath);
  if (result) {
    nodeset = result->nodesetval;
    for (i = 0; i < nodeset->nodeNr; i++) {
      cur = nodeset->nodeTab[i];
      if (cur) {
        id = xmlGetProp (cur, (const xmlChar *) "id");
      }
      cur = cur->children;
      while (cur) {
        if (xmlStrcmp (cur->name, (const xmlChar*) "name") == 0) {
          name = xmlNodeGetContent (cur);
          break;
        }
        cur = cur->next;
      }
      printf ("id = %s, name = %s\n", id, name);
      xmlFree (id);
      xmlFree (name);
    }
  }
  xmlFreeDoc (doc);

}

int main(int argc, char const *argv[])
{
  char xml_name[] = "demo.xml";
  parse_xml (xml_name);
  return 0;
}
