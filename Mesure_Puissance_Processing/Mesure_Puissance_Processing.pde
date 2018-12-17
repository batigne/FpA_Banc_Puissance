/**************************************************************************************/
/*  GUI for the power measurement to be used with an Arduino board connected on the USB port.
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/
import processing.serial.*;

Serial myPort = null; // USB port connected to the Arduino board and from which data are get.
boolean portValid = false; // Flag used to know if the communication with the Arduino is established.
QuitButton quitButton; // Button used to quit the application.
SwitchButton startButton; // Button used to start and stop the acquisition.
Button readDataButton; // Button used to get data from a file.
Button storeDataButton; // Button used to store data into a file.
Button pictureButton; // Button used to take a screenshot of the plot.
WebLinkImage ImageMoodleLink; // Button used to open the Moodle page of the project (left click) or switch the display colours (right click).
itemSelector arduinoPorts; // Button used to select the port on which the Arduino is plugged. Information stored in the configuration file.
itemSelector arduinoSpeed; // Button used to select the data speed of the communication with the Arduino. Information stored in the configuration file.
DisplayData displayData; // Object used to display and control data.
String dataDirectory = "/data/"; // Relative path where the data are stored by default.
String pictureDirectory = "/pictures/"; // Relative path where the pictures are stored by default.
String configFileName = "config.dat"; // Name of the configuration file.
String portConfigID = "Arduino Port: ";
String speedConfigID = "Arduino Speed: ";
String configSeparator = "*******************************************************";
String RShuntID = "Shunt resistance (in Ohm): ";
String RShuntCSV = "R_Shunt";
float RShuntDefault = 0.1; // Value of the shunt resistance read from the configuration file. 
String ShuntAmpFactorID = "Amplification Factor for current measurement: ";
String ShuntAmpFactorCSV = "AmpFactor";
float AmpFactorDefault = 80.; // Value of the Shunt Amplification Factor read from the configuration file.
String dataHeader = "Time;U_shunt;V_motor;V_tachy;Omega"; // Header of the csv file where data are stored.
int dataHeaderSize = 3; // Number of header lines in the csv file.
boolean newDataReady = false; // Boolean used to force the data display refresh.
String portName = null; // Name of the port on which the Arduino is plugged.
String portSpeed = null; // Communication speed with the Arduino (in bauds). This value must be consistent with the one used in the Arduino code. 
int countLimit = 10; // Maximum number of tries for testing communication with the Arduino board.
String[] bufferLines; // Buffer containing data from Arduino.
boolean dataReceived = false; // Flag used to know if some data have been received from the Arduino.
boolean dataDecoded = true; // Flag used to know if the data have been decoded. In that case, new data can be received.
boolean acq = false; // Boolean indicating if acquisition is running or not.
boolean displayLight = false; // Boolean used to switch display.
float calibFactor = 5./1023.; // 5V on 1024 channels. Data are sent in ADC channel and not in V. 
String selectPort = "Select Port";
String[] speedList = { "300", "9600", "19200", "38400", "57600", "115200" }; // Different value of 
  // the communication speed (in bauds). It is just a sample; other values can be set.

// Definition of variables used for the change of appearance of the GUI (Light/Dark versions).
color defaultColor = color(209); // Light grey.
color blackColor = color(0);
color whiteColor = color(255);
color backgroundLight = defaultColor;
color backgroundDark = color(20,41,60); // Processing dark blue.
color backgroundColor = backgroundLight;
color textLight = defaultColor;
color textDark = blackColor;
color textColor = textDark;
PImage logoLight; // Light version of the logo, used in dark display mode.
PImage logoDark; // Dark version of the logo, used in light display mode.

void setup() {
  size(695,700); // Size of the window (width, height).
  background(backgroundLight); // Set background colour to light display mode.
  logoLight = loadImage("IMT_Atlantique_logo_Metal_Light.png"); 
  logoDark = loadImage("IMT_Atlantique_logo_Metal.png");
  windowLayout(); // Draw the different elements of the GUI.
  dataDirectory = sketchPath() + dataDirectory; // Absolute path where the data are stored by default.
  pictureDirectory = sketchPath() + pictureDirectory; // Absolute path where the pictures are stored by default.
  readConfigFile(); // Read the configuration file. To be called after creating all objects.
  updateArduinoPort(); // Update the Arduino port and check if it is valid.
  switchLayout(); // I prefer the dark display mode. So, I force the display mode. ^_^
}

void draw() {
  if (dataReceived) { // If some data have been received, they have to be decoded and registered. 
    decodeEvent(); // Decoding and registration of data.
    dataReceived = false; // Reinitialisation of the flag.
    dataDecoded = true; // Data have been decoded. Therefore, new data can be received.
  }
  quitButton.overButton(mouseX,mouseY); // Check if the mouse is passing over the item (change the aspect accordingly).
  startButton.overButton(mouseX,mouseY);
  arduinoPorts.overButton(mouseX,mouseY);
  arduinoSpeed.overButton(mouseX,mouseY);
  readDataButton.overButton(mouseX,mouseY);
  storeDataButton.overButton(mouseX,mouseY);
  pictureButton.overButton(mouseX,mouseY);
  if (newDataReady) {
    displayData.draw();
    newDataReady = false; // Display has to be updated only once after having received new data.
  }
  if (arduinoPorts.isExpanded()) arduinoPorts.draw(); // Redraw only if the port list is displayed
        // Otherwise other graphical objects stand over the list and prevent to read it.
  if (arduinoSpeed.isExpanded()) arduinoSpeed.draw();
}

void decodeEvent() { // Method to decode the data received from the Arduino.
  dataDecoded = false; 
  float time = 0.;
  float shunt = 0.;
  float motor = 0.;
  float tachy = 0.;
  int separator = 0;
  int startData = 0;
  // Data are stored in a vector of strings.
  for (int i=0; i<(bufferLines.length-1); ++i) {
    separator = bufferLines[i].indexOf(" "); // Within one event, data are separated by a space character.
    if (separator > -1) { // If separator has been found, decode the line.
      time = float(bufferLines[i].substring(startData,separator))/1000000.; // Time is tansmitted in microseconds.
      startData = separator+1;
      separator = bufferLines[i].indexOf(" ",startData);
      // Voltages are transmitted in DAC values. "calibFactor" variable allows the conversion into V.
      shunt = float(int(trim(bufferLines[i].substring(startData,separator))))*calibFactor;
      startData = separator+1;
      separator = bufferLines[i].indexOf(" ",startData);
      motor = float(int(trim(bufferLines[i].substring(startData,separator))))*calibFactor;
      startData = separator+1;
      tachy = float(int(trim(bufferLines[i].substring(startData))))*calibFactor;
      displayData.addData(time,shunt,motor,tachy); // Transmission of the new data to the data manager.
    }
  }
}

void serialEvent(Serial myPort) { // Method called each time data are received from the port.
  if (acq && portValid && dataDecoded) { // Trying to get data only when acquisition is running, the port is valid and data have been decoded.
    String data = myPort.readStringUntil('\n'); // Get data from the port (Arduino).
    if (data != null) { // If nothing has been received, do nothing.
      if (trim(data).indexOf("Q")>=0) {
        acq = false;
        startButton.setState(acq);
        displayData.updateDataDisplay(); // Acquisition is finished. Raw data can be processed before being displayed.
        newDataReady = true; // New data to be displayed.
        println("Stop");
      }
      else {
        bufferLines = split(data,";"); // Get lines from Arduino. Each line corresponds to one measurement.
        dataReceived = true;
        myPort.clear(); // Clear the port in order to avoid keeping crap.
      }
    }
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    displayData.buttonDragged(mouseX,mouseY); // Managing the cursor. 
  }
}

void mouseReleased() { // Function used to validate a click on an item. 
// If a mouse button is pressed continuously, the function mousePressed() is called continuously, 
// which can be annoying if a switch button is used. To avoid this issue, the click is validated 
// only when the button is released. Moreover, taps on trackpad can be used which is not the case 
// for the mousePressed() function.
  if (mouseButton == LEFT) {
    quitButton.buttonPressed(mouseX,mouseY); // quit the application.
    ImageMoodleLink.buttonPressed(mouseX,mouseY); // open the linked web page.
    displayData.buttonPressed(mouseX,mouseY);
    if (readDataButton.buttonPressed(mouseX,mouseY)) { // If the "Read Data" button is pressed, the file selection window is opened.
      selectInput("Select data file","readData",dataFile(dataDirectory+".")); // File selection in the default data selection directory.
    }
    if (storeDataButton.buttonPressed(mouseX,mouseY)) { // If the "Save Data" button is pressed, the file selection window is opened.
      selectOutput("Select file to store data","storeData",dataFile(dataDirectory+"FpA_Mesure_"+getTimeString()+".csv")); // File selection in the default data selection directory.
      // By default the name of the file starts by FpA_Mesure_ followed by the date and time when the data are saved.
    }
    if (pictureButton.buttonPressed(mouseX,mouseY)) { // If the "Save Graph" button is pressed, the file selection window is opened.
      selectOutput("Select file to save the graph","savePicture",dataFile(pictureDirectory+"FpA_Graph_"+getTimeString()+".png")); // File selection in the default picture selection directory.
      // By default the name of the file starts by FpA_Graph_ followed by the date and time when the data are saved.
    }
    boolean portRedraw = arduinoPorts.buttonPressed(mouseX,mouseY); // When cliking on a selection item object, the list of items is either expanded or not. Redrawing the window is necessary then.
    boolean speedRedraw = arduinoSpeed.buttonPressed(mouseX,mouseY);
    if (arduinoPorts.isNewSelection() || arduinoSpeed.isNewSelection()) {
      updateArduinoPort(); // The settings of the port could be updated.
    }
    if (portRedraw || speedRedraw) redraw(); // Need to redraw the window when necessary.
    if (startButton.buttonPressed(mouseX,mouseY)) { // Start/Stop the acquisition
      acq = !acq; //switching acquisition state; same button is used to start and stop acquisition.
      if (portValid) { // Do something only if the port is valid.
        myPort.clear(); // Cleaning port because it might contain rubbish.
        if (acq) { // If one want to start acquisition.
          myPort.write("S"); // Sending "S" to the Arduino board in order to trigger the start of sending data.
          println("Start");
          displayData.setRShunt(RShuntDefault); // Reinitialisation of the shunt resistance and amplification values to the default ones,
          displayData.setShuntAmpFactor(AmpFactorDefault); // in case of having read previously a data set with different such values. 
          displayData.resetData(0); // As a new acquisition is starting, one need to reset all data stored in the data manager.
        } else { // Otherwise, one want to stop acquisition.
          myPort.write("E"); // Sending "E" to the Arduino board in order to stop data sending.
          displayData.updateDataDisplay(); // Acquisition is finished. Raw data can be processed before being displayed.
          newDataReady = true; // New data to be displayed.
          println("Stop");
        }
      }
    }
  }
  if (mouseButton == RIGHT) {
    if (ImageMoodleLink.isMouseOver(mouseX,mouseY)) { // The switch of appearance is triggered 
        // by a right click on the logo.
      switchLayout();
    }
  }
}

void redraw() { // Refresh completely the display. Mainly because of the selection list(s).
  background(backgroundColor);
  ImageMoodleLink.draw();
  quitButton.draw();
  startButton.draw();
  arduinoPorts.draw();
  arduinoSpeed.draw();
  readDataButton.draw();
  storeDataButton.draw();
  pictureButton.draw();
  displayData.draw();
  drawLabels();
}

void switchLayout() { // Switch of the GUI appearance (Light/Dark).
  displayLight = !displayLight;
  if (displayLight) { // change of settings.
    backgroundColor = backgroundDark;
    ImageMoodleLink.setImage(logoLight);
    textColor = textLight;
  } else {
    backgroundColor = backgroundLight;
    ImageMoodleLink.setImage(logoDark);
    textColor = textDark;
  }
  quitButton.switchImages();
  startButton.switchImages();
  arduinoPorts.switchColors();
  arduinoSpeed.switchColors();
  readDataButton.switchColors();
  storeDataButton.switchColors();
  pictureButton.switchColors();
  displayData.setTextColor(textColor);
  displayData.switchColors();
  displayData.setAppBkgColor(backgroundColor);
  redraw();
}

void windowLayout() { // Display the GUI items at start-up.
  insertStartStopButton();
  insertQuitButton();
  insertLogo();
  insertDataButtons();
  insertDisplay(); 
  insertPortSettings();
  drawLabels();
}

void drawLabels() { // Display of all labels on the GUI
  fill(textColor);
  textSize(12);
  text("Acquisition",startButton.getPosX()+7,startButton.getPosY()-5);
  text("Arduino Port:",arduinoPorts.getPosX(),arduinoPorts.getPosY()-5);
  text("Port Speed:",arduinoSpeed.getPosX(),arduinoSpeed.getPosY()-5);
}

void insertStartStopButton() { // Define the Start/Stop acquisition button.
  PImage StartLight = loadImage("SwitchOnLight.png");
  PImage StartDark = loadImage("SwitchOnDark.png");
  PImage StopLight = loadImage("SwitchOffLight.png");
  PImage StopDark = loadImage("SwitchOffDark.png");
  int buttonWidth = 80;
  int buttonHeight = buttonWidth/2;
  int buttonPosx = width - buttonWidth - 5;
  int buttonPosy = height - buttonHeight - 5;
  startButton = new SwitchButton(buttonPosx,buttonPosy,buttonWidth,buttonHeight,
    StartLight,StopLight,StartDark,StopDark);
  startButton.draw();
  
}

void insertQuitButton() { // Define the exit button.
  PImage ExitOn = loadImage("ExitLight.png");
  PImage ExitOff = loadImage("ExitDark.png");
  int ButtonSize = 40;
  int ButtonPosx = 5;
  int ButtonPosy = height - 5 - ButtonSize;
  quitButton = new QuitButton(ButtonPosx,ButtonPosy,ButtonSize,ButtonSize,ExitOn,ExitOff);
  quitButton.draw();
}

void insertLogo() {
  PImage logo = logoDark;
  String Link = "https://moodle.imt-atlantique.fr/course/view.php?id=11&section=14";
  float logo_ratio = 2.5;
  int logo_shiftx = -10;
  int logo_shifty = -10;
  int logo_posx = width - int(logo.width/logo_ratio) - logo_shiftx;
  int logo_posy = logo_shifty;
  ImageMoodleLink = new WebLinkImage(logo_posx,logo_posy,int(logo.width/logo_ratio),int(logo.height/logo_ratio),logo,Link);
  ImageMoodleLink.draw();
}

void insertPortSettings() {  // Create the selector to choose the port and speed used to communicate with the 
                              // Arduino board. To be called after reading the configuration file.
  int selectorPosX = 20;
  int selectorPosY = 20;
  int selectorWidth = 220;
  int selectorHeight = 20;
  // Serial variable contains the list of possible ports on the computer.
  arduinoPorts = new itemSelector(selectorPosX,selectorPosY,selectorWidth,selectorHeight,Serial.list());

  selectorPosX = selectorPosX + selectorWidth + 20;
  selectorWidth = 100;
  arduinoSpeed = new itemSelector(selectorPosX,selectorPosY,selectorWidth,selectorHeight,speedList);
  
  if (portName != null) { 
    if (portName.indexOf(selectPort)==-1 || portName.indexOf("null")==-1) {
      arduinoPorts.setText(portName); // Set the actual port name (from the configuration file or selected one).
    }
  }
  if (portSpeed != null) arduinoSpeed.setText(portSpeed); // Set the port speed (from the configuration file or selected one).
  
  arduinoPorts.draw();
  arduinoSpeed.draw();
}

void insertDataButtons() { // Define the buttons used to store/read data or to save pictures.
  int buttonHeight = 40;
  int buttonWidth = 120;
  int readPosX = width/2 - buttonWidth - buttonWidth/2 - 30;
  int readPosY = height - 5 - buttonHeight;
  int fontSize = 20;
  readDataButton = new Button(readPosX,readPosY,buttonWidth,buttonHeight,"Read Data",fontSize);
  readDataButton.setTextPosition(11,12);
  int storePosX = readDataButton.getPosX() + readDataButton.getWidth() + 10;
  int storePosY = readDataButton.getPosY();
  storeDataButton = new Button(storePosX,storePosY,buttonWidth,buttonHeight,"Save Data",fontSize);
  storeDataButton.setTextPosition(14,12);
  int picturePosX = storeDataButton.getPosX() + readDataButton.getWidth() + 10;
  int picturePosY = readDataButton.getPosY();
  pictureButton = new Button(picturePosX,picturePosY,buttonWidth,buttonHeight,"Save Graph",fontSize);
  pictureButton.setTextPosition(7,12);
  
  readDataButton.draw();
  storeDataButton.draw();
  pictureButton.draw();
}

void insertDisplay() { // Insert the different objects to visualise, store and process data. 
  int displayPosX = 10;
  int displayPosY = 60;
  int display_Width = width - 2*displayPosX;
  int display_Height = height-120;
  displayData = new DisplayData(displayPosX,displayPosY,display_Width,display_Height);
  displayData.setAppBkgColor(backgroundColor);
  displayData.draw();
}

void updateArduinoPort() { // Checking the validity of the port.
  if (portName != null || portName != arduinoPorts.getText()) { // If a new port is selected. 
    portName = arduinoPorts.getText();
    writeConfigFile(); // Store the arduino port name in the configuration file.
  }
  if (portSpeed != arduinoSpeed.getText()) { // Same thing but with the speed.
    portSpeed = arduinoSpeed.getText();
    writeConfigFile();
  }
  if (portName != null) {
    if (portName.indexOf(selectPort)<0 && portName.indexOf("null")<0 && portSpeed != null) { // Only if the port name corresponds to an actual port.
      portValid = false; // Before testing the port, it is assumed as invalid.
      int count = 0; // Counter of connection tries.
      try { // Try to connect to the selected port. 
        myPort = new Serial(this, portName, int(portSpeed)); // Setting the USB communication. The last number is the 
        // communication speed in bauds. This number must be the same as used by the Arduino.
        String val = "";
        while(count<countLimit && !portValid) {
          val = myPort.readStringUntil('\n');
          if (val != null) {
            if (trim(val).indexOf("W")>=0) { // trim function remove the carriage return character ("\n").
              myPort.write("R");
              portValid = true; // Communication established if "W" character is received.
            }
          }
          count++;
          delay(1000);
        }
      } catch (Exception e) {
      println(e);
      }
      println("port status: "+portValid + " after " + count + "/" + countLimit + " tries");
      if (count == countLimit) { // If the port is not valid, do not store the wrong port into the configuration file.
                                 // This will prevent a long start-up at the next launch. 
        portName = selectPort;   // The port name is set back to the default value, which is not a port name BTW. 
        arduinoPorts.setText(portName);
        writeConfigFile();
      }
    }
  }
}

void readData(File data) { // Read raw data from a file.
  newDataReady = false;
  if (data!=null) {
    println("Read Data: " + data.getName());
    String[] dataLines = loadStrings(data); // In the file, one line corresponds to one measurement.
    if (dataLines != null) { // If data are not empty.
      for (int i=0; i<dataHeaderSize; i++) {
        dataLines[i] = dataLines[i].replace(",","."); // This line is necessary if you are using French number format (with comma instead of dot).
        String[] HeaderLineData = split(dataLines[i],";");
        if (HeaderLineData[0].indexOf(RShuntCSV)>-1) displayData.setRShunt(float(HeaderLineData[1]));
        if (HeaderLineData[0].indexOf(ShuntAmpFactorCSV)>-1) displayData.setShuntAmpFactor(float(HeaderLineData[1]));
      }
      displayData.resetData(dataLines.length-dataHeaderSize); // Reset data in the data manager. As first line is the header, 
                                                              // the number of measurements corresponds to the number of lines 
                                                              // in the file minus the header lines (3 here). 
      for (int i=dataHeaderSize; i < dataLines.length; i++) { // Starting from line 1 and not 0 because of the header.
        dataLines[i] = dataLines[i].replace(",","."); // This line is necessary if you are using French number format (with comma instead of dot).
        float[] dataValues = float(split(dataLines[i],";"));
        // data are, by order, time, shunt, motor and tachymeter.
        displayData.addData(i-dataHeaderSize,dataValues[0],dataValues[1],dataValues[2],dataValues[3]);
      }
    displayData.updateDataDisplay(); // Processing raw data in order to be displayed. 
    newDataReady = true; // New data to be displayed.
    }
  }
}

void storeData(File data) { // Store raw data into a .csv file.
  if (data!=null) { // If data are not empty only.
    println("Store Data: " + data.getAbsolutePath());
    PrintWriter dataFile = createWriter(data.getAbsolutePath()); // Creating file.
    // Adding the Header.
    String tempString = new String(RShuntCSV + ";" + displayData.getRShunt() + ";;");
    dataFile.println(tempString.replace(".",",")); // This line is necessary if you are using French number format (with comma instead of dot).
    tempString = new String(ShuntAmpFactorCSV + ";" + displayData.getShuntAmpFactor() + ";;");
    dataFile.println(tempString.replace(".",",")); // This line is necessary if you are using French number format (with comma instead of dot).
    dataFile.println(dataHeader);
    // Writing data.
    String line;
    for (int i=0; i<displayData.getNValues();i++) {
      line = str(displayData.getTime(i))+";"+str(displayData.getUShunt(i))+";"+str(displayData.getVMotor(i))+";"+str(displayData.getVTachy(i))+";"+str(displayData.getOmega(i));
      line = line.replace(".",","); // This line is necessary if you are using French number format (with coma instead of dot)
      dataFile.println(line); // Insertion of a measurement. One per line.
    }
    dataFile.flush(); // Actually writing into the file.
    dataFile.close(); // Closing the file.
  }
}

void savePicture(File picture) { // Dumping the data manager objects into a file.
  if (picture!=null) {
    PImage shot = get(displayData.getPosX(),displayData.getPosY(),displayData.getWidth(),displayData.getHeight());
    shot.save(picture.getAbsolutePath());
  }
}

String getTimeString() { // Formating the date and time. Used to define the file names.
  return year()+"_"+nf(month(),2)+"_"+nf(day(),2)+"_"+nf(hour(),2)+nf(minute(),2)+nf(second(),2);
}

void writeConfigFile() { // Writing configuration settings into a file.
  PrintWriter configFile = createWriter(configFileName);
  configFile.println(configSeparator);
  configFile.println(portConfigID + portName); // Write the port name used to communicate with Arduino.
  configFile.println(speedConfigID + portSpeed); // Write the port speed used to communicate with Arduino.
  configFile.println(configSeparator);
  configFile.println(RShuntID + RShuntDefault);
  configFile.println(ShuntAmpFactorID + AmpFactorDefault);
  configFile.println(configSeparator);
  configFile.flush();
  configFile.close();
}

void readConfigFile() { // Retrieving settings from the configuration file.
  String[] configLines = loadStrings(configFileName); // Array of lines from the file.
  int index = 0;
  if (configLines != null) { // If file is not empty only.
    for (int i = 0 ; i < configLines.length; i++) {
      // Read the port used to communicate with Arduino.
      index = configLines[i].indexOf(portConfigID);
      if (index>-1) { // If the line corresponds to the port name setting.
        portName = trim(configLines[i]).substring(index + portConfigID.length());
        // Check if the name of the port is part of the port list; mainly useful at the first launch
        // or when changing of OS.
        int j=0;
        while (j<Serial.list().length && Serial.list()[j].indexOf(portName)!=0) j++;
        if (j>=Serial.list().length) portName = null;
        if (portName==null) arduinoPorts.setText(selectPort);
        else arduinoPorts.setText(portName);
      }
      index = configLines[i].indexOf(speedConfigID);
      if (index>-1) { // If the line corresponds to the port speed setting.
        portSpeed = trim(configLines[i]).substring(index + speedConfigID.length());
        arduinoSpeed.setText(portSpeed);
      }
      index = configLines[i].indexOf(RShuntID);
      if (index>-1) { // If the line corresponds to the value of the shunt resistance.
        RShuntDefault = Float.valueOf(trim(configLines[i]).substring(index + RShuntID.length()));
        displayData.setRShunt(RShuntDefault);
      }
      index = configLines[i].indexOf(ShuntAmpFactorID);
      if (index>-1) { // If the line corresponds to the port speed setting.
        AmpFactorDefault = Float.valueOf(trim(configLines[i]).substring(index + ShuntAmpFactorID.length()));
        displayData.setShuntAmpFactor(AmpFactorDefault);
      }
    }
  }
}
