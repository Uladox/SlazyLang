#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

struct node{
	int x;
	int y;
	struct node *hor;
	struct node *ver;
	char *str;
};

//sets string in node (argnode) to value (like str_new)
void set_node(struct node *argnode, const char *value)
{
	if (argnode->str == NULL){
		argnode->str = malloc(strlen(value));
		strcpy(argnode->str, value);
	} else {
		argnode->str = realloc(argnode->str, strlen(value));
		strcpy(argnode->str, value);
	}
}

//makes first string exactly equivalent (size and content) to second
void str_new(char *argstr, const char *value)
{
	if (argstr == NULL){
		argstr =  malloc(strlen(value));
		strcpy(argstr, value);
	} else {
		//	char *tempstr = argstr;
		if ((argstr =  realloc(argstr, strlen(value))) == NULL){
			printf("Error: yo out of memory!");
			exit(EXIT_FAILURE);
		} else {
			strcpy(argstr, value);
		}
	}
}

//returns string without whitespace at beggining
char *rmv_spc(char* argstr)
{
	char *rstpnt = argstr;
	while (isspace(*argstr))
		argstr++;	
        char* tempstr = (char *) malloc(strlen(argstr));
	strcpy(tempstr, argstr);
	argstr = rstpnt;
	return tempstr;
}

char *spc_slt(char* argstr)
{
	char *rstpnt = argstr;
	while (!isspace(*argstr))
		argstr++;
	int token_s = strlen(rstpnt) - strlen(argstr);
        char* tempstr =  malloc(token_s);
	argstr = rstpnt;
	strncpy(tempstr, argstr, token_s);
	return tempstr;
}

void rem_str_ft(char *argstr, int size)
{
	char *tempstr = argstr;
	int i;
	for (i = 0; i != size; i++)
		tempstr++;
	int temp_size = strlen(tempstr);
	strncpy(argstr, tempstr, temp_size);
	argstr = realloc(argstr, temp_size);
}
char *eval(char* argstr)
{
	char* tempstr = argstr;
	tempstr = rmv_spc(tempstr);
	str_new(argstr, tempstr);
	char *tempstr2;
	tempstr2 = spc_slt(tempstr);
	free(tempstr);
	rem_str_ft(argstr, strlen(argstr) - strlen(tempstr2));
	return tempstr2;
}
main()
{
	char *a = malloc(100);
        strcpy(a, "  df  ghv fg"); 
	printf("%s\n", eval(a));
	printf("%s\n", a);
}
