/**************************************************************************************/
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/

class Cursor extends GUIObject {

  boolean horizontal = true;
  boolean dragged = false;
  boolean activated = true;
  int guideLineLength;
  float[] PosX = { 0., 0., 0. };
  float[] PosY = { 0., 0., 0. };
  float[] PosX_local = { 0., 0., 0. };
  float[] PosY_local = { 0., 0., 0. };
  int posMin;
  int posMax;
  int Size = 5;
  int dashSpace = 4;
  color cursorColor = color(0,160,255);
  
  Cursor(int x, int y, int min, int max, int gl, boolean h) {
    super(x,y,0,0);
    guideLineLength = gl;
    horizontal = h;
    posMin = min;
    posMax = max;
    if (horizontal) {
      PosX_local[0] = float(Size);
      PosY_local[0] = 0.;
      PosX_local[1] = -float(Size)/2.;
      PosY_local[1] = float(Size)*sqrt(3.)/2.;
      PosX_local[2] = -float(Size)/2.;
      PosY_local[2] = -float(Size)*sqrt(3.)/2.;
    } else {
      PosX_local[0] = 0.;
      PosY_local[0] = -float(Size);
      PosX_local[1] = float(Size)*sqrt(3.)/2.;
      PosY_local[1] = float(Size)/2.;
      PosX_local[2] = -float(Size)*sqrt(3.)/2.;
      PosY_local[2] = float(Size)/2.;    
    }
    updateCursorPosition();
  } 
  
  void updateCursorPosition() {
    for (int i=0; i<3; ++i) {
      PosX[i] = float(posx) + PosX_local[i];
      PosY[i] = float(posy) + PosY_local[i];
    }
  }
  
  void draw() {
    fill(cursorColor);
    stroke(cursorColor);
    triangle(PosX[0],PosY[0],PosX[1],PosY[1],PosX[2],PosY[2]);
    if (dragged) {
      if (horizontal) {
        dashLineH(posx,posy,posx+guideLineLength);
      } else {
        dashLineV(posx,posy-guideLineLength,posy);
      }
    }
  }
  
  void setActivate(boolean b) {
    activated = b;
  }
  
  void setColor(color c) {
    cursorColor = c;
  }
  
  int getPosMin() {
    return posMin;
  }
  
  int getPosMax() {
    return posMax;
  }
  
  int getSize() {
    return Size;
  }
  
  color getColor() {
    return cursorColor;
  }
  
  boolean isInScreen() {
    if (horizontal) {
      if (posy>posMin && posy<posMax) return true;
    } else {
      if (posx>posMin && posx<posMax) return true;    
    }
    return false;
  }
  
  boolean isDragged() {
    return dragged;
  }
  
  boolean isMouseOver(int x, int y) {
    if (!activated) return false;
    if (horizontal) {
      if ((x>posx-Size/2)&&(x<posx+Size)) {
        if (abs(y-posy)<Size/2) {
          return true;
        }
      }
    } else {
      if ((y>posy-Size)&&(y<posy+Size/2)) {
        if (abs(x-posx)<Size/2) {
          return true;
        }
      }    
    }
    return false;
  }
  
  void buttonReleased() {
    dragged = false;
  }
  
  boolean buttonPressed(int x,int y) {
    if (isMouseOver(x,y) || dragged) {
      dragged = true;
      if (horizontal) {
        if (y<posMin) y = posMin;
        if (y>posMax) y = posMax;
        posy = y;   
      } else {
        if (x<posMin) x = posMin;
        if (x>posMax) x = posMax;
        posx = x;
      }
      updateCursorPosition();
      return true;
    }
    return false;
  }
  
  void dashLineH(int xmin, int y, int xmax) {
     int x = xmin;
     int xf = x+dashSpace;
     while(x<xmax) {
       xf = x+dashSpace;
       if (xf>xmax) {
         xf = xmax;
       }
       line(x,y,xf,y);
       x = x+2*dashSpace;
     }
  }
  
  void dashLineV(int x, int ymin, int ymax) {
     int y = ymin;
     int yf = y+dashSpace;
     while(y<ymax) {
       yf = y+dashSpace;
       if (yf>ymax) {
         yf = ymax;
       }
       line(x,y,x,yf);
       y = y+2*dashSpace;
     }
  }
}
