String[] words = { 
  "one", "two", "three", "four", "five", "six", "seven",
  "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen",
  "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty",
  "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety" };
  
void setup() {
  for(int i = 0; i < 100; ++i) {
    for(String s: numberToWords(i, true)) {
      print(s);
    }
    println();
  }
}

void draw() {
  
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
