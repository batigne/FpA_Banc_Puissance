/**************************************************************************************/
/*    G. Batigne
/*      23/10/2018
/**************************************************************************************/

// Pins connected to measurement points:
const int U_SHUNT = A0;
const int V_MOTOR = A3;
const int V_TACHY = A2;
// Pin used to enable/disable the phototransistor:
const int STARTSTOP = 2;

const int START_ASCII = 83; // ASCII code for the "S" character, sent by the computer to start acquisition.
const int STOP_ASCII = 69; // ASCII code for the "E" character, sent by the computer to stop acquisition.

int dataSize = 1; // Number of measurements performed before sending data to the computer.
int counter = 0; // Used to count the actual number of measurements.
long timeRef = 0; // Time when acquisition is started.
long timeStop = 0; // Time at which the motor is stopped.
long timeLaps = 1000000; // Time (in us) after which the PT is enabled or after which the data taking is stopped.
int val = 0; // ASCII chain received from computer.
String dataBunch = ""; // String used to store measurements.
boolean startDataTransmission = false; // Flag to start/stop acquisition.
boolean activationPT = false; // Flag to know if the phototransistor is enabled or not.
int VMotor = 0; // DAC value of the measurement of the voltage of the motor.
int VMotorThreshold = 10; // DAC value under which the motor is considered as stopped.

void setup() { // Set-up the Arduino board and initialisation 
  // put your setup code here, to run once:
  Serial.begin(115200); // Set data transmission speed. To be consistent with the processing software configuration.
  pinMode(LED_BUILTIN,OUTPUT); // The onboard LED is used as indicator of the initialisation of the communication
                               // with the computer and also of the status of the activation of
                               // the phototransistor (LED ON = PT enabled; LED OFF = PT disabled).
  pinMode(U_SHUNT,INPUT); // The measurement pins are obviously inputs.
  pinMode(V_MOTOR,INPUT);
  pinMode(V_TACHY,INPUT);
  pinMode(STARTSTOP,OUTPUT); // The enabling pin is an output connected to the PT.
                             // LOW State sets the output to 0V (PT is disable).
                             // HIGH State sets the output to 5V (PT is enable).
  establishContact(); // Checking the communication between the Arduino board and the computer.
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available()>0) { // If some data is received from the computer through USB link.
    val = Serial.read(); // val is set to the received message and coded in ASCII.
    if (val == START_ASCII) { // ASCII code for "S", value sent to start data taking.
      startDataTransmission = true; // Activation of the acquisition.
      counter = 0; // Initialisation to the measurement counter.
      timeRef = micros(); // Internal time at which the acquisition is started. 
                          // In the Arduino code, time is counted from the start of the program.
      timeStop = -1;
    }
    if (val == STOP_ASCII) { // ASCII code for "E", value sent to stop data taking.
      startDataTransmission = false; // Desactivation of the acquisition.
      digitalWrite(STARTSTOP,LOW); // PT disabled.
      digitalWrite(LED_BUILTIN,LOW); // Turn-off of the LED.
      activationPT = false; // desactivation of the 
    }
  } else if (startDataTransmission) { // If acquisition is activated and no data is received.
    VMotor = analogRead(V_MOTOR);
    // Get and store measurements:
    dataBunch += String(micros()-timeRef) + " " + String(analogRead(U_SHUNT)) + " " + String(VMotor) + " " + String(analogRead(V_TACHY)) + ";";
    counter += 1; // Increment of the measurement counter.
    if (!activationPT) { // If the PT is not enabled yet.
      if (micros()-timeRef>timeLaps && timeStop<0) { // Is time laps between start of data taking and activation of the PT is passed ?
        digitalWrite(STARTSTOP,HIGH); // PT enabled.
        digitalWrite(LED_BUILTIN,HIGH); // Turn-on of the LED.
        activationPT = true;
      }
      if (micros()-timeStop>timeLaps && timeStop>0) {
        startDataTransmission = false; // Stop of the acquisition.
        Serial.println("Q");
      }
    } else if (VMotor<VMotorThreshold) { // Detection of the stop of the motor.
      if (activationPT) { // Disabling the PT in order to avoid a restart of the motor.
        activationPT = false;
        digitalWrite(STARTSTOP,LOW); // PT disabled.
        digitalWrite(LED_BUILTIN,LOW); // Turn-off of the LED.
        timeStop = micros();  
      }
    }

    if (counter == dataSize) { // If the data size is reached, transmission of the data to the computer.
      Serial.println(dataBunch); // Send data to the computer.
      Serial.flush(); // Cleaning the serial port.
      counter = 0; // Reinitialisation of the data counter and data.
      dataBunch = "";
    }
  }
}

// Check the communication between the Arduino board and the computer.
void establishContact() 
{
  digitalWrite(LED_BUILTIN, HIGH); // Turn on the LED to indicate waiting for initialisation.
  while (Serial.available()<=0) {  // Send W character to the USB link until the processing
    Serial.println("W");           // software is responding. The TX led should be flashing.
    delay(100);
    }
  digitalWrite(LED_BUILTIN, LOW); // Turn off the LED to indicate that initialisation is done.
  // At the end, no more LED are ON on the Arduino Board which is then waiting for instruction 
  // from the computer.
}

