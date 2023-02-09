import oscP5.*;
import processing.sound.*;


String [] filenames = {"1512a.mp3", "1512b.mp3", "1512c.mp3", "1512d.mp3", "1512e.mp3", "1512f.mp3"};
int [] circle_radius =  {90, 180, 270, 360, 450, 540};//540, 450, 360, 270, 180, 90} {540, 450, 360, 270, 180, 90};
boolean [] states = {false, false, false, false, false, false};

SoundFile [] soundfiles;
OscP5 oscP5;
int framesSinceLastOscMessage = 0;

PImage img;
boolean debug = false;
boolean mode = false; // kinect = false, mouse = true
//float x_pos, y_pos;



void setup() {
  //fullScreen(1920,1080);
  size(1440, 1080);
  oscP5 = new OscP5(this, 6789);
  background(0);
  imageMode(CENTER);
  noStroke();
  img = loadImage("plante1_pic.png");
  soundfiles = new SoundFile[filenames.length];
  
  for (int i = 0; i < soundfiles.length; i++){
    soundfiles[i] = new SoundFile(this, filenames[i]);
    ellipse(width/2, height/2, circle_radius[i]*2, circle_radius[i]*2);
  }
  
}

void draw(){
  
  background(0);
  image(img, width/2, height/2, height, height);
  
  if(debug){
    for (int i = states.length-1; i >= 0; i--){
      if (states[i]) fill(0, 255, 0);
      else fill(255, 0,0);
      stroke(255);
      ellipse(width/2, height/2, circle_radius[i]*2, circle_radius[i]*2);
    }
  }
  
  if (mode == true){ // mouse mode
    
    for (int j = 0; j < circle_radius.length; j++) states[j] = false; // reset the array
        
    for (int j = 0; j < circle_radius.length; j++){ // set state array when blobs are inside a ring
          
      float distance = dist(width/2, height/2, mouseX, mouseY);
          
      if (j == 0 && distance < circle_radius[j]) states[j] = true;
      else if (distance < circle_radius[j] && distance > circle_radius[j-1]) states[j] = true;
          
    }
    fill(255,255,0);
    ellipse(mouseX, mouseY, 40, 40);
  }
  
  
  for (int i = 0; i < states.length; i++){
    if (states[i] == true && !soundfiles[i].isPlaying()) soundfiles[i].play();
    else if (states[i] == false && soundfiles[i].isPlaying()) soundfiles[i].pause(); 
  }
}



void oscEvent(OscMessage theOscMessage) {
  println("--- OSC MESSAGE RECEIVED ---");
  // Check if the address pattern is the right one
  if (theOscMessage.checkAddrPattern("/Blobs|X|Y|MIN_DEPTH|ID|NR_OF_PIXELS|")==true) {
    println("AddressPattern matched:", theOscMessage.addrPattern());
    // check if the typetag is the right one
    String typeTag = "";
    for (int i = 0; i < theOscMessage.typetag().length(); i++) typeTag += "i";
    if (theOscMessage.checkTypetag(typeTag)) {
      println("TypeTag matched:", theOscMessage.typetag());
      
      
      
      for (int i = 0; i <= theOscMessage.typetag().length()-5; i+=5) { // iterate single blobs
        
        // iterate the blobs, and extract their data
        int x, y, blobMinDepth, id, nrOfPixels__;
        x = theOscMessage.get(i).intValue();
        y = theOscMessage.get(i+1).intValue();
        blobMinDepth = theOscMessage.get(i+2).intValue();
        id = theOscMessage.get(i+3).intValue();
        nrOfPixels__ = theOscMessage.get(i+4).intValue();
        println("X: ", x, "Y: ", y, "Min Depth", blobMinDepth, "ID: ", id, "Pixels: ", nrOfPixels__);
        x = constrain(x, 80, 80+480);
        
        float x_mapped = map(x, 0, 640, 0, width);
        float y_mapped = map(y, 0, 480, 0, height);
        

        
        if (i == 0) for (int j = 0; j < circle_radius.length; j++) states[j] = false; // reset the array
        
        for (int j = 0; j < circle_radius.length; j++){ // set state array when blobs are inside a ring
          
          float distance = dist(width/2, height/2, x_mapped, y_mapped);
          
          if (j == 0 && distance < circle_radius[j]) states[j] = true;
          else if (distance < circle_radius[j] && distance > circle_radius[j-1]) states[j] = true;
          
        }
        
        
        
        
        
      }
         

      
      framesSinceLastOscMessage = 0;
    }
  }
  println("----------------------------");
  println();
}

void keyReleased(){
  if (key == 'd') debug = !debug;
  if (key == 'm') mode = !mode;
}
