import java.time.*;
import java.time.format.*;

//SimpleDateFormat twentyFourHour;
DateTimeFormatter twelveHour;

final int numStars = 1000;
final float desiredStarSpeed = 30f;
final float desiredStarLength = 50f;

int lastInteractiveMillis = 0;
int speedUpMillis = 1000;

float starSpeed = 30f;
float lineLength = 50f;

final int X = 0, Y = 1, Z = 2, F = 3, N = 4;
float[] stars;

float textSize;

void setup() {
  //fullScreen(P3D);
  size(400, 400, P3D);
  frameRate(30);
  background(0);
  
  //twentyFourHour = new SimpleDateFormat("HH:mm");
  twelveHour = DateTimeFormatter.ofPattern("h:mm a");  

  rectMode(CENTER);
  //textSize = 30 * displayDensity;
  textSize = 30;
  textFont(createFont("SansSerif", textSize));
  textAlign(CENTER, CENTER);
  
  stars = new float[numStars * N];
  for(int i = Z; i < numStars; i += N)
    stars[i] = lerp(0, -width * 2, (float)i / numStars);
}

void draw() {
  background(0);
  
  //translate(width/2, height/2 + wearInsets().bottom/2);
  translate(width/2, height/2, 0);
  
  noFill();
  //if(wearAmbient()) {
  if(!mousePressed) {
    
    lastInteractiveMillis = 0;
    
    stroke(127);
    strokeWeight(2);
    
    drawStarsAmbient();
    
  } else {
    
    if(lastInteractiveMillis == 0) {
      lastInteractiveMillis = millis();
    }
    float frac = (float)(millis() - lastInteractiveMillis) / speedUpMillis;
    if(frac > 1) frac = 1;
    float expFrac = frac * frac;
    
    starSpeed = lerp(0, desiredStarSpeed, expFrac);
    lineLength = lerp(0, desiredStarLength, expFrac);
    stroke(lerp(127, 255, expFrac));
    strokeWeight(lerp(2, 1, expFrac));
    
    drawStars();
  }
  
  String time = twelveHour.format(LocalDateTime.now()).toLowerCase();  
  fill(0);
  noStroke();
  rect(0, 0, textWidth(time.toString()) + 10, textSize);
  
  fill(255);
  text(time, 0, -5);
}

void drawStars() {
  for(int i = 0; i < numStars; i += N) {
    if(stars[i+Z] >= width)
      randomizeStar(i);
        
    line(stars[i+X], stars[i+Y], stars[i+Z], stars[i+X], stars[i+Y], stars[i+Z] - lineLength);
    if(lineLength < 10) point(stars[i+X], stars[i+Y], stars[i+Z]);
    stars[i+Z] += starSpeed;
  }
}

void drawStarsAmbient() {
  for(int i = 0; i < numStars; i += N) {
    point(stars[i+X], stars[i+Y], stars[i+Z]);
  }
}

void randomizeStar(int star) {
  stars[star+X] = random(width * 2) - width;
  stars[star+Y] = random(height * 2) - height;
  stars[star+Z] = -width * 2;
  stars[star+F] = frameCount;
}
