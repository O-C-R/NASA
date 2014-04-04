import rita.render.*;
//import rita.json.*;
import rita.support.*;
import rita.*;

/*

 NGram counter
 jer@o-c-r.org
 
 */

//This version uses a stop list

int startYear = 1961;
int endYear = 2009;
String dataPath = "../../Data/MasterFlatText/";
String outPath = "../../Data/networks/";
String masterFile = "allYears.txt";
String[] sentences;
int threshold = 500;
int wc;

HashMap<String, String> stopList = new HashMap();

ArrayList<Word> words = new ArrayList();
HashMap<String, Word> wordMap = new HashMap();
ArrayList<WordEdge> allEdges = new ArrayList();

void setup() {
  size(1280, 720);

  loadStopList("../../Data/stoplist.txt");
  //loadCorpus(dataPath + masterFile);

  for (int i = 1; i < 4; i++) {
    //saveGrams(countGrams(i), i + "grams.txt");
  }

  for (int i = 1; i < 4; i++) {
    //countSaveGramsYears(i, i + "year_grams.txt");
  }

  generateNetwork("moon");

  //countSavePosYears("scared", "_series.txt");
  //countSavePosYears("landing", "_series.txt");
  //countSavePosYears("moon", "_series.txt");
  //countSavePosYears("the moon", "_series.txt");
  //countSavePosYears("the lunar landings", "_series.txt");
  /*
  countSavePosYears("lunar landing", "_series.txt");
   countSavePosYears("the lunar landing", "_series.txt");
   countSavePosYears("lunar landing gear", "_series.txt");
   countSavePosYears("main sounding systems", "_series.txt");
   countSavePosYears("positioning systems", "_series.txt");
   countSavePosYears("positioning system", "_series.txt");
   countSavePosYears("two years", "_series.txt");
   countSavePosYears("two crazy years", "_series.txt");
   countSavePosYears("an amazing thing", "_series.txt");
   countSavePosYears("sophisticated instruments", "_series.txt");
   //*/
}

void draw() {
  background(0);
}

void loadStopList(String url) {
  String[] stops = loadStrings(url);
  for (String s:stops) {
    stopList.put(s, s);
  }
}

//Returns true if the word is safe
boolean checkStop(String s) {
  String[] words = RiTa.tokenize(RiTa.stripPunctuation(s.toLowerCase()));
  int c = 0;
  for (String w:words) {
    if (stopList.containsKey(w)) c++;
  }
  return((float) c / words.length < 0.5 && !stopList.containsKey(words[words.length - 1]));
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
      outs[1] = nf(float(c) / wc, 1, 6);
      for (int i = 2; i < outs.length; i++) {
        outs[i] = nf((float) yearCounters[i - 2].get(k) / wc, 1, 6);
      }
      writer.println(join(outs, ","));
    }
  }

  writer.flush();
  writer.close();
}

void generateNetwork(String pos) {
  String[] matchList = RiTa.getPosTags(pos);
  String match = join(matchList, " ");

  //Get the list of matches
  loadCorpus(dataPath + masterFile);
  IntDict counter = countPos(pos);

  //For each, create a Word object
  for (String ws:counter.keys()) {
    if (counter.get(ws) > 10) {
      Word w = new Word(ws);
      w.size = counter.get(ws);
      words.add(w); 
      wordMap.put(ws, w);
    }
  }


  int lc = 0;
  //Go through the sentences and build the links
  for (String s:sentences) {
    String[] words = RiTa.tokenize(RiTa.stripPunctuation(s.toLowerCase()));
    for (String w:words) {
      if (wordMap.containsKey(w)) {
        Word wo1 = wordMap.get(w);
        for (String w2:words) {
          if (wordMap.containsKey(w2)) {
            Word wo2 = wordMap.get(w2);
            if (!w.equals(w2) && w.length() > 2 && w2.length() > 2 && !wo2.edgeMap.containsKey(wo1)) {
              link(wo1, wo2);
              lc++;
            }
          }
        }
      }
    }
  }


  //Clean out small edges
  ArrayList<WordEdge> tempEdges = new ArrayList();
  for (WordEdge we:allEdges) {
    if (we.weight > 50 && checkStop(we.w1.word) && checkStop(we.w2.word)) {
      tempEdges.add(we);
    }
  }
  allEdges = tempEdges;

  java.util.Collections.sort(allEdges);
  java.util.Collections.reverse(allEdges);

  //Write the JSON
  JSONObject jo = new JSONObject();

  ArrayList<Word> usedWords = new ArrayList();

  JSONArray edges = new JSONArray();
  for (int i = 0; i < allEdges.size(); i++) {
    WordEdge we = allEdges.get(i);
    JSONObject edge = new JSONObject();
    edge.setString("id", "e" + i);
    edge.setString("source", we.w1.word);
    edge.setString("target", we.w2.word);
    edge.setFloat("weight", sqrt(we.weight) * 0.05);
    edges.setJSONObject(i, edge);
    
    if(!usedWords.contains(wordMap.get(we.w1.word))) usedWords.add(we.w1);
    if(!usedWords.contains(wordMap.get(we.w2.word))) usedWords.add(we.w2);
  }
  jo.setJSONArray("edges", edges);


  JSONArray nodes = new JSONArray();
  for (int i = 0; i < usedWords.size(); i++) {
    Word w = usedWords.get(i);
    JSONObject node = new JSONObject();
    node.setString("id", w.word);
    node.setString("label", w.word);
    node.setFloat("x", random(10));
    node.setFloat("y", random(10));
    node.setFloat("size",sqrt(w.size) + 30);
    nodes.setJSONObject(i, node);
  }
  jo.setJSONArray("nodes", nodes);



  saveJSONObject(jo, outPath + match + ".json");
}

void link(Word w1, Word w2) {
  w1.addEdge(w2);
}

void countSavePosYears(String pos, String url) {

  String[] matchList = RiTa.getPosTags(pos);
  String match = join(matchList, " ");

  PrintWriter writer = createWriter(outPath + match + url);

  println("MASTER");
  //Get the master list
  loadCorpus(dataPath + masterFile);
  IntDict counter = countPos(pos);
  println("YEARS");
  //Get the other years
  IntDict[] yearCounters = new IntDict[endYear - startYear];
  for (int i = 0;i < yearCounters.length; i++) {
    int y = startYear + i;
    println(y);
    loadCorpus(dataPath + y + ".txt");
    yearCounters[i] = countPos(pos);
  }


  println("TIME SERIES");
  //Make time series for the most popular words
  for (String k:counter.keys()) {
    int c = counter.get(k);
    if (c > threshold) {
      String[] outs = new String[(endYear - startYear) + 2];
      outs[0] = k;
      outs[1] = str(c);
      for (int i = 2; i < outs.length; i++) {
        outs[i] = nf((float) yearCounters[i - 2].get(k) / ((float) wc / matchList.length), 1, 6);//str(yearCounters[i - 2].get(k));
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
      writer.println(k + ":" + nf(float(c) / wc, 1, 6));
    }
  }
  writer.flush();
  writer.close();
}


void loadCorpus(String url) {
  String all = join(loadStrings(url), " ");
  wc = RiTa.getWordCount(all);
  sentences = RiTa.splitSentences(all);
}

IntDict countPos(String pos) {

  println("COUNTING " + pos + " POS");
  IntDict counter = new IntDict();

  //Get the Pos string
  String[] matchList = RiTa.getPosTags(pos);
  String match = join(matchList, " ");
  ArrayList<String[]> candidates = new ArrayList();

  for (int i = 0; i < sentences.length; i++) {
    String s = sentences[i].toLowerCase();
    String p = join(RiTa.getPosTags(s), " ");
    if (p.indexOf(match) != -1) {
      String[] sa = {
        s, p
      };
      candidates.add(sa);
    }
  }

  //Get the pieces
  HashMap<String, String> wordMap = new HashMap();
  ArrayList<String> returnSegments = new ArrayList();
  for (String[] s:candidates) {
    String ss = RiTa.stripPunctuation(s[0]);
    String[] words = RiTa.tokenize(s[0]);
    String[] spos = s[1].split(" ");

    for (int i = 0; i < words.length - matchList.length + 1; i++) {
      String sss = join(java.util.Arrays.copyOfRange(spos, i, i + matchList.length), " ");

      if (sss.equals(match)) {

        String seg = join(java.util.Arrays.copyOfRange(words, i, i + matchList.length), " ");
        counter.increment(seg);
      };
    }
  }

  counter.sortValuesReverse();
  return(counter);
}

IntDict countGrams(int n) {
  println("COUNTING " + n + "grams");
  IntDict counter = new IntDict();
  for (String s:sentences) {
    String[] words = RiTa.tokenize(RiTa.stripPunctuation(s.toLowerCase()));
    for (int i = 0; i <= words.length - n; i++) {
      String ngram = "";
      for (int j = 0; j < n; j++) {
        ngram += words[i + j];
        if (j != n) ngram += " ";
      }

      if (checkStop(ngram)) counter.increment(ngram);
    }
  }

  counter.sortValuesReverse();
  return(counter);
}

