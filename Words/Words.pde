import java.time.*;
import java.time.format.*;

DateTimeFormatter timeFormatter;
String timeNumbers;
TimeWords timeWords;

static enum CapsStyle { NONE, FIRST, ALL };

// First 2 chars: hour
// Second 2 chars: minute
// Last char: meridian
String displayPattern = "aBac";

String[] words = { 
  "zero", "one", "two", "three", "four", "five", "six", "seven",
  "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen",
  "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty",
  "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety" };
  
void setup() {
  size(400, 400);
  timeFormatter = DateTimeFormatter.ofPattern("h m a");
  timeWords = new TimeWords();
  textAlign(CENTER, CENTER);  
}

void draw() {
  LocalDateTime now = LocalDateTime.now();
  String newTimeNumbers = timeFormatter.format(now);
  if(!newTimeNumbers.equals(timeNumbers)) {
    timeNumbers = newTimeNumbers;
    ArrayList<String> timeWordTexts = timeNumbersToWords(timeNumbers);
    timeWords.setWords(timeWordTexts);
  }
  
  background(0);
  translate(width/2, height/2);
  
  timeWords.draw();
}

ArrayList<String> timeNumbersToWords(String time) {
  ArrayList<String> result = new ArrayList<String>();
  String[] words = time.split(" ");
  result.addAll(numberStringToWords(words[0], false));
  result.addAll(numberStringToWords(words[1], true));
  result.add(words[2]);
  return result;
}

ArrayList<String> numberStringToWords(String num, boolean includeO) {
  try {
    return numberToWords(Integer.parseInt(num), includeO); 
  } catch(Exception e) {
    println("Parse error: \"" + num + "\" could not be parsed to an int");
    return null; 
  }
}

ArrayList<String> numberToWords(int num, boolean includeO) {
  ArrayList<String> result = new ArrayList<String>();
  if(includeO && num < 10) {
    result.add("o'");
    if(num == 0) {
      result.add("clock"); 
    }
  }
  else if(num >= 20) {
    result.add(words[(num / 10) + 18]);
    num = num % 10;
  }
  if(num > 0) {
    result.add(words[num]);
  }
  return result;
}

void printWords(ArrayList<String> words, String pattern) {
  int patternIndex = 0;
  for(String word: words) {
    char c = pattern.charAt(patternIndex);
    patternIndex = (patternIndex + 1) % pattern.length();
    if(c >= 'A' && c <= 'Z') {
      word = word.toUpperCase();
      c += 'a' - 'A';
    }
    print(word);
  }
  println();
}
