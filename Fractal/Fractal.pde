import java.util.Stack;
import java.time.LocalDateTime;

static final int AMBIENT = 0, INTERACTIVE = 1;
static final int MINUTE = 0, HOUR = 1;

TrigTable trig;

// Seconds, Minutes, Hours
float[] angles;
float[] lastAngles;
float[] lengths;

//ArrayList<FractalState> endpoints;

int lastInteractiveMillis = 1;
int animationMillis = 2 * 1000;

FractalShape fractal;
PGraphics[] faces;
float genFraction = 1f;

void setup() {
  //fullScreen(P2D);
  size(400, 400, P2D);
  frameRate(30);
  colorMode(HSB);

  TrigTable.initialize();
  
  angles = new float[2];
  lastAngles = new float[2];
  lengths = new float[] { 100, 50 };
    
  //endpoints = new ArrayList<FractalState>();
    
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
  if(mousePressed) secondAngle = TWO_PI * (now.getSecond() + now.getNano() * 1e-9) / 60f;
  desiredAngles[MINUTE] = (TWO_PI * now.getMinute() + secondAngle) / 60f;
  desiredAngles[HOUR] = (TWO_PI * now.getHour() + angles[1]) / 12f;


  float frac = 1f;
  if(!mousePressed) {
    
    if(lastInteractiveMillis > 0) {
      lastInteractiveMillis = 0;
      genFraction = fractal.getMaxIterations();
    }

    angles[MINUTE] = desiredAngles[MINUTE];
    angles[HOUR] = desiredAngles[HOUR];
    
  } else {
        
    if(lastInteractiveMillis == 0) {
      lastInteractiveMillis = millis();
      lastAngles[MINUTE] = angles[MINUTE] - TWO_PI;
      lastAngles[HOUR] = angles[HOUR] - TWO_PI;
    }
    frac = (float)(millis() - lastInteractiveMillis) / animationMillis;
        
    if(frac >= 1) {
      angles[MINUTE] = desiredAngles[MINUTE];
      angles[HOUR] = desiredAngles[HOUR];
      genFraction = genFraction * 0.995f + 0.1f;
    } else {
      float logisticFrac = logistic(frac, 1, 3);
  
      for(int hand = 0; hand < 2; ++hand) {
        //if(desiredAngles[hand] < angles[hand])
        //  desiredAngles[hand] += TWO_PI;
          
        angles[hand] = lerp(lastAngles[hand], desiredAngles[hand], logisticFrac);
      }
      genFraction = lerp(fractal.getMaxIterations(), 1, logisticFrac);
    }
    
  }
  
  strokeWeight(1);
  fractal.setVertexes();
  shape(fractal.get());
  
  drawHands();
  
  resetMatrix();
  //blendMode(EXCLUSION);
  if(mousePressed) image(faces[INTERACTIVE], 0, 0);
  else image(faces[AMBIENT], 0, 0);
}

void keyPressed() {  
  if(key == 'w') {
    fractal.resetVertexes();
    genFraction = 1f;
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
        strokeWeight(9);
      } else if(hand == HOUR) {
        switch(hand) {
          case MINUTE: stroke(255); break; 
          case HOUR: stroke(200); break; 
        }
        strokeWeight(3);
      }
      line(0, 0, 0, -lengths[hand]);
      popMatrix();
    }
  }
}

float logistic(float t, float max, float steep) {
  return pow(t, steep)/(pow(t, steep)+pow((1-t), steep)) * max;
}

float pingPong(float t, float max) {
  return max - abs(abs(t) % (2 * max) - max);
}

void createFaces() {
  faces = new PGraphics[2];
  for(int i = 0; i < 2; ++i) {
    faces[i] = createGraphics(width, height);
    faces[i].beginDraw();
    faces[i].translate(width/2, height/2);
    
    int notches = 12;
    if(i == INTERACTIVE) notches *= 5;
    
    for(int j = 0; j < notches; ++j) {
      float l = 20f;
      
      if(i == AMBIENT || j % 5 == 0) l *= 2;
      faces[i].stroke(0);
      faces[i].strokeWeight(6);
      faces[i].line(0, height/2f, 0, height/2f - l);
      
      if(i == INTERACTIVE) faces[i].stroke(255);
      else faces[i].stroke(127);
      faces[i].strokeWeight(3);
      faces[i].line(0, height/2f, 0, height/2f - l);
      
      faces[i].rotate(TWO_PI/notches);
    }
    faces[i].endDraw();
  }
}
