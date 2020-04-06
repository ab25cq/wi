#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <limits.h>

#include "common.h"

impl ViWin version 9
{
void searchModeView(ViWin* self, Vi* nvi)
{
    //werase(self.win);

    self.textsView(nvi);

    wattron(self.win, A_REVERSE);
    mvwprintw(self.win, self.height-1, 0, "/%ls"
                    , nvi.searchString);
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
    if(nvi.searchString == null ||
        wcscmp(nvi.searchString, wstring("")) == 0) 
    {
        return;
    }
    
    var cursor_line = self.texts
            .item(self.scroll+self.cursorY, null);

    int x = cursor_line.substring(self.cursorX+1, -1)
                .index(nvi.searchString, -1);

    if(x != -1) {
        self.saveReturnPoint();

        x += self.cursorX + 1;
        self.cursorX = x;
    }
    else {
        self.texts.sublist(self.scroll+self.cursorY+1, -1).each {
            int x = it.index(nvi.searchString, -1);

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
            int x = it.rindex(nvi.searchString, -1);

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
    var key = self.getKey();

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
void enterSearchMode(Vi* self) {
    self.mode = kSearchMode;
    self.searchString = wstring("");
}
void exitFromSearchMode(Vi* self) {
    self.mode = kEditMode;
}

initialize() {
    inherit(self);

    self.events.replace('/', lambda(Vi* self, int key) 
    {
        self.enterSearchMode();
    });

    self.events.replace('n', lambda(Vi* self, int key) 
    {
        self.activeWin.search(self);
    });
    self.events.replace('N', lambda(Vi* self, int key) 
    {
        self.activeWin.searchReverse(self);
    });
    self.events.replace('*', lambda(Vi* self, int key) 
    {
        self.activeWin.searchWordOnCursor(self);
    });
    self.events.replace('#', lambda(Vi* self, int key) 
    {
        self.activeWin.searchWordOnCursorReverse(self);
    });
}
}
