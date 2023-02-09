// This is the template sketch for the HoS project planet sound sketches
// Volumen is going from low to high, the effects: Delay, Envelope, Rate are all implemented into the sphere class
// This happens when a user enters the sphere circle, and is adjusted according to distance from user blob center to sphere cente

import oscP5.*;
import processing.sound.*;

OscP5 oscP5;
Blob [] blobs;
int framesSinceLastOscMessage = 0;

Sphere [] spheresFX;
Sphere [] spheresClean;

boolean simulate = false;
int millisToFadeInside = 300;
int millisToFadeOutside = 1000;
int millisToFadeNoBlobs = 5000;

boolean groupsEnabled = false;

int kinect_w = 640;
int kinect_h = 480;

float scale_factor = 2.25;
int x_offset = 240;

boolean kinect_view = true;

PImage [] pics = new PImage[9];

// alert prosponer
//OscAlertProsponer soundAlertProsponer;

void setup() {
  size(1920, 1080);
  frameRate(25);
  textAlign(CENTER);
  
  oscP5 = new OscP5(this, 6789);
  spheresClean = new Sphere [9];
  spheresFX = new Sphere [9];
  
  // create spheres
  spheresFX[0] = new Sphere(143, 98, 90, "with_fx/1.wav", this, 1, 2);
  spheresFX[1] = new Sphere(319, 104, 90, "with_fx/2.wav", this, 2, 4);
  spheresFX[2] = new Sphere(489, 93, 90, "with_fx/3.wav", this, 3, 3);
  spheresFX[3] = new Sphere(147, 255, 90, "with_fx/4.wav", this, 4, 3);
  spheresFX[4] = new Sphere(321, 250, 90, "with_fx/5.wav", this, 5, 1);
  spheresFX[5] = new Sphere(489, 250, 90, "with_fx/6.wav", this, 6, 4);
  spheresFX[6] = new Sphere(149, 408, 90, "with_fx/7.wav", this, 7, 4);
  spheresFX[7] = new Sphere(325, 410, 90, "with_fx/8.wav", this, 8, 3);
  spheresFX[8] = new Sphere(500, 407, 90, "with_fx/9.wav", this, 9, 2);
  
  spheresClean[0] = new Sphere(143, 98, 90, "without_fx/1.wav", this, 1, 2);
  spheresClean[1] = new Sphere(319, 104, 90, "without_fx/2.wav", this, 2, 4);
  spheresClean[2] = new Sphere(489, 93, 90, "without_fx/3.wav", this, 3, 3);
  spheresClean[3] = new Sphere(147, 255, 90, "without_fx/4.wav", this, 4, 3);
  spheresClean[4] = new Sphere(321, 250, 90, "without_fx/5.wav", this, 5, 1);
  spheresClean[5] = new Sphere(489, 250, 90, "without_fx/6.wav", this, 6, 4);
  spheresClean[6] = new Sphere(149, 408, 90, "without_fx/7.wav", this, 7, 4);
  spheresClean[7] = new Sphere(325, 410, 90, "without_fx/8.wav", this, 8, 3);
  spheresClean[8] = new Sphere(500, 407, 90, "without_fx/9.wav", this, 9, 2);
  
  pics[0] = loadImage("data/pics/64.png");
  pics[1] = loadImage("data/pics/65.png");
  pics[2] = loadImage("data/pics/66.png");
  pics[3] = loadImage("data/pics/67.png");
  pics[4] = loadImage("data/pics/68.png");
  pics[5] = loadImage("data/pics/69.png");
  pics[6] = loadImage("data/pics/70.png");
  pics[7] = loadImage("data/pics/71.png");
  pics[8] = loadImage("data/pics/72.png");
  imageMode(CENTER);
  
  // prevent text overlap
  for (int i = 0; i < spheresFX.length; i++){
    spheresFX[i].yMove = -20;
    spheresClean[i].yMove = 20;
  }
  
  // settings for FX sounds
  for (Sphere s : spheresFX) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    s.enableRate(); // ### rate
    s.rate.setMinMax(0.92,1.0); // ### rare
    //s.rate.reverse(true);
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
    
  }
  
  // settings for clean sounds
  for (Sphere s : spheresClean) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    s.enableRate(); // ### rate
    s.rate.setMinMax(0.92,1.0); // ### rare
    //s.rate.reverse(true);
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
    s.vol.setMinMax(0.00001, 0.6); // ### 2-track : turn down the max of the clean
  }
  
  // alert prosponer
  //soundAlertProsponer = new OscAlertProsponer(oscP5, "127.0.0.1", 11011, "/SoundAlive");
  //soundAlertProsponer.isActive = true;
}


void draw() {
  background(0);
  stroke(255);
  noFill();
  rect(x_offset, 0, 640*scale_factor, 480*scale_factor);
  for (int i = 0; i < pics.length; i++){
    image(pics[i], map(spheresFX[i].x, 0, 640, 0, 640*scale_factor)+x_offset, map(spheresFX[i].y, 0, 480, 0, 480*scale_factor)); 
  }
  if (kinect_view) draw_kinect_view();

}


void draw_kinect_view(){
  
  //background(0);
  fill(0);
  noStroke();
  rect(0, 0, kinect_w, kinect_h);
  
  for (Sphere s : spheresFX) {
    s.show(0, 255, 0);
    s.update();
    if (simulate) mouseInteraction(s, spheresFX, "LINEAR_FADE");
    else blobsInteraction(s, spheresFX, "LINEAR_FADE");
  }
  
  for (Sphere s : spheresClean) {
    s.show(0, 0, 255);
    s.update();
    if (simulate) mouseInteraction(s, spheresClean, "SINUS_FADE");
    else blobsInteraction(s, spheresClean, "SINUS_FADE");
  }
  
  fill(0, 0, 255);
  text("Simulate: " + simulate, 50, kinect_h -10);
  
  // update alert prosponer
  //soundAlertProsponer.update();

}
