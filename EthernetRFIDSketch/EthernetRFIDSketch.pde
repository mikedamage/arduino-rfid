/** 
 * RFID reader for Arduino
 * by Mike Green
 * ----------------------------------------------------------
 * Uses hardware serial interface for input and
 * the Arduino Ethernet Shield for output.
 * ----------------------------------------------------------
 * Configuration: (READER => ARDUINO)
 *    VCC => 5V
 *    GND => GND
 *    /ENABLE => Digital Pin 2
 *    SOUT => Rx Pin
 *
 *    Confirmation LED => Digital Pin 13
 *    Piezo Buzzer => Digital Pin 11
 * ----------------------------------------------------------
 * This code was borrowed from Gumbo Labs' excellent article on using
 * the Parallax RFID reader with Arduino.
 * http://www.gumbolabs.org/2009/10/17/parallax-rfid-reader-arduino/
 * ----------------------------------------------------------
 *
 * Copyright (c) 2010, Mike Green
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
/*= Constants
----------------------------------------------------------*/
#define RFID_ENABLE 2
#define OK_LED 3
#define BUZZER 4
#define BITRATE 2400
#define CODE_LEN 10
#define START_BYTE 0x0A
#define STOP_BYTE 0x0D
#define VALIDATE_TAG 1 // Set to 1 to perform validation on tag reads
#define VALIDATE_LENGTH 200 // maximum time between tag read and validate
#define ITERATION_LENGTH 2000 // time, in ms, given to the user to move their hand away

/*= Setup
----------------------------------------------------------*/
#include <Ethernet.h>
//#include <WString.h> // TODO: incorporate this for storing the auth key as a string

const char auth_key[] = "f08c454466e";
char tag[CODE_LEN];
char response[2]; // For now, server will send all responses as 2 character codes
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 10, 0, 0, 177 };
byte tag_server[] = { 10, 0, 0, 150 };
Client client(tag_server, 8081);

void setup() {
  pinMode(RFID_ENABLE, OUTPUT);
  pinMode(OK_LED, OUTPUT);
  pinMode(BUZZER, OUTPUT);
  Ethernet.begin(mac, ip);
  Serial.begin(BITRATE);
}

/*= Main Loop
----------------------------------------------------------*/
void loop() {
  enableRFID();
  getRFIDTag();
  
  if (VALIDATE_TAG == 1) {
    if (isCodeValid()) {
      // Turn off the reader and send the code
      disableRFID();
      sendCode();
      
      // Since the Arduino can't give people hugs, we flash a light and play
      // a quick confirmation tone to let them know everything's ok :)
      digitalWrite(OK_LED, HIGH);
      playTone(1014, 300);
      delay(ITERATION_LENGTH);
      digitalWrite(OK_LED, LOW);
    } else {
      disableRFID();
      //sendNoiseError();
      delay(ITERATION_LENGTH);
    }
  } else {
    disableRFID();
    sendCode();
    delay(ITERATION_LENGTH);
  }
  clearCode();
}

/*= Ethernet Functions
----------------------------------------------------------*/
// TODO: Change this to send the tag code over ethernet instead of serial
void sendCode() {
  if (client.connect()) {
    /*for (int i=0; i<CODE_LEN; i++) {
      client.print(tag[i]);
    }*/
    client.print(tag);
    client.print("QUIT");
    client.stop();
  }
}

void sendNoiseError() {
  // TODO: Send an error to a different URL so we can record how often the device
  // receives random noise.
  if (client.connect()) {
    byte response_byte;
    byte response_bytes_read = 0;
    
    client.print("NOISE\r\n");
    client.println();
    client.print("QUIT\r\n");
    client.stop();
    // TODO: read response from server via client.read()
  }
}

/*= RFID Functions
----------------------------------------------------------*/
void clearCode() {
  for (int i=0; i<CODE_LEN; i++) {
    tag[i] = 0;
  }
}

void enableRFID() {
  digitalWrite(RFID_ENABLE, LOW);
}

void disableRFID() {
  digitalWrite(RFID_ENABLE, HIGH);
}

void getRFIDTag() {
  // next_byte is temporary storage for each byte
  byte next_byte;
  
  // Blocks execution until we start receiving bytes in the incoming
  // serial buffer. Comment this out if you need to do stuff while
  // waiting for tags.
  while(Serial.available() <= 0) {}
  
  if ((next_byte = Serial.read()) == START_BYTE) {
    // bytes_read keeps track of how many bytes into the tag we are
    byte bytes_read = 0;
    
    /**
     * This while() loop makes sure we don't read
     * any more bytes than we can store in the tag array.
     */
     while(bytes_read < CODE_LEN) {
       if (Serial.available() > 0) {
         
         // Break the loop if the next byte is the STOP_BYTE
         if ((next_byte = Serial.read()) == STOP_BYTE) break;
         
         // If it's not the STOP_BYTE, pop it onto the tag array
         tag[bytes_read++] = next_byte;
         
       }
     }
  }
}

boolean isCodeValid() {
  byte next_byte;
  int count = 0;
  
  while (Serial.available() < 2) {
    delay(1);
    if (count++ > VALIDATE_LENGTH) return false;
  }
  Serial.read();
  if ((next_byte = Serial.read()) == START_BYTE) {
    byte bytes_read = 0;
    while (bytes_read < CODE_LEN) {
      if (Serial.available() > 0) {
        if ((next_byte = Serial.read()) == STOP_BYTE) break;
        if (tag[bytes_read++] != next_byte) return false;
      }
    }
  }
  return true;
}

/*= Miscellaneous Functions
----------------------------------------------------------*/
void playTone(int tone, int duration) {
  for (long i = 0; i < duration * 1000L; i += tone * 2) {
    digitalWrite(BUZZER, HIGH);
    delayMicroseconds(tone);
    digitalWrite(BUZZER, LOW);
    delayMicroseconds(tone);
  }
}
