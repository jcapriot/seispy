/* Copyright (c) Colorado School of Mines, 2011.*/
/* All rights reserved.                       */

/*********************** self documentation **********************/

#ifdef _WIN32
#include <stdio.h>
#include <io.h>
#define fdopen _fdopen
#define unlink _unlink
#define close fclose
#else
#include <unistd.h> /* unlink, close */
#endif
#include "cwp.h"

/*****************************************************************************
TEMPORARY_FILENAME - Creates a file name in a user-specified directory.

******************************************************************************
Function prototypes:
FILE *temporary_stream (char *tempfile);
char *temporary_filename(char *tempfile);

******************************************************************************
temporary_stream:
Input:
tempfile	pointer to directory prefix string (eg. /usr/tmp/)

Output:
filestream	pointer to temporary file stream
******************************************************************************
temporary_filename:
Input:
tempfile	pointer to directory prefix string (eg. /usr/tmp/)

Output:
tempfile	pointer to filename string (eg. /usr/tmp/1206aaa)

******************************************************************************
Notes:
temporary_stream creates a file stream by appending a sequence of
numbers and letters (which is created by mkstemp) to the prefix string
passed as its argument. 

******************************************************************************
Author:  Andreas Klaedtke, 12/2/2009

******************************************************************************
temporary_filename creates a file name by appending a sequence of
numbers and letters (which is created by tmpnam) to the prefix string
passed as its argument.  On return the input argument points to the
(now augmented) prefix string.

It is duty of the calling program to provide room for the augmented
string.  The resulting string is typically used as a name for a
temporary file; in this case it is the calling program's job to make
sure that the supplied prefix ends with a slash.

This routine was written to supplement the ANSI C function tmpnam
which also creates a temporary filename, but within a fixed directory,
usually the /tmp directory.  Unfortunately, some /tmp directories are
too small to hold typical seismic data sets, so this routine allows
the user to specify a directory with sufficient capacity.  Also note
that on many systems, the tmpfile() call avoids this problem by
simulating a temporary file with a memory buffer.  However, this is
not a panacea as the file size might exceed available memory and on
some systems this call does actually create a file (again, usually in
/tmp).
******************************************************************************
Author:  Jack K. Cohen, Colorado School of Mines, 12/12/95

******************************************************************************/
/**************** end self doc ********************************/

FILE *temporary_stream (char const * const prefix) 
{
   int tfd = -1;
   FILE *tfp;
   char *buffer = NULL; 

   if (prefix != NULL) {
       buffer = (char*)malloc(strlen(prefix) + 11 + 1);
      if (0 == buffer) {
         return NULL;
      }
      strcpy(buffer, prefix);
   }    
   else {
      buffer = (char*)malloc(11 + 1);
      if (0 == buffer) {
         return NULL;
      }
   }

   #ifdef _WIN32
   strcat(buffer, "\\fileXXXXXX");

   tfd = _mktemp_s(buffer, strlen(buffer) + 1);
   #else
   strcat(buffer, "/fileXXXXXX");
   tfd = mkstemp(buffer);
   #endif
   if (tfd == -1 || (tfp = fdopen(tfd, "w+")) == NULL) {

#ifdef TEST
      printf("Temporary filename is %s\n", buffer);
#endif

      if (tfd != -1) {
         unlink(buffer);
         close(tfd);
      }

      free(buffer);
      return NULL;
   }

#ifdef TEST
   printf("Temporary filename is %s\n", buffer);
#endif

   /* remove temporary file when we close it */
   unlink(buffer); /* unlink immediately */
   free(buffer);

   return tfp;
}

char *temporary_filename(char *prefix) {

	static char name[BUFSIZ];
	int temp_fd;

	#ifdef _WIN32
	char *tmp = "cmguiXXXXXX";
	int template_size = strlen(tmp) + 1;

	temp_fd = _mktemp_s( tmp, template_size );

	#else
	/* char buffer[L_tmpnam]; */
	char template_name[]="/tmp/cmguiXXXXXX";

    temp_fd=mkstemp(template_name);
        /* [ak] tmpnam is considered unsafe */
    char *tmp = strrchr(template_name, '/');

    #endif


	strcpy(name, prefix);
	return strcat(name, tmp);
}


#ifdef TEST
main()
{
        FILE *fp;
	char tempfile[BUFSIZ] = "/usr/tmp";

	printf("Temporary filename is %s\n", temporary_filename(tempfile));

	/* or : */
	/*
        tfp = temporary_stream(tempfile);
        if (tfp != NULL) {
           fclose(tfp);
        }
        tfp = temporary_stream(NULL);
        if (tfp != NULL) {
           fclose(tfp);
        }
	*/

	return(EXIT_SUCCESS);
}
#endif
