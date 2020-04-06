#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <limits.h>

#include "common.h"

impl ViWin version 8 
{
initialize(int y, int x, int width, int height, Vi* vi) {
    inherit(self, y, x, width, height, vi);

    self.visualModeHead = 0;

    self.visualModeHeadBefore = -1;
    self.visualModeTailCursorYBefore = -1;
    self.visualModeTailScrollBefore = -1;
}

void visualModeView(ViWin* self, Vi* nvi){
    int maxy = getmaxy(self.win);
    int maxx = getmaxx(self.win);

    //werase(self.win);

    self.texts
        .sublist(self.scroll, self.scroll+maxy-1)
        .each 
    {
        var line = it.substring(0, maxx-1);

        if(it2 >= (self.visualModeHead-self.scroll) 
            && it2 <= self.cursorY) 
        {
            wattron(self.win, A_REVERSE);
            mvwprintw(self.win, it2, 0, "%s", line.to_string(""));
            wattroff(self.win, A_REVERSE);
        }
        else if(it2 <= 
            (self.visualModeHead-self.scroll) 
            && it2 >= self.cursorY) 
        {
            wattron(self.win, A_REVERSE);
            mvwprintw(self.win, it2, 0, "%s", line.to_string(""));
            wattroff(self.win, A_REVERSE);
        }
        else {
            mvwprintw(self.win, it2, 0, "%s", line.to_string(""));
        }
    }

    wattron(self.win, A_REVERSE);
    mvwprintw(self.win, self.height-1, 0, "VISUAL MODE x %d y %d", self.cursorX, self.cursorY);
    wattroff(self.win, A_REVERSE);

    //wrefresh(self.win);
}

void view(ViWin* self, Vi* nvi) {
    if(nvi.mode == kVisualMode 
        && nvi.activeWin.equals(self)) 
    {
        self.visualModeView(nvi);
    }
    else {
        inherit(self, nvi);
    }
}

void yankOnVisualMode(ViWin* self, Vi* nvi) {
    int head = self.visualModeHead;
    int tail = self.scroll+self.cursorY;

    if(head >= tail) {
        int tmp = tail;
        tail = head;
        head = tmp;
    }

    nvi.yank.reset();
    self.texts.sublist(head, tail+1).each {
        nvi.yank.push_back(clone it);
    }
    
    nvi.yankKind = kYankKindLine;
}

void indentVisualMode(ViWin* self, Vi* nvi) {
    self.pushUndo();

    int head = self.visualModeHead;
    int tail = self.scroll+self.cursorY;

    if(head >= tail) {
        int tmp = tail;
        tail = head;
        head = tmp;
    }
    
    self.texts.sublist(head, tail+1).each {
        wstring new_line = wstring("    ") + it;

        self.texts.replace(it2+head, new_line);
    }

    self.modifyOverCursorXValue();
}

void backIndentVisualMode(ViWin* self, Vi* nvi) {
    self.pushUndo();

    int head = self.visualModeHead;
    int tail = self.scroll+self.cursorY;

    if(head >= tail) {
        int tmp = tail;
        tail = head;
        head = tmp;
    }

    self.texts.sublist(head, tail+1).each {
        wstring new_line = wstring("") + it;

        if(new_line.index(wstring("    "), -1) == 0) {
            for(int i=0; i<4; i++) {
                new_line.delete(0);
            }

            self.texts.replace(it2+head, new_line);
        }
    }

    self.modifyOverCursorXValue();
}

void deleteOnVisualMode(ViWin* self, Vi* nvi) {
    self.pushUndo();

    self.yankOnVisualMode(nvi);

    int head = self.visualModeHead;
    int tail = self.scroll+self.cursorY;

    if(head >= tail) {
        int tmp = tail;
        tail = head;
        head = tmp;
    }

    self.texts.delete_range(head, tail+1);

    if(self.scroll+self.cursorY >= self.visualModeHead) {
        self.cursorY -= tail - head;

        self.modifyUnderCursorYValue();
    }
}

void makeInputedKeyGVIndent(ViWin* self, Vi* nvi) {
}

void makeInputedKeyGVDeIndent(ViWin* self, Vi* nvi) {
}

void inputVisualMode(ViWin* self, Vi* nvi){
    var key = self.getKey();

    switch(key) {
        case 'l':
            self.forward();
            break;
        
        case 'h':
            self.backward();
            break;

        case KEY_DOWN:
        case 'j':
            self.nextLine();
            break;
    
        case KEY_UP:
        case 'k':
            self.prevLine();
            break;

        case '0':
            self.moveAtHead();
            break;

        case '$':
            self.moveAtTail();
            break;

        case 'C'-'A'+1:
            nvi.exitFromVisualMode();
            break;

        case 'D'-'A'+1:
            self.halfScrollDown();
            break;

        case 'U'-'A'+1:
            self.halfScrollUp();
            break;
            
        case 'G':
            self.moveBottom();
            break;

        case 'g':
            self.keyG(nvi);
            break;

        case 'y':
            self.yankOnVisualMode(nvi);
            nvi.exitFromVisualMode();
            break;

        case 'd':
            self.deleteOnVisualMode(nvi);
            nvi.exitFromVisualMode();
            break;

        case '>':
            self.indentVisualMode(nvi);
            nvi.exitFromVisualMode();
    
            self.makeInputedKeyGVIndent(nvi);
            break;

        case '<':
            self.backIndentVisualMode(nvi);
            nvi.exitFromVisualMode();
            self.makeInputedKeyGVDeIndent(nvi);
            break;
            
        case '%':
            self.gotoBraceEnd(nvi);
            break;

        case 27:
            nvi.exitFromVisualMode();
            break;
    }
}

void input(ViWin* self, Vi* nvi) {
    if(nvi.mode == kVisualMode) {
        self.inputVisualMode(nvi);
    }
    else {
        inherit(self, nvi);
    }
}

/// implemented after layer
void restoreVisualMode(ViWin* self, Vi* nvi) {
    nvi.mode = kVisualMode;

    if(self.visualModeHeadBefore != -1) {
        self.visualModeHead = self.visualModeHeadBefore;
        self.cursorY = self.visualModeTailCursorYBefore;
        self.scroll = self.visualModeTailScrollBefore;
    }
}

void gotoBraceEnd(ViWin* self, Vi* nvi) {
}

}

impl Vi version 8
{
void enterVisualMode(Vi* self) {
    self.mode = kVisualMode;
    self.activeWin.visualModeHead = self.activeWin.cursorY + self.activeWin.scroll;
}

void exitFromVisualMode(Vi* self) {
    self.mode = kEditMode;

    self.activeWin.visualModeHeadBefore = self.activeWin.visualModeHead;
    self.activeWin.visualModeTailCursorYBefore = self.activeWin.cursorY;
    self.activeWin.visualModeTailScrollBefore = self.activeWin.scroll;
}

initialize() {
    inherit(self);

    self.events.replace('V', lambda(Vi* self, int key) 
    {
        self.enterVisualMode();
    });
}
}
