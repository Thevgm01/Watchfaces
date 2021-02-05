import java.time.LocalDateTime;

// Seconds, Minutes, Hours
float[] angles;
float[] lastAngles;
float[] lengths;

float minScale;
float interactiveMinScale;
float ambientMinScale;

float interactiveSecondLength;

int smallestHandToDraw = 0;

int lastInteractiveMillis = 0;
int animationMillis = 1 * 1000;

PGraphics face;

void setup() {
  fullScreen(P2D);
  frameRate(30);
  colorMode(HSB);
  
  angles = new float[3];
  lastAngles = new float[3];
  lengths = new float[] { 75, 100, 50 };
  
  interactiveMinScale = 0.1f;
  ambientMinScale = 0.01f;
  
  interactiveSecondLength = 75;
  
  face = createGraphics(width, height);
  face.beginDraw();
  face.translate(width/2, height/2);
  for(int i = 0; i < 12 * 5; ++i) {
    float l = 20f;
    if(i % 5 == 0) l *= 2;
    face.stroke(0);
    face.strokeWeight(6);
    face.line(0, height/2f, 0, height/2f - l);
    face.stroke(255);
    face.strokeWeight(3);
    face.line(0, height/2f, 0, height/2f - l);
    face.rotate(TWO_PI / (12 * 5));
  }
  face.endDraw();
}

void draw() {    
  background(0);
  translate(width/2, height/2);

  stroke(255);
      
  // Defaults
  float baseScale = 0.8f;
  float scaleChange = 0.7f;
  float handScale = 0.8f;
  
  // Ambient-specific
  float colChange = 150;

  float frac = 1f;
  if(wearAmbient()) {
    smallestHandToDraw = 1;
    lastInteractiveMillis = 0;
    minScale = ambientMinScale;

    angles[1] = TWO_PI * minute() / 60f;
    angles[2] = (TWO_PI * hour() + angles[1]) / 12f;
    angles[0] = angles[1];
    
    lengths[0] = lengths[1];
  } else {
    smallestHandToDraw = 0;
    minScale = interactiveMinScale;
    colChange = 160;
    
    LocalDateTime now = LocalDateTime.now();
    float[] desiredAngles = new float[3];
    desiredAngles[0] = TWO_PI * (now.getSecond() + now.getNano() * 1e-9) / 60f;
    desiredAngles[1] = (TWO_PI * now.getMinute() + desiredAngles[0]) / 60f;
    desiredAngles[2] = (TWO_PI * now.getHour() + angles[1]) / 12f;
        
    if(lastInteractiveMillis == 0) {
      lastInteractiveMillis = millis();
      for(int i = 0; i < 3; ++i) lastAngles[i] = angles[i];
    }
    frac = (float)(millis() - lastInteractiveMillis) / animationMillis;
        
    if(frac >= 1) {
      for(int i = 0; i < 3; ++i) angles[i] = desiredAngles[i];
      lengths[0] = interactiveSecondLength;
    } else {
      float logisticFrac = logistic(frac, 1, 3);
  
      for(int i = 0; i < 3; ++i) {
        if(desiredAngles[i] < angles[i])
          desiredAngles[i] += TWO_PI;
          
        float diff = desiredAngles[i] - lastAngles[i];
        if(diff <= PI) angles[i] = lerp(lastAngles[i], desiredAngles[i], logisticFrac);
        else           angles[i] = lerp(lastAngles[i], desiredAngles[i] - TWO_PI, logisticFrac);
      }
      
      lengths[0] = lerp(lengths[1], interactiveSecondLength, logisticFrac);
    }
  }

  float col = pingPong(angles[1] * 60f / PI * 255f, 255);
  //blendMode(BLEND);
  strokeWeight(1);
  drawHands(baseScale, scaleChange, col, colChange);
  strokeWeight(10);
  drawHands(handScale, 0.0f, 0, 0);
  strokeWeight(5);
  drawHands(handScale, 0.0f, 255, 50);
  
  resetMatrix();
  //blendMode(EXCLUSION);
  image(face, 0, 0);
}

void drawHands(float scale, float scaleChange, float col, float colChange) {
  if(scale < minScale) return;
    
  for(int i = 2; i >= smallestHandToDraw; --i) {
    pushMatrix();
    rotate(angles[i]);
    translate(0, -lengths[i] * scale);
    drawHands(scale * scaleChange, scaleChange, col, colChange * scaleChange);
    //stroke(col % 255, 255, 255);
    stroke(0, 0, pingPong(col, 255));
    line(0, 0, 0, lengths[i] * scale);
    popMatrix();
    col += colChange;
  }
}

float logistic(float t, float max, float steep) {
  return pow(t, steep)/(pow(t, steep)+pow((1-t), steep)) * max;
}

float pingPong(float t, float max) {
  float L = 2 * max;
  float T = t % L;
  if(T >= 0 && T < max) return T;
  return L - T;
}
