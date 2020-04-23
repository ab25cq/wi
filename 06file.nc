#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <wctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <limits.h>

#include "common.h"


impl ViWin version 6
{
initialize(int y, int x, int width, int height, Vi* vi) {
    inherit(self, y, x, width, height, vi);

    self.fileName = string("a.txt");
    //self.fileName = "a.txt";
}
void statusBarView(ViWin* self, Vi* nvi)
{
    int maxy = getmaxy(self.win);
    int maxx = getmaxx(self.win);

    wattron(self.win, A_REVERSE);
    mvwprintw(self.win, self.height-1, 0, "x %d y %d scroll %d file %s writed %d", self.cursorX, self.cursorY, self.scroll, self.fileName, (self.writed ? 1:0));
    wattroff(self.win, A_REVERSE);

    wrefresh(self.win);
}

void saveCursorPosition(ViWin* self, char* file_name) {
    char* home = getenv("HOME");
    
    if(home == null) {
        return;
    }
    
    char file_name2[PATH_MAX];
    
    snprintf(file_name2, PATH_MAX, "%s/.wi", home);
    
    (void)mkdir(file_name2, 0755);
    
    var bname = xbasename(file_name);  

    snprintf(file_name2, PATH_MAX, "%s/.wi/%s.pos"
                , home, bname);
    
    FILE* f = fopen(file_name2, "w");

    if(f == null) {
        return;
    }
    
    fprintf(f, "%d %d\n", self.scroll, self.cursorY);
    
    fclose(f);
}
void readCursorPosition(ViWin* self, char* file_name) {
    char* home = getenv("HOME");
    
    if(home == null) {
        self.scroll = 0;
        self.cursorY = 0;
        return;
    }
    
    char file_name2[PATH_MAX];
    
    var bname = xbasename(file_name); 
    snprintf(file_name2, PATH_MAX, "%s/.wi/%s.pos"
                , home, bname);
    
    FILE* f = fopen(file_name2, "r");

    if(f == null) {
        self.cursorY = 0;
        return;
    }
    
    char line[4096];

    int scroll = 0;
    int cursor_y = 0;
    fscanf(f, "%d %d", &scroll, &cursor_y);
    
    fclose(f);
    
    self.scroll = scroll;
    self.cursorY = cursor_y;
    
    if(self.scroll >= self.texts.length()) {
        self.scroll = self.texts.length() - 1;
        self.cursorY = 0;
    }
    
    self.modifyUnderCursorYValue();
    self.modifyOverCursorYValue();
}

void openFile(ViWin* self, char* file_name, int line_num)
{
    FILE* f = fopen(file_name, "r");
    
    if(f == null) {
        char cmd[PATH_MAX+128];
        
        snprintf(cmd, PATH_MAX+128, "techo \"\" > %s", file_name);

        self.texts.push_back(wstring(""))
        
        int rc = system(cmd);
        
        if(rc != 0) {
            endwin();
            fprintf(stderr, "can't open file %s\n", file_name);
            exit(2);
        }

        self.fileName = string(file_name);
        //self.fileName = "a.txt";
        
        self.cursorY = 0;
        self.cursorX = 0;
        self.scroll = 0;
    }
    else {
        char line[4096];

        while(fgets(line, 4096, f) != NULL)
        {
            line[strlen(line)-1] = '\0';
            self.texts.push_back(wstring(line))
        }

        fclose(f);

        if(self.texts.length() == 0) {
            self.texts.push_back(wstring(""))
        }

        self.fileName = string(file_name);
        //self.fileName = "a.txt";

        if(line_num == -1) {
            self.readCursorPosition(file_name);
        }
        else {
            self.cursorY = line_num;
            
            self.modifyUnderCursorYValue();
            self.modifyOverCursorYValue();
            self.centeringCursor();
        }
    }
}

void writeFile(ViWin* self) {
    FILE* f = fopen(self.fileName, "w");

    if(f != null) {
        self.texts.each {
            fprintf(f, "%s\n", it.to_string(""));
        }

        fclose(f);

        self.writed = false;
        self.saveCursorPosition(self.fileName);
    }
}
void writedFlagOn(ViWin* self) {
    self.writed = true;
}
}

impl Vi version 6
{
void toggleWin(Vi* self) {
    if(self.toggleWin >= 0 && self.toggleWin < self.wins.length()) {
        int toggle_win = self.wins.find(self.activeWin, -1);
        self.activeWin = self.wins.item(self.toggleWin, null);
        self.toggleWin = toggle_win;
    }
}

initialize() {
    inherit(self);

    self.events.replace('W'-'A'+1, lambda(Vi* self, int key) 
    {
        var key2 = self.activeWin.getKey(false);

        switch(key2) {
            case 'W'-'A'+1:
                self.toggleWin();
                break;
        }
    });
}
void saveLastOpenFile(Vi* self, char* file_name) {
    char* home = getenv("HOME");
    
    if(home == null) {
        return;
    }
    
    char file_name2[PATH_MAX];
    
    snprintf(file_name2, PATH_MAX, "%s/.nvi", home);
    
    (void)mkdir(file_name2, 0755);
    
    snprintf(file_name2, PATH_MAX, "%s/.nvi/last_open_file", home, file_name);
    
    FILE* f = fopen(file_name2, "w");

    if(f == null) {
        return;
    }
    
    fprintf(f, "%s\n", file_name);
    
    fclose(f);
}

string readLastOpenFile(Vi* self) {
    char* home = getenv("HOME");
    
    if(home == null) {
        return null;
    }
    
    char file_name2[PATH_MAX];
    
    snprintf(file_name2, PATH_MAX, "%s/.nvi/last_open_file", home);
    
    FILE* f = fopen(file_name2, "r");

    if(f == null) {
        return null;
    }

    char file_name[PATH_MAX];

    if(fgets(file_name, PATH_MAX, f) == NULL) {
        fclose(f);

        return string("");
    }
    
    file_name[strlen(file_name)-1] = '\0';
    
    fclose(f);

    return string(file_name);
}

void repositionWindows(Vi* self) {
    int maxy = xgetmaxy();
    int maxx = xgetmaxx();

    int height = maxy / self.wins.length();

    /// determine the position ///
    self.wins.each {
        it.height = height;
        it.y = height * it2;

        delwin(it.win);
        var win = newwin(it.height, it.width, it.y, it.x);
        keypad(win, true);
        it.win = win;

        it.centeringCursor();
        it.cursorX = 0;
    }
}

void openFile(Vi* self, char* file_name, int line_num) 
{
    if(file_name == null) {
        var file_name = self.readLastOpenFile();
        
        if(access(file_name, R_OK) == 0) {
            int active_pos = self.wins.find(self.activeWin, -1);
            self.wins.delete(active_pos);
    
            var maxx = xgetmaxx();
            var maxy = xgetmaxy();
            
            var win = new ViWin.initialize(0,0, maxx-1, maxy, self);
    
            self.activeWin = win;
            self.wins.push_back(win);
            
            self.activeWin.openFile(file_name, -1);
            
            self.repositionWindows();
        }
    }
    else {
        if(access(file_name, R_OK) == 0) {
            int active_pos = self.wins.find(self.activeWin, -1);
            self.wins.delete(active_pos);
    
            var maxx = xgetmaxx();
            var maxy = xgetmaxy();
            
            var win = new ViWin.initialize(0,0, maxx-1, maxy, self);
    
            self.activeWin = win;
            self.wins.push_back(win);
            
            self.activeWin.openFile(file_name, line_num);
            self.saveLastOpenFile(file_name);
            
            self.repositionWindows();
        }
        else {
            int active_pos = self.wins.find(self.activeWin, -1);
            if(active_pos != -1) {
                self.wins.delete(active_pos);
            }
    
            int rc = system(xsprintf("echo \"\" > %s", file_name));
            
            if(rc == 0) {
                var maxx = xgetmaxx();
                var maxy = xgetmaxy();
                
                var win = new ViWin.initialize(0,0, maxx-1, maxy, self);
        
                self.activeWin = win;
                self.wins.push_back(win);
                
                self.activeWin.openFile(file_name, line_num);
                self.saveLastOpenFile(file_name);
                
                self.repositionWindows();
            }
        }
    }
}

void openNewFile(Vi* self, char* file_name) {
    int maxy = xgetmaxy();
    int maxx = xgetmaxx();

    int height = maxy / (self.wins.length() + 1);

    var win = new ViWin.initialize(0,0, maxx-1, height, self);
    
    win.openFile(file_name, -1);

    self.activeWin = win;

    self.wins.push_back(win);

    self.repositionWindows();

    self.wins.each {
        if(!it.equals(self.activeWin)) {
            self.toggleWin = it2;
        }
    }
}

void closeActiveWin(Vi* self) {
    int active_pos = self.wins.find(self.activeWin, -1);
    
    self.wins.delete(active_pos);

    self.repositionWindows();

    self.activeWin = self.wins.item(0, null);
}

void exitFromApp(Vi* self) {
    self.wins.each {
        it.writeFile();
    }
    self.appEnd = true;
}
}
