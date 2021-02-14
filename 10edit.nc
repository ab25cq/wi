#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <limits.h>
#include <wctype.h>

#include "common.h"

impl ViWin version 10
{
void modifyCursorOnDeleting(ViWin* self) {
    self.modifyOverCursorYValue();
    self.modifyOverCursorXValue();
}

void modifyOverCursorXValue2(ViWin* self){
    if(self.texts.length() == 0) {
        self.scroll = 0;
        self.cursorY = 0;
        self.cursorX = 0;
    }
    else {
        var cursor_line = self.texts.item(self.scroll+self.cursorY, null);

        if(cursor_line) {
            if(self.cursorX >= cursor_line.length())
            {
                self.cursorX = cursor_line.length();

                if(self.cursorX < 0) {
                    self.cursorX = 0;
                }
            }
        }
    }
}

void modifyCursorOnDeleting2(ViWin* self) {
    self.modifyOverCursorYValue();
    self.modifyOverCursorXValue2();
}

void deleteOneLine(ViWin* self, Vi* nvi) {
    if(self.digitInput > 0) {
        self.pushUndo();
        
        nvi.yank.reset();
        nvi.yankKind = kYankKindLine;
        
        for(int i=0; i<self.digitInput+1; i++) {
            var line = self.texts.item(self.scroll+self.cursorY, null);
            
            if(line != null) {
                nvi.yank.push_back(clone line);
                
                self.texts.delete(self.scroll+self.cursorY);
        
                self.modifyCursorOnDeleting();
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var line = self.texts.item(self.scroll+self.cursorY, null);
        if(line != null) {
            self.pushUndo();
            nvi.yank.reset();
            nvi.yank.push_back(clone line);
            nvi.yankKind = kYankKindLine;
            self.texts.delete(self.scroll+self.cursorY);
    
            self.modifyCursorOnDeleting();
        }
    }
}

void deleteOneLine2(ViWin* self, Vi* nvi) {
    if(self.digitInput > 0) {
        self.pushUndo();
        
        nvi.yank.reset();
        nvi.yankKind = kYankKindLine;
        
        for(int i=0; i<self.digitInput+1; i++) {
            var line = self.texts.item(self.scroll+self.cursorY, null);
            
            if(line != null) {
                nvi.yank.push_back(clone line);
                
                self.texts.delete(self.scroll+self.cursorY);
        
                self.modifyCursorOnDeleting();
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var line = self.texts.item(self.scroll+self.cursorY, null);
        if(line != null) {
            self.pushUndo();
            self.texts.delete(self.scroll+self.cursorY);
            self.texts.insert(self.scroll+self.cursorY, wstring(""));
    
            self.modifyCursorOnDeleting();
        }
    }
}

void deleteWord(ViWin* self, Vi* nvi) {
    self.pushUndo();
    
    if(self.digitInput > 0) {
        var line = self.texts.item(self.scroll+self.cursorY, wstring(""));
    
        if(wcslen(line) == 0) {
            self.deleteOneLine(nvi);
        }
        else {
            int count = self.digitInput + 1;
            
            int x = self.cursorX;
    
            for(int i=0; i<count; i++) {
                wchar_t* p = line + x;
        
                if((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_')
                {
                    while((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_')
                    {
                        p++;
                        x++;
        
                        if(x >= line.length())
                        {
                            break;
                        }
                    }
                }
                else if((*p >= '!' && *p <= '/') || (*p >= ':' && *p <= '@') || (*p >= '{' && *p <= '~' ))
                {
                    while((*p >= '!' && *p <= '/') || (*p >= ':' && *p <= '@') || (*p >= '{' && *p <= '~' ))
                    {
                        p++;
                        x++;
        
                        if(x >= line.length())
                        {
                            break;
                        }
                    }
                }
                else if(iswalpha(*p)) {
                    while(iswalpha(*p)) {
                        p++;
                        x++;
        
                        if(x >= line.length())
                        {
                            break;
                        }
                    }
                }
                else if(iswblank(*p)) {
                    while(iswblank(*p)) {
                        p++;
                        x++;
        
                        if(x >= line.length())
                        {
                            break;
                        }
                    }
                }
                else if(iswdigit(*p)) {
                    while(iswdigit(*p)) {
                        p++;
                        x++;
        
                        if(x >= line.length())
                        {
                            break;
                        }
                    }
                }
            }
    
//            nvi.yank.reset();
//            nvi.yank.push_back(line.substring(self.cursorX, x));
//            nvi.yankKind = kYankKindNoLine;
            line.delete_range(self.cursorX, x);
    
            self.modifyCursorOnDeleting2();
        }
        
        self.digitInput = 0;
    }
    else {
        var line = self.texts.item(self.scroll+self.cursorY, wstring(""));
    
        if(wcslen(line) == 0) {
            self.deleteOneLine(nvi);
        }
        else {
            int x = self.cursorX;
    
            wchar_t* p = line + x;
    
            if((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_')
            {
                while((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_')
                {
                    p++;
                    x++;
    
                    if(x >= line.length())
                    {
                        break;
                    }
                }
            }
            else if((*p >= '!' && *p <= '/') || (*p >= ':' && *p <= '@') || (*p >= '{' && *p <= '~' ))
            {
                while((*p >= '!' && *p <= '/') || (*p >= ':' && *p <= '@') || (*p >= '{' && *p <= '~' ))
                {
                    p++;
                    x++;
    
                    if(x >= line.length())
                    {
                        break;
                    }
                }
            }
            else if(iswalpha(*p)) {
                while(iswalpha(*p)) {
                    p++;
                    x++;
    
                    if(x >= line.length())
                    {
                        break;
                    }
                }
            }
            else if(iswblank(*p)) {
                while(iswblank(*p)) {
                    p++;
                    x++;
    
                    if(x >= line.length())
                    {
                        break;
                    }
                }
            }
            else if(iswdigit(*p)) {
                while(iswdigit(*p)) {
                    p++;
                    x++;
    
                    if(x >= line.length())
                    {
                        break;
                    }
                }
            }
    
//            nvi.yank.reset();
//            nvi.yank.push_back(line.substring(self.cursorX, x));
//            nvi.yankKind = kYankKindNoLine;
            line.delete_range(self.cursorX, x);
    
            self.modifyCursorOnDeleting2();
        }
    }
}

void deleteForNextCharacter(ViWin* self) {
    self.pushUndo();
    
    if(self.digitInput > 0) {
        var key = self.getKey(false);
    
        var line = self.texts.item(self.scroll+self.cursorY, wstring(""));
    
        if(wcslen(line) > 0) {
            int x = self.cursorX;
            
            int count = self.digitInput + 1;
            
            wchar_t* p;
    
            for(int i=0; i<count; i++) {
                p = line + x;
        
                while(*p != key) {
                    p++;
                    x++;
        
                    if(x >= line.length())
                    {
                        break;
                    }
                }
                
                if(i != count -1) {
                    x++;
                }
            }
            
            if(*p == key) {
                line.delete_range(self.cursorX, x+1);
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var key = self.getKey(false);
    
        var line = self.texts.item(self.scroll+self.cursorY, wstring(""));
    
        if(wcslen(line) > 0) {
            int x = self.cursorX;
    
            wchar_t* p = line + x;
    
            while(*p != key) {
                p++;
                x++;
    
                if(x >= line.length())
                {
                    break;
                }
            }
            
            if(*p == key) {
                line.delete_range(self.cursorX, x+1);
            }
        }
    }
}

void deleteForNextCharacter2(ViWin* self) {
    self.pushUndo();
    
    if(self.digitInput > 0) {
        var key = self.getKey(false);
    
        var line = self.texts.item(self.scroll+self.cursorY, wstring(""));
    
        if(wcslen(line) > 0) {
            int x = self.cursorX;
            
            int count = self.digitInput + 1;
            
            wchar_t* p;
    
            for(int i=0; i<count; i++) {
                p = line + x;
        
                while(*p != key) {
                    p++;
                    x++;
        
                    if(x >= line.length())
                    {
                        break;
                    }
                }
                
                if(i != count -1) {
                    x++;
                }
            }
            
            if(*p == key) {
                line.delete_range(self.cursorX, x);
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var key = self.getKey(false);
    
        var line = self.texts.item(self.scroll+self.cursorY, wstring(""));
    
        if(wcslen(line) > 0) {
            int x = self.cursorX;
    
            wchar_t* p = line + x;
    
            while(*p != key) {
                p++;
                x++;
    
                if(x >= line.length())
                {
                    break;
                }
            }
            
            if(*p == key) {
                line.delete_range(self.cursorX, x);
            }
        }
    }
}

void deleteCursorCharactor(ViWin* self) {
    self.pushUndo();
    
    if(self.digitInput > 0) {
        int num = self.digitInput + 1;
        
        var line = self.texts.item(self.scroll+self.cursorY, null);
        
        for(int i= 0; i<num; i++) {
            line.delete(self.cursorX);
        }
    
        self.modifyOverCursorXValue();
        
        self.digitInput = 0;
    }
    else {
        var line = self.texts.item(self.scroll+self.cursorY, null);
        line.delete(self.cursorX);
    
        self.modifyOverCursorXValue();
    }
}

void replaceCursorCharactor(ViWin* self) {
    self.pushUndo();
    
    var key = self.getKey(false);
    
/*
    if(self.digitInput > 0) {
        int num = self.digitInput + 1;
        
        var line = self.texts.item(self.scroll+self.cursorY, null);
        
        for(int i= 0; i<num; i++) {
            line.replace(self.cursorX+i, (wchar_t)key);
        }
        
        self.digitInput = 0;
    }
    else {
*/
        var line = self.texts.item(self.scroll+self.cursorY, null);
        line.replace(self.cursorX, (wchar_t)key);
//    }
}

void deleteUntilTail(ViWin* self) {
    self.pushUndo();
    
    if(self.digitInput > 0) {
        var line = self.texts.item(self.scroll+self.cursorY, null);
        
        line.delete_range(self.cursorX, -1);
        
        int num = self.digitInput + 1;
        
        for(int i=1; i<num; i++) {
            var line = self.texts.item(self.scroll+self.cursorY+1, null);
            
            if(line != null) {
                self.texts.delete(self.scroll+self.cursorY+1);
        
                self.modifyCursorOnDeleting();
            }
        }
        
        self.modifyOverCursorXValue();
        
        self.digitInput = 0;
    }
    else {
        var line = self.texts.item(self.scroll+self.cursorY, null);
        line.delete_range(self.cursorX, -1);
        
        self.modifyOverCursorXValue();
    }
}

void joinLines(ViWin* self) {
    self.pushUndo();

    if(self.scroll+self.cursorY+1 < self.texts.length()) {
        var line = self.texts.item(self.scroll+self.cursorY, null);
        var next_line = self.texts.item(self.scroll+self.cursorY+1, null);

        self.texts.replace(self.scroll+self.cursorY, line + wstring(" ") + next_line);
        self.texts.delete(self.scroll+self.cursorY+1);
    }

    self.modifyOverCursorXValue();
}

void yankOneLine(ViWin* self, Vi* nvi) {
    if(self.digitInput > 0) {
        self.pushUndo();
        
        nvi.yank.reset();
        nvi.yankKind = kYankKindLine;
        
        for(int i=0; i<self.digitInput+1; i++) {
            var line = self.texts.item(self.scroll+self.cursorY+i, null);
            
            if(line != null) {
                nvi.yank.push_back(clone line);
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var line = self.texts.item(self.scroll+self.cursorY, null);
        if(line != null) {
            self.pushUndo();
            nvi.yank.reset();
            nvi.yank.push_back(clone line);
            nvi.yankKind = kYankKindLine;
        }
    }
}

void joinLines2(ViWin* self) {
    self.pushUndo();

    if(self.scroll+self.cursorY+1 < self.texts.length()) {
        var line = self.texts.item(self.scroll+self.cursorY, null);
        var next_line = self.texts.item(self.scroll+self.cursorY+1, null);

        self.texts.replace(self.scroll+self.cursorY, line + next_line);
        self.texts.delete(self.scroll+self.cursorY+1);
    }

    self.modifyOverCursorXValue();
}

void forwardToNextCharacter1(ViWin* self) {
    var key = self.getKey(false);
    
    var line = self.texts.item(self.scroll+self.cursorY, null);
    
    if(self.digitInput > 0) {
        for(int i=0; i<self.digitInput+1; i++) {
            var cursor_x = line.substring(self.cursorX+1, -1).index(xsprintf("%c", key).to_wstring(), -1);
            
            if(cursor_x != -1) {
                self.cursorX += cursor_x + 1;
            }
            else {
                break;
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var cursor_x = line.substring(self.cursorX + 1, -1).index(xsprintf("%c", key).to_wstring(), -1);
        
        if(cursor_x != -1) {
            self.cursorX += cursor_x + 1;
        }
    }
}

void forwardToNextCharacter2(ViWin* self) {
    var key = self.getKey(false);
    
    var line = self.texts.item(self.scroll+self.cursorY, null);
    
    if(self.digitInput > 0) {
        for(int i=0; i<self.digitInput+1; i++) {
            var cursor_x = line.substring(self.cursorX + 2, -1).index(xsprintf("%c", key).to_wstring(), -1);
            
            if(cursor_x != -1) {
                self.cursorX += cursor_x + 1;
            }
            else {
                break;
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var cursor_x = line.substring(self.cursorX+1, -1).index(xsprintf("%c", key).to_wstring(), -1);
        
        if(cursor_x != -1) {
            self.cursorX += cursor_x;
        }
    }
}

void backwardToNextCharacter1(ViWin* self) {
    var key = self.getKey(false);
    
    var line = self.texts.item(self.scroll+self.cursorY, null);
    
    if(self.digitInput > 0) {
        for(int i=0; i<self.digitInput+1; i++) {
            var cursor_x = line.substring(0, self.cursorX).rindex(xsprintf("%c", key).to_wstring(), -1);
            
            if(cursor_x != -1) {
                self.cursorX = cursor_x;
            }
            else {
                break;
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var cursor_x = line.substring(0, self.cursorX).rindex(xsprintf("%c", key).to_wstring(), -1);
        
        if(cursor_x != -1) {
            self.cursorX = cursor_x;
        }
    }
}

void backwardToNextCharacter2(ViWin* self) {
    var key = self.getKey(false);
    
    var line = self.texts.item(self.scroll+self.cursorY, null);
    
    if(self.digitInput > 0) {
        for(int i=0; i<self.digitInput+1; i++) {
            var cursor_x = line.substring(0, self.cursorX-1).rindex(xsprintf("%c", key).to_wstring(), -1);
            
            if(cursor_x != -1) {
                self.cursorX = cursor_x + 1;
            }
            else {
                break;
            }
        }
        
        self.digitInput = 0;
    }
    else {
        var cursor_x = line.substring(0, self.cursorX).rindex(xsprintf("%c", key).to_wstring(), -1);
        
        if(cursor_x != -1) {
            self.cursorX = cursor_x + 1;
        }
    }
}

void changeCase(ViWin* self) {
    self.pushUndo();

    var line = self.texts.item(self.scroll+self.cursorY, null);
    
    if(self.digitInput > 0) {
        for(int i=0; i<self.digitInput+1; i++) {
            wchar_t c = line.item(self.cursorX + i, -1);
            
            if(c != -1) {
                if(c >= 'a' && c <= 'z') {
                    wchar_t c2 = c - 'a' + 'A';
                    
                    line.replace(self.cursorX + i, c2);
                }
                else if(c >= 'A' && c <= 'Z') {
                    wchar_t c2 = c - 'A' + 'a';
                    
                    line.replace(self.cursorX + i, c2);
                }
            }
            else {
                break;
            }
        }
        
        self.digitInput = 0;
    }
    else {
        wchar_t c = line.item(self.cursorX, -1);
            
        if(c != -1) {
            if(c >= 'a' && c <= 'z') {
                wchar_t c2 = c - 'a' + 'A';
                
                line.replace(self.cursorX, c2);
            }
            else if(c >= 'A' && c <= 'Z') {
                wchar_t c2 = c - 'A' + 'a';
                
                line.replace(self.cursorX, c2);
            }
        }
    }
}

void moveToHead(ViWin* self) {
    var line = self.texts.item(self.scroll+self.cursorY, null);
    
    var point = line.to_string("").index_regex(regex!("\\S"), -1);
    
    if(point != -1) {
        self.cursorX = point;
    }
}

}

impl Vi version 10
{
initialize() {
    inherit(self);

    self.events.replace('d', lambda(Vi* self, int key) {
        var key2 = self.activeWin.getKey(true);

        switch(key2) {
            case 'd':
                self.activeWin.deleteOneLine(self);
                self.activeWin.writed = true;
                break;
            
            case 'w':
            case 'e':
                self.activeWin.deleteWord(self);
                self.activeWin.writed = true;
                break;
            
            case 'f':
                self.activeWin.deleteForNextCharacter();
                self.activeWin.writed = true;
                break;
                
            case 't':
                self.activeWin.deleteForNextCharacter2();
                self.activeWin.writed = true;
                break;
                
            case '$':
                self.activeWin.deleteUntilTail();
                self.activeWin.writed = true;
                break;
        }

        self.activeWin.saveInputedKey();
    });

    self.events.replace('c', lambda(Vi* self, int key) {
        var key2 = self.activeWin.getKey(true);

        switch(key2) {
            case '$':
                self.activeWin.deleteUntilTail();
                self.enterInsertMode();
                if(self.activeWin.texts.length() != 0) {
                    self.activeWin.cursorX++;
                }
                self.activeWin.writed = true;
                break;
                
            case 'c':
                self.activeWin.deleteOneLine2(self);
                self.enterInsertMode();
                if(self.activeWin.texts.length() != 0) {
                    self.activeWin.cursorX = 0;
                }
                self.activeWin.writed = true;
                break;
                
                
            case 'w':
            case 'e': {
                self.activeWin.deleteWord(self);
                self.enterInsertMode2();
                self.activeWin.writed = true;
                }
                break;
                
            case 't':
                self.activeWin.deleteForNextCharacter2();
                self.enterInsertMode();
                self.activeWin.writed = true;
                break;
                
            case 'f':
                self.activeWin.deleteForNextCharacter();
                self.enterInsertMode();
                self.activeWin.writed = true;
                break;
        }
    });
    self.events.replace('y', lambda(Vi* self, int key) {
        var key2 = self.activeWin.getKey(true);

        switch(key2) {
            case 'y':
                self.activeWin.yankOneLine(self);
                break;
        }
    });
    self.events.replace('Y', lambda(Vi* self, int key) {
        self.activeWin.yankOneLine(self);
    });
    self.events.replace('D', lambda(Vi* self, int key) {
        self.activeWin.deleteUntilTail();
        self.activeWin.writed = true;

        self.activeWin.saveInputedKey();
    });

    self.events.replace('C', lambda(Vi* self, int key) {
        self.activeWin.deleteUntilTail();
        self.enterInsertMode();
        if(self.activeWin.texts.length() != 0) {
            self.activeWin.cursorX++;
        }
        self.activeWin.writed = true;
    });
    self.events.replace('x', lambda(Vi* self, int key) {
        self.activeWin.deleteCursorCharactor();
        self.activeWin.writed = true;

        self.activeWin.saveInputedKey();
    });
    self.events.replace('r', lambda(Vi* self, int key) {
        self.activeWin.replaceCursorCharactor();
        self.activeWin.writed = true;

        self.activeWin.saveInputedKey();
    });
    self.events.replace('J', lambda(Vi* self, int key) {
        self.activeWin.joinLines();
        self.activeWin.writed = true;

        self.activeWin.saveInputedKey();
    });
    self.events.replace('~', lambda(Vi* self, int key) {
        self.activeWin.changeCase();

        self.activeWin.saveInputedKey();
    });
    self.events.replace('f', lambda(Vi* self, int key) {
        self.activeWin.forwardToNextCharacter1();

        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('t', lambda(Vi* self, int key) {
        self.activeWin.forwardToNextCharacter2();

        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('F', lambda(Vi* self, int key) {
        self.activeWin.backwardToNextCharacter1();

        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('T', lambda(Vi* self, int key) {
        self.activeWin.backwardToNextCharacter2();

        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('^', lambda(Vi* self, int key) {
        self.activeWin.moveToHead();

        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('+', lambda(Vi* self, int key) 
    {
        self.activeWin.nextLine();
        self.activeWin.moveToHead();
        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
    self.events.replace('-', lambda(Vi* self, int key) 
    {
        self.activeWin.prevLine();
        self.activeWin.moveToHead();
        self.activeWin.saveInputedKeyOnTheMovingCursor();
    });
}
}
