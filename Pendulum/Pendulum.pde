import java.time.*;
import java.time.format.*;

float pendulumLength = 0;
float circleRadius = 0;
float curCircleRadius = 0;
float maxAngle = 0;
float halfMaxHeight = 0;

float lineThickness = 5;
float maxAngleReduce = 0.8f;

int side = 0;

int lastInteractiveMillis = 0;
int animationMillis = 1000;

PGraphics mask;

float textSize = 50;
DateTimeFormatter timeFormatter;
DateTimeFormatter timeSecondFormatter;
DateTimeFormatter dateFormatter;

void setup() {
  fullScreen();
  //size(400, 400);
  frameRate(30);
  
  pendulumLength = height * 0.75f;
  circleRadius = 80;
  curCircleRadius = circleRadius;
  maxAngle = asin((width/2 - circleRadius) / pendulumLength);
  maxAngle *= maxAngleReduce;
  halfMaxHeight = sin(maxAngle) * 0.5f * circleRadius;
  
  mask = createMask(circleRadius);
  
  timeFormatter = DateTimeFormatter.ofPattern("h:mm a");  
  timeSecondFormatter = DateTimeFormatter.ofPattern("h:mm:ss a");  
  dateFormatter = DateTimeFormatter.ofPattern("EE, MMMM d");
  
  imageMode(CENTER);
  rectMode(CORNERS);
  strokeCap(SQUARE);
  textAlign(CENTER, CENTER);
  textFont(createFont("SansSerif", 50));
}

void draw() {
  background(0);
  translate(0, wearInsets().bottom/2);
  //translate(0, 0);
  
  LocalDateTime now = LocalDateTime.now();
  String time;
  if(wearAmbient())
  //if(!mousePressed)
    time = timeFormatter.format(now).toLowerCase();
  else time = timeSecondFormatter.format(now).toLowerCase();
  String date = dateFormatter.format(now);
  
  fill(255);
  noStroke();
  drawText(time, date);

  if(wearAmbient()) {
  //if(!mousePressed) {
    lastInteractiveMillis = 0;
    noFill();
    stroke(127);
    strokeWeight(lineThickness);
    circle(width/2, height/2, width - lineThickness);
  } else {
    
    float logisticFrac;
    if(lastInteractiveMillis == 0) {
      lastInteractiveMillis = millis();
    }
    float frac = (float)(millis() - lastInteractiveMillis) / animationMillis;
    if(frac >= 1) logisticFrac = 1;
    else logisticFrac = logistic(frac, 1, 2.5f);
      
    side = (int)((System.currentTimeMillis() / 1000) % 2);
    float angle = cos((side + now.getNano() * 1e-9) * PI) * maxAngle + HALF_PI;
    float cos = cos(angle), sin = sin(angle);
    
    float circleX = cos * pendulumLength, circleY = sin * pendulumLength - pendulumLength + halfMaxHeight;
    
    curCircleRadius = lerp(width/2, circleRadius, logisticFrac);
    angle = lerp(HALF_PI, angle, logisticFrac);
    circleX = lerp(0, circleX, logisticFrac);
    circleY = lerp(0, circleY, logisticFrac);
    //circleY = lerp(lerp(0, -height, frac), lerp(0, circleY, frac), logisticFrac);
    
    translate(circleX + width/2, circleY + height/2);
    
    // Draw the mask
    pushMatrix();
    scale(curCircleRadius / circleRadius);
    image(mask, 0, 0);
    popMatrix();
    
    noFill();
    stroke(255);
    strokeWeight(lineThickness);
    
    // Draw the pendulum circle
    circle(0, 0, curCircleRadius * 2);
    
    // Draw the swinging line
    rotate(angle - HALF_PI);
    line(0, -curCircleRadius, 0, -pendulumLength);
  }
}

float logistic(float t, float max, float steep) {
  return pow(t, steep)/(pow(t, steep)+pow((1-t), steep)) * max;
}

PGraphics createMask(float radius) {
  PGraphics result = createGraphics(width * 2, height * 2);
  
  float circleX = result.width/2;
  float circleY = result.height/2;
  int numSides = 20;
  
  result.beginDraw();
  result.fill(0);
  result.noStroke();

  // Boxes from the edges to the radius of the circle
  result.rect(0, 0, circleX - radius, result.height);
  result.rect(circleX + radius, 0, result.width, result.height);
  result.rect(circleX - radius, 0, circleX, circleY - radius);
  result.rect(circleX - radius, circleY + radius, circleX, result.height);

  // Rotated boxes around the circle
  result.translate(circleX, circleY);
  result.rectMode(CENTER);
  result.pushMatrix();
  for(int i = 0; i < numSides; ++i) {
    result.translate(0, radius);
    result.rect(0, radius/2, radius, radius);
    result.translate(0, -radius);
    result.rotate(TWO_PI / numSides); 
  }
  result.popMatrix();
  result.endDraw();

  return result;
}

void drawText(String time, String date) {
  pushMatrix();
  
  //fill(0);
  //noStroke();
  //rect(0, 0, textWidth(time.toString()) + 10, textSize);
    
  float timeSize = textSize;
  textSize(timeSize);
  float timeWidth = textWidth(time);
  
  float dateSize = textSize;
  float dateSizeDiff = timeSize * 0.5f;
  while(dateSizeDiff > 1f) {
    textSize(dateSize);
    float dateWidth = textWidth(date);
    if(timeWidth < dateWidth) dateSize -= dateSizeDiff;
    else dateSize += dateSizeDiff;
    dateSizeDiff *= 0.5f;
  }

  float w = timeWidth, h = timeSize + dateSize;

  textAlign(CENTER, CENTER);
  translate(width/2, height/2);

  fill(255);
  textSize(timeSize);
  text(time, 0, -h/4);
  textSize(dateSize);
  text(date, 0,  h/4);
  
  popMatrix();
}
