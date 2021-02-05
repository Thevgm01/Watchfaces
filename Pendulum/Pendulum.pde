import java.time.*;

float circleRadius = 70;
float pendulumLength = 300;
float maxAngleReduce = 0.8f;
float maxAngle = 0;
float maxHeight = 0;

int state = 0;
int side = 0;

void setup() {
  size(400, 400); 
  
  maxAngle = asin((width/2 - circleRadius) / pendulumLength);
  maxAngle *= maxAngleReduce;
  maxHeight = sin(maxAngle);
  
  textSize(50);
  textAlign(CENTER, CENTER);
}

void draw() {
  background(0);
  translate(width/2, height/2);
  
  Instant now = Instant.now();
  
  LocalDateTime ldt = LocalDateTime.ofInstant(now, ZoneId.systemDefault());
  String time = getTime(ldt);
  fill(255);
  noStroke();
  text(time, 0, 0);
  
  state = (int)(now.getEpochSecond() % 3);
  side = (int)(now.getEpochSecond() % 2);
  float angle = cos((side + now.getNano() * 1e-9) * PI) * maxAngle + HALF_PI;
  float cos = cos(angle), sin = sin(angle);
  
  float circleX = cos * pendulumLength, circleY = sin * pendulumLength - pendulumLength + maxHeight * 0.5f * circleRadius;
  setPixelsToBlack(circleX, circleY);
  
  strokeCap(SQUARE);
  noFill();
  stroke(255);
  strokeWeight(9);
  line(0, -pendulumLength, circleX - cos * circleRadius, circleY - sin * circleRadius);
  stroke(0);
  strokeWeight(3);
  line(0, -pendulumLength, circleX - cos * circleRadius, circleY - sin * circleRadius);
  stroke(255);
  circle(circleX, circleY, circleRadius * 2);
}

String getTime(LocalDateTime ldt) {
  String time = ldt.getSecond() + "";
  if(ldt.getSecond() < 10) time = "0" + time;
  time = ldt.getMinute() + ":" + time;
  if(ldt.getMinute() < 10) time = "0" + time;
  int hour = ldt.getHour();
  if(hour > 12) time = (hour - 12) + ":" + time + " pm"; 
  else time = hour + ":" + time + " am";
  return time;
}

void setPixelsToBlack(float x, float y) {
  x += width/2;
  y += height/2;
  float radiusSquared = circleRadius * circleRadius;
  color black = color(0);
  
  loadPixels();
  for(int i = 0; i < pixels.length; ++i) {
    int px = i % width, py = i / width;
    float dx = px - x, dy = py - y;
    boolean outside = dx * dx + dy * dy > radiusSquared;
    if(outside) pixels[i] = black;
  }
  updatePixels();
}
