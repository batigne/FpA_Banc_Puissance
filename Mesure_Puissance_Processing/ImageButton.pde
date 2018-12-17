/**************************************************************************************/
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/

class ImageButton extends GUIObject { // A clickable image. The image is changing when the mouse is
  //located over it.

  PImage imgDefault;
  PImage imgOver;
  PImage currentImage;
  
  ImageButton(int x,int y,int w,int h,PImage img1, PImage img2) {
    super(x,y,w,h);
    imgDefault = img1;
    imgOver = img2;
    currentImage = imgDefault;
  }
  
  void draw() {
    image(currentImage,posx,posy,Width,Height);
  }
  
  void switchImages() {
    PImage temp = imgDefault;
    imgDefault = imgOver;
    imgOver = temp;
  }

  void overButton(int x,int y) {
    PImage previousImage = currentImage;
    if (isMouseOver(x,y)) {
      currentImage = imgOver;
    }
    else {
      currentImage = imgDefault;  
    }
    if (previousImage != currentImage) draw();
  }

}
