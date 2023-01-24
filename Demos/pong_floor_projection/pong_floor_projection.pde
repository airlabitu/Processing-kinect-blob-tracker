// Based on this code: https://openprocessing.org/sketch/47481/ by Gabriel Lovato

// adapted for two playser within a Kinect tracking and floow projection space by Halfdan Hauch Jensen (halj@itu.dk) at AIR LAB ITU
import oscP5.*;

OscP5 oscP5;

int framesSinceLastOscMessage = 0;

int player_area_width = 200;
int left_player_area_x = 200;
int right_player_area_x = 1620;
int left_player_pad_x = left_player_area_x + player_area_width + 10;
int right_player_pad_x = right_player_area_x - 20;
int left_player_pad_y;
int right_player_pad_y;

boolean gameStart = false;
long timer = 9000000;
int interval = 1000; // (1 sec)

float x = left_player_pad_x + 50;
float y = 150;
float speedX = random(7, 10);
float speedY = random(7, 10);
int diam = 20;
int rectSize = 150;

int mode = 2; // 0 = mouse, 1 = 1_player, 2 = 2_player


void setup() {
  fullScreen(1920,1080);
  //size(1920, 1080);
  oscP5 = new OscP5(this, 6789);
  noStroke();
  smooth();
  ellipseMode(CENTER);
}

void draw() { 
  
  if (mode == 0) {
    left_player_pad_y = mouseY;
    right_player_pad_y = mouseY;
  }
  
  background(0);
  
  // draw player tracking area
  fill(255,0,0);
  rect(left_player_area_x,0, player_area_width, height);
  rect(right_player_area_x,0, player_area_width, height);
  
  // draw the ball
  fill(255);
  ellipse(x, y, diam, diam);
  
  // draw the pads
  fill(255);
  rect(left_player_pad_x, left_player_pad_y-rectSize/2, 10, rectSize);
  fill(255);
  rect(right_player_pad_x, right_player_pad_y-rectSize/2, 10, rectSize);
  
  // draw the bounding edges (top/bottom)
  fill(255);
  rect(left_player_area_x,0, dist(left_player_area_x,0, right_player_area_x+player_area_width, 0),50);
  rect(left_player_area_x,height-50, dist(left_player_area_x,0, right_player_area_x+player_area_width, 0),50);
  fill(0);
  rect(0,0,width,40);
  rect(0,height-40, width, 40);
  
  // draw mode info
  fill(255);
  if (mode == 0) text("mode: mouse", 10, 20);
  if (mode == 1) text("mode: 1_player", 10, 20);
  if (mode == 2) text("mode: 2_player", 10, 20);
  
  
  // start game again after point score pause
  if (millis() > timer+interval) gameStart = true; 
  
  // if game is running
  if (gameStart) {
    
    // move the ball
    x = x + speedX; 
    y = y + speedY;

    // if ball hits right bar, invert X direction and apply effects
    if ( x > right_player_pad_x - diam/2 && x < right_player_pad_x && y > right_player_pad_y-rectSize/2 && y < right_player_pad_y+rectSize/2 ) {
      speedX = speedX * -1;
      x = x + speedX;
      rectSize = rectSize-10;
      rectSize = constrain(rectSize, 10,150);      
    } 
    
    // if ball hits left bar, invert X direction and apply effects
    if ( x < left_player_pad_x + 10 + diam/2 && x > left_player_pad_x + 10 && y > left_player_pad_y-rectSize/2 && y < left_player_pad_y+rectSize/2 ) {
      speedX = speedX * -1;
      x = x + speedX;
      rectSize = rectSize-10;
      rectSize = constrain(rectSize, 10,150);      
    } 

    // resets things if right player lose
    if (x > right_player_area_x) { 
      gameStart = false; // pause after point
      timer = millis(); // reset timer for pause
      x = right_player_pad_x-40;
      y = constrain(right_player_pad_y, 100, 980); 
      speedX = random(-7, -10);
      speedY = random(-7, -10);
      rectSize = 150;
    }
    
    // reset things if left player loose 
    if (x < left_player_area_x + player_area_width) { 
      gameStart = false; // pause after point
      timer = millis(); // reset timer for pause
      x = left_player_pad_x + 50;
      y = constrain(left_player_pad_y, 100, 980); 
      speedX = random(7, 10);
      speedY = random(7, 10);
      rectSize = 150;
    }

    // bounce ball if it hits up or down
    if ( y > height-50-diam/2 || y < 50+diam/2 ) {
      speedY = speedY * -1;
      y = y + speedY;
    }
  }
}

void keyReleased(){
  if (key == 'm') mode = (mode+1)%3; // change mode (0=mouse, 1=1_player, 2=2_player)
  if (key == 's') timer = millis()-interval; // start the game

}
                
