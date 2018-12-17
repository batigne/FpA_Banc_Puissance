/**************************************************************************************/
/*    G. Batigne
/*      14/09/2018
/**************************************************************************************/

class valueDisplay extends GUIObject { // Class defining a display for Text.

  int sizeFont;
  String displayValue;
  int fillColor = 255;
  int strokeColor = 0;
  color textColor = color(0,0,0);
  
  valueDisplay(int x,int y, int w, int h, String s) {
    super(x,y,w,h);
    displayValue = s;
    sizeFont = 20;
  }

  valueDisplay(int x,int y, int w, int h) {
    super(x,y,w,h);
    displayValue = "0 V";
    sizeFont = 20;
  }
  
  void setFillColor(int fc) {
    fillColor = fc;
  }
  
  void setStrokeColor(int sc) {
    strokeColor = sc;
  }
  
  void setFontSize(int fs) {
    sizeFont = fs;
  }
  
  void setTextColor(color c) {
    textColor = c;
  }
  
  String getText() {
    return displayValue;
  }
  
  void draw() {
    fill(fillColor);
    stroke(strokeColor);
    rect(posx,posy,Width,Height);
    fill(0);
    textSize(sizeFont);
    fill(textColor); 
    text(displayValue,posx+8,posy+Height-10);
  }
  
  void updateValue(String s) {
    displayValue = s;
  } 
  
}
