#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <dirent.h>
#include <unistd.h>
#include <locale.h>
#include <wctype.h>

int main()
{
    var li = list!("AAA", "ABC", "DEF");
    
    var li2 = li.filter { it[0] == 'A' };
    
    li2.each {
        printf("%s\n", it);
    }
    
    return 0;
}
