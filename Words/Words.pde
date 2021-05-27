import java.time.*;
import java.time.format.*;

DateTimeFormatter timeFormatter;
String timeNumbers;

String[] words = { 
  "one", "two", "three", "four", "five", "six", "seven",
  "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen",
  "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty",
  "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety" };
  
void setup() {
  timeFormatter = DateTimeFormatter.ofPattern("h m a");  
}

void draw() {
  LocalDateTime now = LocalDateTime.now();
  String newTimeNumbers = timeFormatter.format(now).toLowerCase();
  if(!newTimeNumbers.equals(timeNumbers)) {
    timeNumbers = newTimeNumbers;
    printWords(timeNumbersToWords(timeNumbers));
  }
}

ArrayList<String> timeNumbersToWords(String time) {
  ArrayList<String> result = new ArrayList<String>();
  String[] words = time.split(" ");
  result.addAll(numberToWords(words[0], false));
  result.addAll(numberToWords(words[1], true));
  result.add(words[2]);
  return result;
}

ArrayList<String> numberToWords(String num, boolean includeO) {
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
    result.add(words[(num / 10) + 17]);
    num = num % 10;
  }
  if(num > 0) {
    result.add(words[num - 1]);
  }
  return result;
}

void printWords(ArrayList<String> words) {
  for(String word: words) {
    print(word);
  }
  println();
}
