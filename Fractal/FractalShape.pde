class FractalShape {
  
  private class FractalState {
    float a = 0, x = 0, y = 0, s = 0;
    int n = 0; 
  }
  
  private PShape fractal;
  public PShape get() { return fractal; }
  
  private float scaleChange = 0.7f;
  private int maxIterations = 10;
  public int getMaxIterations() { return maxIterations; }
  private int counter = 0;
  
  public FractalShape() {
    createFractal(); 
  }
  
  private void createFractal() {
    fractal = createShape();
    fractal.beginShape(LINES);
    fractal.strokeWeight(1);
    for(int i = 0; i < calculateBranches(2, maxIterations); ++i) {
      fractal.stroke(pingPong(i / 10f, 200) + 56);
      fractal.vertex(0, 0);
      fractal.vertex(0, 0);
    }
    fractal.endShape(); 
  }
  
  public void resetVertexes() {
    for(int i = 0; i < fractal.getVertexCount(); ++i)
      fractal.setVertex(i, 0, 0);
  }
  
  public void changeIterations(int amount) {
    maxIterations += amount;
    if(maxIterations < 0) maxIterations = 0;
    createFractal();
  }
  
  public void setVertexes() {
    //endpoints.clear();
    
    counter = 0;
    FractalState fs = new FractalState();
    fs.a = HALF_PI;
    fs.s = 1f;
    setVertexes(fs);
    
    //println(counter + "\t" + fractal.getVertexCount());
  }
  
  private void setVertexes(FractalState fs) {
    if(fs.n > maxIterations) {
      //endpoints.add(fs);
      return;
    }
    
    if(fs.n < genFraction && fs.n > genFraction - 1) {
      fs.s *= genFraction - (int)genFraction;
    } else if(fs.n >= genFraction) {
      fs.s = 0; 
    }
    
    for(int hand = 0; hand < 2; ++hand) {
      
      FractalState nfs = new FractalState();
      
      float l = lengths[hand] * fs.s;
      nfs.a = fs.a + angles[hand];
      nfs.x = fs.x - TrigTable.cos(nfs.a) * l;
      nfs.y = fs.y - TrigTable.sin(nfs.a) * l;
      nfs.s = fs.s * scaleChange;
      nfs.n = fs.n + 1;
        
      setVertexes(nfs);
        
      fractal.setVertex(counter++, fs.x, fs.y);
      fractal.setVertex(counter++, nfs.x, nfs.y);
    }
  }
  
  private int calculateBranches(int splits, int depth) { 
    int count = splits;
    while(depth-- >= 1)
      count = (count + 1) * splits;
    return count;
  }
  
  /*
  numVertexes = 0;
  numVertexes += fractal.getVertexCount();
  
  if(toggle) return;
  fractal.setStrokeWeight(1f/endpoints.get(0).s);
  for(int i = 0; i < endpoints.size(); ++i) {
    FractalState endpoint = endpoints.get(i);
    pushMatrix();
    translate(endpoint.x, endpoint.y);
    rotate(endpoint.a);
    scale(endpoint.s);
    shape(fractal);
    popMatrix();
    
    numVertexes += fractal.getVertexCount();
  }
  */
}
