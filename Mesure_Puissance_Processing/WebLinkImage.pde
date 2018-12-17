/**************************************************************************************/
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/

class WebLinkImage extends GUIObject {

  PImage WLI;
  String Link;
  
  WebLinkImage(int x, int y, int w, int h, PImage img, String l) {
    super(x,y,w,h);
    WLI = img;
    Link = l;
  }
  
  void draw() {
    image(WLI,posx,posy,Width,Height);
  }
  
  void setImage(PImage img) {
    WLI = img;
  }

  void buttonPressed(int x, int y) {
    if (isMouseOver(x,y)) {
      link(Link);
    }
  }
  
}
