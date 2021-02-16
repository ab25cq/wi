#include "common.h"

impl Vi version 6
{

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
    }
}
}
