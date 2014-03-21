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
  //loadCorpus(dataPath + masterFile);
  /*
  for (int i = 5; i < 8; i++) {
   saveGrams(countGrams(i),i + "grams.txt");
  }
  */
  
  for (int i = 1; i < 8; i++) {
    countSaveGramsYears(i, i + "grams_series.txt");
  }
}

void draw() {
  background(0);
}

void countSaveGramsYears(int n, String url) {
  
  PrintWriter writer = createWriter(outPath + url);
  
  println("MASTER");
  //Get the master list
  loadCorpus(dataPath + masterFile);
  IntDict counter = countGrams(n);
  println("YEARS");
  //Get the other years
  IntDict[] yearCounters = new IntDict[endYear - startYear];
  for (int i = 0;i < yearCounters.length; i++) {
   int y = startYear + i;
   println(y);
   loadCorpus(dataPath + y + ".txt");
   yearCounters[i] = countGrams(n);
  }
  
  
  println("TIME SERIES");
  //Make time series for the most popular words
  for (String k:counter.keys()) {
     int c = counter.get(k);
     if (c > threshold) {
       String[] outs = new String[(endYear - startYear) + 2];
       outs[0] = k;
       outs[1] = c;
       for (int i = 2; i < outs.length; i++) {
        outs[i] = str(yearCounters[i - 2].get(k));
       }
       writer.println(join(outs, ","));
     }
     
   }
   
   writer.flush();
   writer.close();
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


