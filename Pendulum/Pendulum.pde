import java.time.*;

float lineThickness = 4;
float circleRadius = 70;
float pendulumLength = 300;
float maxAngleReduce = 0.8f;
float maxAngle = 0;
float halfMaxHeight = 0;

float curCircleRadius = circleRadius;

int state = 0;
int side = 0;

int lastInteractiveMillis = 0;
int animationMillis = 1 * 1000;

void setup() {
  size(400, 400); 
  
  maxAngle = asin((width/2 - circleRadius) / pendulumLength);
  maxAngle *= maxAngleReduce;
  halfMaxHeight = sin(maxAngle) * 0.67f * circleRadius;
  
  strokeCap(SQUARE);
  textAlign(CENTER, CENTER);
}

void draw() {
  background(0);
  translate(width/2, height/2);
  
  Instant now = Instant.now();
  
  LocalDateTime ldt = LocalDateTime.ofInstant(now, ZoneId.systemDefault());
  String time = getTime(ldt);
  String date = getDate(ldt);
  fill(255);
  noStroke();
  textSize(50);
  text(time, 0, -15);
  textSize(30);
  text(date, 0, 35);
  
  if(!mousePressed) {
    lastInteractiveMillis = 0;
    noFill();
    stroke(127);
    strokeWeight(lineThickness);
    circle(0, 0, width);
  } else {
    
    float logisticFrac;
    if(lastInteractiveMillis == 0) {
      lastInteractiveMillis = millis();
    }
    float frac = (float)(millis() - lastInteractiveMillis) / animationMillis;
    if(frac >= 1) logisticFrac = 1;
    else logisticFrac = logistic(frac, 1, 2.5f);
      
    state = (int)(now.getEpochSecond() % 3);
    side = (int)(now.getEpochSecond() % 2);
    float angle = cos((side + now.getNano() * 1e-9) * PI) * maxAngle + HALF_PI;
    float cos = cos(angle), sin = sin(angle);
    
    float circleX = cos * pendulumLength, circleY = sin * pendulumLength - pendulumLength + halfMaxHeight;
    
    curCircleRadius = lerp(width/2, circleRadius, logisticFrac);
    angle = lerp(HALF_PI, angle, logisticFrac);
    circleX = lerp(0, circleX, logisticFrac);
    circleY = lerp(0, circleY, logisticFrac);
    //circleY = lerp(lerp(0, -height, frac), lerp(0, circleY, frac), logisticFrac);
    
    setPixelsToBlack(circleX, circleY, curCircleRadius);
    
    pushMatrix();
    translate(circleX, circleY);
    rotate(angle - HALF_PI);
    noFill();
    stroke(255);
    strokeWeight(lineThickness * 3);
    line(0, -curCircleRadius, 0, -pendulumLength);
    stroke(0);
    strokeWeight(lineThickness);
    line(0, -curCircleRadius, 0, -pendulumLength);
    popMatrix();
    
    stroke(255);
    circle(circleX, circleY, curCircleRadius * 2);
  }
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

String[] monthNames = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
String getDate(LocalDateTime ldt) {
  String date = ldt.getDayOfMonth() + "";
  date = monthNames[ldt.getMonthValue() - 1] + " " + date;
  date = date + ", " + ldt.getYear();
  return date;
}

void setPixelsToBlack(float x, float y, float radius) {
  x += width/2;
  y += height/2;
  float radiusSquared = radius * radius;
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

float logistic(float t, float max, float steep) {
  return pow(t, steep)/(pow(t, steep)+pow((1-t), steep)) * max;
}
