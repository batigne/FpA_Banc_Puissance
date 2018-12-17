/**************************************************************************************/
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/

class SwitchButton extends ImageButton { // Class defining a switch button
  
  PImage imgStateOnLight;
  PImage imgStateOffLight;
  PImage imgStateOnDark;
  PImage imgStateOffDark;
  boolean started = false;
  
  SwitchButton(int x,int y,int w,int h,PImage imgOnL, PImage imgOffL, PImage imgOnD, PImage imgOffD) {
    super(x,y,w,h,imgOffL,imgOffD);
    imgStateOnLight = imgOnL;
    imgStateOnDark = imgOnD;
    imgStateOffLight = imgOffL;
    imgStateOffDark = imgOffD;
  }
  
  void switchImages() {
    PImage temp = imgStateOnLight;
    imgStateOnLight = imgStateOnDark;
    imgStateOnDark = temp;
    temp = imgStateOffLight;
    imgStateOffLight = imgStateOffDark;
    imgStateOffDark = temp;
    if (started) {
      imgDefault = imgStateOnLight;
      imgOver = imgStateOnDark;
    } else {
      imgDefault = imgStateOffLight;
      imgOver = imgStateOffDark;    
    }
  }
  
  void setState(boolean s) {
    started = s;
    if (started) {
      imgDefault = imgStateOnLight;
      imgOver = imgStateOnDark;
    } else {
      imgDefault = imgStateOffLight;
      imgOver = imgStateOffDark;    
    }
  }
  
  boolean getState() {
    return started;
  }
  
  boolean buttonPressed(int x,int y) {
    if (isMouseOver(x,y)) {
      started = !started;
      if (started) {
        imgDefault = imgStateOnLight;
        imgOver = imgStateOnDark;
      } else {
        imgDefault = imgStateOffLight;
        imgOver = imgStateOffDark;
      }
      draw();
      return true;
    }   
    return false;
  }
  
}
