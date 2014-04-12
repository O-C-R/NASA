import rita.render.*;
import rita.json.*;
import rita.support.*;
import rita.*;

/*

 NGram counter
 jer@o-c-r.org
 
 */

//This version uses a stop list

int startYear = 1961;
int endYear = 2009;
String dataPath = "../../Data/BucketText/";
String outPath = "../../Data/BucketGramsAll/";
String subBucket = "/uniqueBucketStories/";
String xmlPath = "../../Data/EntityXML/";
String masterFile = "allYears.txt";
String[] sentences;
int threshold = 0;
int wc;

String buckets = "administrative,astronaut,mars,moon,people,politics,research_and_development,rockets,russia,satellites,space_shuttle,spacecraft,us";
String currentBucket = "rockets";

HashMap<String, String> stopList = new HashMap();

void setup() {
  size(1280, 1280);

  //loadStopList("../../Data/stoplist.txt");
  //loadCorpus(dataPath + masterFile);

  for (int i = 1; i < 4; i++) {
    //saveGrams(countGrams(i), i + "grams.txt");
  }

  for (int i = 1; i < 4; i++) {
    //countSaveGramsYears(i, i + "year_grams.txt");
  }

  String[] bucketList = buckets.split(",");

  for (String s:bucketList) {
    currentBucket = s;
    /*
    countSavePosYears("landing", "_series.txt");
     countSavePosYears("moon", "_series.txt");
     countSavePosYears("the moon", "_series.txt");
     countSavePosYears("the lunar landings", "_series.txt");
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
     */
    countSaveEntities("Person");
    countSaveEntities("Country");
    countSaveEntities("Facility");
    countSaveEntities("FieldTerminology");
  }
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

  PrintWriter writer = createWriter(outPath  + url);

  println("MASTER");
  //Get the master list
  println(dataPath + currentBucket + subBucket + masterFile);
  loadCorpus(dataPath + currentBucket + subBucket + masterFile);
  IntDict counter = countGrams(n);
  println("YEARS");
  //Get the other years
  IntDict[] yearCounters = new IntDict[endYear - startYear];
  for (int i = 0;i < yearCounters.length; i++) {
    int y = startYear + i;
    println(y);
    loadCorpus(dataPath + currentBucket + subBucket + y + ".txt");
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

void countSaveEntities(String eType) {

  HashMap<String, Entity> entityMap = new HashMap();
  ArrayList<Entity> allEntities = new ArrayList();
  for (int y = startYear; y <= endYear; y++) {
    XML eXML = loadXML(xmlPath + currentBucket + "/" + y + ".xml");
    XML[] entities = eXML.getChildren("entities/entity");
    for (XML entity:entities) {
      String type = entity.getChild("type").getContent();
      if (type.equals(eType)) {
        String label = null;
        //Is it disambiguated?
        if (entity.getChild("disambiguated") != null) {
          label = entity.getChild("disambiguated/name").getContent();
        } 
        else {
          label = entity.getChild("text").getContent();
        };
        int count = int(entity.getChild("count").getContent());
        
        if (label.split(" ").length > 1) {
        if (!entityMap.containsKey(label)) {
          Entity e = new Entity().init();
          e.term = label;
          e.counts[y - startYear] = count;
          entityMap.put(label, e);
          allEntities.add(e);
          e.count+= count;
        } 
        else {
          Entity e = entityMap.get(label);
          e.counts[y - startYear] = count;
          e.count += count;
        }
        }
      }
    }
    
  }
  java.util.Collections.sort(allEntities);
  java.util.Collections.reverse(allEntities);
  
  PrintWriter writer = createWriter(outPath + "/" + currentBucket + "/" + eType + ".txt");
  
  for (Entity e:allEntities) {
    int c = e.count;
    if (c > threshold) {
      String[] outs = new String[(endYear - startYear) + 1];
      outs[0] = e.term;
      outs[1] = str(c);
      for (int i = 2; i < outs.length; i++) {
        outs[i] = str(e.counts[i]);
      }
      writer.println(join(outs, ","));
    }
  }

  writer.flush();
  writer.close();
  
}

void countSavePosYears(String pos, String url) {

  String[] matchList = RiTa.getPosTags(pos);
  String match = join(matchList, " ");

  PrintWriter writer = createWriter(outPath + "/" + currentBucket + "/" + match + url);

  println("MASTER");
  //Get the master list
  loadCorpus(dataPath + currentBucket + "/" + subBucket + masterFile);
  IntDict counter = countPos(pos);
  println("YEARS");
  //Get the other years
  IntDict[] yearCounters = new IntDict[endYear - startYear];
  for (int i = 0;i < yearCounters.length; i++) {
    int y = startYear + i;
    println(y);
    loadCorpus(dataPath + currentBucket + subBucket + y + ".txt");
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

