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
      for (int i = 0; i <= theOscMessage.typetag().length()-5; i+=5) {
        
        // iterate the blobs, and extract their data
        int x, y, blobMinDepth, id, nrOfPixels__;
        x = theOscMessage.get(i).intValue();
        y = theOscMessage.get(i+1).intValue();
        blobMinDepth = theOscMessage.get(i+2).intValue();
        id = theOscMessage.get(i+3).intValue();
        nrOfPixels__ = theOscMessage.get(i+4).intValue();
        println("X: ", x, "Y: ", y, "Min Depth", blobMinDepth, "ID: ", id, "Pixels: ", nrOfPixels__);
        
        // Set new pong pads positions if blobs are within the interaction areas
        if (map(x, 0, 640, 0, 1920) < player_area_width) {
          if (mode == 2) left_player_pad_y = int(map(y, 0, 480, 0, 1080)); // 2 player mode
          else if (mode == 1) { // 1 player mode
            right_player_pad_y = int(map(y, 0, 480, 0, 1080));
            left_player_pad_y = int(map(y, 0, 480, 0, 1080)); 
          }
        }
        else if (map(x, 0, 640, 0, 1920) > width-player_area_width) {
          if (mode == 2) right_player_pad_y = int(map(y, 0, 480, 0, 1080)); // 2 player mode
          else if (mode == 1) { // 1 player mode
            left_player_pad_y = int(map(y, 0, 480, 0, 1080));
            right_player_pad_y = int(map(y, 0, 480, 0, 1080)); 
          }
        }
      }
      framesSinceLastOscMessage = 0;
    }
  }
  println("----------------------------");
  println();
}
