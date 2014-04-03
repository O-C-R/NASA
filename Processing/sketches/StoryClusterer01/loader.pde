//
void loadStories(int[] yearRangeIn) {
  int currentYear = 0;
  int manualBreak = 0;
  for (int i = yearRangeIn[0] - 1; i <= yearRangeIn[1]; i++) {
    try {
      JSONObject json = loadJSONObject(jsonDirectory + i + ".json");
      currentYear = json.getInt("year");
      JSONArray storiesJS = json.getJSONArray("stories");
      for (int j = 0; j < storiesJS.size(); j++) {
        //if (manualBreak > 80) break; // manual break
        //if (manualBreak > 130) break; // manual break
        HistoryStory newStory = new HistoryStory(storiesJS.getJSONObject(j), currentYear);
        newStory.id = historyStoriesAll.size(); 
        historyStoriesAll.add(newStory);
        manualBreak++;
      }
    }
    catch (Exception e) {
      println("could not load year file: " + i);
    }
  }
  println("finished loading " + historyStoriesAll.size() + " total stories");
} // end loadStories

//
void loadPhrases() {
  String[] lines = loadStrings(baseKeyWordsFile);
  for (String s : lines) {
    String[] broken = split(s, ",");
    Phrase pr = new Phrase(broken[0].replace("\"", "").toLowerCase(), Integer.parseInt(broken[1]));
    if (pr.nytCount > 1) phrasesAll.add(pr); // weed out the small ones
  }
  
  println("made " + phrasesAll.size() + " new phrases");
} // end loadPhrases


//
//
//
//

