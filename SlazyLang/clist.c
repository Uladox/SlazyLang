#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

struct node
{
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

struct node *add_node(struct node *argnode)
{
	if (argnode->ver == NULL){
		argnode->ver = malloc(sizeof(struct node));
	} else {
		argnode->ver = realloc(argnode->ver, sizeof(struct node));
	}
}
//makes first string exactly equivalent (size and content) to second
void str_new(char *argstr, const char *value)
{
	if (argstr == NULL){
		argstr =  malloc(strlen(value));
		strcpy(argstr, value);
	} else {
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
        char *tempstr = malloc(strlen(argstr) + 1);	
	strcpy(tempstr, argstr);
	argstr = rstpnt;
	return tempstr;
}

//returns first section of string before first whitespace
char *spc_slt(char* argstr)
{
	char *rstpnt = argstr;
	while (!isspace(*argstr) && (*argstr) != '\0')
		argstr++;
	int token_s = strlen(rstpnt) - strlen(argstr);
        char* tempstr =  malloc(token_s + 1);
	argstr = rstpnt;
	strncpy(tempstr, argstr, token_s);
	return tempstr;
}

//cuts off size from beggining of string
void rem_str_ft(char *argstr, int size)
{
	char *tempstr = malloc(strlen(argstr) - size);
	int i;
	for (i = 0; i != size; i++)
		argstr++;
	int e = strlen(argstr);
	for (i = 0; i != e; i++)
		*tempstr++ = *argstr++;
	str_new(argstr, tempstr);
//	free(tempstr);
}
//gets rid of first token and returns it
char *rip_tok(char* argstr)
{
	if(strlen(argstr) == 0){
		return NULL;
	} else {
		char* tempstr;
		char *tempstr2;
		tempstr =  rmv_spc(argstr);
		if(strlen(tempstr) == 0){
//			free(tempstr);
			return NULL;
		}
		str_new(argstr, tempstr);
//		free(tempstr);
		tempstr2 = spc_slt(argstr);
		rem_str_ft(argstr, strlen(tempstr2));
		return tempstr2;
	}		
}



main()
{
	char *a = malloc(10);
        strcpy(a, "    a b c"); 
/*
	char *b = rip_tok(a);
	while (b!= NULL) {
		printf("%s\n", b);
		b = rip_tok(a);
	}
	printf("%s", a);
*/
	char *b = rmv_spc(a);
	char *c = spc_slt(b);
	printf("%s", c);
//	rem_str_ft(a, strlen(spc_slt(rmv_spc(a))));
//	printf("%s", spc_slt(rmv_spc(a)));
	free(a);
	free(b);
	free(c);
}
