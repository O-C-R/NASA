class Bucket {
  String phrase = "";
  ArrayList<String> phrases = new ArrayList<String>();
  HashMap<String, ArrayList<HistoryStory>> storyTracker = new HashMap<String, ArrayList<HistoryStory>>();
  int uniqueStoryCount = 0;

  ArrayList<HistoryStory> uniqueStories = new ArrayList<HistoryStory>(); // unique stories in this bucket .. .can be in other buckets too
  ArrayList<HistoryStory> uniqueToThisBucket = new ArrayList<HistoryStory>(); // stories that ONLY this bucket has

  //
  Bucket (String phrase) {
    this.phrase = phrase;
  } // end constructor


  //
  void addPhrase(String s) {
    if (!phrases.contains(s)) {
      phrases.add(s);
      storyTracker.put(s, new ArrayList<HistoryStory>());
    }
  } // end addPhrase

  //
  void addHistoryStory(String phraseIn, HistoryStory hs) {
    if (!((ArrayList<HistoryStory>)storyTracker.get(phraseIn)).contains(hs)) ((ArrayList<HistoryStory>)storyTracker.get(phraseIn)).add(hs);
  } // end addHistoryStory

  //
  ArrayList<HistoryStory> makeUniqueStories() {
    HashMap<HistoryStory, Integer> hsCount = new HashMap<HistoryStory, Integer>();
    for (Map.Entry me : storyTracker.entrySet()) {
      ArrayList<HistoryStory> thing = (ArrayList<HistoryStory>)me.getValue();
      for (HistoryStory hst : thing) {
        hsCount.put(hst, 0);
      }
    }
    ArrayList<HistoryStory> st  = new ArrayList<HistoryStory>();
    for (Map.Entry me : hsCount.entrySet()) {
      st.add((HistoryStory)me.getKey());
    } 
    return st;
  } // end makeUniqueStories

  //
  int getUniqueStoryCount() {
    return (makeUniqueStories()).size();
  } // end getUniqueStoryCount

  //
  String toString() {
    String builder = "BUCKET: " + phrase + " \n";
    builder += " unique stories in this bucket count: " + uniqueStories.size() + "\n";
    builder += " unique stories ONLY in this bucket count: " + uniqueToThisBucket.size() + "\n";
    int count = 0;
    for (Map.Entry me : storyTracker.entrySet()) {
      if (count != 0) builder += "\n";
      builder += "  phrase: " + (String)me.getKey() + " -- " + ((ArrayList<HistoryStory>)me.getValue()).size();
      count++;
    }
    return builder;
  } // end toString
} // end class Bucket

//
//
//
//
//
//

