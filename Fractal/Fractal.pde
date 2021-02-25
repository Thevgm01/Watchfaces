import java.util.Stack;
import java.time.LocalDateTime;

static final int AMBIENT = 0, INTERACTIVE = 1;
static final int MINUTE = 0, HOUR = 1;

TrigTable trig;

// Seconds, Minutes, Hours
float[] angles;
float[] lastAngles;
float[] lengths;
float thickness;

//ArrayList<FractalState> endpoints;

int lastInteractiveMillis = 1;
int[] animationMillis;
int baseAnimationMillis = 1000;

FractalShape fractal;
PGraphics[] faces;
int faceRotationDirection = 1;
float genFraction = 0f;

void setup() {
  fullScreen(P2D);
  //size(800, 800, P2D);
  frameRate(30);
  colorMode(HSB);
  imageMode(CENTER);

  TrigTable.initialize();
  
  angles = new float[2];
  lastAngles = new float[2];
  lengths = new float[] { width/4, width/8 };
  thickness = 2 * displayDensity;
  //thickness = width * 0.01f;
  
  animationMillis = new int[2];
        
  fractal = new FractalShape();
  createFaces();
}

void draw() {    
  
  //scaleChange = sin(frameCount / 10f) * 0.02f + 0.7f;
  
  background(0);
  translate(width/2, height/2);

  LocalDateTime now = LocalDateTime.now();
  float[] desiredAngles = new float[2];
  float secondAngle = 0;
  if(wearInteractive())
  //if(mousePressed);
    secondAngle = TWO_PI * (now.getSecond() + now.getNano() * 1e-9) / 60f;
  desiredAngles[MINUTE] = (TWO_PI * now.getMinute() + secondAngle) / 60f;
  desiredAngles[HOUR] = (TWO_PI * now.getHour() + angles[MINUTE]) / 12f;

  float smallestFrac = 1f;
  float smallestLogisticFrac = 1f;

  if(wearAmbient()) {
  //if(!mousePressed) {
    
    if(lastInteractiveMillis > 0) {
      lastInteractiveMillis = 0;
    }

    angles[MINUTE] = desiredAngles[MINUTE];
    angles[HOUR] = desiredAngles[HOUR];
    
    genFraction = fractal.getMaxIterations();
    
  } else {
        
    if(lastInteractiveMillis == 0) {
      lastInteractiveMillis = millis();
      faceRotationDirection *= -1;

      do {
        animationMillis[MINUTE] = (int)random(baseAnimationMillis) + baseAnimationMillis;
        animationMillis[HOUR] = (int)random(baseAnimationMillis) + baseAnimationMillis;
      } while(animationMillis[MINUTE] + animationMillis[HOUR] < baseAnimationMillis * 3);
      
      lastAngles[MINUTE] = angles[MINUTE] - TWO_PI;
      lastAngles[HOUR] = angles[HOUR] - TWO_PI;
    }
    
    for(int hand = 0; hand < 2; ++hand) {
      float frac = (float)(millis() - lastInteractiveMillis) / animationMillis[hand];
      if(frac < smallestFrac)
        smallestFrac = frac;
      if(frac >= 1) {
        angles[hand] = desiredAngles[hand];
      } else {
        float logisticFrac = logistic(frac, 1, 3);
        angles[hand] = lerp(lastAngles[hand], desiredAngles[hand], logisticFrac);
      }
    }
    
    if(smallestFrac >= 1) {
      genFraction = genFraction * 0.995f + 0.1f;
    } else {
      smallestLogisticFrac = logistic(smallestFrac, 1, 3);
      genFraction = lerp(fractal.getMaxIterations(), 0, smallestLogisticFrac);
    }
    
  }
  
  strokeWeight(1);
  fractal.setVertexes();
  shape(fractal.get());
  
  drawHands();
  
  drawFaces();
}

void keyPressed() {  
  if(key == 'w') {
    fractal.resetVertexes();
    genFraction = 0f;
  }
  if(key == 'a') fractal.changeIterations(-1);
  else if(key == 'd') fractal.changeIterations(1);
}

void drawHands() {
  for(int i = 0; i < 2; ++i) {
    for(int hand = 1; hand >= 0; --hand) {
      pushMatrix();
      rotate(angles[hand]);
      if(i == 0) {
        stroke(0);
        strokeWeight(thickness * 3);
      } else {
        /*
        switch(hand) {
          case MINUTE: stroke(255); break; 
          case HOUR: stroke(200); break; 
        }*/
        stroke(255);
        strokeWeight(thickness);
      }
      line(0, 0, 0, -lengths[hand]);
      popMatrix();
    }
  }
}

void drawFaces() {
  resetMatrix();
  //blendMode(EXCLUSION);
  translate(width/2, height/2);
  //rotate(smallestLogisticFrac * HALF_PI / 3 * faceRotationDirection);
  
  if(wearAmbient())
  //if(!mousePressed)
    image(faces[AMBIENT], 0, 0);
  else
    image(faces[INTERACTIVE], 0, 0);
}

float logistic(float t, float max, float steep) {
  return pow(t, steep)/(pow(t, steep)+pow((1-t), steep)) * max;
}

float pingPong(float t, float max) {
  return max - abs(abs(t) % (2 * max) - max);
}

void createFaces() {
  faces = new PGraphics[2];
  float tickLength = 5 * displayDensity;
  //float tickLength = 20f;
  float offset = height/2 - (lengths[0] - tickLength * 2 - thickness) * 0.8f;

  for(int i = 0; i < 2; ++i) {
    faces[i] = createGraphics(width, height);
    faces[i].beginDraw();
    faces[i].translate(width/2, height/2);
    
    int notches = 12;
    if(i == INTERACTIVE) notches *= 5;
    
    for(int j = 0; j < notches; ++j) {
      float l = tickLength;
      
      if(i == AMBIENT || j % 5 == 0) l = l * 2 + thickness;
      faces[i].stroke(0);
      faces[i].strokeWeight(thickness * 2);
      faces[i].line(0, offset, 0, offset - l); // Background
      
      if(i == INTERACTIVE) faces[i].stroke(255);
      else faces[i].stroke(127);
      faces[i].strokeWeight(thickness);
      faces[i].line(0, offset, 0, offset - l); // Main tick
      
      faces[i].rotate(TWO_PI/notches);
    }
    faces[i].endDraw();
  }
}
