class TimeWords {
  private ArrayList<TimeWord> timeWords;
  private ArrayList<Float> lineHeights;
  private ArrayList<Float> lineWidths;
  private float totalHeight;
  private float totalWidth;
  
  private PFont defaultFont;
  private float defaultHeight = 30;
  
  public TimeWords() {
    timeWords = new ArrayList<TimeWord>();
    lineHeights = new ArrayList<Float>();
    lineWidths = new ArrayList<Float>();
    defaultFont = createFont("Arial", defaultHeight);
  }
  
  public void setWords(ArrayList<String> words) {
    for(int i = 0; i < words.size(); ++i) {
      if(timeWords.size() <= i) {
        timeWords.add(new TimeWord(words.get(i), defaultFont)); 
      } else {
        timeWords.get(i).setText(words.get(i)); 
      }
    }
  }
  
  private void calculateLineSizes() {
    lineHeights.clear();
    lineWidths.clear();
    float curLineWidth = 0;
    float maxLineWidth = width/4;
    for(TimeWord tw: timeWords) {    
      if(curLineWidth > 0 && curLineWidth + tw.getWidth() >= maxLineWidth) {
        lineHeights.add(tw.getHeight());
        lineWidths.add(curLineWidth);
        curLineWidth = tw.getWidth();
      } else {
        if(tw.getHeight() > lineHeights.get(lineWidths.size())) {
          lineHeights.set(lineWidths.size(), tw.getHeight()); 
        }
        curLineWidth += tw.getWidth();
      }
    }
  }
  
  public void draw() {
    for(TimeWord tw: timeWords) {
      tw.draw();
      translate(0, defaultHeight);
    }
  }
}
