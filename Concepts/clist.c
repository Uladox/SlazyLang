#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct node {
	int type;

	struct node *right;
	struct node *down;

	struct node *left;
	struct node *up;

	char *tag;
};

void add_node(struct node *argnode, char *argstr)
{
	argnode->right = (struct node *)malloc(sizeof(struct node));
	argnode->right->tag = malloc(strlen(argstr) + 1);
	strcpy(argnode->right->tag, argstr);
	argnode->right->right = NULL;
	argnode->right->down = NULL;
	argnode->right->left = argnode;
	argnode->right->up = argnode->up;
}

void make_var(struct node argnode)
{
	argnode.right = NULL;
	argnode.left = NULL;
	argnode.up = NULL;
}

//makes first string exactly equivalent (size and content) to second
void str_new(char *argstr, char *value)
{

	if (argstr == NULL) {
		argstr = malloc(strlen(value) + 1);
		strcpy(argstr, value);
		printf("%s", argstr);
	} else {
		argstr = realloc(argstr, strlen(value) + 1);
		strcpy(argstr, value);
	}
}

void node_str_new(struct node *argnode, char *value)
{
	if (argnode->tag == NULL) {
		argnode->tag = malloc(strlen(value) + 1);
		strcpy(argnode->tag, value);
	} else {
		argnode->tag = realloc(argnode->tag, strlen(value) + 1);
		strcpy(argnode->tag, value);
	}
}

//returns string without whitespace at beggining
char *rmv_spc(char *argstr)
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
char *spc_slt(char *argstr)
{
	char *rstpnt = argstr;
	while (!isspace(*argstr) && (*argstr) != '\0')
		argstr++;
	int token_s = strlen(rstpnt) - strlen(argstr);
	char *tempstr = malloc(token_s + 1);
	argstr = rstpnt;
	strncpy(tempstr, argstr, token_s);
	return tempstr;
}

//cuts off size from beggining of string
void rem_str_ft(char *argstr, int size)
{
	char *rstpnt = argstr;
	char *tempstr = malloc(1 + (strlen(argstr) - size));
	int i;
	for (i = 0; i != size; i++)
		argstr++;
	int e = strlen(argstr);
	for (i = 0; i != e; i++) {
		*tempstr = *argstr;
		tempstr++;
		argstr++;
	}
	*tempstr = '\0';
	for (i = 0; i != e; i++)
		tempstr--;
	argstr = rstpnt;
	str_new(argstr, tempstr);
	free(tempstr);
}

char *rmv_slt(char *argstr)
{
	char *fnt_cln = rmv_spc(argstr);
	char *spl_str = spc_slt(fnt_cln);
	rem_str_ft(argstr,
		   (strlen(argstr) - strlen(fnt_cln)) + strlen(spl_str));
	free(fnt_cln);
	return spl_str;
}

void list_form(struct node *argnode, char *argstr)
{
	struct node *currnode = argnode;
	while (strlen(argstr) != 0) {
		char *tempchar = rmv_slt(argstr);
		if (strlen(argstr) != 0) {
			add_node(currnode, tempchar);
			currnode = currnode->right;
		}
		if (tempchar != NULL)
			free(tempchar);
	}
}

void free_node(struct node *argnode)
{
	if (argnode->tag != NULL) {
		free(argnode->tag);
		argnode->tag = NULL;
	}
	if (argnode->down != NULL) {
		free_node(argnode->down);
		argnode->down = NULL;
	}
	if (argnode->right != NULL) {
		free_node(argnode->right);
		argnode->right = NULL;
	}
	if (argnode->up != NULL)
		if (argnode->up->down == argnode)
			argnode->up->down = NULL;
	if (argnode->left != NULL)
		argnode->left->right = NULL;
	free(argnode);
	argnode = NULL;
}

struct node *find_node(struct node *argnode, char *argstr,
		       struct node *checkpoint, int checkside)
{
	struct node *levelnode = NULL;
	if (argnode->down == NULL && checkside != 1)
		return NULL;
	if (argnode->down != NULL) {
		if (argnode->down->tag != NULL)
			if (strcmp(argnode->down->tag, argstr) == 0)
				return argnode->down;
		levelnode = find_node(argnode->down, argstr, NULL, 1);
	}
	if (levelnode != NULL)
		return levelnode;
	if (checkside == 1 && argnode->right != NULL)
		if (argnode->right->tag != NULL)
			if (strcmp(argnode->right->tag, argstr) == 0)
				return argnode->right;
	if (checkside == 1 && argnode->right != NULL)
		levelnode = find_node(argnode->right, argstr, NULL, 1);
	return levelnode;
}

int main(void)
{
	struct node *k;
	k = (struct node *)malloc(sizeof(struct node));

	struct node *l;
	l = (struct node *)malloc(sizeof(struct node));

	struct node *h;
	h = (struct node *)malloc(sizeof(struct node));

	struct node *o;
	o = (struct node *)malloc(sizeof(struct node));

	struct node *v;
	v = (struct node *)malloc(sizeof(struct node));

	char *m = malloc(3);
	strcpy(m, "af");
	node_str_new(k, m);
	l->down = o;
	o->right = v;
	v->down = k;
	k->down = h;
	if (find_node(l, m, NULL, 0) != NULL)
		printf("%s", find_node(l, m, NULL, 0)->tag);
}
