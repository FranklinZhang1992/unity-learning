#include <stdio.h>
#include <string.h>

int main(int argc, char const *argv[])
{
	const char *str1;
	const char *str2;
	const char *str3;

	char *s1;
	char *s2;
	char *s3;

	char arr1[] = "";
	char arr2[] = "123";

	str1 = NULL;
	str2 = arr1;
	str3 = arr2;

	printf("begin\n");
	// s1 = strdup (str1);
	// printf("s1 = %s\n", s1);
	s2 = strdup (str2);
	printf("s2 = %s\n", s2);
	s3 = strdup (str3);
	printf("s3 = %s\n", s3);
	printf("end\n");
	return 0;
}
