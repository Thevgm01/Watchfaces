static class TrigTable {
  private static final int trigTableSize = 4000;
  private static float[] sinTable, cosTable;
  
  public static void initialize() {
    int numEntries = (int)(TWO_PI * trigTableSize);
    sinTable = new float[numEntries + 1];
    cosTable = new float[numEntries + 1];
    for(int i = 0; i <= numEntries; ++i) {
      float frac = (float)i / trigTableSize;
      sinTable[i] = (float)Math.sin(frac);
      cosTable[i] = (float)Math.cos(frac);
    }
  }
  
  private static float getTrigTable(float[] table, float angle) {
    angle = angle % TWO_PI;
    while(angle < 0) angle += TWO_PI;
    return table[(int)(angle * trigTableSize)];
  }
  
  public static float sin(float angle) {
    return getTrigTable(sinTable, angle); 
  }
  
  public static float cos(float angle) {
    return getTrigTable(cosTable, angle); 
  }
}
