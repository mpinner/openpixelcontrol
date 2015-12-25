OPC opc;
PImage dot;

import oscP5.*;
import netP5.*;

OscP5 oscP5;

int cursorX;
int cursorY;

void setup()
{
  size(640, 360);

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 8005);


  // Load a sample image
  dot = loadImage("dot.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map an 8x8 grid of LEDs to the center of the window
  ledGrid8x1(opc, 0, width/2, height/2, height / 12.0, 0, false);
}


  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  void ledGrid8x1(OPC opc, int index, float x, float y, float spacing, float angle, boolean zigzag)
  {
    opc.ledGrid(index, 8, 1, x, y, spacing, spacing, angle, zigzag);
  }

void draw()
{
  background(0);

  // Draw the image, centered at the mouse location
  float dotSize = height * 0.7;
  image(dot, cursorX - dotSize/2, cursorY - dotSize/2, dotSize, dotSize);
}


void oscEvent(OscMessage msg) {

  println("### done received an osc message. with address pattern "+msg.addrPattern());
  println ("typetag: " + msg.typetag());


  if (msg.addrPattern().startsWith("/cursor")) {
    float x = msg.get(0).floatValue();
    float y = msg.get(1).floatValue();
    cursorX = (int) map (x, 0.0, 1.0, 0, width); 
    cursorY = (int) map (y, 0.0, 1.0, 0, height);

  }
}

