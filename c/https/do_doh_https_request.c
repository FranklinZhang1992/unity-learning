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
#include <regex.h>

#define EVERRUNALERTCALLHOMESENT_UNKNOWN    1
#define EVERRUNALERTCALLHOMESENT_FALSE    2
#define EVERRUNALERTCALLHOMESENT_TRUE   3

/*
 * enums for column everRunAlertEAlertSent
 */
#define EVERRUNALERTEALERTSENT_UNKNOWN    1
#define EVERRUNALERTEALERTSENT_FALSE    2
#define EVERRUNALERTEALERTSENT_TRUE   3

/*
 * enums for column everRunAlertSNMPTrapSent
 */
#define EVERRUNALERTSNMPTRAPSENT_UNKNOWN    1
#define EVERRUNALERTSNMPTRAPSENT_FALSE    2
#define EVERRUNALERTSNMPTRAPSENT_TRUE   3


/*
 * enums for scalar sraAgentMibFamily
 */
#define SRAAGENTMIBFAMILY_STCP    1
#define SRAAGENTMIBFAMILY_FTSERVER    2
#define SRAAGENTMIBFAMILY_FTLINUX   3
#define SRAAGENTMIBFAMILY_AVANCE    4
#define SRAAGENTMIBFAMILY_EVERRUN   5

/*
 * enums for scalar sraAgentMibRevision
 */
#define SRAAGENTMIBREVISION_REV01   1

/*
 * enums for scalar sraSiOverallSystemStatus
 */
#define SRASIOVERALLSYSTEMSTATUS_UNSUPPORTED    1
#define SRASIOVERALLSYSTEMSTATUS_NOFAULTS   2
#define SRASIOVERALLSYSTEMSTATUS_SYSTEMFAULT    3
#define SRASIOVERALLSYSTEMSTATUS_SYSTEMDOWN   4

/*
 * enums for scalar sraSiCpuFamily
 */
#define SRASICPUFAMILY_UNSUPPORTED    1
#define SRASICPUFAMILY_M68K   2
#define SRASICPUFAMILY_I860   3
#define SRASICPUFAMILY_HPPA   4
#define SRASICPUFAMILY_IA32   5
#define SRASICPUFAMILY_IA64   6

/*
 * enums for scalar sraSiOsType
 */
#define SRASIOSTYPE_UNSUPPORTED   1
#define SRASIOSTYPE_FTX   2
#define SRASIOSTYPE_HPUX    3
#define SRASIOSTYPE_FTLINUX   4
#define SRASIOSTYPE_VOS   5
#define SRASIOSTYPE_WINDOWS   6
#define SRASIOSTYPE_AVANCE  7
#define SRASIOSTYPE_EVERRUN 8

#define XML_TEMP_FILE "/tmp/snmp/tempxml"
#define INIT_HTTP_RESPONSE_SIZE 100000


int process_doh_request( int , char ** );

static int keep_running;
int enable_requests = 0;

// pthread_mutex_t doh_mutex = PTHREAD_MUTEX_INITIALIZER;

struct hostent *http_hostent;
struct sockaddr_in doh_address;
int doh_sock = -1;
int http_string_length, xml_string_length;
int sent_bytes, received_bytes;
char http_request[1024];
char *http_response = NULL;
int http_response_size = 0;
char login_request[1024];
char login_username[256];
char login_password[256];
char current_session_id[256];
time_t lastcredtime = 0;
time_t lastalerttime = 0;
time_t lastaudittime = 0;
time_t lastconfigtime = 0;
time_t lasthosttime = 0;
time_t lastsupernovatime = 0;
time_t lastusertime = 0;
time_t laststoragetime = 0;
char salt1[] = "avance";
int salt1len = 6;
char salt2[] = "EVERrun";
int salt2len = 7;
char secret[] = "NNY";
int secretlen = 3;

struct alertLogEntry {
   struct alertLogEntry *next_ptr;
   char alertID[40];
   char logID[40];
   char *source;
   char *timestamp;
   char *explain_text;
   char *type;
   char *SNMPtrap_OID;
   int severity;
   int callhome_sent;
   int eAlert_sent;
   int SNMPtrap_sent;
};

struct auditLogEntry {
   struct auditLogEntry *next_ptr;
   char *index;
   char *day;
   char *timestamp;
   char remotehost[4];
   char *remoteuser;
   char *description;
};

struct alertLogEntry *alertTableList = NULL;
struct auditLogEntry *auditTableList = NULL;
struct alertLogEntry *doh_alertTableList = NULL;
struct auditLogEntry *doh_auditTableList = NULL;
struct alertLogEntry *alertTableWalkList = NULL;
struct auditLogEntry *auditTableWalkList = NULL;

int doh_alertTableFlag = 0;
int doh_auditTableFlag = 0;

char *blank = " ";

struct in_addr ipAddress;
struct in_addr doh_ipAddress;
char *systemName = NULL;
char *doh_systemName = NULL;
int systemMemory = 0;
int doh_systemMemory = 0;
int systemCPUs = 0;
int doh_systemCPUs = 0;
int systemUsedCPUs = 0;
int doh_systemUsedCPUs = 0;
int systemMaxCPUsPerVM = 0;
int doh_systemMaxCPUsPerVM = 0;
int systemState = 0;
int doh_systemState = 0;
char *systemSerial = NULL;
char *doh_systemSerial = NULL;
char *systemSiteID = NULL;
char *doh_systemSiteID = NULL;
int systemStorageUsed = 0;
int doh_systemStorageUsed = 0;
int systemStorageFree = 0;
int doh_systemStorageFree = 0;
int systemStorageTotal = 0;
int doh_systemStorageTotal = 0;


int in_alert = 0;
int in_audit = 0;
int in_log = 0;
int in_callhome = 0;
int in_ealert = 0;
int in_snmp = 0;

long long host_storage_total[2];

char *alertTablePtr = "alert table";
long alertIndex = 1;
long *alertIndexPtr = &alertIndex;
long alertSeverity = 0;
long *alertSeverityPtr = &alertSeverity;
char *alertTypePtr = "alert type";
char *alertSNMPTrapOIDPtr = NULL;
char *alertSourcePtr = "alert source";
char *alertDateTimePtr = "today";
long alertCallHomeSent = 0;
long *alertCallHomeSentPtr = &alertCallHomeSent;
long alertEAlertSent = 0;
long *alertEAlertSentPtr = &alertEAlertSent;
long alertSNMPTrapSent = 0;
long *alertSNMPTrapSentPtr = &alertSNMPTrapSent;
char *alertInformationPtr = "alert info";

char *auditTablePtr = "audit table";
long auditIndex = 1;
long *auditIndexPtr = &auditIndex;
char auditDateTime[80];
char *auditDateTimePtr = "today";
char *auditUsernamePtr = "me";
char *auditOriginatingHostPtr = "my DUT";
char *auditActionPtr = "none";

int loopContext = 1;
int noLoopContext = 0;
int indexdata = 1;

#define DOH_SUPERNOVA 0
#define DOH_LOGIN 1
#define DOH_SYSTEM_STATUS 2
#define DOH_SYSTEM_NAME 3
#define DOH_SERIAL_NUMBER 4
#define DOH_SITE_ID 5
#define DOH_AVAIL_VIRTUAL_MEMORY 6
#define DOH_VIRTUAL_CPU_TOTAL 7
#define DOH_VIRTUAL_CPU_IN_USE 8
#define DOH_VIRTUAL_CPUS_MAX_PER_VM 9
#define DOH_VIRTUAL_CPUS_PERCENTAGE_USED 10
#define DOH_STORAGE_TOTAL 11
#define DOH_STORAGE_USED 12
#define DOH_STORAGE_USED_BY_MANAGEMENT 13
#define DOH_STORAGE_FREE 14
#define DOH_DISK_READ_BYTES 15
#define DOH_DISK_WRITE_BYTES 16
#define DOH_NETWORK_READ_BYTES 17
#define DOH_NETWORK_WRITE_BYTES 18
#define DOH_ALERT_TABLE 19
#define DOH_AUDIT_TABLE 20
#define DOH_LOGOUT 21

#define DOH_SUCCESS 0
#define DOH_RESPONSE -1
#define DOH_NEED_LOGIN -2

char *xml_supernova_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"20\" target=\"supernova\"><select></select></request></requests>";

char *xml_login_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"10\" target=\"session\"><login><username><![CDATA[%s]]></username><password><![CDATA[%s]]></password></login></request></requests>";

char *xml_logout_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"10\" target=\"session\"><logout /></request></requests>";

char *xml_host_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"20\" target=\"host\"><select></select></request></requests>";

char *xml_user_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"1\" target=\"user\"><viewOwner/></request></requests>";

char *xml_sharedstorage_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"1\" target=\"sharedstorage\"><select></select></request></requests>";

char *xml_volume_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"1\" target=\"volume\"><select>volume/size</select></request></requests>";

char *xml_alert_table_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"1\" target=\"alert\"><select></select></request></requests>";

char *xml_audit_table_request = "<?xml version=\"1.0\" encoding=\"utf-8\"?><requests output=\"XML\"><request id=\"1\" target=\"audit\"><select></select></request></requests>";

static char * copy_string (char * src)
{
  int copy_len;
  char * copy;

  if (src) {  // only if not null
    copy_len = strlen (src);
    copy = malloc (copy_len + 1);
    strncpy (copy, src, copy_len);
    copy[copy_len] = 0;
    return copy;
  }
  else {
    return NULL;
  }
}

static int copy_integer (char * src)
{
  if (src) {
    return atoi (src);
  }
  else {
    return 0;
  }
}

int get_tag_value( xmlTextReaderPtr reader, const xmlChar **name,
                   char *tagName, char **value ) {

  int ret;
  const xmlChar *read_value;

  // we've just read the tag name; read the next element
  // (which should be the value)
  ret = xmlTextReaderRead(reader);
  if ( ret != 1 ) return (ret);
  *name = xmlTextReaderConstName(reader);
  read_value = xmlTextReaderConstValue(reader);


  // if there was no value, for example:
  //
  //   <iceCreamFlavor></iceCreamFlavor>
  //
  // then, we will have gotten the tag name back
  // as the "name"; if this is the case, we skip
  // getting the value
  if ( strcmp( (char *) *name, tagName ) != 0 ) {
     /*if (*value != NULL) free (*value);a*/
     *value = copy_string( (char *) read_value );

     // read the ending tag (for example,
     // </iceCreamFlavor> returns "iceCreamFlavor")

     ret = xmlTextReaderRead(reader);
     *name = xmlTextReaderConstName(reader);
  }
  return(ret);
}

int populate_login_scalars( char *xml_ptr ) {

    xmlTextReaderPtr reader;

    int ret;
    const xmlChar *name;
    char *temp_value;

    /*
     *  Access the XML message (already read into memory).
     */
    reader = xmlReaderForFile(XML_TEMP_FILE, 0, 0);
    if (reader == NULL)
        return(0);

    /*
     *  Loop through all the info in the XML message, a
     *  line at a time.
     */
    while ((ret = xmlTextReaderRead(reader)) == 1) {

        /* Get the name just read. */
        name = xmlTextReaderConstName(reader);

        if ( strcmp( (char *) name, "login" ) == 0 ) {

            /*
             *  We have a "login" tag.
             *  If it is empty, there was an error logging in.
             */
            if ( xmlTextReaderIsEmptyElement(reader) == 1 ) return(0);
        }
        else if ( strcmp( (char *) name, "session-id" ) == 0 ) {

            /* We have a "session-id" tag. */
            if ( xmlTextReaderIsEmptyElement(reader) == 1 ) return(0);

            ret = get_tag_value( reader, &name, "session-id", &temp_value );

            /* If we got a value, save the session ID globally. */
            if ((ret == 1) && (temp_value != NULL)) {

                strncpy(current_session_id, temp_value,
                        sizeof(current_session_id));
                current_session_id[sizeof(current_session_id)-1] = '\0';
                free(temp_value);
                temp_value = NULL;
                printf("Using authenticated session ID: %s\n", current_session_id);
            }

        } /* end while */
    }

    /*
     *  Free the XML reader.
     */
    xmlFreeTextReader(reader);
    return(1);
}

/*
 * Check for login errors.
 */
int check_need_login(const xmlChar *name, xmlTextReaderPtr reader)
{
    int ret = 0;
    char *temp_value = NULL;

    if (strcmp((char *)name, "error") == 0) {
        if (xmlTextReaderIsEmptyElement(reader) == 1) return 0;
        ret = get_tag_value(reader, &name, "error", &temp_value);

        if ((ret == 1) && (temp_value != NULL))
            if (strstr(temp_value, "login required") != NULL)
                ret = DOH_NEED_LOGIN;

        if (temp_value != NULL)
            free(temp_value);
    }

    return ret;
}

/*
 *  populate_supernova_scalars takes a previously fetched XML
 *  message that contains Supernova info and sets scalar
 *  values based on that info.
 */

int populate_supernova_scalars( char *xml_ptr ) {

   xmlTextReaderPtr reader;

   int ret, status;
   int error_found = 0;
   const xmlChar *name;
   char *temp_value;
   long long  memory_int64;

   /*
    *  Free any elements already on the alert list.
    */
#if 0
   while ( alertTableList != NULL ) {

      alert_entry = alertTableList;
      if ( alert_entry->source != NULL )
         free ( alert_entry->source );
      if ( alert_entry->timestamp != NULL )
         free ( alert_entry->timestamp );
      if ( ( alert_entry->explain_text != NULL ) &&
           ( alert_entry->explain_text != blank ) )
         free ( alert_entry->explain_text);
      if ( alert_entry->type != NULL )
         free ( alert_entry->type );
      if ( ( alert_entry->SNMPtrap_OID != NULL ) &&
           ( alert_entry->SNMPtrap_OID != blank ) )
         free ( alert_entry->SNMPtrap_OID);

      alertTableList = alert_entry->next_ptr;
   }

   alert_entry = NULL;
#endif

   /*
    *  Access the XML message (already read into memory).
    */

   reader = xmlReaderForFile(XML_TEMP_FILE, 0, 0);
   if (reader == NULL)
      return(0);

   /*
    *  Free previous value.
    */

   if ( ( systemName != NULL ) && ( systemName != blank ) ) {
      free( systemName );
      systemName = blank;
   }


   /*
    *  Loop through all the info in the XML message, a
    *  line at a time.
    */

   while ((ret = xmlTextReaderRead(reader)) == 1) {

      /*
       *  Get the name just read.
       */

      name = xmlTextReaderConstName(reader);

      /*
       * Check if DOH requires a login.
       * If it does, return DOH_NEED_LOGIN to login and retry.
       */
      ret = check_need_login(name, reader);
      if ( ret < 0 ) {
          xmlFreeTextReader(reader);
          return ret;
      }

      /*
       * We can get an error before DOH has fully initialized.
       */
      if ( strcmp( (char *) name, "error" ) == 0 ) {

          error_found = 1;
          printf ("populate_supernova_scalars encountered DOH error\n");

      }
      else if ( strcmp( (char *) name, "management-ip" ) == 0 ) {

        /*
         *  We have a "management-ip" tag.
         *  Get its value if the tag is not empty.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;

        ret = get_tag_value( reader, &name, "management-ip", &temp_value );

        /*
         *  If we got a value, set the appropriate info in our new
         *  alert entry.
         */

        if ((ret == 1) && (temp_value != NULL)) {

            status = inet_aton( temp_value, &ipAddress );

            free(temp_value);
            temp_value = NULL;
        }
      }

      /*
       *  The "name" tag...
       */

      else if ( strcmp( (char *) name, "name" ) == 0 ) {

        /*
         *  If there is a value for this tag, get it.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
        ret = get_tag_value( reader, &name, "name", &systemName );

        if ( systemName == 0 ) systemName = blank;

      }

      /*
       *  The "memory-total" tag...
       */

      else if ( strcmp( (char *) name, "memory-total" ) == 0 ) {

        /*
         *  If there is a value for this tag, get it.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
        ret = get_tag_value( reader, &name, "memory-total", &temp_value );

        /*
         *  Convert to megabytes.
         */

        if ( temp_value > 0 ) {

          memory_int64 = atoll( temp_value );
          systemMemory = memory_int64 / 1048576;

          free( temp_value );
        }

        temp_value = NULL;
      }

      /*
       *  The "vcpus-total" tag...
       */

      else if ( strcmp( (char *) name, "vcpus-total" ) == 0 ) {

        /*
         *  If there is a value for this tag, get it.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
        ret = get_tag_value( reader, &name, "vcpus-total", &temp_value );

        /*
         *  Convert to megabytes.
         */

        if ( temp_value > 0 ) {

          systemCPUs = atoi( temp_value );

          free( temp_value );
        }

        temp_value = NULL;
      }

      /*
       *  The "vcpus-used" tag...
       */

      else if ( strcmp( (char *) name, "vcpus-used" ) == 0 ) {

        /*
         *  If there is a value for this tag, get it.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
        ret = get_tag_value( reader, &name, "vcpus-used", &temp_value );

        /*
         *  Convert to megabytes.
         */

        if ( temp_value > 0 ) {

          systemUsedCPUs = atoi( temp_value );

          free( temp_value );
        }

        temp_value = NULL;
      }

      /*
       *  The "vcpus-max-per-vm" tag...
       */

      else if ( strcmp( (char *) name, "vcpus-max-per-vm" ) == 0 ) {

        /*
         *  If there is a value for this tag, get it.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
        ret = get_tag_value( reader, &name, "vcpus-max-per-vm", &temp_value );

        /*
         *  Convert to megabytes.
         */

        if ( temp_value > 0 ) {

          systemMaxCPUsPerVM = atoi( temp_value );

          free( temp_value );
        }

        temp_value = NULL;
      }

      else if ( strcmp( (char *) name, "sra-si-overall-system-status") == 0)  {

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
  ret = get_tag_value( reader, &name, "sraSiOverallSystemStatus", &temp_value );

  if (temp_value != NULL) {

    if (strcmp( (char *) temp_value, "NOFAULTS") == 0) {
      systemState = SRASIOVERALLSYSTEMSTATUS_NOFAULTS;
    }

    else if (strcmp( (char *) temp_value, "SYSTEMFAULT") == 0) {
      systemState = SRASIOVERALLSYSTEMSTATUS_SYSTEMFAULT;
    }

    else if (strcmp( (char *) temp_value, "SYSTEMDOWN") == 0) {
      systemState = SRASIOVERALLSYSTEMSTATUS_SYSTEMDOWN;
    }

    free( temp_value);
    temp_value = NULL;

  }
      }


    } /* end while */

    /*
     *  Free the XML reader.
     */

    xmlFreeTextReader(reader);

    if (error_found == 1)
      return (0);

    lastsupernovatime = time( 0 );

    return(1);
}

/*
 *  populate_host_scalars takes a previously fetched XML
 *  message that contains host info and sets scalar
 *  values based on that info.
 */

int populate_host_scalars( char *xml_ptr ) {

   xmlTextReaderPtr reader;

   int ret;
   int system_ok = 0;
   int system_warning = 0;
   int system_broken = 0;
   const xmlChar *name;
   char *temp_value;

   /*
    *  Free any elements already on the alert list.
    */
#if 0
   while ( alertTableList != NULL ) {

      alert_entry = alertTableList;
      if ( alert_entry->source != NULL )
         free ( alert_entry->source );
      if ( alert_entry->timestamp != NULL )
         free ( alert_entry->timestamp );
      if ( ( alert_entry->explain_text != NULL ) &&
           ( alert_entry->explain_text != blank ) )
         free ( alert_entry->explain_text);
      if ( alert_entry->type != NULL )
         free ( alert_entry->type );
      if ( ( alert_entry->SNMPtrap_OID != NULL ) &&
           ( alert_entry->SNMPtrap_OID != blank ) )
         free ( alert_entry->SNMPtrap_OID);

      alertTableList = alert_entry->next_ptr;
   }

   alert_entry = NULL;
#endif

  /*
   *  Access the XML message (already read into memory).
   */

   reader = xmlReaderForFile(XML_TEMP_FILE, 0, 0);
   if (reader == NULL)
      return(0);

   /*
    *  Loop through all the info in the XML message, a
    *  line at a time.
    */

   while ((ret = xmlTextReaderRead(reader)) == 1) {

      /*
       *  Get the name just read.
       */

      name = xmlTextReaderConstName(reader);

      /*
       * Check if DOH requires a login.
       * If it does, return DOH_NEED_LOGIN to login and retry.
       */
      ret = check_need_login(name, reader);
      if ( ret < 0 ) {
          xmlFreeTextReader(reader);
          return ret;
      }

      if ( strcmp( (char *) name, "standing-state" ) == 0 ) {

        /*
         *  We have a "standing-state" tag.
         *  Get its value if the tag is not empty.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;

        ret = get_tag_value( reader, &name, "standing-state", &temp_value );

        /*
         *  If we got a value, set the appropriate info in our new
         *  alert entry.
         */

        if ((ret == 1) && (temp_value != NULL)) {

            if ( strcmp(temp_value, "normal") == 0 ) {
                 system_ok = 1;
            }
            else if ( strcmp(temp_value, "warning") == 0 ) {
                 system_warning = 1;
              }
            else if ( strcmp(temp_value, "broken") == 0 ) {
                 system_broken = 1;
            }

            free(temp_value);

        }

        temp_value = NULL;
      }

    } /* end while */

    /*
     *  Free the XML reader.
     */

    xmlFreeTextReader(reader);

    lasthosttime = time( 0 );

    return(1);
}

/*
 *  populate_user_scalars takes a previously fetched XML
 *  message that contains user info and sets scalar
 *  values based on that info.
 */

int populate_user_scalars( char *xml_ptr ) {

   xmlTextReaderPtr reader;

   int ret;
   const xmlChar *name;

   /*
    *  Free any elements already on the alert list.
    */
#if 0
   while ( alertTableList != NULL ) {

      alert_entry = alertTableList;
      if ( alert_entry->source != NULL )
         free ( alert_entry->source );
      if ( alert_entry->timestamp != NULL )
         free ( alert_entry->timestamp );
      if ( ( alert_entry->explain_text != NULL ) &&
           ( alert_entry->explain_text != blank ) )
         free ( alert_entry->explain_text);
      if ( alert_entry->type != NULL )
         free ( alert_entry->type );
      if ( ( alert_entry->SNMPtrap_OID != NULL ) &&
           ( alert_entry->SNMPtrap_OID != blank ) )
         free ( alert_entry->SNMPtrap_OID);

      alertTableList = alert_entry->next_ptr;
   }

   alert_entry = NULL;
#endif

   /*
    *  Access the XML message (already read into memory).
    */

   reader = xmlReaderForFile(XML_TEMP_FILE, 0, 0);
   if (reader == NULL)
      return(0);

   /*
    *  Free old values.
    */

   if ( ( systemSerial != NULL ) && ( systemSerial != blank ) ) {

       free( systemSerial );
       systemSerial = blank;
   }

   if ( ( systemSiteID != NULL ) && ( systemSiteID != blank ) ) {

       free( systemSiteID );
       systemSiteID = blank;
   }


   /*
    *  Loop through all the info in the XML message, a
    *  line at a time.
    */

   while ((ret = xmlTextReaderRead(reader)) == 1) {

      /*
       *  Get the name just read.
       */

      name = xmlTextReaderConstName(reader);

      /*
       * Check if DOH requires a login.
       * If it does, return DOH_NEED_LOGIN to login and retry.
       */
      ret = check_need_login(name, reader);
      if ( ret < 0 ) {
          xmlFreeTextReader(reader);
          return ret;
      }

      if ( strcmp( (char *) name, "licenseKey" ) == 0 ) {

        /*
         *  We have a "management-ip" tag.
         *  Get its value if the tag is not empty.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;

        ret = get_tag_value( reader, &name, "licenseKey", &systemSerial );

        if ( systemSerial <= 0 ) systemSerial = blank;

        systemSiteID = malloc(strlen(systemSerial) + 1);
        strcpy(systemSiteID, systemSerial);
      }

    } /* end while */

    /*
     *  Free the XML reader.
     */

    xmlFreeTextReader(reader);

    lastusertime = time( 0 );

    return(1);
}

/*
 *  populate_storage_scalars takes a previously fetched XML
 *  message that contains storage info and sets scalar
 *  values based on that info.
 */

int populate_storage_scalars( char *xml_ptr ) {

   xmlTextReaderPtr reader;

   int ret;
   long long storage_int64 = 0;
   long long storage_used_int64 = 0;
   const xmlChar *name;
   char *temp_value;

   /*
    *  Access the XML message (already read into memory).
    */

   reader = xmlReaderForFile(XML_TEMP_FILE, 0, 0);
   if (reader == NULL)
      return(0);

   systemStorageUsed = 0;
   systemStorageFree = 0;
   systemStorageTotal = 0;

   /*
    *  Loop through all the info in the XML message, a
    *  line at a time.
    */

   while ((ret = xmlTextReaderRead(reader)) == 1) {

      /*
       *  Get the name just read.
       */

      name = xmlTextReaderConstName(reader);

      /*
       * Check if DOH requires a login.
       * If it does, return DOH_NEED_LOGIN to login and retry.
       */
      ret = check_need_login(name, reader);
      if ( ret < 0 ) {
          xmlFreeTextReader(reader);
          return ret;
      }

      if ( strcmp( (char *) name, "size" ) == 0 ) {

        /*
         *  We have a "size" tag.
         *  Get its value if the tag is not empty.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;

        ret = get_tag_value( reader, &name, "size", &temp_value );

        if ( temp_value > 0 ) {

          storage_int64 = storage_int64 + atoll( temp_value );
          free( temp_value );
        }

        temp_value = NULL;

      }

      else if ( strcmp( (char *) name, "size-used" ) == 0 ) {

        /*
         *  We have a "size-used" tag.
         *  Get its value if the tag is not empty.
         */

        if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;

        ret = get_tag_value( reader, &name, "size-used", &temp_value );

        if ( temp_value > 0 ) {

          storage_used_int64 = storage_used_int64 + atoll( temp_value );
          free( temp_value );
        }

        temp_value = NULL;

      }

    } /* end while */

    /*
     *  Free the XML reader.
     */

    xmlFreeTextReader(reader);

    systemStorageUsed = storage_used_int64 / 1048576;

    systemStorageTotal = storage_int64 / 1048576;

    systemStorageFree = systemStorageTotal - systemStorageUsed;
    if ( systemStorageFree < 0 ) systemStorageFree = 0;

    laststoragetime = time( 0 );

    return(1);
}

/*
 *  populate_alert_list takes a previously fetched XML
 *  message that contains alert log entries and creates
 *  a linked list out of them for SNMP queries.
 */

int populate_alert_list( char *xml_ptr ) {

   xmlTextReaderPtr reader;

   struct alertLogEntry *alert_entry = NULL;
   struct alertLogEntry *previous_loop_ptr = NULL;
   struct alertLogEntry *alert_loop_ptr = NULL;

   int ret;
   const xmlChar *name;
   xmlChar *read_value;
   char *found_logID = NULL;
   char *temp_value;

   char *found_alertID = NULL;
   char *found_source = NULL;
   char *found_SNMPtrapOID = NULL;

   /*
    *  We're only going to repopulate the cache every 30 seconds.
    */

   if ( ( time(0) - lastalerttime ) < 30 )
      return ( 1 );

   /*
    *  Free any elements already on the alert list.
    */

   while ( alertTableList != NULL ) {

      alert_entry = alertTableList;
      if ( alert_entry->source != NULL )
         free ( alert_entry->source );
      if ( alert_entry->timestamp != NULL )
         free ( alert_entry->timestamp );
      if ( ( alert_entry->explain_text != NULL ) &&
           ( alert_entry->explain_text != blank ) )
         free ( alert_entry->explain_text);
      if ( alert_entry->type != NULL )
         free ( alert_entry->type );
      if ( ( alert_entry->SNMPtrap_OID != NULL ) &&
           ( alert_entry->SNMPtrap_OID != blank ) )
         free ( alert_entry->SNMPtrap_OID);

      alertTableList = alert_entry->next_ptr;
      free( alert_entry );
   }

   alert_entry = NULL;
   in_alert = 0;

   /*
    *  Access the XML message (already read into memory).
    */

   reader = xmlReaderForFile(XML_TEMP_FILE, 0, 0);
   if (reader == NULL)
      return(0);

   /*
    *  Loop through all the info in the XML message, a
    *  line at a time.
    */

   while ((ret = xmlTextReaderRead(reader)) == 1) {

      /*
       *  Get the name just read.
       */

      name = xmlTextReaderConstName(reader);

      /*
       * Check if DOH requires a login.
       * If it does, return DOH_NEED_LOGIN to login and retry.
       */
      ret = check_need_login(name, reader);
      if ( ret < 0 ) {
          xmlFreeTextReader(reader);
          return ret;
      }

      /*
       *  If we got a name, read its associated value.
       */

      if ( name != NULL) {
          xmlTextReaderConstValue(reader);
      }

      /*
       *  If we see the tag "alert" and this isn't an
       *  empty element (i.e., it doesn't equal an empty
       *  tag such as "<iceCreamFlavor/>", then toggle the
       *  value of in_alert -- which indicates whether or
       *  not we're in an "alert" portion of the xml
       *  message.  Note that the first time we see it, we're
       *  entering an alert section (so we set in_alert
       *  to 1) and the next time we see it, we're exiting
       *  the section (so in_alert is 0).
       */

      if ( ( strcmp( (char *) name, "alert" ) == 0 ) &&
           ( xmlTextReaderIsEmptyElement(reader) == 0 ) ) {

        /*
         *  Are we in an "alert" section?
         */

        if ( in_alert ) {
           /*
            *  Yes; this means we're leaving an alert section.
            *  Did we extract an alert ID when we entered this
            *  section?
            */

           if ( found_alertID != NULL ) {

             /*
              *  We got an alert ID.  Loop through all of the
              *  alert elements that we've generated.
              */

             alert_loop_ptr = alertTableList;
             while ( alert_loop_ptr != NULL ) {

                /*
                 *  If this alert element is associated with the alert
                 *  ID of the alert section we're leaving, then update
                 *  the alert element's source field with the source
                 *  for this alert ID if it doesn't have one.
                 */

                if ( strcmp( alert_loop_ptr->alertID, found_alertID ) == 0 ) {
                   if ( alert_loop_ptr->source == NULL ) {
                      if ( found_source != NULL )
                         alert_loop_ptr->source = strdup( found_source );
                      else
                         alert_loop_ptr->source = strdup( " " );
                   }
                }
                alert_loop_ptr = alert_loop_ptr->next_ptr;
             }
           }

           /*
            *  Cleanup.
            */

           if ( found_alertID ) free( found_alertID );
           if ( found_SNMPtrapOID ) free( found_SNMPtrapOID );

           found_source = NULL;
           found_alertID = NULL;
           found_SNMPtrapOID = NULL;
           in_alert = 0;
        }
        else {

           /*
            *  We're entering an alert section.  Extract the alert
            *  ID from this tag.
            */

           found_alertID = (char *) xmlTextReaderGetAttribute( reader,
                                          (xmlChar *) "id");
           in_alert = 1;
        }
      }

      /*
       *  Similarly, see if we're entering or leaving a "log" section.
       */

      else if ( ( strcmp( (char *) name, "log" ) == 0 ) &&
           ( xmlTextReaderIsEmptyElement(reader) == 0 ) ) {

        /*
         *  If we're already in a "log" section and we see the "log" tag,
         *  that means that we're now leaving a log section.
         */

        if ( in_log ) {

           /*
            *  We want to add the alert log entry that we just
            *  finished generating to our list of entries.
            */

           alert_loop_ptr = alertTableList;

           /*
            *  If this is the first entry, just put it on the list!
            */

           if ( alertTableList == NULL ) {
             alertTableList = alert_entry;
           }

           /*
            *  There's at least one other entry here; we want to
            *  sort these by log ID, so find this entry's appropriate
            *  spot in the list.
            */

           else {
             int added = 0;
             previous_loop_ptr = NULL;

             /*
              *  Begin looping through the list.
              */

             while ( alert_loop_ptr != NULL ) {

               /*
                *  If the current entry's log ID is greater than
                *  the one in our new entry, we've found the
                *  place to insert it!
                */

               if ( strcmp( alert_loop_ptr->logID, alert_entry->logID ) > 0 ) {

                 /*
                  *  Set the new entry to point to the entry
                  *  already in the list that has the higher
                  *  log ID.
                  */

                 alert_entry->next_ptr = alert_loop_ptr;

                 /*
                  *  If we're inserting it at the beginning of the
                  *  list, point the list header to it.
                  */

                 if ( previous_loop_ptr == NULL ) {
                    alertTableList = alert_entry;
                    added = 1;
                 }

                 /*
                  *  If we're inserting into the middle of the list,
                  *  point the previous entry to our new entry.
                  */

                 else {
                    previous_loop_ptr->next_ptr = alert_entry;
                    added = 1;
                 }
                 break;
               }

               /*
                *  Update pointers for our next trip through the loop.
                */

               previous_loop_ptr = alert_loop_ptr;
               alert_loop_ptr = alert_loop_ptr->next_ptr;
             }

             /*
              *  If we haven't added the new entry yet, it goes on the
              *  end of the list!
              */

             if ( added == 0 ) {
               previous_loop_ptr->next_ptr = alert_entry;
             }
           }

           in_log = 0;
        }
        else {

           /*
            *  We're entering a log section; create a new entry.
            */

           alert_entry = calloc( 1, sizeof(struct alertLogEntry) );

           if ( found_SNMPtrapOID != NULL ) {
              alert_entry->SNMPtrap_OID = strdup(found_SNMPtrapOID);
           }

           /*
            *  The ID associated with this log entry is stored
            *  in the log tag with a value that begins with
            *  "log:o", which is followed by a series of digits.
            *  I'm told that the ":o" is guaranteed to be there,
            *  so that's what we'll assume!  Get to the digits
            *  and store the ID!
            */

           read_value = xmlTextReaderGetAttribute( reader,
                          (xmlChar *) "id");
           if ( read_value > 0 ) {

             /*
              *  Add 2 to the address of the ":o" to get to the
              *  digits.
              */

             found_logID = strstr((char*)read_value, ":o") + 2;

             /*
              *  If strstr() returned 0 (so, the above equation
              *  yields a value of 2), then that means we didn't
              *  find the ID; so check if this is the case before
              *  trying to access the ID.
              */

             if ( found_logID != (char *)2 ) {
               strcpy( alert_entry->logID, (char *) found_logID );
             }
           }

           /*
            *  If we got an alert ID when we entered the "alert"
            *  section (the "log" section lives in the "alert"
            *  section), then put that alert ID into our new entry.
            */

           if ( found_alertID != NULL ) {
               strcpy( alert_entry->alertID, found_alertID );
           }
           in_log = 1;
           if (read_value != NULL)
               xmlFree(read_value);
        }
      }

      /*
       *  There are callhome, ealert and snmp sections within
       *  the log section.  See if we're entering or leaving any
       *  of those and set the appropriate flags.
       */

      else if ( ( strcmp( (char *) name, "callhome" ) == 0 ) &&
           ( xmlTextReaderIsEmptyElement(reader) == 0 ) ) {
        if ( in_callhome ) in_callhome = 0;
        else in_callhome = 1;
      }

      else if ( ( strcmp( (char *) name, "ealert" ) == 0 ) &&
           ( xmlTextReaderIsEmptyElement(reader) == 0 ) ) {
        if ( in_ealert ) in_ealert = 0;
        else in_ealert = 1;
      }

      else if ( ( strcmp( (char *) name, "snmp" ) == 0 ) &&
           ( xmlTextReaderIsEmptyElement(reader) == 0 ) ) {
        if ( in_snmp ) in_snmp = 0;
        else in_snmp = 1;
      }

      /*
       *  If we're already in the callhome section (within a log section
       *  which is within an alert section), then we may find a "posted"
       *  which tells us whether or not a CallHome message was sent
       *  when this alert log was generated.
       */

      else if ( ( in_alert == 1 ) && ( in_log == 1 ) && ( in_callhome == 1 ) ) {

        if ( strcmp( (char *) name, "posted" ) == 0 ) {

          /*
           *  We have a "posted" tag within the callhome section.
           *  Get its value if the tag is not empty.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;

          ret = get_tag_value( reader, &name, "posted", &temp_value );

          /*
           *  If we got a value, set the appropriate info in our new
           *  alert entry.
           */

          if ((ret == 1) && (temp_value != NULL)) {
            if ( strncmp( temp_value, "true", 4 ) == 0 ) {
              alert_entry->callhome_sent = EVERRUNALERTCALLHOMESENT_TRUE;
            }
            else {
              alert_entry->callhome_sent = EVERRUNALERTCALLHOMESENT_FALSE;
            }

            free(temp_value);
            temp_value = NULL;
          }
        }

      }

      /*
       *  If we're already in the ealert section (within a log section
       *  which is within an alert section), then we may find a "posted"
       *  which tells us whether or not an eAlert message was sent
       *  when this alert log was generated.
       */

      else if ( ( in_alert == 1 ) && ( in_log == 1 ) && ( in_ealert == 1 ) ) {

        if ( strcmp( (char *) name, "posted" ) == 0 ) {

          /*
           *  We have a "posted" tag within the ealert section.
           *  Get its value if the tag is not empty.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "posted", &temp_value );

          /*
           *  If we got a value, set the appropriate info in our new
           *  alert entry.
           */

          if ((ret == 1) && (temp_value != NULL)) {
            if ( strncmp( temp_value, "true", 4 ) == 0 ) {
              alert_entry->eAlert_sent = EVERRUNALERTEALERTSENT_TRUE;
            }
            else {
              alert_entry->eAlert_sent = EVERRUNALERTEALERTSENT_FALSE;
            }

            free(temp_value);
            temp_value = NULL;
          }
        }

      }

      /*
       *  If we're already in the snmp section (within a log section
       *  which is within an alert section), then we may find a "posted"
       *  which tells us whether or not an SNMP trap was sent
       *  when this alert log was generated.
       */

      else if ( ( in_alert == 1 ) && ( in_log == 1 ) && ( in_snmp == 1 ) ) {

        if ( strcmp( (char *) name, "posted" ) == 0 ) {

          /*
           *  We have a "posted" tag within the snmp section.
           *  Get its value if the tag is not empty.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "posted", &temp_value );

          /*
           *  If we got a value, set the appropriate info in our new
           *  alert entry.
           */

          if ((ret == 1) && (temp_value != NULL)) {
            if ( strncmp( temp_value, "true", 4 ) == 0 ) {
              alert_entry->SNMPtrap_sent = EVERRUNALERTSNMPTRAPSENT_TRUE;
            }
            else {
              alert_entry->SNMPtrap_sent = EVERRUNALERTSNMPTRAPSENT_FALSE;
            }

            free(temp_value);
            temp_value = NULL;
          }
        }

      }

      /*
       *  If we are in the log section (but not in the callhome,
       *  ealert or snmp sections), then there are other tags
       *  for us to look for.
       */

      else if ( ( in_alert == 1 ) && ( in_log == 1 ) ) {

        /*
         *  The "time" tag...
         */

        if ( strcmp( (char *) name, "time" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "time", &alert_entry->timestamp );
        }

        /*
         *  The "explain-text" tag...
         */

        else if ( strcmp( (char *) name, "explain-text" ) == 0 ) {

          char *cr_found;

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) {
                 alert_entry->explain_text = blank;
                 continue;
          }

          ret = get_tag_value( reader, &name, "explain-text",
                 &alert_entry->explain_text );

          if (alert_entry->explain_text == NULL) {
             /*
              * snmpagent was crashing without this.  New DOH sends empty
              * explain-text as <explain-text></explain-text> as against
              * <explain-text/>. This does not pass the xmlTextReaderIsEmptyElement()
              * test above and get_tag_value() leaves this value is NULL.
              * But rest of the code here assumes this value to be non NULL.
              */
             alert_entry->explain_text = blank;
          }

          /*
           *  We want to remove the "__CR__" strings from this text (they
           *  are non-standard control mechanisms).
           *  Find each instance of the string and remove it by shifting
           *  the rest of the string 6 characters over (effectively
           *  wiping out the "__CR__" string.
           */

          while ( ( cr_found = strstr( alert_entry->explain_text, "__CR__")) ) {
             while ( *(cr_found+6) != '\0' ) {
               *cr_found = *(cr_found+6);
               cr_found++;
             }
          *cr_found = '\0';
          }

        }

        /*
         *  The "component" tag...
         */

        else if ( strcmp( (char *) name, "component" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) {
                 alert_entry->source = strdup(blank);
                 continue;
          }

          ret = get_tag_value( reader, &name, "component",
                 &alert_entry->source );
          found_source = alert_entry->source;

        }

        /*
         *  The "type" tag...
         */

        else if ( strcmp( (char *) name, "type" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "type", &alert_entry->type );
        }

        /*
         *  The "severity" tag...
         */

        else if ( strcmp( (char *) name, "severity" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "severity",
                      &temp_value );

          /*
           *  If we got a value, convert the string to an integer.
           */

          if ((ret == 1) && (temp_value != NULL)) {
            alert_entry->severity = copy_integer(temp_value);
            free(temp_value);
            temp_value = NULL;
          }
        }
      } /* end in alert and log */

      /*
       *  If we are in the alert section (but not in the log, callhome,
       *  ealert or snmp sections), then there is another tag
       *  for us to look for.
       */

      else if  ( in_alert == 1 ) {

        /*
         *  The "trapOID" tag...
         */

        if ( strcmp( (char *) name, "trapOID" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) {
                 found_SNMPtrapOID = strdup(blank);
                 continue;
          }

          ret = get_tag_value( reader, &name, "trapOID",
                 &found_SNMPtrapOID );

        }

      } /* end in alert */

    } /* end while */

    /*
     *  Free the XML reader.
     */

    xmlFreeTextReader(reader);

    lastalerttime = time( 0 );

    return(1);
}

/*
 *  populate_audit_list takes a previously fetched XML
 *  message that contains audit log entries and creates
 *  a linked list out of them for SNMP queries.
 */

int populate_audit_list( char *xml_ptr ) {

   xmlTextReaderPtr reader;

   struct auditLogEntry *audit_entry = NULL;
   struct auditLogEntry *previous_loop_ptr = NULL;
   struct auditLogEntry *audit_loop_ptr = NULL;

   int ret, status;
   const xmlChar *name;
   const xmlChar *read_value;
   char *temp_value;

   /*
    *  We're only going to repopulate the cache every 30 seconds.
    */

   if ( ( time(0) - lastaudittime ) < 30 )
      return ( 1 );

   /*
    *  Free any elements already on the audit list.
    */

   while( auditTableList != NULL ) {

     audit_entry = auditTableList;
     if ( audit_entry->index != NULL )
           free( audit_entry->index );
     if ( audit_entry->day != NULL )
           free( audit_entry->day );
     if ( audit_entry->timestamp != NULL )
           free( audit_entry->timestamp );
     if ( audit_entry->remoteuser != NULL )
           free( audit_entry->remoteuser );
     if ( audit_entry->description != NULL )
           free( audit_entry->description );

     auditTableList = audit_entry->next_ptr;

     free( audit_entry );
   }

   audit_entry = NULL;
   in_audit = 0;

   /*
    *  Access the XML message (already read into memory).
    */

   reader = xmlReaderForFile(XML_TEMP_FILE, 0, 0);
   if (reader == NULL)
      return(0);

   /*
    *  Loop through all the info in the XML message, a
    *  line at a time.
    */

   while ((ret = xmlTextReaderRead(reader)) == 1) {

      /*
       *  Get the name just read.
       */

      name = xmlTextReaderConstName(reader);

      /*
       * Check if DOH requires a login.
       * If it does, return DOH_NEED_LOGIN to login and retry.
       */
      ret = check_need_login(name, reader);
      if ( ret < 0 ) {
          xmlFreeTextReader(reader);
          return ret;
      }

      /*
       *  If we got a name, read its associated value.
       */

      if ( name != NULL) {
        read_value = xmlTextReaderConstValue(reader);
      }

      /*
       *  If we see the tag "audit" and this isn't an
       *  empty element (i.e., it doesn't equal an empty
       *  tag such as "<iceCreamFlavor/>", then toggle the
       *  value of in_audit -- which indicates whether or
       *  not we're in the "audit" portion of the XML
       *  message.  Note that the first time we see it, we're
       *  entering the audit section (so we set in_audit
       *  to 1) and the next time we see it, we're exiting
       *  the section (so in_audit is 0)
       */

      if ( ( strcmp( (char *) name, "audit" ) == 0 ) &&
           ( xmlTextReaderIsEmptyElement(reader) == 0 ) ) {

        /*
         *  If in_audit is set, then we're leaving the audit section.
         */

        if ( in_audit ) {

           /*  First, we need to make sure we got an index; otherwise,
            *  we're not going to use this audit entry.
            */

           if ( audit_entry->index == NULL ) {
              if ( audit_entry->day != NULL )
                 free( audit_entry->day );
              if ( audit_entry->timestamp != NULL )
                 free( audit_entry->timestamp );
              if ( audit_entry->remoteuser != NULL )
                 free( audit_entry->remoteuser );
              if ( audit_entry->description != NULL )
                 free( audit_entry->description );
              free(audit_entry);
              audit_entry = NULL;
           }

           /*
            *  We want to add our new audit log entry to the linked
            *  list of entries.  If the list is empty, just add the
            *  entry to the header!
            */
           else {
              audit_loop_ptr = auditTableList;
              if ( auditTableList == NULL ) {
                auditTableList = audit_entry;
              }

              /*
               *  We want the list to be sorted by the index, so loop through
               *  the list of audit entries, looking for this entry's spot
               *  in the list.
               */

              else {
                int added = 0;
                previous_loop_ptr = NULL;
                while ( audit_loop_ptr != NULL ) {

                  /*
                   *  If this list element has a larger index than our
                   *  new element, we've found our spot!
                   */

                  if ( strcmp( audit_loop_ptr->index, audit_entry->index ) > 0 ) {

                    /*
                     *  Have our new element point to the next element
                     *  in the list.
                     */

                    audit_entry->next_ptr = audit_loop_ptr;

                    /*
                     *  If we're to be at the beginning of the list,
                     *  set the header to point to our new entry.
                     */

                    if ( previous_loop_ptr == NULL ) {
                       auditTableList = audit_entry;
                       added = 1;
                    }

                    /*
                     *  If we're in the middle of the list, have the
                     *  previous element point to us.
                     */

                    else {
                       previous_loop_ptr->next_ptr = audit_entry;
                       added = 1;
                    }
                    break;
                  }

                  /*
                   *  Modify pointers for the next trip through the loop.
                   */

                  previous_loop_ptr = audit_loop_ptr;
                  audit_loop_ptr = audit_loop_ptr->next_ptr;
                }

                /*
                 *  If we didn't add the new element yet, put it at the
                 *  end of the list.
                 */

                if ( added == 0 ) {
                  previous_loop_ptr->next_ptr = audit_entry;
                }
              }

              in_audit = 0;

           }  /* end of having an index */
        } /* end of leaving an audit section */

        /*
         *  We're entering an audit section.
         */

        else {

           /*
            *  Create a new audit log entry.
            */

           audit_entry = calloc( 1, sizeof(struct auditLogEntry) );

           in_audit = 1;
        }
      }

      /*
       *  If we were already in an audit section, see if it's one of the
       *  tags within that section that we're interested in.
       */

      else if ( in_audit == 1 ) {

        /*
         *  The "auditIndex" tag...
         */

        if ( strcmp( (char *) name, "auditIndex" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "auditIndex",
                 &audit_entry->index );

        }

        /*
         *  The "day" tag...
         */

        else if ( strcmp( (char *) name, "day" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "time", &audit_entry->day );
        }

        /*
         *  The "time" tag...
         */

        else if ( strcmp( (char *) name, "time" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "time", &audit_entry->timestamp );
        }

        /*
         *  The "remotehost" tag...
         */

        else if ( strcmp( (char *) name, "remotehost" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "remotehost",
                 &temp_value );

          /*
           *  If we got a value, convert the string to an integer.
           */

          if ((ret == 1) && (temp_value != NULL)) {

             /*
              *  If DOH returns the string "null", then assume this
              *  is localhost (127.0.0.1).
              */

             if (strcmp( temp_value, "null" ) == 0 ) {
               free( temp_value );
               temp_value = strdup("127.0.0.1");
             }

             status = inet_aton( temp_value,
                         (struct in_addr *) &audit_entry->remotehost );

             /*
              *  If we can't make heads or tails of the IP address,
              *  use localhost.
              */

             if ( status == 0 ) {
               free( temp_value );
               temp_value = strdup("127.0.0.1");
               status = inet_aton( temp_value,
                         (struct in_addr *) &audit_entry->remotehost );

             }

             free(temp_value);
             temp_value = NULL;
          }
        }

        /*
         *  The "remoteuser" tag...
         */

        else if ( strcmp( (char *) name, "remoteuser" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "remoteuser",
                 &audit_entry->remoteuser );

        }

        /*
         *  The "description" tag...
         */

        else if ( strcmp( (char *) name, "description" ) == 0 ) {

          /*
           *  If there is a value for this tag, get it.
           */

          if ( xmlTextReaderIsEmptyElement(reader) == 1 ) continue;
          ret = get_tag_value( reader, &name, "description",
                 &audit_entry->description );
        }
      }

    } /* end while */

    /*
     *  Free the XML reader.
     */

    xmlFreeTextReader(reader);

    lastaudittime = time( 0 );

    return(1);
}

int fetch_doh_information()
{
  char *xml_ptr;
  int status, request;
  int sequence[] = {
      DOH_SUPERNOVA,
      DOH_SYSTEM_STATUS,
      DOH_SERIAL_NUMBER,
      DOH_STORAGE_USED,
      DOH_ALERT_TABLE,
      DOH_AUDIT_TABLE
  };
  const int sequence_len = sizeof(sequence)/sizeof(sequence[0]);
  for ( request = 0; request < sequence_len; request++ ) {
    status = process_doh_request( sequence[request], &xml_ptr );
    if ( status == -1 ) {
      printf("process_doh_request fail\n");
      break;
    }
    if ( status == DOH_NEED_LOGIN ) {
        process_doh_request( DOH_LOGOUT, &xml_ptr );
        status = process_doh_request( DOH_LOGIN, &xml_ptr );
        if ( status == -1 ) {
            printf("Unable to log in to DOH! Some SNMP results may not be updated.\n");
            break;
        }
        status = process_doh_request( sequence[request], &xml_ptr);
    }
  }
  if ( status == -1 ) {
   return status;
  }

  return 1;
}

void check_session_id(char *http_response)
{
#define csid_length 32
#define csid_expected 1
#define csid_strsub(x) #x
#define csid_str(x) csid_strsub(x)

    regex_t regex;
    regoff_t id_start, id_end;
    regmatch_t matches[csid_expected];
    char *pattern = "[[:xdigit:]]\\{" csid_str(csid_length) "\\}";
    char *cookie_ptr;
    char *cookie_end;
    char *cookie_str;
    size_t cookie_len;

    do {
        cookie_ptr = strstr(http_response, "Set-Cookie");
        if (cookie_ptr == NULL)
            break;

        cookie_end = strstr(cookie_ptr, "\r\n");
        if (cookie_end == NULL)
            break;

        cookie_len = cookie_end-cookie_ptr;
        cookie_str = (char *)malloc(cookie_len*sizeof(char));
        if (cookie_str == NULL)
            break;

        strncpy(cookie_str, cookie_ptr, cookie_len);
        cookie_str[cookie_len-1] = '\0';

        if (regcomp(&regex, pattern, 0) != 0) {
            free(cookie_str);
            break;
        }

        if (regexec(&regex, cookie_str, csid_expected, matches, 0) != 0) {
            free(cookie_str);
            regfree(&regex);
            break;
        }

        id_start = matches[0].rm_so;
        id_end = matches[0].rm_eo;

        if (id_end-id_start != csid_length) {
            free(cookie_str);
            regfree(&regex);
            break;
        }

        strncpy(current_session_id, cookie_str+id_start, csid_length);
        current_session_id[csid_length] = '\0';
        free(cookie_str);
        regfree(&regex);

        printf("Using unauthenticated session ID: %s\n", current_session_id);
    } while (0);
}

int process_doh_request( int request, char **xml_ptr )
{
  int i, status;
  char *xml_request = NULL;
  char *tmp_ptr;
  FILE *filefd;
  char *http_string = NULL;
  SSL *ssl;
  SSL_CTX *ctx;

  char *http_login_string = "POST /doh/ HTTP/1.0\r\nHost: localhost\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11\r\nAccept: text/javascript, text/html, application/xml, text/xml, */*\r\nAccept-Language: en-us,en;q=0.5\r\nAccept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 300\r\nConnection: close\r\nContent-Type: text/xml\r\nContent-Length: %d\r\nPragma: no-cache\r\nCache-Control: no-cache\r\n\r\n";

  char *http_loggedin_string = "POST /doh/ HTTP/1.0\r\nHost: localhost\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11\r\nAccept: text/javascript, text/html, application/xml, text/xml, */*\r\nAccept-Language: en-us,en;q=0.5\r\nAccept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 300\r\nConnection: close\r\nContent-Type: text/xml\r\nContent-Length: %d\r\nPragma: no-cache\r\nCache-Control: no-cache\r\nCookie: JSESSIONID=%s\r\n\r\n";


  switch( request ) {
  case DOH_LOGIN:
    strcpy(login_username, "admin");
    strcpy(login_username, "admin");
    sprintf(login_request, xml_login_request, login_username, login_password);
    break;
  case DOH_LOGOUT:

    if ( current_session_id[0] == '\0' )
        return (0);
    break;

  case DOH_SUPERNOVA:
  case DOH_SYSTEM_NAME:
  case DOH_AVAIL_VIRTUAL_MEMORY:
  case DOH_VIRTUAL_CPU_TOTAL:
  case DOH_VIRTUAL_CPU_IN_USE:
  case DOH_VIRTUAL_CPUS_MAX_PER_VM:

    if ( ( time( 0 ) - lastsupernovatime ) < 30 )
        return( 0 );
    break;

  case DOH_SYSTEM_STATUS:

    if ( ( time( 0 ) - lasthosttime ) < 30 )
        return( 0 );
    break;

  case DOH_SERIAL_NUMBER:
  case DOH_SITE_ID:

    if ( ( time( 0 ) - lastusertime ) < 30 )
        return( 0 );
    break;

  case DOH_STORAGE_USED:
  case DOH_STORAGE_FREE:
  case DOH_STORAGE_TOTAL:

    if ( ( time( 0 ) - laststoragetime ) < 30 )
        return( 0 );
    break;

  case DOH_ALERT_TABLE:

    if ( ( time( 0 ) - lastalerttime ) < 30 )
        return( 0 );
    break;

  case DOH_AUDIT_TABLE:

    if ( ( time( 0 ) - lastaudittime ) < 30 )
        return( 0 );
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
  status = SSL_set_fd(ssl, doh_sock);
  if ( status == 0 ) {
    printf("SL link socket error\n");
    close(doh_sock);
    status = SSL_shutdown(ssl);
    if ( status != 1 ) {
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
  status = SSL_connect(ssl);
  if ( status != 1 ) {
    printf("SSL connect failed\n");
    close(doh_sock);
    status = SSL_shutdown(ssl);
    if ( status != 1 ) {
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

  case DOH_LOGOUT:
    http_string = http_loggedin_string;
    xml_request = xml_logout_request;
    break;

  case DOH_SUPERNOVA:
  case DOH_SYSTEM_NAME:
  case DOH_AVAIL_VIRTUAL_MEMORY:
  case DOH_VIRTUAL_CPU_TOTAL:
  case DOH_VIRTUAL_CPU_IN_USE:
  case DOH_VIRTUAL_CPUS_MAX_PER_VM:
    http_string = http_loggedin_string;
    xml_request = xml_supernova_request;
    break;

  case DOH_SYSTEM_STATUS:
    http_string = http_loggedin_string;
    xml_request = xml_host_request;
    break;

  case DOH_SERIAL_NUMBER:
  case DOH_SITE_ID:
    http_string = http_loggedin_string;
    xml_request = xml_user_request;
    break;

  case DOH_STORAGE_USED:
  case DOH_STORAGE_FREE:
  case DOH_STORAGE_TOTAL:
    http_string = http_loggedin_string;
    xml_request = xml_sharedstorage_request;
    break;

  case DOH_ALERT_TABLE:
    http_string = http_loggedin_string;
    xml_request = xml_alert_table_request;
    break;

  case DOH_AUDIT_TABLE:
    http_string = http_loggedin_string;
    xml_request = xml_audit_table_request;
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
     status = SSL_shutdown(ssl);
     if ( status != 1 ) {
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
      status = SSL_shutdown(ssl);
      if ( status != 1 ) {
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
    printf("Warning - Unable to open /tmp/snmp/tempxml\n");
    close(doh_sock);
    status = SSL_shutdown(ssl);
    if ( status != 1 ) {
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
       status = SSL_shutdown(ssl);
       if ( status != 1 ) {
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
  status = SSL_shutdown(ssl);
  if ( status != 1 ) {
    SSL_shutdown(ssl);
  }
  SSL_free(ssl);
  SSL_CTX_free(ctx);

switch(request) {

case DOH_LOGIN:
  status = populate_login_scalars( *xml_ptr );
  break;

case DOH_LOGOUT:
  memset(current_session_id, '\0', sizeof(current_session_id));
  break;

case DOH_SUPERNOVA:
case DOH_SYSTEM_NAME:
case DOH_AVAIL_VIRTUAL_MEMORY:
case DOH_VIRTUAL_CPU_TOTAL:
case DOH_VIRTUAL_CPU_IN_USE:
case DOH_VIRTUAL_CPUS_MAX_PER_VM:
  status = populate_supernova_scalars( *xml_ptr );
  break;

case DOH_SYSTEM_STATUS:
  status = populate_host_scalars( *xml_ptr );
  break;

case DOH_SERIAL_NUMBER:
case DOH_SITE_ID:
  status = populate_user_scalars( *xml_ptr );
  break;

case DOH_STORAGE_USED:
case DOH_STORAGE_FREE:
case DOH_STORAGE_TOTAL:
  status = populate_storage_scalars( *xml_ptr );
  break;

case DOH_ALERT_TABLE:
  status = populate_alert_list( *xml_ptr );
  break;

case DOH_AUDIT_TABLE:
  status = populate_audit_list( *xml_ptr );
  break;
}

if ( status == 0 )
    status = DOH_RESPONSE;
else if ( status != DOH_NEED_LOGIN )
    status = DOH_SUCCESS;

return(status);
}

int main(int argc, char const *argv[])
{

  int status = fetch_doh_information();
  if ( status == -1 ) {
      printf("fetch_doh_information failed.\n");
      return -1;
  }
  printf("fetch_doh_information success\n");
  return 0;
}
