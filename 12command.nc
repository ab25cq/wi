#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <limits.h>
#include <libgen.h>
#include <dirent.h>
#include <sys/stat.h>

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

string selector(ViWin* self, list<string>* lines) {
    bool end_of_select = false;
    bool canceled = false;

    int maxx = getmaxx(self.win);
    int maxy = getmaxy(self.win);

    int scrolltop = 0;
    int cursor = 0;

    while(!end_of_select) {
        clear();
        int maxy2 = lines.length() - scrolltop;

        ### view ###
        for(int y=0; y<maxy && y < maxy2; y++) {
            var it = lines.item(scrolltop+y, null);

            var line = it.substring(0, maxx-1);

            if(cursor == y) {
                attron(A_REVERSE);
                mvprintw(y, 0, "%s", line);
                attroff(A_REVERSE);
            }
            else {
                mvprintw(y, 0, "%s", line);
            }
        }
        refresh();

        ### input ###
        var key = getch();

        switch(key) {
            case KEY_UP:
            case 'k':
            case 'P'-'A'+1:
                cursor--;
                break;

            case KEY_DOWN:
            case 'j':
            case 'N'-'A'+1:
            case (('I'-'A')+1):
                cursor++;
                break;

            case 'D'-'A'+1:
                cursor+=10;
                break;
           
            case (('U'-'A')+1):
                cursor-=10;
                break;

            case ('C'-'A')+1:
            case 'q':
            case ('['-'A')+1:
                canceled = true;
                end_of_select = true;
                break;

            case KEY_ENTER:
            case ('J'-'A')+1:
                end_of_select = true;
                break;
        }
        
        ### modification ###
        if(cursor < 0) {
            int scroll_size = -cursor +1;
            
            cursor = 0;
            scrolltop-=scroll_size;

            if(scrolltop < 0) {
                scrolltop = 0;
                cursor = 0;
            }
        }

        if(maxy2 < maxy) {
            if(cursor >= maxy2) {
                cursor = maxy2 - 1;
            }
        }
        else {
            if(cursor >= maxy) {
                int scroll_size = cursor - maxy + 1;

                scrolltop += scroll_size;
                cursor -= scroll_size;
            }
        }
    }

    if(canceled) {
        return string("");
    }
    return string(lines.item(scrolltop+cursor, string("")));
}

void fileCompetion(ViWin* self, Vi* nvi) {
    char* line = nvi.commandString;

    char* p = line + strlen(line) -1;
    
    while(p >= line) {
        if(*p == ' ' || *p == '\t') {
            p++;
            break;
        }
        else {
            p--;
        }
    }
    
    var word = string(p);

    string dir_name = null;
    if(word.item(-1, -1) == '/') {
        dir_name = string(word);
    }
    else {
        char* dname = dirname(clone word);

        if(strcmp(dname, "/") == 0) {
            dir_name = string("/");
        }
        else {
            dir_name = string(dirname(clone word)) + string("/");
        }
    }

    var words = new list<string>.initialize();

    if(dir_name.equals("./")) {
        char* cwd = getenv("PWD");
        
        if(cwd == null) {
            return;
        }
    
        DIR* dir = opendir(cwd);
    
        if(dir == null) {
            return;
        }
    
        while(true) {
            struct dirent* entry = readdir(dir);
    
            if(entry == null) {
                break;
            }
            
            string path = string(cwd) + string("/") + string(entry->d_name);
            
            stat stat_;
            stat(path, &stat_);
            
            if(S_ISDIR(stat_.st_mode)) {
                words.push_back(string(entry->d_name) + string("/"));
            }
            else {
                words.push_back(string(entry->d_name));
            }
        }
    
        closedir(dir);
    }
    else if(dir_name.item(0, -1) == '/') {
        DIR* dir;
        if(strcmp(word, "/") != 0 && word.item(-1, -1) == '/') {
            dir = opendir(word.substring(0, -2));
        }
        else {
            dir = opendir(dir_name);
        }
    
        if(dir == null) {
            return;
        }
    
        while(true) {
            struct dirent* entry = readdir(dir);
    
            if(entry == null) {
                break;
            }
            
            string path = dir_name + string(entry->d_name);
            
            stat stat_;
            stat(path, &stat_);
            
            if(S_ISDIR(stat_.st_mode)) {
                words.push_back(dir_name + string(entry->d_name) + string("/"));
            }
            else {
                words.push_back(dir_name + string(entry->d_name));
            }
        }
    
        closedir(dir);
    }
    else {
        DIR* dir;
        if(word.item(-1, -1) == '/') {
            dir = opendir(word.substring(0, -2));
        }
        else {
            dir = opendir(dir_name);
        }
    
        if(dir == null) {
            return;
        }
    
        while(true) {
            struct dirent* entry = readdir(dir);
    
            if(entry == null) {
                break;
            }
            
            string path = dir_name + string(entry->d_name);
            
            stat stat_;
            stat(path, &stat_);
            
            if(S_ISDIR(stat_.st_mode)) {
                words.push_back(dir_name + string(entry->d_name) + string("/"));
            }
            else {
                words.push_back(dir_name + string(entry->d_name));
            }
        }
    
        closedir(dir);
    }
    
    var words2 = words.filter { FILE* f = fopen("AAA", "a"); fprintf(f, "it %s word %s\n", it, word); fclose(f); strcmp(word, "") == 0 || strstr(it, word) == it }.sort();
    
    var file_name = self.selector(words2).substring(strlen(word), -1);
    
    nvi.commandString = nvi.commandString + file_name;
}

void commandModeInput(ViWin* self, Vi* nvi) {
    var key = self.getKey(false);

    switch(key) {
        case '\n':
            nvi.exitFromComandMode();
            break;

        case 3:
        case 27:
            nvi.mode = kEditMode;
            break;
            
        case '\t':
            self.fileCompetion(nvi);
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
            var new_line = it.to_string("").sub(reg, replace, null).to_wstring();
            
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
        var file_name = self.commandString.scan(regex!("sp \(.+\)")).clone_item(1, null);

        if(file_name != null) {
            self.openNewFile(file_name);
        }
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
