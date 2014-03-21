import rita.render.*;
import rita.json.*;
import rita.support.*;
import rita.*;

/*

NGram counter
jer@o-c-r.org

*/

int startYear = 1961;
int endYear = 1977;
String dataPath = "../../Data/PDFsAsText/textEdited/";
String outPath = "../../Data/grams/";
String masterFile = "allYears.txt";
String[] sentences;
int threshold = 3;

void setup() {
  size(1280,720);
  loadCorpus(dataPath + masterFile);
  for (int i = 1; i < 5; i++) {
  saveGrams(countGrams(i),i + "grams.txt");
  }
}

void draw() {
  background(0);
}

void saveGrams(IntDict counter, String url) {
   PrintWriter writer = createWriter(outPath + url);
   for (String k:counter.keys()) {
     int c = counter.get(k);
     if (c > threshold) {
      writer.println(k + ":" + c); 
     }
   }
   writer.flush();
   writer.close();
}


void loadCorpus(String url) {
  String all = join(loadStrings(url)," ");
  sentences = RiTa.splitSentences(all);
}

IntDict countGrams(int n) {
  println("COUNTING " + n + "grams");
  IntDict counter = new IntDict();
  for (String s:sentences) {
   String[] words = RiTa.tokenize(RiTa.stripPunctuation(s.toLowerCase()));
   for (int i = 0; i <= words.length - n; i++) {
     String ngram = "";
     for(int j = 0; j < n; j++) {
       ngram += words[i + j];
       if (j != n) ngram += " ";
     }
    
     counter.increment(ngram);
   }
  
  }
  
   counter.sortValuesReverse();
   return(counter);
}


