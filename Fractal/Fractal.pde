import java.util.Stack;
import java.time.LocalDateTime;

// Seconds, Minutes, Hours
float[] angles;
float[] lastAngles;
float[] lengths;

float minScale;
float scaleChange;
float interactiveMinScale;
float ambientMinScale;

float interactiveSecondLength;

int smallestHandToDraw = 0;

int lastInteractiveMillis = 0;
int animationMillis = 1 * 1000;

PGraphics[] faces;

void setup() {
  //fullScreen(P2D);
  size(400, 400, P2D);
  frameRate(30);
  colorMode(HSB);
  
  angles = new float[3];
  lastAngles = new float[3];
  lengths = new float[] { 75, 100, 50 };
  
  interactiveMinScale = 0.05f;
  ambientMinScale = 0.05f;
  scaleChange = 0.7f;
  
  interactiveSecondLength = 75;
  
  createFaces();
}

void draw() {    
  background(0);
  translate(width/2, height/2);

  stroke(255);
      
  // Defaults
  float baseScale = 0.8f;
  float handScale = 0.8f;
  
  // Ambient-specific
  float colChange = 150;

  LocalDateTime now = LocalDateTime.now();
  float[] desiredAngles = new float[3];
  if(mousePressed) desiredAngles[0] = TWO_PI * (now.getSecond() + now.getNano() * 1e-9) / 60f;
  desiredAngles[1] = (TWO_PI * now.getMinute() + desiredAngles[0]) / 60f;
  desiredAngles[2] = (TWO_PI * now.getHour() + angles[1]) / 12f;

  float frac = 1f;
  if(!mousePressed) {
    
    smallestHandToDraw = 1;
    lastInteractiveMillis = 0;
    minScale = ambientMinScale;

    angles[0] = desiredAngles[1];
    angles[1] = desiredAngles[1];
    angles[2] = desiredAngles[2];
    lengths[0] = lengths[1];
    
  } else {
    
    smallestHandToDraw = 0;
    minScale = interactiveMinScale;
    //colChange = 160;
    
    if(lastInteractiveMillis == 0) {
      lastInteractiveMillis = millis();
      for(int hand = 0; hand < 3; ++hand) lastAngles[hand] = angles[hand];
    }
    frac = (float)(millis() - lastInteractiveMillis) / animationMillis;
        
    if(frac >= 1) {
      for(int hand = 0; hand < 3; ++hand) angles[hand] = desiredAngles[hand];
      lengths[0] = interactiveSecondLength;
    } else {
      float logisticFrac = logistic(frac, 1, 3);
  
      for(int hand = 0; hand < 3; ++hand) {
        if(desiredAngles[hand] < angles[hand])
          desiredAngles[hand] += TWO_PI;
          
        float diff = desiredAngles[hand] - lastAngles[hand];
        if(diff <= PI) angles[hand] = lerp(lastAngles[hand], desiredAngles[hand], logisticFrac);
        else           angles[hand] = lerp(lastAngles[hand], desiredAngles[hand] - TWO_PI, logisticFrac);
      }
      
      lengths[0] = lerp(lengths[1], interactiveSecondLength, logisticFrac);
    }
  }

  /*
  base = null;
  float col = pingPong(angles[1] * 60f / PI * 255f, 255);
  //blendMode(BLEND);
  stroke(255);
  strokeWeight(1);
  drawHands(baseScale, scaleChange, col, colChange);
  shape(fractal);
  //strokeWeight(10);
  //drawHands(handScale, 0.0f, 0, 0);
  //strokeWeight(5);
  //drawHands(handScale, 0.0f, 255, 50);
  */
    
  float col = pingPong(angles[1] * 60f / PI * 255f, 255);
  PShape fractal = createFractal(baseScale, scaleChange, col, colChange);
  shape(fractal);
  
  resetMatrix();
  //blendMode(EXCLUSION);
  if(mousePressed) image(faces[0], 0, 0);
  else image(faces[1], 0, 0);
}

PShape createFractal(float scale, float scaleChange, float col, float colChange) {
  PShape fractal = createShape();
  fractal.beginShape(LINES);
  fractal.stroke(255);
  fractal.noFill();
  
  FractalState fs = new FractalState();
  fs.s = scale;
  generateFractal(fractal, fs);

  fractal.endShape();  
  return fractal;
}

void generateFractal(PShape fractal, FractalState fs) {
  if(fs.s < minScale) return;
  
  for(int hand = smallestHandToDraw; hand < 3; ++hand) {
      
    fractal.vertex(fs.x, fs.y);
    FractalState nfs = new FractalState();
    
    float l = lengths[hand] * fs.s;
    nfs.a = fs.a + angles[hand];
    nfs.x = fs.x + sin(nfs.a) * l;
    nfs.y = fs.y - cos(nfs.a) * l;
    nfs.s = fs.s * scaleChange;

    fractal.vertex(nfs.x, nfs.y);
    generateFractal(fractal, nfs);
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

void createFaces() {
  faces = new PGraphics[2];
  for(int i = 0; i < 2; ++i) {
    faces[i] = createGraphics(width, height);
    faces[i].beginDraw();
    faces[i].translate(width/2, height/2);
    
    int notches = 12;
    if(i == 0) notches *= 5;
    
    for(int j = 0; j < notches; ++j) {
      float l = 20f;
      
      if(i == 1 || j % 5 == 0) l *= 2;
      faces[i].stroke(0);
      faces[i].strokeWeight(6);
      faces[i].line(0, height/2f, 0, height/2f - l);
      
      if(i == 0) faces[i].stroke(255);
      else faces[i].stroke(127);
      faces[i].strokeWeight(3);
      faces[i].line(0, height/2f, 0, height/2f - l);
      
      faces[i].rotate(TWO_PI/notches);
    }
    faces[i].endDraw();
  }
}

class FractalState {
  float a = 0, x = 0, y = 0, s = 0; 
}
