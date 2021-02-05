import java.text.SimpleDateFormat;
import java.util.Date;

SimpleDateFormat twentyFourHour;
SimpleDateFormat twelveHour;

final int numStars = 1000;
final float starSpeed = 30f;
final int maxFrames = 50;

color fillColor;

final int X = 0, Y = 1, Z = 2, F = 3, N = 4;
float[] stars;

float textSize;

void setup() {
  fullScreen(P3D);
  //size(400, 400, P3D);
  frameRate(30);
  background(0);
  
  twentyFourHour = new SimpleDateFormat("HH:mm");
  twelveHour = new SimpleDateFormat("h:mm a");
  
  rectMode(CENTER);
  textSize = 30 * displayDensity;
  //textSize = 30;
  textFont(createFont("SansSerif", textSize));
  textAlign(CENTER, CENTER);

  fillColor = color(255);
  fill(fillColor);
  
  stars = new float[numStars * N];
  for(int i = 0; i < numStars; i += N)
    randomizeStar(i);
}

void draw() {
  background(0);
  
  translate(width/2, height/2 + wearInsets().bottom/2);
  //translate(width/2, height/2, 0);
  
  noFill();
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
  for(int i = 0; i < numStars; i += N) {
    if(stars[i+Z] >= width)
      randomizeStar(i);
    
    //point(stars[i], stars[i+1], stars[i+2]);
    //stroke(lerpColor(color(0), color(255),  (-width*2) / stars[i+2]));
    float frac = 1;
    if(frameCount - stars[i+F] < 10) frac = (frameCount - stars[i+F])/10f;
    else stroke(frac * 255f);
    
    line(stars[i+X], stars[i+Y], stars[i+Z], stars[i+X], stars[i+Y], stars[i+Z] + 50);
    stars[i+Z] += starSpeed;
  }
}

void randomizeStar(int star) {
  stars[star+X] = random(width * 2) - width;
  stars[star+Y] = random(height * 2) - height;
  stars[star+Z] = -random(width) - width;
  stars[star+F] = frameCount;
}
