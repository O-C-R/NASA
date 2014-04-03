class Phrase {
  String phrase = "";
  int nytCount = 0;
  int phraseWordCount = 0;
  HashMap<HistoryStory, Integer> historyStories = new HashMap<HistoryStory, Integer>();
  int totalMentions = 0;
  int totalStories = 0;
  
  PVector centerLoc = new PVector();

  //
  Phrase(String phrase, int nytCount) {
    this.phrase = phrase;
    this.nytCount = nytCount;
    phraseWordCount = (split(phrase, " ")).length;
  } // end constructor

  //
  void addHistoryStory(HistoryStory hs, int count) {
    historyStories.put(hs, count);
  } // end addHistoryStory 

  

  //
  int getMentions() {
    int total = 0;
    for (Map.Entry me : historyStories.entrySet()) {
      total += (Integer)me.getValue();
    }
    return total;
  } // end getMentions

  // 
  ArrayList<HistoryStory> getOrderedHistoryStories() {
    ArrayList<HSTemp> hsTemp = new ArrayList<HSTemp>();
    for (Map.Entry me : historyStories.entrySet()) hsTemp.add(new HSTemp((Integer)me.getValue(), (HistoryStory)me.getKey()));
    hsTemp = OCRUtils.sortObjectArrayListSimple(hsTemp, "count");
    hsTemp = OCRUtils.reverseArrayList(hsTemp);
    ArrayList<HistoryStory> hs = new ArrayList<HistoryStory>();
    for (HSTemp hst : hsTemp) hs.add(hst.hs);
    return hs;
  } // end getOrderedHistoryStories

  //
  String toString() {
    return "PHRASE: " + phrase + " _nytCount: " + nytCount + " _historyStories.size(): " + historyStories.size() + " _mentions: " + totalMentions;
  } // end toString
} // end class Phrase



// 
class HSTemp {
  int count;
  HistoryStory hs;
  HSTemp(int count, HistoryStory hs) {
    this.count = count;
    this.hs = hs;
  } // end constructor
} // end class HSTemp
//
//
//
//
//

