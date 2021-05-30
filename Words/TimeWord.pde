class TimeWord {
  private String text;
  private PFont font;
  private float height;
  private float width;
  private CapsStyle caps;
  
  public float getHeight() { return height; }
  public float getWidth() { return width; }
  
  public TimeWord(String text, PFont font) {
    this.text = text;
    this.font = font;
    this.height = font.getSize();
    caps = CapsStyle.NONE;
    calculateWidth();
  }
  
  public void draw(float x, float y) {
    textFont(font);
    textSize(height);
    text(text, x, y);
  }
  
  public void draw() {
    draw(0, 0); 
  }
  
  public void setText(String text) {
    if(!this.text.equals(text)) {
      this.text = text;
      calculateWidth();
    }
  }
  
  public void setFont(PFont font) {
    if(this.font != font) {
      this.font = font;
      calculateWidth();
    }
  }
  
  public void setHeight(float height) {
    if(this.height != height) {
      this.height = height;
      calculateWidth();
    }
  }
  
  public void setCaps(CapsStyle caps) {
    if(this.caps != caps) {
      this.caps = caps;
      switch(caps) {
        case NONE:
          text = text.toLowerCase();
          //break;
        case FIRST:
          text = text.substring(0, 1).toUpperCase() + text.substring(1);
          break;
        case ALL:
          text = text.toUpperCase();
          break;
      }
      calculateWidth();
    }
  }
  
  private void calculateWidth() {
    textFont(font);
    textSize(height);
    width = textWidth(text);
  }
}
