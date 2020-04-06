#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <limits.h>

#include "common.h"

impl ViWin version 12
{
void commandModeView(ViWin* self, Vi* nvi) {
    //werase(self.win);

    self.textsView(nvi);

    wattron(self.win, A_REVERSE);
    mvwprintw(self.win, self.height-1, 0, ":%s", nvi.commandString);
    wattroff(self.win, A_REVERSE);

    //wrefresh(self.win);
}
void commandModeInput(ViWin* self, Vi* nvi) {
    var key = self.getKey();

    switch(key) {
        case '\n':
            nvi.exitFromComandMode();
            break;

        case 3:
        case 27:
            nvi.mode = kEditMode;
            break;

        case 8:
        case 127:
        case KEY_BACKSPACE:
            nvi.commandString.delete(-1);
            break;

        default:
            nvi.commandString = nvi.commandString + key.to_string();
            break;
    }
}

void view(ViWin* self, Vi* nvi) {
    if(nvi.mode == kCommandMode && self == nvi.activeWin) {
        self.commandModeView(nvi);
    }
    else {
        inherit(self, nvi);
    }
}
void input(ViWin* self, Vi* nvi) {
    if(nvi.mode == kCommandMode) {
        self.commandModeInput(nvi);
    }
    else {
        inherit(self, nvi);
    }
}
void subAllTextsFromCommandMode(ViWin* self, Vi* nvi) {
    /// parse command ///
    var command = nvi.commandString
           .scan(regex!("%s\/\(.+\)\/\(.*\)\/*?"));
               
    var str = command.item(1, null);
    var replace = command.item(2, null);
    
    if(str != null && replace != null) {
        self.pushUndo();
        self.texts.each {
            var reg = regex(str, false, false, true, false
                        , false, false, false, false);
            var new_line = it.to_string("")
                        .sub(reg, replace, null).to_wstring();
            
            self.texts.replace(it2, new_line);
        }
    }
}

impl Vi version 12
{
void enterComandMode(Vi* self) {
    self.mode = kCommandMode;
    self.commandString = string("");
}
void exitFromComandMode(Vi* self) {
    if(self.commandString.index("%", -1) != -1) {
        self.activeWin.subAllTextsFromCommandMode(self);
        self.mode = kEditMode;
    }
    if(self.commandString.index("w", -1) != -1) {
        self.activeWin.writeFile();
    }
    if(self.commandString.index("q", -1) != -1) {
        bool writed = self.activeWin.writed;

        if(!writed || self.commandString.index("!", -1) != -1) {
            if(self.wins.length() == 1) {
                self.appEnd = true;
            }
            else {
                self.closeActiveWin();
            }
        }
    }
    if(self.commandString.index("shell", -1) != -1) {
        endwin();
        
        (void)system("bash");

        self.init_curses();
    }
    if(self.commandString.index("sp", -1) == 0) {
        self.activateFiler();
    }

    self.mode = kEditMode;
}
initialize() {
    inherit(self);

    self.commandString = string("");

    self.events.replace(':', lambda(Vi* self, int key) {
        self.enterComandMode();
    });
}

/// implemeted after ///
void activateFiler(Vi* self) {
}
}
