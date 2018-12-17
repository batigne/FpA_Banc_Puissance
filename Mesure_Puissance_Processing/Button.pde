/**************************************************************************************/
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/

class Button extends GUIObject { // Class to define a button with Text on it.

  String Text; // Text written on the button..
  int textPosX = 5; // Default position (from bottom left)
  int textPosY = 5; 
  color defaultColor = color(209); 
  color highlightColor = color(180);
  color currentColor = defaultColor; // Colour of the button.
  color defaultStrokeColor = color(0); // Colour of the border in Light display.
  color highlightStrokeColor = color(255); // Colour of the border in Dark display.
  color currentStrokeColor = defaultStrokeColor;
  boolean state; // Button is On (true) or Off (false).
  
  Button(int x,int y,int w,int h,String t) {
    super(x,y,w,h);
    Text = t;
    state = true;
  }
  
  Button(int x,int y,int w,int h,String t,int fs) {
    super(x,y,w,h);
    Text = t;
    fontSize = fs;
    state = true;
  }
  
  void draw() {
    fill(currentColor);
    stroke(currentStrokeColor);
    rect(posx,posy,Width,Height);
    fill(0);
    textSize(fontSize);
    text(Text,posx+textPosX,posy+Height-textPosY);
  }
  
  void setStrokeColor(color c) {
    defaultStrokeColor = c;
    currentStrokeColor = defaultStrokeColor;
  }
  
  void setFillColor(color fc) {
    defaultColor = fc;
    currentColor = defaultColor;
    state = true;
  }
  
  void setText(String s) {
    Text = s;
  }
  
  void setTextPosition(int x, int y) {
    textPosX = x;
    textPosY = y;
  }
  
  boolean getState() {
    return state;
  }
  
  color getBkgColor() {
    return currentColor;
  }
  
  color getStrokeColor() {
    return currentStrokeColor;
  }
  
  String getText() {
    return Text;
  }
  
  void switchColor() {
    color c = highlightColor;
    highlightColor = defaultColor;
    defaultColor = c;
    if (currentColor == defaultColor) {
      currentColor = highlightColor;
    } else {
      currentColor = defaultColor;
    }  
  }
  
  void switchStrokeColor() {
    color c = highlightStrokeColor;
    highlightStrokeColor = defaultStrokeColor;
    defaultStrokeColor = c;
    currentStrokeColor = defaultStrokeColor;
  }
  
  void switchColors() {
    switchColor();
    switchStrokeColor();
  }
  
  void switchState() {
    state = !state;
    if (state) currentColor = defaultColor;
    else currentColor = highlightColor;
  }
  
  void setButtonOn() {
    currentColor = highlightColor;
    state = true;
  }
  
  void setButtonOff() {
    currentColor = defaultColor;
    state = false;
  }
  
  boolean buttonPressed(int x, int y) {
    return isMouseOver(x,y);
  }
  
  void overButton(int x,int y) {
    int previousColor = currentColor;
    if (isMouseOver(x,y)) {
      currentColor = highlightColor;
    }
    else {
      currentColor = defaultColor;  
    }
    if (previousColor != currentColor) draw();
  }
  
}
