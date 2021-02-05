import java.text.SimpleDateFormat;
import java.util.Date;

SimpleDateFormat twentyFourHour;
SimpleDateFormat twelveHour;

final int numStars = 150;
final float starSpeed = 10;
final int maxFrames = 50;

color fillColor;

float[] starsX, starsY;
int[] frame;

float textSize;

void setup() {
  fullScreen(P2D);
  frameRate(30);
  
  twentyFourHour = new SimpleDateFormat("HH:mm");
  twelveHour = new SimpleDateFormat("h:mm a");
  
  rectMode(CENTER);
  textSize = 30 * displayDensity;
  textFont(createFont("SansSerif", textSize));
  textAlign(CENTER, CENTER);

  fillColor = color(255);
  fill(fillColor);
  
  starsX = new float[numStars];
  starsY = new float[numStars];
  frame = new int[numStars];
  
  for(int i = 0; i < numStars; ++i)
    frame[i] = (int)random(maxFrames);
}

void draw() {
  background(0);
  translate(width/2, height/2 + wearInsets().bottom/2);
    
  stroke(fillColor);
  strokeWeight(1);
  drawStars();
  
  String time = hour() + ":" + minute();
  try {
    Date date = twentyFourHour.parse(time);
    time = twelveHour.format(date).toLowerCase();
  } catch(Exception e) {}
  fill(0);
  noStroke();
  rect(0, 0, textWidth(time) + 10, textSize);
  
  fill(fillColor);
  text(time, 0, -5);
}

void drawStars() {
  for(int i = 0; i < numStars; ++i) {
    if(frame[i] > maxFrames) {
      starsX[i] = random(width) - width/2;
      starsY[i] = random(height) - height/2;
      frame[i] = (int)random(10) + 1;
    } else {
      ++frame[i];
    }
    
    float scale = frame[i] * frame[i] / (5000f / starSpeed);
    float innerScale = scale * 0.8f;
    line(starsX[i] * scale, starsY[i] * scale, starsX[i] * innerScale, starsY[i] * innerScale); 
    //point(starsX[i] * scale, starsY[i] * scale);
  }
}
