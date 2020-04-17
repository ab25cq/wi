#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <limits.h>
#include <wctype.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "common.h"

impl ViWin version 9
{
void searchModeView(ViWin* self, Vi* nvi)
{
    //werase(self.win);

    self.textsView(nvi);

    wattron(self.win, A_REVERSE);
    mvwprintw(self.win, self.height-1, 0, "/%ls", nvi.searchString);
    wattroff(self.win, A_REVERSE);

    //wrefresh(self.win);
}

void view(ViWin* self, Vi* nvi) {
    if(nvi.mode == kSearchMode && self.equals(nvi.activeWin)) {
        self.searchModeView(nvi);
    }
    else {
        inherit(self, nvi);
    }
}

void search(ViWin* self, Vi* nvi) {
    if(nvi.searchString == null || wcscmp(nvi.searchString, wstring("")) == 0) 
    {
        return;
    }
    
    var cursor_line = self.texts.item(self.scroll+self.cursorY, null);

    int x = cursor_line.substring(self.cursorX+1, -1)
                .index(nvi.searchString, -1);

    if(x != -1) {
        self.saveReturnPoint();

        x += self.cursorX + 1;
        self.cursorX = x;
    }
    else {
        self.texts.sublist(self.scroll+self.cursorY+1, -1).each {
            int x;
            
            if(nvi.regexSearch) {
                x = it.to_string("").index_regex(nvi.searchString.to_string("").to_regex(), -1);
            }
            else {
                x = it.index(nvi.searchString, -1);
            }

            if(x != -1) {
                self.saveReturnPoint();

                self.cursorY += it2 + 1;
                self.modifyOverCursorYValue();
                self.cursorX = x;
                *it3 = true;
                return;
            }
        }
    }
}

void searchReverse(ViWin* self, Vi* nvi) {
    if(nvi.searchString == null
        || wcscmp(nvi.searchString, wstring("")) == 0) 
    {
        return;
    }
    
    var cursor_line = self.texts.item(self.scroll+self.cursorY, null);

    int x;
    if(self.cursorX < nvi.searchString.length())
    {
        x = -1;
    }
    else {
        x = cursor_line.substring(0, self.cursorX-1).rindex(nvi.searchString, -1)
    }

    if(x != -1) {
        self.saveReturnPoint();

        self.cursorX = x;
    }
    else {
        self.texts.sublist(0, self.scroll+self.cursorY).reverse().each {
            int x;
            if(nvi.regexSearch) {
                x = it.to_string("").rindex_regex(nvi.searchString.to_string("").to_regex(), -1);
            }
            else {
                x = it.rindex(nvi.searchString, -1);
            }

            if(x != -1) {
                self.saveReturnPoint();

                self.cursorY = self.cursorY - it2 -1;
                self.modifyUnderCursorYValue();
                self.cursorX = x;
                *it3 = true;
                return;
            }
        }
    }
}

void searchWordOnCursor(ViWin* self, Vi* nvi)
{
    wchar_t* line = self.texts.item(self.scroll+self.cursorY, wstring(""));

    if(self.cursorX < line.length()) {
        wchar_t* p = line + self.cursorX;
        
        int cursor_x_before = self.cursorX;

        if((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || (*p >= '0' && *p <= '9') || *p == '_')
        {
            while((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || (*p >= '0' && *p <= '9') || *p == '_')
            {
                p--;
                self.cursorX--;
            }

            self.cursorX++;
        }

        int scroll_before = self.scroll;
        int cursor_y_before = self.cursorY;
        int cursor_x_before2 = self.cursorX;

        self.forwardWord();

        if((cursor_y_before == self.cursorY) && (scroll_before == self.scroll)) 
        {
            var search_word = self.texts.item(self.scroll+self.cursorY, null)
                  .substring(cursor_x_before2, self.cursorX);
            nvi.searchString = clone search_word;
            
            self.cursorX = cursor_x_before;

            self.search(nvi);
        }
    }
}
void searchWordOnCursorReverse(ViWin* self, Vi* nvi)
{
    wchar_t* line = self.texts.item(self.scroll+self.cursorY, wstring(""));

    if(self.cursorX < line.length()) {
        int cursor_x_before = self.cursorX;
        
        wchar_t* p = line + self.cursorX;

        if((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || (*p >= '0' && *p <= '9') || (*p == '_'))
        {
            while((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || (*p >= '0' && *p <= '9') || *p == '_')
            {
                p--;
                self.cursorX--;
            }

            self.cursorX++;
        }

        int scroll_before = self.scroll;
        int cursor_y_before = self.cursorY;
        int cursor_x_before2 = self.cursorX;

        self.forwardWord();

        if((cursor_y_before == self.cursorY) && (scroll_before == self.scroll)) 
        {
            var search_word 
                = self.texts.item(self.scroll+self.cursorY, null)
                 .substring(cursor_x_before2, self.cursorX);
            nvi.searchString = clone search_word;
            
            self.cursorX = cursor_x_before;

            self.searchReverse(nvi);
        }
    }
}

void inputSearchlMode(ViWin* self, Vi* nvi)
{
    var key = self.getKey(false);

    switch(key) {
        case 27:
            nvi.exitFromSearchMode();
            break;

        case 'C'-'A'+1:
            nvi.exitFromSearchMode();
            break;

        case 10:
            self.search(nvi);
            nvi.exitFromSearchMode();
            break;
            
        case 8:
        case 127:
        case KEY_BACKSPACE:
            nvi.searchString.delete(-1);
            break;

        default:
            nvi.searchString = nvi.searchString + wstring(xasprintf("%c", key));
            break;
    }
}

void input(ViWin* self, Vi* nvi) {
    if(nvi.mode == kSearchMode) {
        self.inputSearchlMode(nvi);
    }
    else {
        inherit(self, nvi);
    }
}
}

impl Vi version 9
{
void saveSearchString(Vi* self, char* file_name) {
    char* home = getenv("HOME");
    
    if(home == null) {
        return;
    }
    
    char file_name2[PATH_MAX];
    
    snprintf(file_name2, PATH_MAX, "%s/.wi", home);
    
    (void)mkdir(file_name2, 0755);
    
    snprintf(file_name2, PATH_MAX, "%s/.wi/%s", home, file_name);
    
    FILE* f = fopen(file_name2, "w");

    if(f == null) {
        return;
    }
    
    if(self.searchString != null && wcscmp(self.searchString, wstring("")) != 0) 
    {
        fprintf(f, "%ls\n", self.searchString);
    }
    
    fclose(f);
}

void readSearchString(Vi* self, char* file_name) {
    char* home = getenv("HOME");
    
    if(home == null) {
        self.searchString = wstring("");
        return;
    }
    
    char file_name2[PATH_MAX];
    
    snprintf(file_name2, PATH_MAX, "%s/.wi/%s", home, file_name);
    
    FILE* f = fopen(file_name2, "r");

    if(f == null) {
        self.searchString = wstring("");
        return;
    }
    
    char line[4096];

    if(fread(line, 1, 4096, f) <= 0) {
        fclose(f);
        self.searchString = wstring("");
        return;
    }
    
    line[strlen(line)-1] = '\0';

    fclose(f);
    
    self.searchString = wstring(line);
}

void enterSearchMode(Vi* self, bool regex_search) {
    self.mode = kSearchMode;
    self.searchString = wstring("");
    self.regexSearch = regex_search;
}
void exitFromSearchMode(Vi* self) {
    self.mode = kEditMode;
}

initialize() {
    inherit(self);
    
    self.readSearchString("searchString.wi");

    self.events.replace('/', lambda(Vi* self, int key) 
    {
        self.enterSearchMode(false);
    });

    self.events.replace('n', lambda(Vi* self, int key) 
    {
        self.activeWin.search(self);
        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('N', lambda(Vi* self, int key) 
    {
        self.activeWin.searchReverse(self);
        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('*', lambda(Vi* self, int key) 
    {
        self.activeWin.searchWordOnCursor(self);
        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('#', lambda(Vi* self, int key) 
    {
        self.activeWin.searchWordOnCursorReverse(self);
        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
}
    
finalize() {
    self.saveSearchString("searchString.wi");
    
    inherit(self);
}

}
