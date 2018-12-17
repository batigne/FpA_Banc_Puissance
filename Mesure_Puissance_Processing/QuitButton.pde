/**************************************************************************************/
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/

class QuitButton extends ImageButton { // Exit image button.
  
  QuitButton(int x,int y,int w,int h,PImage img1,PImage img2) {
    super(x,y,w,h,img1,img2);
  }
  
  void buttonPressed(int x,int y) {
    if (isMouseOver(x,y)) 
      exit();
  }
  
}
