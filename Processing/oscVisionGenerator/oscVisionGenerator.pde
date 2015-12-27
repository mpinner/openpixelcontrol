/**
 * oscP5parsing by andreas schlegel
 * example shows how to parse incoming osc messages "by hand".
 * it is recommended to take a look at oscP5plug for an
 * alternative and more convenient way to parse messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

int rows = 6;
int columns = 5;
int zones = rows * columns;

int margin = 10;

int zoneHeight;
int zoneWidth;

int[] zoneArea = new int[30];

int areaMax = 400;
int areaSpike = 50;


void setup() {
  size(500, 900);
  frameRate(24);
  zoneHeight = height / rows;
  zoneWidth = width / columns;

  for ( int i = 0; i < 30; i ++ ) {
    zoneArea[i] = 50;
  }


  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);

  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("10.10.10.55", 8010);
  }





void draw() {
  background(0);  
  rectMode(CENTER);


  for (int i =0; i < zones; i++) {
    drawRect(i);
    fadeZone(i);
  }

    //sendCursor();

    sendZones();
  return;  
}

void drawRect(int zone) {
  int column = zone % columns;

  int row = zone / (rows-1);

  int rectX = column * zoneWidth + zoneWidth/2;
  int rectY = row * zoneHeight + zoneHeight/2;

  if (zone == getZone(mouseX, mouseY)) {
    fill(255, 0, 255);
  } 
  else {
    fill(zoneArea[zone]);
  }


  rect (rectX, rectY, zoneWidth, zoneHeight, 7);

  //println (zone + " " + column + " " + row + " " + rectX + " " + rectY);
  return;
}

void fadeZone(int zone) {
  if (50 < zoneArea[zone] ) {
    zoneArea[zone] = zoneArea[zone] - 1;
  }
  return;
}

void mouseEvent (int zone) {
  

}

int getZone(int x, int y) {
  int column = mouseX / zoneWidth;
  int row = mouseY / zoneHeight;
  int zoneId = row * columns + column;
  //println (mouseX + " " + mouseY + " " + zoneId + " " + column + " " + row);

  return zoneId;
}

void mousePressed() {

  //sendCursor();
  setZone(getZone(mouseX, mouseY));
  
  sendZones();

  return;
}

void setZone ( int zoneId) {
  
  zoneArea[zoneId] = zoneArea[zoneId] + areaSpike;
  if (areaMax < zoneArea[zoneId]) {
    zoneArea[zoneId] = areaSpike;
  }    

  return;
}



void sendZones()
{

    //println ("sendingZone");

  for (int i =0; i < zones; i++) {

    /* create a new osc message object */
    OscMessage myMessage = new OscMessage("/camera/zone/" + (i+1));


    for ( int hue = 0; hue < 3; hue++) {
    //  myMessage.add(100); /* add an int to the osc message */
    //  myMessage.add(100); /* add a float to the osc message */
      myMessage.add(((float)zoneArea[i]/(float)areaMax)); /* add a string to the osc message */
    }

    /* send the message */
    oscP5.send(myMessage, myRemoteLocation);
  }

  return;
}


void sendCursor()
{
  String rsName = "s85";

  /* create a new osc message object */
  OscMessage myMessage = new OscMessage("/cursor/"+ rsName);

  myMessage.add(map (mouseX, 0, width, 0.0, 1.0));
  myMessage.add(map(mouseY, 0, height, 0.0, 1.0)); 
  myMessage.add(0.0); 


  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);

  return;
}



void sendVision(OscMessage msg) {
  println ("camera: "+msg.addrPattern());
 // int x = msg.get(0).intValue(); 
 // int y = msg.get(1).intValue(); 
  int area = msg.get(2).intValue();
}

void oscEvent(OscMessage msg) {
  /* check if theOscMessage has the address pattern we are looking for. */

  println ("typetag: " + msg.typetag());


  if (msg.addrPattern().startsWith("/camera")) {
    sendVision(msg);
  }
  println("### done received an osc message. with address pattern "+msg.addrPattern());
}

