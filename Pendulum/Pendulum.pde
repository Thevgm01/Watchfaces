import java.time.*;

float pendulumLength = 0;
float circleRadius = 0;
float curCircleRadius = 0;
float maxAngle = 0;
float halfMaxHeight = 0;

float lineThickness = 5;
float maxAngleReduce = 0.8f;

int state = 0;
int side = 0;

int lastInteractiveMillis = 0;
int animationMillis = 1 * 1000;

void setup() {
  fullScreen();
  frameRate(30);
  
  pendulumLength = height;
  circleRadius = 80;
  curCircleRadius = circleRadius;
  maxAngle = asin((width/2 - circleRadius) / pendulumLength);
  maxAngle *= maxAngleReduce;
  halfMaxHeight = sin(maxAngle) * 0.67f * circleRadius;
    
  imageMode(CENTER);
  rectMode(CORNERS);
  strokeCap(SQUARE);
  textAlign(CENTER, CENTER);
}

void draw() {
  background(0);
  //translate(0, wearInsets().bottom/2);
  translate(0, 0);
  
  Instant now = Instant.now();
  
  LocalDateTime ldt = LocalDateTime.ofInstant(now, ZoneId.systemDefault());
  String time = getTime(ldt);
  String date = getDate(ldt);
  fill(255);
  noStroke();
  pushMatrix();
  translate(width/2, height/2);
  scale(displayDensity);
  textSize(30);
  text(time, 0, -15);
  textSize(20);
  text(date, 0, 15);
  popMatrix();
  
  if(wearAmbient()) {
    lastInteractiveMillis = 0;
    noFill();
    stroke(127);
    strokeWeight(lineThickness);
    circle(width/2, height/2, width - lineThickness/2);
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
    
    circleX += width/2;
    circleY += height/2;
    
    fill(0);
    noStroke();
    rect(0, 0, circleX - curCircleRadius, height);
    rect(circleX + curCircleRadius, 0, width, height);
    rect(circleX - curCircleRadius, 0, circleX, circleY - curCircleRadius);
    rect(circleX - curCircleRadius, circleY + curCircleRadius, circleX, height);
    
    translate(circleX, circleY);
    
    strokeWeight(lineThickness);
    pushMatrix();
    for(int i = 0; i < 10; ++i) {
      rect(-curCircleRadius, -curCircleRadius * 2, curCircleRadius, -curCircleRadius);
      rotate(TWO_PI / 10); 
    }
    rotate(angle - HALF_PI);
    noFill();
    stroke(255);
    line(0, -curCircleRadius, 0, -pendulumLength);
    popMatrix();
    
    noFill();
    stroke(255);
    strokeWeight(lineThickness);
    circle(0, 0, curCircleRadius * 2);
  }
}

String getTime(LocalDateTime ldt) {
  String time = "";
  if(wearInteractive()) {
    time = ldt.getSecond() + "";
    if(ldt.getSecond() < 10) time = "0" + time;
    time = ":" + time;
  }
  time = ldt.getMinute() + time;
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

float logistic(float t, float max, float steep) {
  return pow(t, steep)/(pow(t, steep)+pow((1-t), steep)) * max;
}
