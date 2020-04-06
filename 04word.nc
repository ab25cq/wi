#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <wctype.h>

#include "common.h"

impl ViWin version 4
{
void forwardWord(ViWin* self) {
    wchar_t* line = self.texts.item(self.scroll+self.cursorY, wstring(""));

    wchar_t* p = line + self.cursorX;

    if(self.cursorX == wcslen(line)) 
    {
        self.cursorY++;

        self.modifyOverCursorYValue();

        line = self.texts.item(self.scroll+self.cursorY, wstring(""));

        self.cursorX = 0;
    }

    if(wcslen(line) == 0) {
        while(wcslen(line) == 0) {
            self.cursorY++;

            self.modifyOverCursorYValue();

            if(self.scroll+self.cursorY >= self.texts.length()-1)
            {
                break;
            }

            line = self.texts.item(self.scroll+self.cursorY, wstring(""));
        }

        self.cursorX = 0;
    }
    else if((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_')
    {
        while((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_')
        {
            p++;
            self.cursorX++;

            if(self.cursorX >= line.length())
            {
                self.cursorY++;

                if(self.scroll+self.cursorY > self.texts.length()-1)
                {
                    self.cursorY--;
                    self.modifyUnderCursorYValue();
                    line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                    self.cursorX = line.length()-1;
                    break;
                }

                self.modifyOverCursorYValue();

                line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                p = line;
                self.cursorX = 0;
            }
        }
    }
    else if((*p >= '!' && *p <= '/') || (*p >= ':' && *p <= '@') || (*p >= '{' && *p <= '~' ) || (*p >= '[' && *p <= '`'))
    {
        while((*p >= '!' && *p <= '/') || (*p >= ':' && *p <= '@') || (*p >= '{' && *p <= '~' ) || (*p >= '[' && *p <= '`'))
        {
            p++;
            self.cursorX++;

            if(self.cursorX >= line.length())
            {
                self.cursorY++;

                if(self.scroll+self.cursorY > self.texts.length()-1)
                {
                    self.cursorY--;
                    self.modifyUnderCursorYValue();
                    line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                    self.cursorX = line.length()-1;
                    break;
                }

                self.modifyOverCursorYValue();

                line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                p = line;
                self.cursorX = 0;
            }
        }
    }
    else if(iswalpha(*p)) {
        while(iswalpha(*p)) {
            p++;
            self.cursorX++;

            if(self.cursorX >= line.length())
            {
                self.cursorY++;

                if(self.scroll+self.cursorY > self.texts.length()-1)
                {
                    self.cursorY--;
                    self.modifyUnderCursorYValue();
                    line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                    self.cursorX = line.length()-1;
                    break;
                }

                self.modifyOverCursorYValue();

                line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                p = line;
                self.cursorX = 0;
            }
        }
    }
    else if(iswblank(*p)) {
        while(iswblank(*p)) {
            p++;
            self.cursorX++;

            if(self.cursorX >= line.length())
            {
                self.cursorY++;

                if(self.scroll+self.cursorY > self.texts.length()-1)
                {
                    self.cursorY--;
                    self.modifyUnderCursorYValue();
                    line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                    self.cursorX = line.length()-1;
                    break;
                }

                self.modifyOverCursorYValue();

                line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                p = line;
                self.cursorX = 0;
            }
        }
    }
    else if(iswdigit(*p)) {
        while(iswdigit(*p)) {
            p++;
            self.cursorX++;

            if(self.cursorX >= line.length())
            {
                self.cursorY++;

                if(self.scroll+self.cursorY > self.texts.length()-1)
                {
                    self.cursorY--;
                    self.modifyUnderCursorYValue();
                    line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                    self.cursorX = line.length()-1;
                    break;
                }

                self.modifyOverCursorYValue();

                line = self.texts.item(self.scroll+self.cursorY, wstring(""));
                p = line;
                self.cursorX = 0;
            }
        }
    }
}
void backwardWord(ViWin* self) {
    wchar_t* line = self.texts.item(self.scroll+self.cursorY, wstring(""));

    wchar_t* p = line + self.cursorX;

    if(self.cursorX == wcslen(line)) 
    {
        self.cursorX--;
        p--;

        if(self.cursorX < 0) {
            self.cursorX++;
            p++;
        }
    }

    if(wcslen(line) == 0) {
        while(wcslen(line) == 0) {
            self.cursorY--;

            self.modifyUnderCursorYValue();

            if(self.scroll == 0 && self.cursorY == 0)
            {
                break;
            }

            line = self.texts.item(self.scroll+self.cursorY, wstring(""));
        }

        self.cursorX = wcslen(self.texts.item(self.scroll+self.cursorY, wstring(""))) -1;

        if(self.cursorX < 0) {
            self.cursorX = 0;
        }
    }
    else if((*p >= '!' && *p <= '/') || (*p >= ':' && *p <= '@') || (*p >= '{' && *p <= '~' ) || (*p >= '[' && *p <= '`'))
    {
        while((*p >= '!' && *p <= '/') || (*p >= ':' && *p <= '@') || (*p >= '{' && *p <= '~' ) || (*p >= '[' && *p <= '`'))
        {
            p--;
            self.cursorX--;

            if(self.cursorX < 0)
            {
                self.cursorX = 0;
                self.cursorY--;

                self.modifyUnderCursorYValue();

                if(self.scroll+self.cursorY <= 0) 
                {
                    self.cursorY = 0;
                    self.scroll = 0;
                    break;
                }

                line = self.texts.item(self.scroll+self.cursorY, wstring(""));

                if(wcslen(line) == 0)
                {
                    p = line;
                    self.cursorX = 0;
                }
                else {
                    self.cursorX = wcslen(line) -1;
                    p = line + self.cursorX;
                }
            }
        }
    }
    else if((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_')
    {
        while((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_')
        {
            p--;
            self.cursorX--;

            if(self.cursorX < 0)
            {
                self.cursorX = 0;
                self.cursorY--;

                self.modifyUnderCursorYValue();

                if(self.scroll+self.cursorY <= 0) 
                {
                    self.cursorY = 0;
                    self.scroll = 0;
                    break;
                }


                line = self.texts.item(self.scroll+self.cursorY, wstring(""));

                if(wcslen(line) == 0)
                {
                    p = line;
                    self.cursorX = 0;
                }
                else {
                    self.cursorX = wcslen(line) -1;
                    p = line + self.cursorX;
                }
            }
        }
    }
    else if(iswalpha(*p)) {
        while(iswalpha(*p)) {
            p--;
            self.cursorX--;

            if(self.cursorX < 0)
            {
                self.cursorX = 0;
                self.cursorY--;

                self.modifyUnderCursorYValue();

                if(self.scroll+self.cursorY <= 0)
                {
                    self.cursorY = 0;
                    self.scroll = 0;
                    break;
                }


                line = self.texts.item(self.scroll+self.cursorY, wstring(""));

                if(wcslen(line) == 0)
                {
                    p = line;
                    self.cursorX = 0;
                }
                else {
                    self.cursorX = wcslen(line) -1;
                    p = line + self.cursorX;
                }
            }
        }
    }
    else if(iswdigit(*p)) {
        while(iswdigit(*p)) {
            p--;
            self.cursorX--;

            if(self.cursorX < 0)
            {
                self.cursorX = 0;
                self.cursorY--;

                self.modifyUnderCursorYValue();

                if(self.scroll+self.cursorY <= 0)
                {
                    self.cursorY = 0;
                    self.scroll = 0;
                    break;
                }


                line = self.texts.item(self.scroll+self.cursorY, wstring(""));

                if(wcslen(line) == 0)
                {
                    p = line;
                    self.cursorX = 0;
                }
                else {
                    self.cursorX = wcslen(line) -1;
                    p = line + self.cursorX;
                }
            }
        }
    }
    else if(iswblank(*p)) {
        while(iswblank(*p)) {
            p--;
            self.cursorX--;

            if(self.cursorX < 0)
            {
                self.cursorX = 0;
                self.cursorY--;

                self.modifyUnderCursorYValue();

                if(self.scroll+self.cursorY <= 0)
                {
                    self.cursorY = 0;
                    self.scroll = 0;
                    break;
                }


                line = self.texts.item(self.scroll+self.cursorY, wstring(""));

                if(wcslen(line) == 0)
                {
                    p = line;
                    self.cursorX = 0;
                }
                else {
                    self.cursorX = wcslen(line) -1;
                    p = line + self.cursorX;
                }
            }
        }
    }
}
}

impl Vi version 4
{
initialize() {
    inherit(self);

    self.events.replace('w', lambda(Vi* self, int key) 
    {
        self.activeWin.forwardWord();
    });
    self.events.replace('e', lambda(Vi* self, int key) 
    {
        self.activeWin.forwardWord();
    });
    self.events.replace('b', lambda(Vi* self, int key) 
    {
        self.activeWin.backwardWord();
    });
}
}
