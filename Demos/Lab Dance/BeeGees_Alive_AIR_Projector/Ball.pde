class Ball {
  float targetX, targetY, dx, dy, posX, posY, easing;
  float t1, n1, t2, n2;
  float size, minSize, maxSize;
  float disX, disY;
  int bn, locX, oldX, oldY;
  String name;

  Ball(int ballNumber, String _name) {
    disX = random(0, width);
    disY = random(0, height);
    posX = random(50, width-50);
    posY = random(50, width-50);
    bn = ballNumber;
    minSize = 40;
    size = minSize;
    maxSize = minSize*5;
    easing = random(0.03, 0.08);
    t1 = random(1, 1000);
    t2 = random(1, 1000);
    name = _name;
  }

  void display() {
    t1 += 0.01;
    n1 = noise(t1);
    t2 += 0.01;
    n2 = noise(t2);


    if (follow) {
      if (mouseControl) {
        targetX = mouseX;
        targetY = mouseY;
      } else {
        targetX = globalX;
        targetY = globalY;
      }
    } else {
      targetX = disX;
      targetY = disY;
    }

    dx = targetX - posX;
    dy = targetY - posY;
    if (abs(dx) > 1) {
      posX += dx * easing*easing;
      posY += dy * easing*easing;
    }

    //Control sizes of circles
    if(mouseControl){
      size = constrain(map(dist(posX, posY, mouseX, mouseY), 0, activationDistance, maxSize, minSize), minSize, maxSize);
    }
    else{
      size = constrain(map(dist(posX, posY, globalX, globalY), 0, activationDistance, maxSize, minSize), minSize, maxSize);

    }
    
    oldX  = globalX;
    oldY  = globalY;

    //Circle Channels
    if (whiteFill) {
      stroke(255);
      strokeWeight(10);
      fill(255, map(size, minSize, maxSize, 0, 100));
    } else {
      noStroke();
      fill(200-map(size, minSize, maxSize, 0, 200), map(size, minSize, maxSize, 0, 200), map(size, minSize, maxSize, 0, 100));
    }
    ellipse(posX+map(n1, 0, 1, -25, 25), posY+map(n2, 0, 1, -25, 25), size, size);
    fill(255,0,0);
    textSize(32);
    text(name,posX,posY);
  }
}
