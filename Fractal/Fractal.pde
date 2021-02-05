import java.time.LocalDateTime;

// Seconds, Minutes, Hours
float[] angles;
float[] lengths;

float minScale = 0.033f;

float interactiveSecondAngle;
float interactiveSecondLength;

int smallestHandToDraw = 0;

int lastAmbientFrame = 0;
int animationFrames = 120;

boolean mode = false;

PGraphics face;

void setup() {
  size(400, 400, P2D);
  frameRate(30);
  colorMode(HSB);
  
  angles = new float[3];
  lengths = new float[] { 75, 100, 50 };
  
  interactiveSecondAngle = 0;
  interactiveSecondLength = 75;
  
  face = createGraphics(width, height);
  face.beginDraw();
  face.translate(width/2, height/2);
  face.stroke(255);
  face.strokeWeight(3);
  for(int i = 0; i < 12 * 5; ++i) {
    float l = 20f;
    if(i % 5 == 0) l *= 2;
    face.line(0, height/2f, 0, height/2f - l);
    face.rotate(TWO_PI / (12 * 5));
  }
  face.endDraw();
}

void draw() {  
  background(0);
  image(face, 0, 0);
  translate(width/2, height/2);

  stroke(255);
    
  LocalDateTime now = LocalDateTime.now();
  interactiveSecondAngle = TWO_PI * (now.getSecond() + now.getNano() * 1e-9) / 60f;
  angles[1] = (TWO_PI * now.getMinute() + interactiveSecondAngle) / 60f;
  angles[2] = (TWO_PI * now.getHour() + angles[1]) / 12f;
  
  float colChange = 0;
  float sc = 0.7f;
  if(mode) {
    minScale = 0.01f;
    smallestHandToDraw = 1;
    lastAmbientFrame = frameCount;

    angles[0] = angles[1];
    
    lengths[0] = lengths[1];
    colChange = 150;
    
    sc *= 0.995f;
  } else {
    minScale = 0.033f; 
    smallestHandToDraw = 0;
    
    float frac = (float)(frameCount - lastAmbientFrame) / animationFrames;
    if(frac >= 1) {
      angles[0] = interactiveSecondAngle;
      lengths[0] = interactiveSecondLength;
    } else {
      angles[0] += logistic(frac, interactiveSecondAngle - angles[0], 2);
      lengths[0] += logistic(frac, 75 - lengths[0], 2);
    }
    
    colChange = 100;
  }
    
  //float col = pingPong(angles[1], PI) * 255;
  //float col = angles[0] / TWO_PI * 255;
  blendMode(BLEND);
  strokeWeight(1);
  drawHands(0.8f, sc, 255, colChange);
  strokeWeight(10);
  drawHands(0.8f, 0.0f, 0, 0);
  strokeWeight(5);
  drawHands(0.8f, 0.0f, 255, 50);
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

void keyPressed() {
  mode = !mode;
}
