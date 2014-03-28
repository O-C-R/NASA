class ImportantStory {
  HistoryStory historyStory = null;

  ArrayList<NYTStory> nytStories = new ArrayList<NYTStory>();
  ArrayList<IntDict> occurances = new ArrayList<IntDict>();


  //
  ImportantStory (HistoryStory historyStory) {
    this.historyStory = historyStory;
  } // end constructor

  // 
  void addNYTStory(NYTStory storyIn, IntDict occuranceIn) {
    if (!nytStories.contains(storyIn)) {
      nytStories.add(storyIn);
      occurances.add(occuranceIn);
    }
  } // end addNYTStory

  // 
  String toString() {
    String builder = "";
    builder += "IMPORTANT STORY:\n";
    builder += " history: " + getNicePubDateString(historyStory.cal) + "\n";
    builder += " text: " + historyStory.story + "\n";
    builder += " total nyt stories: " + nytStories.size() + "\n";
    for (int i = 0; i < nytStories.size(); i++) {
      NYTStory nyt = nytStories.get(i);
      builder += "   page: " + nyt.printPage + "\n";
      builder += "   occurances: " + occurances.get(i).toString() + "\n";
      builder += "   nytStory: " + nyt.headline + "\n";
    }
    return builder;
  } // end toString

  //
  int getLowestPage() {
    int lowestPage = nytStories.get(0).printPage;
    for (int i = 1; i < nytStories.size(); i++) lowestPage = (lowestPage < nytStories.get(i).printPage ? lowestPage : nytStories.get(i).printPage);
    return lowestPage;
  } // end getLowestPage

    //
  JSONObject getJSON() {
    JSONObject output = new JSONObject();
    output.setJSONObject("historyStory", historyStory.getJSON());
    JSONArray nytStoriesArray = new JSONArray();
    for (int i = 0; i < nytStories.size(); i++) {
      NYTStory nyt = nytStories.get(i);
      JSONObject nytStoryObj = new JSONObject();
      //nytStoriesArray.setJSONObject(nytStoriesArray.size(), nyt.getJSON());
      nytStoryObj.setJSONObject("nytStory", nyt.getJSON());
      
      
      JSONObject occuranceJSONAwesome = new JSONObject();
      occuranceJSONAwesome.setString("description", "the words connecting the nytStory to the historyStory and their counts");
      IntDict occurance = occurances.get(i);
      JSONArray occuranceArray = new JSONArray();
      for (String occuranceKey : occurance.keys()) {
        int count = (Integer)occurance.get(occuranceKey);
        JSONObject occuranceJSON = new JSONObject();
        occuranceJSON.setString("word", occuranceKey);
        occuranceJSON.setInt("count", count);
        occuranceArray.setJSONObject(occuranceArray.size(), occuranceJSON);
      }
      occuranceJSONAwesome.setJSONArray("connections", occuranceArray);
      nytStoryObj.setJSONObject("gramOccurances", occuranceJSONAwesome);


      nytStoriesArray.setJSONObject(nytStoriesArray.size(), nytStoryObj);
    } 
    output.setJSONArray("nytStories", nytStoriesArray);
    output.setInt("totalNYTStories", nytStories.size());
    int lowestPage, highestPage;
    lowestPage = highestPage = nytStories.get(0).printPage;
    for (int i = 1; i < nytStories.size(); i++) {
      lowestPage = (lowestPage < nytStories.get(i).printPage ? lowestPage : nytStories.get(i).printPage);
      highestPage = (highestPage > nytStories.get(i).printPage ? highestPage : nytStories.get(i).printPage);
    }
    output.setInt("lowestPage", lowestPage);
    output.setInt("highestPage", highestPage);
    return output;
  } // end getJSON
} // end class ImportantStory

//
//
//
//

