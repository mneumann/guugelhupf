#include <stdio.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <hash_map>
#include <ctype.h>

#include "MyMmapTokenStream.h"

int
getFileLength(int handle)
{
	int length;

	length = lseek(handle, 0, SEEK_END);
	lseek(handle, 0, SEEK_SET);
	return length;
}

void 
printout(char *start, char *end)
{
	while (start != end) {
		putchar(*start);
		start++;
	}
}


struct eqstr
{ 
  bool operator()(const char* s1, const char* s2) const
  {
    return strcmp(s1, s2) == 0;
  }
};

int main(int argc, char** argv) {
  int fd;
  int length;

  Token *tok;

  if ((fd = open(argv[1], O_RDONLY)) == -1) {
	perror("Failed to open file!");
	exit(-1);
  }
  length = getFileLength(fd);

  MyMmapTokenStream obj(fd, length);

  hash_map<const char*, int, hash<const char*>, eqstr> h;

  int str_len;
  char *str;
  char *cur;
  char buffer[256];

  while( (tok = obj.next()) != NULL ) {
    printout(tok->start_ptr, tok->end_ptr);
   putchar('\n');
/*
   // str_len = tok->end_ptr - tok->start_ptr + 1;
    //if (str_len > 255) {
    //  perror("Token too large!");
    //  exit(-1);
    //} 

//    str = buffer; 
    str     = (char*)malloc(str_len+1);

    if (str == NULL) {
      perror("Failed to alloc memeory!");
      exit(-1);
    } 

    for(int i=0; i<str_len; i++) {
      str[i] = (char) tolower(tok->start_ptr[i]);
    }
    str[str_len] = '\0';

    //free(str);

    h[str] += 1; 

    //printout(tok->start_ptr, tok->end_ptr);
    //putchar('\n'); */
  }

//  printf("%d\n", h["sdlkf"]);
  return 0;
}
