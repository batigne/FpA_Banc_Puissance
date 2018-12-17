/**************************************************************************************/
/*    G. Batigne
/*      19/10/2018
/**************************************************************************************/

class DisplayData extends GUIObject {

  DisplayScreen displayScreen;
  DisplayControl displayControl;

  color timeColor = color(0);
  color shuntColor = color(255,0,0);
  color motorColor = color(0,200,0);
  color tachyColor = color(200,0,200);
  color powerColor = color(0,0,255);
  color omegaColor = color(150,150,0);

  DisplayData(int x,int y, int w, int h) {
    super(x,y,w,h);
    displayControl = new DisplayControl(posx,posy+Height,Width);
    displayControl.setTimeColor(timeColor);
    displayControl.setShuntColor(shuntColor);
    displayControl.setMotorColor(motorColor);
    displayControl.setTachyColor(tachyColor);
    displayControl.setPowerColor(powerColor);
    displayControl.setOmegaColor(omegaColor);
    displayScreen = new DisplayScreen(posx,posy,Width,Height-displayControl.getHeight());
    displayScreen.setTimeColor(timeColor);
    displayScreen.setShuntColor(shuntColor);
    displayScreen.setMotorColor(motorColor);
    displayScreen.setTachyColor(tachyColor);
    displayScreen.setPowerColor(powerColor);
    displayScreen.setOmegaColor(omegaColor);
    displayScreen.setShuntActive(displayControl.getShuntState());
    displayScreen.setMotorActive(displayControl.getMotorState());
    displayScreen.setTachyActive(displayControl.getTachyState());
    displayScreen.setPowerActive(displayControl.getPowerState());
    displayScreen.setOmegaActive(displayControl.getOmegaState());
  }
  
  void draw() {
    displayControl.draw();
    displayScreen.draw();
  }
  
  void buttonPressed(int x,int y) {
    displayScreen.buttonReleased(x,y); // In case of clicking on the cursor. 
    if (displayControl.buttonReleased(x,y)) { // In case of clicking on a curve displaying button.
      updateScreenDisplay(); // Update the graph according to the curves to be displayed.
      displayScreen.draw();
    }
  }
  
  void buttonDragged(int x,int y) { // Used in case of moving the cursor.
    displayScreen.buttonDragged(x,y); // Moving the cursor eventually.
    updateControlDisplay(); // Update the displayed values according to the cursor position.
    displayControl.draw(); // Refreshing the displayed values.
    displayScreen.draw(); // Refreshing the plots.
  }
  
  void switchColors() {
    displayScreen.switchColors();
    displayControl.switchColors();
    displayControl.setTextColor(textColor);
  }
  
  void overButton(int x, int y) {
  }
  
  int getNValues() {
    return displayScreen.getNValues();
  }
  
  float getTime(int i) {
    return displayScreen.getTime(i);
  }
  
  float getUShunt(int i) {
    return displayScreen.getUShunt(i);
  }
  
  float getVMotor(int i) {
    return displayScreen.getVMotor(i);
  }
  
  float getVTachy(int i) {
    return displayScreen.getVTachy(i);
  }
  
  float getOmega(int i) {
    return displayScreen.getOmega(i);
  }
  
  float getRShunt() {
    return displayScreen.getRShunt();
  }

  float getShuntAmpFactor() {
    return displayScreen.getShuntAmpFactor();
  }
    
  void setRShunt(float rs) {
    displayScreen.setRShunt(rs);
  }
  
  void setShuntAmpFactor(float saf) {
    displayScreen.setShuntAmpFactor(saf);
  }
  
  void setAppBkgColor(color abc) {
    displayScreen.setAppBkgColor(abc);
    displayControl.setAppBkgColor(abc);
  }

  void resetData(int n) { // Reset all data (called before a new data taking or reading a data file).
    displayScreen.resetData(n);
  }
  
  void addData(float t, float s, float m, float v) { // Adding a new measurement (used during online data taking).
    displayScreen.addData(t,s,m,v);
  }
  
  void addData(int index, float t, float s, float m, float v) { // Adding a new measurement (used during offline data retrieving).
    displayScreen.addData(index,t,s,m,v);
  }
  
  void updateDataDisplay() { // Processing raw data in order to be plotted.
    displayScreen.updateDataDisplay();
    updateControlDisplay();
  }

  void updateScreenDisplay() { // Set the flags to know which curves have to be plotted.
    displayScreen.setShuntActive(displayControl.getShuntState());
    displayScreen.setMotorActive(displayControl.getMotorState());
    displayScreen.setTachyActive(displayControl.getTachyState());
    displayScreen.setPowerActive(displayControl.getPowerState());
    displayScreen.setOmegaActive(displayControl.getOmegaState());
  }
  
  void updateControlDisplay() { // Update the values to be displayed at time corresponding to the cursor position.
    displayScreen.updateIndexCursor();
    if (displayScreen.getNValues()>0) {
      displayControl.setTime(displayScreen.getTime());
      displayControl.setUShunt(displayScreen.getUShunt());
      displayControl.setVMotor(displayScreen.getVMotor());
      displayControl.setVTachy(displayScreen.getVTachy());
      displayControl.setPower(displayScreen.getPower());
      displayControl.setOmega(displayScreen.getOmega());
    }
  }

}
