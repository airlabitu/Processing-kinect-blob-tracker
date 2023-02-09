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
      blobs = new Blob[theOscMessage.typetag().length()/5];
      println("Blobs length: ", blobs.length);
      for (int i = 0, j = 0; i <= theOscMessage.typetag().length()-5; i+=5, j++) {
        int x, y, blobMinDepth, id, nrOfPixels__;
        x = theOscMessage.get(i).intValue();
        y = theOscMessage.get(i+1).intValue();
        blobMinDepth = theOscMessage.get(i+2).intValue();
        id = theOscMessage.get(i+3).intValue();
        nrOfPixels__ = theOscMessage.get(i+4).intValue();

        blobs[j] = new Blob(x, y, blobMinDepth, id, nrOfPixels__);
        println("X: ", x, "Y: ", y, "Min Depth", blobMinDepth, "ID: ", id, "Pixels: ", nrOfPixels__);
      }
      framesSinceLastOscMessage = 0;
    }
  }
  println("----------------------------");
  println();
}

void mouseInteraction(Sphere s, Sphere [] s_array, String type) {
  fill(0, 255, 0);
  ellipse(mouseX, mouseY, 20, 20);
  int d = (int)dist(mouseX, mouseY, s.x, s.y);
  soundManipulation(s, s_array, d, type);
}

void blobsInteraction(Sphere s, Sphere [] s_array, String type) {
  if (framesSinceLastOscMessage > 25) {
    blobs = null;

    s.vol.setVal(s.vol.getMin(), millisToFadeNoBlobs);
  }
  if (blobs != null) {
    int minDist = 999999999;
    for (Blob b : blobs) {
      if (b != null) {
        int thisDist = (int)dist(b.x, b.y, s.x, s.y);
        if (thisDist < minDist) minDist = thisDist; 

        fill(map(b.minDepth, 0, 2047, 255, 0));
        ellipse(b.x, b.y, 50, 50);
      }
    }
    if (minDist != 999999999) {
      soundManipulation(s, s_array, minDist, type);
    }
  }
  framesSinceLastOscMessage++;
}

void soundManipulation(Sphere s, Sphere [] s_array, int dist, String type) {
  // turn off
float borderOne = 0.6; // border where sinus fade is ended
  float borderTwo = 0.3; // border where the linear fade is at a max
  noFill();
  if (type.equals("SINUS_FADE")){
    circle(s.x, s.y, (s.radius*borderOne)*2);
  }
  circle(s.x, s.y, (s.radius*borderTwo)*2);
  if (dist < s.radius) {
    // control sphere 's'
    if (type.equals("SINUS_FADE")) s.vol.setVal(sin(map(constrain(dist, s.radius*borderOne, s.radius), s.radius*borderOne, s.radius, 0, PI))*s.vol.getMax(), millisToFadeInside);   // shift over 100 millis      
    else if (type.equals("LINEAR_FADE")) s.vol.setVal(map(constrain(dist, s.radius*borderTwo, s.radius), s.radius*borderTwo, s.radius, s.vol.getMax(), s.vol.getMin()), millisToFadeInside);   // shift over 100 millis
    
    // GROUPS
    if (groupsEnabled){
      for (Sphere sp : s_array){ // groups  
        // set all others like id '5'
        if (s.getId() == 5){
          if (s.getId() != sp.getId()){
            sp.vol.setVal(s.vol.getVal(), millisToFadeInside);
            if (sp.rateEnabled) sp.rate.setVal(map(constrain(dist, s.radius*borderTwo, s.radius), s.radius*borderTwo, sp.radius, sp.rate.getMax(), sp.rate.getMin()), millisToFadeInside); 
          }
        }
        // control all in group with sphere 's' like it
        else if (s.getId() != sp.getId() && s.getGroup() == sp.getGroup()){
          sp.vol.setVal(s.vol.getVal(), millisToFadeInside);
          if (sp.rateEnabled) sp.rate.setVal(map(constrain(dist, s.radius*borderTwo, s.radius), s.radius*borderTwo, sp.radius, sp.rate.getMax(), sp.rate.getMin()), millisToFadeInside); 
          
        }
      }
    }
    
    //if (s.delayEnabled) s.delayVal.setVal(map(dist, 0, s.radius, s.delayVal.getMax(), s.delayVal.getMin()), millisToFadeInside);
    if (s.rateEnabled) s.rate.setVal(map(constrain(dist, s.radius*borderTwo, s.radius), s.radius*borderTwo, s.radius, s.rate.getMax(), s.rate.getMin()), millisToFadeInside); 
  }
  else {
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside); // shift to min
    //if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside); 
    if (s.rateEnabled) s.rate.setVal(s.rate.getMin(), millisToFadeOutside);
  }
}

// key for toggling mouse simulation
void keyPressed() {
  if (key == 's') simulate = !simulate;
}
