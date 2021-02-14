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

impl ViWin version 7
{
void pasteAfterCursor(ViWin* self, Vi* nvi) {
    if(nvi.yankKind == kYankKindLine) {
        self.pushUndo();

        nvi.yank.each {
            self.texts.insert(
                self.scroll+self.cursorY+it2+1, 
                clone it);
        }
    }
    else {
        self.pushUndo();

        var line = self.texts.item(self.scroll+self.cursorY, null);
        
        if(nvi.yank.length() == 1) {
            var yank_first_line = nvi.yank.item(0, null);

            var new_line = line.substring(0, self.cursorX+1) 
                                + yank_first_line 
                                + line.substring(self.cursorX+1, -1);
    
            self.texts.replace(self.scroll+self.cursorY, clone new_line);
        }
        else if(nvi.yank.length() == 2) {
            var yank_first_line = nvi.yank.item(0, null);
    
            var new_line = line.substring(0, self.cursorX+1) 
                                + yank_first_line;

            var after_line = line.substring(self.cursorX+1, -1);
    
            self.texts.replace(self.scroll+self.cursorY, clone new_line);
            
            var yank_last_line = nvi.yank.item(-1, null);
            
            var new_line2 = yank_last_line + after_line;
            self.texts.insert(
                self.scroll+self.cursorY+1,
                clone new_line2);
        }
        else if(nvi.yank.length() > 2) {
            var yank_first_line = nvi.yank.item(0, null);
    
            var new_line = line.substring(0, self.cursorX+1) 
                                + yank_first_line;
            var after_line = line.substring(self.cursorX+1, -1);
    
            self.texts.replace(self.scroll+self.cursorY
                            , clone new_line);
            nvi.yank.sublist(1,-2).each {
                self.texts.insert(
                    self.scroll+self.cursorY+it2+1, 
                    clone it);
            }
            
            var yank_last_line = nvi.yank.item(-1, null);
            
            var new_line2 = yank_last_line 
                    + after_line;
            self.texts.insert(
                self.scroll+self.cursorY+nvi.yank.length()-1, 
                clone new_line2);
        }
    }
}

void pasteBeforeCursor(ViWin* self, Vi* nvi) {
    if(nvi.yankKind == kYankKindLine) {
        self.pushUndo();
        nvi.yank.each {
            self.texts.insert(
                self.scroll+self.cursorY+it2, 
                clone it);
        }
    }
    else {
        self.pushUndo();

        var line = self.texts.item(self.scroll+self.cursorY, null);
        
        if(nvi.yank.length() == 1) {
            var yank_first_line = nvi.yank.item(0, null);

            var new_line = line.substring(0, self.cursorX) 
                                + yank_first_line 
                                + line.substring(self.cursorX, -1);
    
            self.texts.replace(self.scroll+self.cursorY, clone new_line);
        }
        else if(nvi.yank.length() == 2) {
            var yank_first_line = nvi.yank.item(0, null);
    
            var new_line = line.substring(0, self.cursorX) 
                                + yank_first_line;
            var after_line = line.substring(self.cursorX, -1);
    
            self.texts.replace(self.scroll+self.cursorY, clone new_line);
            
            var yank_last_line = nvi.yank.item(-1, null);
            
            var new_line2 = yank_last_line + after_line;
            self.texts.insert(
                self.scroll+self.cursorY+1,
                clone new_line2);
        }
        else if(nvi.yank.length() > 2) {
            var yank_first_line = nvi.yank.item(0, null);
    
            var new_line = line.substring(0, self.cursorX) 
                                + yank_first_line;
            var after_line = line.substring(self.cursorX, -1);
    
            self.texts.replace(self.scroll+self.cursorY
                            , clone new_line);
            nvi.yank.sublist(1,-2).each {
                self.texts.insert(
                    self.scroll+self.cursorY+it2+1, 
                    clone it);
            }
            
            var yank_last_line = nvi.yank.item(-1, null);
            
            var new_line2 = yank_last_line + after_line;
            self.texts.insert(
                self.scroll+self.cursorY+nvi.yank.length()-1, 
                clone new_line2);
        }
    }
}
}

impl Vi version 7 
{
void saveYank(Vi* nvi) {
    char* home = getenv("HOME");
    
    if(home == null) {
        return;
    }
    
    char file_name2[PATH_MAX];
    
    snprintf(file_name2, PATH_MAX, "%s/.wi", home);
    
    (void)mkdir(file_name2, 0755);
    
    snprintf(file_name2, PATH_MAX, "%s/.wi/yankring", home);
    
    FILE* f = fopen(file_name2, "w");

    if(f == null) {
        return;
    }
    
    fprintf(f, "%d\n", nvi.yankKind);
    
    if(nvi.yankKind == kYankKindLine) {
        nvi.yank.each {
            fprintf(f, "%ls\n", it);
        }
    }
    else {
        if(nvi.yank.length() == 1) {
            var yank_first_line = nvi.yank.item(0, null);
            
            fprintf(f, "%ls\n", yank_first_line);
        }
        else if(nvi.yank.length() == 2) {
            var yank_first_line = nvi.yank.item(0, null);
            
            fprintf(f, "%ls\n", yank_first_line);
    
            var yank_last_line = nvi.yank.item(-1, null);
            
            fprintf(f, "%ls\n", yank_last_line);
        }
        else if(nvi.yank.length() > 2) {
            var yank_first_line = nvi.yank.item(0, null);
            
            fprintf(f, "%ls\n", yank_first_line);
    
            nvi.yank.sublist(1,-2).each {
                fprintf(f, "%ls\n", it);
            }
            
            var yank_last_line = nvi.yank.item(-1, null);
            
            fprintf(f, "%ls\n", yank_last_line);
        }
    }
    
    fclose(f);
}

void readYank(Vi* nvi) {
    char* home = getenv("HOME");
    
    if(home == null) {
        return;
    }
    
    char file_name2[PATH_MAX];
    
    snprintf(file_name2, PATH_MAX, "%s/.wi", home);
    
    (void)mkdir(file_name2, 0755);
    
    snprintf(file_name2, PATH_MAX, "%s/.wi/yankring", home);
    
    FILE* f = fopen(file_name2, "r");

    if(f == null) {
        return;
    }
    
    char line[4096];

    int kind = 0;
    
    if(fscanf(f, "%d\n", &kind) == 0) {
        fclose(f);
        return;
    }

    nvi.yankKind = kind;

    nvi.yank.reset();
    
    if(nvi.yankKind == kYankKindLine) {
        while(true) {
            if(fgets(line, 4096, f) == null) {
                break;
            }
            line[strlen(line)-1] = '\0';
            var line2 = string(line).to_wstring()
            nvi.yank.push_back(line2);
        }
    }
    else {
        while(true) {
            if(fgets(line, 4096, f) == null) {
                break;
            }
            line[strlen(line)-1] = '\0';
            var line2 = string(line).to_wstring()
            nvi.yank.push_back(line2);
        }
    }
    
    fclose(f);
}

finalize() {
    self.saveYank();
    inherit(self);
}

initialize() {
    inherit(self);

    self.yank = new list<wstring>.initialize();

    self.yankKind = 0;

    self.events.replace('p', lambda(Vi* self, int key) 
    {
        self.activeWin.pasteAfterCursor(self);
        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });

    self.events.replace('P', lambda(Vi* self, int key) 
    {
        self.activeWin.pasteBeforeCursor(self);
        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    
    self.readYank();
}
}
