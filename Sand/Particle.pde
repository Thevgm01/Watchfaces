ArrayList<Particle> Particle;
int[] lastRadius;

void evaluateParticle() {
  for (Particle s : Particle) {
    if (s.falling) {
      s.yPos += s.yVel;
      s.yVel += 0.2f;
      s.y = round(s.yPos);

      if (height - s.y < lastRadius[s.x]) {
        s.falling = false;

        boolean searching = true;
        int radius = lastRadius[s.x];
        while (searching) {
          for (int i = 0; i <= radius; i++) {
            //check x + radius - i, y + i
            if (
              s.x + radius - i < width &&
              lastRadius[s.x + radius - i] <= i) { 
              lastRadius[s.x] = radius; 
              s.x += radius - i; 
              searching = false; 
              break;
            } else if (
              i != radius && 
              s.x - radius + i >= 0 &&
              lastRadius[s.x - radius + i] <= i) { 
                lastRadius[s.x] = radius; 
                s.x -= radius - i; 
                searching = false; 
                break;
            }
          }
          radius++;
        }

        lastRadius[s.x]++;
        s.y = height - lastRadius[s.x];
      }
    }
    set(s.x, s.y, color(s.ParticleHue, 255, 200));
  }
}

class Particle {
  public boolean falling = true;

  public int x, y;
  public float yPos, yVel;

  public float ParticleHue;

  public Particle(int x, int y, float h) {
    this.x = x;
    this.y = y;
    this.yPos = y;
    this.ParticleHue = h;
  }
}
