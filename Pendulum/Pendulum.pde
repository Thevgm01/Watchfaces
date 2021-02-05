import java.time.*;

// period = 2pi * sqrt(length / gravity)
// (period * period) / (2pi * 2pi) = length / gravity
// gravity = length * (2pi * 2pi) / (period * period)

float circleRadius = 70;
float pendulumLength = 300;
float maxAngle = 0;

void setup() {
  size(400, 400); 
  
  maxAngle = asin((width/2 - circleRadius) / pendulumLength);
  
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
  
  float angle = cos(((now.getEpochSecond() % 2) + now.getNano() * 1e-9) * PI) * maxAngle + HALF_PI;
  float cos = cos(angle), sin = sin(angle);
  
  float circleX = cos * pendulumLength, circleY = sin * pendulumLength - pendulumLength;
  setPixelsToBlack(circleX, circleY);
  
  noFill();
  stroke(255);
  strokeWeight(3);
  line(0, -pendulumLength, cos * (pendulumLength - circleRadius), sin * (pendulumLength - circleRadius) - pendulumLength);
  circle(cos * pendulumLength, sin * pendulumLength - pendulumLength, circleRadius * 2);
}

String getTime(LocalDateTime ldt) {
  String time = ldt.getSecond() + "";
  if(ldt.getSecond() < 10) time = "0" + time;
  time = ldt.getMinute() + ":" + time;
  if(ldt.getMinute() < 10) time = "0" + time;
  int hour = ldt.getHour();
  if(hour > 12) time = (hour - 12) + ":" + time + " pm"; 
  else time = hour + ":" + time + "am";
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
    if(dx * dx + dy * dy > radiusSquared) {
      pixels[i] = black;
    }
  }
  updatePixels();
}
