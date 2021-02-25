import java.util.Stack;
import java.time.LocalDateTime;

static final int AMBIENT = 0, INTERACTIVE = 1;

TrigTable trig;

// Seconds, Minutes, Hours
float[] angles;
float[] lastAngles;
float[] lengths;

//ArrayList<FractalState> endpoints;

float interactiveSecondLength;

int smallestHandToDraw = 0;

int lastInteractiveMillis = 0;
int animationMillis = 1 * 1000;

FractalShape fractal;
PGraphics[] faces;
float genFraction = 1f;

void setup() {
  //fullScreen(P2D);
  size(400, 400, P2D);
  frameRate(30);
  colorMode(HSB);

  TrigTable.initialize();
  
  angles = new float[3];
  lastAngles = new float[3];
  lengths = new float[] { 75, 100, 50 };
    
  //endpoints = new ArrayList<FractalState>();
  
  interactiveSecondLength = 75;
  
  createFaces();
}

void draw() {    
  
  //scaleChange = sin(frameCount / 10f) * 0.02f + 0.7f;
  
  background(0);
  translate(width/2, height/2);

  LocalDateTime now = LocalDateTime.now();
  float[] desiredAngles = new float[3];
  if(mousePressed) desiredAngles[0] = TWO_PI * (now.getSecond() + now.getNano() * 1e-9) / 60f;
  desiredAngles[1] = (TWO_PI * now.getMinute() + desiredAngles[0]) / 60f;
  desiredAngles[2] = (TWO_PI * now.getHour() + angles[1]) / 12f;

  genFraction = genFraction * 0.995f + 0.1f;

  float frac = 1f;
  if(!mousePressed) {
    
    smallestHandToDraw = 1;
    lastInteractiveMillis = 0;

    angles[0] = desiredAngles[1];
    angles[1] = desiredAngles[1];
    angles[2] = desiredAngles[2];
    lengths[0] = lengths[1];
    
  } else {
    
    smallestHandToDraw = 1;
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
  
  strokeWeight(1);
  drawFractal();
  drawHands();
  
  resetMatrix();
  //blendMode(EXCLUSION);
  if(mousePressed) image(faces[INTERACTIVE], 0, 0);
  else image(faces[AMBIENT], 0, 0);
}

boolean toggle = true;
void keyPressed() {
  if(key == ' ') toggle = !toggle;
  
  if(key == 'w') {
    fractal.resetVertexes();
  }
  
  if(key == 'a') { fractal.changeIterations(-1); }
  else if(key == 'd') { fractal.changeIterations(1); }
  
  //if(key == 'q') println(numVertexes + " / " + frameRate);
}

void drawHands() {
  for(int i = 0; i < 2; ++i) {
    for(int hand = 2; hand >= smallestHandToDraw; --hand) {
      pushMatrix();
      rotate(angles[hand]);
      if(i == 0) {
        stroke(0);
        strokeWeight(9);
      } else {
        switch(hand) {
          case 0: stroke(255); break; 
          case 1: stroke(200); break; 
          case 2: stroke(145); break; 
        }
        strokeWeight(3);
      }
      line(0, 0, 0, -lengths[hand]);
      popMatrix();
    }
  }
}

void drawFractal() {  
  if(fractal == null) {
    fractal = new FractalShape();
  }
  
  fractal.setVertexes();
  shape(fractal.get());
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
