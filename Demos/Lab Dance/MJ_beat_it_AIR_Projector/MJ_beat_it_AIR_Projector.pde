import ddf.minim.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

Ball[] balls;

final static String[] instrumentFiles = {
  "bass", "cymbals", "drums", "guitar", "kick", "vocals"
};

final static AudioPlayer[] instruments = new AudioPlayer[instrumentFiles.length];
final Minim minim = new Minim(this);

int activationDistance = 300;
int globalX, globalY;
int counter, timer = 500;
boolean mouseControl, follow, showUserOutline = true, whiteFill = true, blend;

void setup() {
  fullScreen();
  smooth();
  noCursor();

  oscP5 = new OscP5(this, 6789);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  for ( byte idx = 0; idx != instrumentFiles.length; 
    instruments[idx] = minim.loadFile( instrumentFiles[idx++] + ".mp3") );

  balls = new Ball[instrumentFiles.length];
  for (int i = 0; i <= balls.length-1; i++) {
    instruments[i].loop();
    balls[i] = new Ball(i);
  }
}

void draw() {
  if (blend) {
    noStroke();
    fill(0, 50);
    rect(0, 0, width, height);
  } else {
    background(0);
  }

  for (int i = 0; i <= balls.length-1; i++) {
    balls[i].display();
    //set gain to size of individual ball with allocated instrument i
    if (balls[i].size > balls[i].minSize+1) {
      instruments[i].setGain(map(balls[i].size, balls[i].minSize, balls[i].maxSize, -20, 10));
    } else {
      instruments[i].setGain(-100);
    }
  }

  if (showUserOutline) {
    noFill();
    strokeWeight(10);
    stroke(255);
    if (mouseControl) {
      ellipse(mouseX, mouseY, activationDistance*2, activationDistance*2);
    } else {
      ellipse(globalX, globalY, activationDistance*2, activationDistance*2);
    }
  }


  if (!follow) {
    counter++;
    if (counter > timer) {
      newTarget();
      counter = 0;
      timer = int(random(500, 3000));
      println(balls[0].disX, balls[0].disY);
    }
  }
}

void mouseReleased() {
  follow = !follow;
  newTarget();
}

void keyReleased() {
  if (key == '1') {
    mouseControl = !mouseControl;
  }
  if (key == '2') {
    showUserOutline = !showUserOutline;
  }
  if (key == '3') {
    whiteFill = !whiteFill;
  }
  if (key == '4') {
    blend = !blend;
  }
}

void newTarget(){
  for (int i = 0; i <= balls.length-1; i++) {
    if (follow) {
      balls[i].targetX = globalX;
      balls[i].targetY = globalY;
    } else {
      balls[i].disX = random(0, width);
      balls[i].disY = random(0, height);
    }
  }
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  //print("### received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //println(" typetag: "+theOscMessage.typetag());
  globalX = int(map(theOscMessage.get(0).intValue(), 0, 640, 0, width));
  globalY = int(map(theOscMessage.get(1).intValue(), 0, 480, 0, height));
  //println(globalX, globalY);
}
