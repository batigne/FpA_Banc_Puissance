/**************************************************************************************/
/*    G. Batigne
/*      19/10/2018
/**************************************************************************************/

class DisplayScreen extends GUIObject {

  // Indices for the different quantities to be computed and displayed.
  int kShunt = 0;
  int kMotor = 1;
  int kTachy = 2;
  int kPower = 3;
  int kOmega = 4;
  int nGraph = 5;
  // Tables containing raw data:
  int NValues;
  float[] Time;
  float[][] Quantity;
  // Tables containing the pixel position of values.
  // Tables used to display data.
  float[] TimeDisplay;
  float[][] QuantityDisplay;
  // Tables containing the values (potentially averaged) of quantities at a given position of the cursor on screen.
  float[] TimePixel;
  float[][] QuantityPixel;

  int[] valuePerPixel; // Table used to know if an average should be performed. 
                       // True in case of the number of raw data is higher than the number of pixels
  float RShunt = 0.1; // Value of the shunt resistor
  float ShuntAmpFactor = 10.; // Value of the amplification factor used to measure U_Shunt
  
  float maxFractionDisplay = 0.95; // The scale is set as maximum value divided by this factor; the maximum is at that fraction of the scale.
  // Conversion factors from value to pixel.
  float timeToPixel;
  float[] quantityToPixel = new float[nGraph];

  int indexCursor; // Position of the cursor on screen (in pixel).

  // Colour definition:
  color timeColor = color(0);
  color[] quantityColor = new color[nGraph];

  boolean isDisplayed[] = new boolean[nGraph]; // Array used to know if a quantity must be displayed or not.

  // Definition of the colors of the screen and dashed lines.
  boolean lightDisplay = true;
  color bkgLight = color(0);
  color bkgDark = color(209);
  color bkgColor = bkgLight;
  color stkLight = bkgDark;
  color stkDark = bkgLight;
  color stkColor = stkLight;
  color dashedLinesLight = bkgDark;
  color dashedLinesDark = bkgLight;
  color dashedLinesColor = dashedLinesLight;
  color appBkgColor = color(0);
  
  int dashSpace = 3; // pitch of dashed lines.
  int nDashedLinesV = 5; // Number of horizontal dashed lines.
  int nDashedLinesT = 7; // Number of vertical dashed lines.
  int backBandHeight = 0; // Size of the band used to erase the old positions of the cursor.
  int backBandExtraWidth = 0;
  
  int NSector = 8; // Number of black/white sectors on the wheel.
  float sectorAngle = 2.*acos(-1)/float(NSector); // Angle corresponding to a sector.
  int medianDim = 5; // Size for the median filtering.
  int medianIndex = int((medianDim+1)/2)-1; // Middle of the filtered local area.
  float[] medianVector = new float[medianDim]; // Local data values to be filtered.
  
  Cursor TimeCursor; // Cursor used to get values at a given time.
  
  DisplayScreen(int x, int y, int w, int h) {
    super(x,y,w,h);
    TimeCursor = new Cursor(posx+Width/2,posy+Height,posx,posx+Width,Height,false);
    TimeCursor.setColor(color(127));
    backBandExtraWidth = TimeCursor.getSize()+1; // Definition of the size of the band used to erase the old positions of the cursor.
    backBandHeight = backBandExtraWidth/2+2;
    // At start-up, none of the curves are displayed, even if their control boxes are on, since there is no data yet.
    for (int i=0; i<nGraph; i++) isDisplayed[i] = false;
    quantityColor[kShunt] = color(255,0,0);
    quantityColor[kMotor] = color(0,255,0);
    quantityColor[kPower] = color(0,0,255);
    quantityColor[kTachy] = color(0,255,255);
    quantityColor[kOmega] = color(0,255,255);
    TimePixel = new float[Width];
    QuantityPixel = new float[nGraph][Width];
    valuePerPixel = new int[Width];
  }
  
  int getTimeReference() {
    return TimeCursor.getPosX(); 
  }
  
  float getRShunt() {
    return RShunt;
  }

  float getShuntAmpFactor() {
    return ShuntAmpFactor;
  }

  void setTimeColor(color c) {
    timeColor = c;
  }
  
  void setShuntColor(color c) {
    quantityColor[kShunt] = c;
  }

  void setMotorColor(color c) {
    quantityColor[kMotor] = c;
  }

  void setTachyColor(color c) {
    quantityColor[kTachy] = c;
  }

  void setOmegaColor(color c) {
    quantityColor[kOmega] = c;
  }
  
  void setPowerColor(color c) {
    quantityColor[kPower] = c;
  }
  
  void setShuntActive(boolean a) {
    isDisplayed[kShunt] = a;
  }
  
  void setMotorActive(boolean a) {
    isDisplayed[kMotor] = a;
  }
  
  void setTachyActive(boolean a) {
    isDisplayed[kTachy] = a;
  }
  
  void setPowerActive(boolean a) {
    isDisplayed[kPower] = a;
  }
  
  void setOmegaActive(boolean a) {
    isDisplayed[kOmega] = a;
  }
  
  void setRShunt(float rs) {
    RShunt = rs;
  }
  
  void setShuntAmpFactor(float saf) {
    ShuntAmpFactor = saf;
  }
  
  void setAppBkgColor(color abc) {
    appBkgColor = abc;
  }
  
  void draw() {
    noStroke();
    // First draw the band used to erase the old positions of the cursor. 
    fill(appBkgColor);
    rect(posx-backBandExtraWidth,posy+Height-backBandHeight,Width+2*backBandExtraWidth,2*backBandHeight);
    // Draw the background of the display.
    fill(bkgColor);
    stroke(stkColor);
    rect(posx,posy,Width,Height);
    drawDashedLines();
    displayValues();
    TimeCursor.draw();
  }
  
  void drawDashedLines() {
    stroke(dashedLinesColor);
    fill(dashedLinesColor);
    for (int i=0; i<nDashedLinesV; ++i) {
      dashLineH(posx,posy+int(float(i+1)/float(nDashedLinesV+1)*float(Height)),posx+Width);
    }
    for (int i=0; i<nDashedLinesT; ++i) {
      dashLineV(posx+int(float(i+1)/float(nDashedLinesT+1)*float(Width)),posy,posy+Height);
    }
  }
  
  void buttonReleased(int x, int y) {
    boolean cursorDragged = TimeCursor.isDragged(); // Check if the cursor was dragged before.
    TimeCursor.buttonReleased(); // As the mouse button is released, it cannot be dragged anymore. 
                                 // This function set the dragged boolean to false.
    if (cursorDragged || isMouseOver(x,y)) draw(); // If the cursor is dragged or if the mouse is
          // over the screen while clicking, the screen is redrawn. For the last case, 
          // clicking on the screen triggers a refresh.
  }
  
  void buttonDragged(int x,int y) { // This function allows to update the cursor when it is dragged.
    if (TimeCursor.buttonPressed(x,y)) { // The refresh of the display (screen and values) is managed
      updateIndexCursor();               // by the DisplayData object.
    }
  }
  
  float getTime() {
    return TimePixel[indexCursor];
  }
  
  float getUShunt() {
    return QuantityPixel[kShunt][indexCursor];
  }
  
  float getVMotor() {
    return QuantityPixel[kMotor][indexCursor];
  }
  
  float getVTachy() {
    return QuantityPixel[kTachy][indexCursor];
  }
  
  float getPower() {
    return QuantityPixel[kPower][indexCursor];
  }
  
  float getOmega() {
    return QuantityPixel[kOmega][indexCursor];
  }
    
  float getTime(int i) {
    return Time[i];
  }
  
  float getUShunt(int i) {
    return Quantity[kShunt][i];
  }
  
  float getVMotor(int i) {
    return Quantity[kMotor][i];
  }
  
  float getVTachy(int i) {
    return Quantity[kTachy][i];
  }
  
  float getPower(int i) {
    return Quantity[kPower][i];
  }
  
  float getOmega(int i) {
    return Quantity[kOmega][i];
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
  
  void switchColors() {
    lightDisplay = !lightDisplay;
    if (lightDisplay) {
      bkgColor = bkgLight;
      stkColor = stkLight;
      dashedLinesColor = dashedLinesLight;
    } else {
      bkgColor = bkgDark;
      stkColor = stkDark;
      dashedLinesColor = dashedLinesDark;    
    }
  }
  
  int getNValues() {
    return NValues;
  }
  
  float convertPower(float shunt, float motor) {
    return (motor-shunt) * shunt/RShunt; 
  }
    
  void computeOmega() {
    int startIndex = 0; // index at which the motor is powered on.
    int stopIndex = -1; // index at which the motor is switched off.
    while(Quantity[kMotor][startIndex] == 0 && startIndex<NValues-1) startIndex += 1; // Find out when the motor has been started.
    for (int i=startIndex; i<NValues-1; i++) { // Find out when the motor has stopped.
      if (Quantity[kMotor][i]>0) stopIndex = i+1;
    }
    float meanVTachy = 0.; // Mean value of the tachymeter signal. It corresponds to the change of sector.
    for (int i=startIndex; i<stopIndex; i++) meanVTachy += Quantity[kTachy][i];
    meanVTachy /= float(stopIndex-startIndex);
    
    // Determination on which sector the Tachymeter is looking at (when the motor is on).
    int[] upDown = new int[NValues];
    for (int i=0; i<NValues; i++){
      if (i<startIndex || i>stopIndex) upDown[i] = 0;
      if (Quantity[kTachy][i]>meanVTachy) {
        upDown[i] = 1; // White sector.
      } else {
        upDown[i] = -1; // Black sector.
      }
    }
    // Find when the tachymeter signal is crossing the mean value (change of sector).
    int[] crossingIndex = new int[1]; // List of indices used to compute the speed (mean value crossing + start and stop time of the motor).
    crossingIndex[0] = startIndex-1;
    for (int i=startIndex;i<stopIndex-1; i++) {
      if (upDown[i]*upDown[i+1]<0) { // Change of sector (WW = BB = 1; WB = BW = -1).
        crossingIndex = append(crossingIndex,i);
      }
    }
    crossingIndex = append(crossingIndex,stopIndex);
    int NCrossings = crossingIndex.length;
    if (startIndex==0) { // If there is not enough data, the speed is considered as 0 everywhere. Used mainly if there is no useful data on VTachy.
      for (int i=0; i<NValues; i++) Quantity[kOmega][i]=0.; 
    } else {
      float[] omegaIni = new float[NCrossings]; // List of speeds deduced from the change of sectors.
      float[] omegaMedian = new float[NCrossings]; // List of speeds after median filtering.
      omegaIni[0] = 0.; // The initial speed is necessarly 0 (motor not started yet).
      for (int i=1; i<NCrossings-1; i++) {
        omegaIni[i] = sectorAngle/(Time[crossingIndex[i]]-Time[crossingIndex[i-1]]);
      }
      omegaIni[NCrossings-1] = 0.; // The final speed is necessarly 0 (motor stopped).
    
      int medianIndexMax = NCrossings-(medianDim-1-medianIndex); // Last index to be filtered.
      for (int i=0; i<medianIndex; i++) omegaMedian[i] = omegaIni[i]; // The first elements of the speed list cannot be filtered.
      for (int i=medianIndex; i<medianIndexMax; i++) { // Median filtering procedure.
        for (int j=0; j<medianDim; j++) medianVector[j] = omegaIni[i-medianIndex+j];
        medianVector = sort(medianVector);
        omegaMedian[i] = medianVector[medianIndex];
      }
      for (int i=medianIndexMax; i<NCrossings; i++) omegaMedian[i] = omegaIni[i]; // The last elements of the speed list cannot be filtered neither.
    
      for (int i=0; i<startIndex; i++) Quantity[kOmega][i]=0.; // Initially, the motor is stopped.
      float deltaTime = 0.; // Time difference between crossing times. Used to compute the speed and the interpolation of speed.
      float deltaSpeed = 0.; // Variation of speed during the time difference.
      for (int i=0; i<NCrossings-1; i++) { // Interpolation between the different speed measurements (at mean crossing times)
        for (int j=crossingIndex[i]+1; j<crossingIndex[i+1]+1; j++) {
          deltaTime = Time[crossingIndex[i+1]]-Time[crossingIndex[i]];
          deltaSpeed = omegaMedian[i+1] - omegaMedian[i];
          Quantity[kOmega][j] = deltaSpeed*(Time[j]-Time[crossingIndex[i]])/deltaTime + omegaMedian[i];
        }
      }
      for (int i=stopIndex; i<NValues; i++) Quantity[kOmega][i]=0.; // At the end of the acquisition the motor is stopped.
    }
  }
  
  void resetData(int n) {
    NValues = n;
    Time = new float[NValues];
    Quantity = new float[nGraph][NValues];
    for (int iq=0; iq<nGraph; iq++)
      for (int i=0; i<Width; i++)
        QuantityPixel[iq][i] = 0;
  }
  
  void addData(float t, float s, float m, float v) { // Adding data to the already existing ones. The sizes of vectors are increased by one. 
    Time = append(Time,t);
    Quantity[kShunt] = append(Quantity[kShunt],s);
    Quantity[kMotor] = append(Quantity[kMotor],m);
    Quantity[kTachy] = append(Quantity[kTachy],v);
    Quantity[kPower] = append(Quantity[kPower],convertPower(s/ShuntAmpFactor,m));
    Quantity[kOmega] = append(Quantity[kOmega],0.);
  }
  
  void addData(int index, float t, float s, float m, float v) { // Updating data. The sizes of vectors are not changed.
    Time[index] = t;
    Quantity[kShunt][index] = s;
    Quantity[kMotor][index] = m;
    Quantity[kTachy][index] = v;
    Quantity[kPower][index] = convertPower(s/ShuntAmpFactor,m);
  }
  
  void updateIndexCursor() {
    indexCursor = TimeCursor.getPosX()-posx;
    if (indexCursor > Width-1) indexCursor = Width - 1;
  }
  
  void updateDataDisplay() {
    NValues = Time.length;
    computeOmega(); // Compute the speed values.
    // Initialisation of vectors used to display data.
    TimeDisplay = new float[NValues];
    QuantityDisplay = new float[nGraph][NValues];
    // Initialisation of the conversion factors.
    for (int i=0; i<nGraph; i++) quantityToPixel[i] = 0;
    timeToPixel = (Width-1)/Time[NValues-1];
    for (int i=0; i<Width; i++) {
      valuePerPixel[i] = 0;
      TimePixel[i] = float(i)/timeToPixel;
    }
    int iPixel = 0;
    for (int i=0; i<NValues; i++) {
      iPixel = int(Time[i]*timeToPixel);
      valuePerPixel[iPixel] += 1;
      for (int iq=0; iq<nGraph; iq++) QuantityPixel[iq][iPixel] += Quantity[iq][i];
      // Maximum value finder:
      for (int iq=0; iq<nGraph; iq++) 
        if (quantityToPixel[iq]<Quantity[iq][i]) quantityToPixel[iq] = Quantity[iq][i];
    }
    for (int i=0; i<Width; i++) {
      // Values are potentially averaged (for the value display at the position of the cursor):
      if (valuePerPixel[i]>0) {
        for (int iq=0; iq<nGraph; iq++) QuantityPixel[iq][i] /= float(valuePerPixel[i]);
      }
    }
    for (int i=1; i<Width; i++) {
      // If there are some cursor positions without data, the values are linearly interpolated.
      if (valuePerPixel[i] == 0) {
        int j = i+1;
        while(valuePerPixel[j] == 0 && j<Width) j++;
        for (int k=i; k<j; k++) {
          for (int iq=0; iq<nGraph; iq++) 
            QuantityPixel[iq][k] = (QuantityPixel[iq][j]-QuantityPixel[iq][i-1])*(k-i+1)/(j-i+1)+QuantityPixel[iq][i-1];
        }
        i = j;
      }
    }
    // Computing the conversion factor value->pixel.
    for (int i=0; i<nGraph; i++) 
      if (quantityToPixel[i] != 0.) quantityToPixel[i] = Height/quantityToPixel[i]*maxFractionDisplay;
    
    // Computing the pixel positions of data.
    float timeRef = posx;
    float valueRef = posy + Height;
    for (int i=0; i<NValues; i++) {
      TimeDisplay[i] = Time[i]*timeToPixel + timeRef;
      for (int iq=0; iq<nGraph; iq++) QuantityDisplay[iq][i] = valueRef - Quantity[iq][i]*quantityToPixel[iq];
    }
  }
  
  void drawQuantity(int k) {
    if (isDisplayed[k]) {
      stroke(quantityColor[k]);
      for (int i=0; i<NValues-1; i++) 
        line(TimeDisplay[i],QuantityDisplay[k][i],TimeDisplay[i+1],QuantityDisplay[k][i+1]);
    }
  }
  
  void displayValues() {
    drawQuantity(kTachy);
    drawQuantity(kMotor);
    drawQuantity(kShunt);
    drawQuantity(kPower);
    drawQuantity(kOmega);
  }
}
