/**************************************************************************************/
/*    G. Batigne
/*      19/10/2018
/**************************************************************************************/

class DisplayControl extends GUIObject {
  
  // Indices for the different objects to be controlled and displayed.
  int kShunt = 0;
  int kMotor = 1;
  int kTachy = 2;
  int kPower = 3;
  int kOmega = 4;
  int nQuant = 5;
  // Objects used to display the values corresponding to the positioin of the cursor.
  valueDisplay timeValue;
  valueDisplay[] quantValue = new valueDisplay[nQuant];
  
  int backBandHeight = 0;
  
  color timeColor = color(0);
  color[] quantColor = new color[nQuant];
  color disableColor = color(180);
  color appBkgColor = color(0);
  
  // Buttons used to validate or not the display of these quantities.
  Button[] quantButton = new Button[nQuant];
 
  DisplayControl(int x,int y, int w) {
    super(x,y,w); // Be careful, (posx,posy) corresponds to the bottom left corner and not the top left one.
    setHeight(90); // Default height of the control panel.
    quantColor[kShunt] = color(255,0,0);
    quantColor[kMotor] = color(0,255,0);
    quantColor[kPower] = color(0,0,255);
    quantColor[kTachy] = color(0,255,255);
    quantColor[kOmega] = color(0,255,255);
 
    insertValues();
    backBandHeight = posy-quantButton[kShunt].getPosY()+2;
  }
  
  void draw() {
    noStroke();
    fill(appBkgColor);
    rect(posx,posy-backBandHeight,Width,backBandHeight);
    timeValue.draw();
    for (int iq=0; iq<nQuant; iq++) quantValue[iq].draw();
    drawButtons();
    drawLabels();
  }

  void setTimeColor(color c) {
    timeColor = c;
  }
  
  void setShuntColor(color c) {
    quantColor[kShunt] = c;
    quantButton[kShunt].setFillColor(quantColor[kShunt]);
    quantValue[kShunt].setTextColor(quantColor[kShunt]);
  }

  void setMotorColor(color c) {
    quantColor[kMotor] = c;
    quantButton[kMotor].setFillColor(quantColor[kMotor]);
    quantValue[kMotor].setTextColor(quantColor[kMotor]);
  }

  void setTachyColor(color c) {
    quantColor[kTachy] = c;
    quantButton[kTachy].setFillColor(quantColor[kTachy]);
    quantValue[kTachy].setTextColor(quantColor[kTachy]);
  }
  
  void setPowerColor(color c) {
    quantColor[kPower] = c;
    quantButton[kPower].setFillColor(quantColor[kPower]);
    quantValue[kPower].setTextColor(quantColor[kPower]);
  }
  
  void setOmegaColor(color c) {
    quantColor[kOmega] = c;
    quantButton[kOmega].setFillColor(quantColor[kOmega]);
    quantValue[kOmega].setTextColor(quantColor[kOmega]);
  }
  
  // Updating and formatting values.
  void setTime(float t) { 
    timeValue.updateValue(nfc(t,3)+" s");
  }
  
  void setUShunt(float t) {
    quantValue[kShunt].updateValue(nfc(t,3)+" V");
  }
  
  void setVMotor(float t) {
    quantValue[kMotor].updateValue(nfc(t,3)+" V");
  }
  
  void setVTachy(float t) {
    quantValue[kTachy].updateValue(nfc(t,3)+" V");
  }
  
  void setPower(float t) {
    quantValue[kPower].updateValue(nfc(t,2)+" W");
  }
  
  void setOmega(float o) {
    quantValue[kOmega].updateValue(nfc(o,2)+" rad/s");
  }
  
  void setAppBkgColor(color abc) {
    appBkgColor = abc;
  }
  
  boolean getShuntState() {
    return quantButton[kShunt].getState();
  }
  
  boolean getMotorState() {
    return quantButton[kMotor].getState();
  }
  
  boolean getTachyState() {
    return quantButton[kTachy].getState();
  }
  
  boolean getPowerState() {
    return quantButton[kPower].getState();
  }
  
  boolean getOmegaState() {
    return quantButton[kOmega].getState();
  }
  
  void switchColors() {
    quantButton[kShunt].switchStrokeColor();
    quantButton[kMotor].switchStrokeColor();
    quantButton[kTachy].switchStrokeColor();
    quantButton[kPower].switchStrokeColor();
    quantButton[kOmega].switchStrokeColor();
  }
  
  // Updating button states and display color when a state button is pressed.
  // When a state button is ON, colours of the button and display are the quantity colour.
  // When a state button is OFF, colours of the button and display are grey.
  boolean buttonReleased(int x,int y) {
    for (int iq=0; iq<nQuant; iq++) {
      if (quantButton[iq].buttonPressed(x,y)) {
        quantButton[iq].switchState();
        quantButton[iq].draw();
        if (quantButton[iq].getState()) quantValue[iq].setTextColor(quantColor[iq]);
        else quantValue[iq].setTextColor(disableColor);
        quantValue[iq].draw();
        return true;
      }
    }
    return false;
  }

  void insertValues() { // Insertion of the value displays.
    int valueHeight = 36;
    int valuePosY = posy-15-valueHeight;
    int valueWidth = 90;
    int valueOmegaWidth = valueWidth + 40;
    int valueSpacing = 15;
    int timePosX = posx+10;
    timeValue = new valueDisplay(timePosX,valuePosY,valueWidth,valueHeight,nfc(0,3)+" s");
    timeValue.setTextColor(timeColor);
    
    int shuntPosX = timeValue.getPosX() + valueWidth + valueSpacing;
    quantValue[kShunt] = new valueDisplay(shuntPosX,valuePosY,valueWidth,valueHeight,nfc(0,3)+" V");
    
    int motorPosX = quantValue[kShunt].getPosX() + valueWidth + valueSpacing;
    quantValue[kMotor] = new valueDisplay(motorPosX,valuePosY,valueWidth,valueHeight,nfc(0,3)+" V");
    
    int powerPosX = quantValue[kMotor].getPosX() + valueWidth + valueSpacing;
    quantValue[kPower] = new valueDisplay(powerPosX,valuePosY,valueWidth,valueHeight,nfc(0,3)+" W");
    
    int tachyPosX = quantValue[kPower].getPosX() + valueWidth + valueSpacing;
    quantValue[kTachy] = new valueDisplay(tachyPosX,valuePosY,valueWidth,valueHeight,nfc(0,3)+" V");
    
    int omegaPosX = quantValue[kTachy].getPosX() + valueWidth + valueSpacing;
    quantValue[kOmega] = new valueDisplay(omegaPosX,valuePosY,valueOmegaWidth,valueHeight,nfc(0,3)+" rad/s");
    
    for (int iq=0; iq<nQuant; iq++) quantValue[iq].setTextColor(quantColor[iq]);
    
    insertButtons();
  }

  void insertButtons() { // Insertion of the state buttons.
    int yShift = 20;
    int posButtonY = quantValue[kShunt].getPosY() - yShift;
    int buttonSize = 10;
    for (int iq=0; iq<nQuant; iq++) {
      quantButton[iq] = new Button(quantValue[iq].getPosX(),posButtonY,buttonSize,buttonSize,"");
      quantButton[iq].setFillColor(quantColor[iq]);
    }
  }

  void drawButtons() {
    for (int iq=0; iq<nQuant; iq++) quantButton[iq].draw();
  }

  void drawLabels() {
    int xShift = quantButton[kShunt].getWidth() + 5;
    int ypos = quantButton[kShunt].getPosY() + quantButton[kShunt].getHeight();
    fill(textColor);
    text("Time",timeValue.getPosX()+xShift,ypos);
    text("Shunt",quantButton[kShunt].getPosX()+xShift,ypos);
    text("Motor",quantButton[kMotor].getPosX()+xShift,ypos);
    text("Power",quantButton[kPower].getPosX()+xShift,ypos);
    text("Tachymeter",quantButton[kTachy].getPosX()+xShift,ypos);
    text("Omega",quantButton[kOmega].getPosX()+xShift,ypos);
  }
}
