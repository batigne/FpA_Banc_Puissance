/**************************************************************************************/
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/

class GUIObject { // General class to define a GUI Object. It defines the main properties 
                  // (position and size) and graphical interactions.
  int Width,Height;
  int posx,posy;
  int fontSize = 12;

  color textColor = color(0);
  
  GUIObject(int x,int y,int w,int h) {
    posx = x; // Top left position
    posy = y; // 
    Width = w;
    Height = h;
  }
  
  GUIObject(int x,int y, int w) {
    posx = x;
    posy = y;
    Width = w;
    Height = 0;
  }
  
  void draw() {
  }
  
  void setPosX(int x) {
    posx = x;
  }
  
  void setPosY(int y) {
    posy = y;
  }
  
  void setWidth(int w) {
    Width = w;
  }
  
  void setHeight(int h) {
    Height = h;
  }
   
  void setFontSize(int fs) {
    fontSize = fs;
  }
 
  void setTextColor(color c) {
    textColor = c;
  }

  int getPosX() {
    return posx;
  }
  
  int getPosY() {
    return posy;
  }
  
  int getWidth() {
    return Width;
  }
  
  int getHeight() {
    return Height;
  }

  boolean isMouseOver(int x,int y) {
    int pos_relx = x-posx;
    if (pos_relx*(Width-pos_relx)>0) { 
      int pos_rely = y-posy;
      if (pos_rely*(Height-pos_rely)>0)
        return true;
    }
    return false;
  }

}
