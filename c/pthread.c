#include <stdio.h>
#include <pthread.h>

#include "p2v.h"

void *start_conversion_thread(void *data);

void main()
{
	struct config *config = NULL;
	config->hostname = "ubuntu";
	struct config *copy = NULL;
	pthread_t tid;
	pthread_attr_t attr;
	int err = 0;

	copy = config;
	pthread_attr_init(&attr);
	err = pthread_create(&tid, &attr, start_conversion_thread, copy);
	
}


void *start_conversion_thread(void *data)
{
	printf("start_conversion_thread");
}