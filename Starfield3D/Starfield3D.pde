import java.time.*;
import java.time.format.*;

DateTimeFormatter timeFormatter;
DateTimeFormatter dateFormatter;

final int numStars = 300;
final float fadeDistance = 1000;

float desiredStarSpeed = 30f;
float desiredStarLength = 60f;

int lastInteractiveMillis = 0;
int speedUpMillis = 1000;

float starSpeed = 30f;
float lineLength = 50f;

float angle = 0;

final int X = 0, Y = 1, Z = 2, M = 3, N = 4;
float[] stars;

float textSize;
String curTime;
PGraphics timeGraphic;

void setup() {
  //fullScreen(P3D);
  size(400, 400, P3D);
  frameRate(30);
  background(0);
  
  //twentyFourHour = new SimpleDateFormat("HH:mm");
  timeFormatter = DateTimeFormatter.ofPattern("h:mm a");  
  dateFormatter = DateTimeFormatter.ofPattern("EE, MMMM d");  
  
  //textSize = 30 * displayDensity;
  textSize = 50;
  textFont(createFont("SansSerif", textSize));
  textAlign(CENTER, CENTER);
  
  imageMode(CENTER);

  stars = new float[numStars * N];
  for(int i = 0; i < stars.length; i += N) {
    randomizeStar(i);
    stars[i+Z] = 2000 * ((float)i / stars.length);
  }
}

void draw() {
  background(0);
  
  pushMatrix();
  //translate(width/2, height/2 + wearInsets().bottom/2);
  translate(width/2, height/2, -1000);
  rotate(sin(angle) * 2);

  noFill();
  //if(wearAmbient()) {
  if(!mousePressed) {
    
    lastInteractiveMillis = 0;
    
    stroke(127);
    strokeWeight(2);
    
    drawStarsAmbient();
    
  } else {
    
    if(lastInteractiveMillis == 0) lastInteractiveMillis = millis();
    float frac = (float)(millis() - lastInteractiveMillis) / speedUpMillis;
    if(frac > 1) frac = 1;
    float expFrac = frac * frac;
        
    starSpeed = lerp(0, desiredStarSpeed, expFrac);
    desiredStarLength = starSpeed * 2f;
    lineLength = lerp(0, desiredStarLength, expFrac);
    stroke(lerp(127, 255, expFrac));
    strokeWeight(lerp(2, 1, expFrac));
    
    angle += expFrac * 0.01f;
    
    drawStars();
  }
  popMatrix();
  
  translate(width/2, height/2, 0);
  
  LocalDateTime now = LocalDateTime.now();
  String time = timeFormatter.format(now).toLowerCase();
  if(!time.equals(curTime)) {
    curTime = time;
    String date = dateFormatter.format(now);
    timeGraphic = createText(time, date, 3);
  }
  hint(DISABLE_DEPTH_TEST);
  image(timeGraphic, 0, 0);
  hint(ENABLE_DEPTH_TEST);
}

void drawStars() {
  for(int i = 0; i < stars.length; i += N) {
    if(stars[i+Z] >= stars[i+M]) randomizeStar(i);
      
    if(stars[i+Z] < fadeDistance)
      stroke(lerp(0, 255, stars[i+Z] / fadeDistance));
    else stroke(255);
      
    line(stars[i+X], stars[i+Y], stars[i+Z], stars[i+X], stars[i+Y], stars[i+Z] - lineLength);
    point(stars[i+X], stars[i+Y], stars[i+Z]);
    stars[i+Z] += starSpeed;
  }
}

void drawStarsAmbient() {
  for(int i = 0; i < stars.length; i += N) {
    float stroke = lerp(0, 255, stars[i+Z] / fadeDistance);
    if(stroke < 127)
      stroke(stroke);
    else stroke(127);
    
    point(stars[i+X], stars[i+Y], stars[i+Z]);
  }
}

void randomizeStar(int star) {
  float angle = random(TWO_PI);
  float length = randomGaussian() * 200 + 50;
  stars[star+X] = cos(angle) * length;
  stars[star+Y] = sin(angle) * length;
  stars[star+Z] = 0;
  stars[star+M] = 2000 - length * 2;
}

PGraphics createText(String time, String date, float strokeWeight) {  
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
  int strokeSamples = 20;

  PGraphics result = createGraphics(ceil(w * 1.1f), ceil(h * 1.1f));
  result.beginDraw();
  result.textAlign(CENTER, CENTER);
  result.translate(result.width/2, result.height/2);

  if(strokeWeight > 0) {
    result.fill(0);
    for(int i = 0; i < 20; ++i) {
      float piFrac = i * TWO_PI / strokeSamples;
      float cos = cos(piFrac) * strokeWeight;
      float sin = sin(piFrac) * strokeWeight;
      
      result.textSize(timeSize);
      result.text(time, cos, sin - h/4);
      result.textSize(dateSize);
      result.text(date, cos, sin + h/4);
    }
  }

  result.fill(255);
  result.textSize(timeSize);
  result.text(time, 0, -h/4);
  result.textSize(dateSize);
  result.text(date, 0,  h/4);
  
  result.endDraw();
  return result;
}
