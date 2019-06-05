#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

struct symT
{
	char name[50];
	int type;
	char value[50];
	char prop[50];
	int scope;
	int line_no;
	int lat_seen;
};

