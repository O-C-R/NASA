//
void loadStories(int[] yearRangeIn) {
  int currentYear = 0;
  for (int i = yearRangeIn[0] - 1; i <= yearRangeIn[1]; i++) {
    try {
      JSONObject json = loadJSONObject(jsonDirectory + i + ".json");
      currentYear = json.getInt("year");
      JSONArray storiesJS = json.getJSONArray("stories");
      for (int j = 0; j < storiesJS.size(); j++) {
        HistoryStory newStory = new HistoryStory(storiesJS.getJSONObject(j), currentYear);
        newStory.id = historyStoriesAll.size(); 
        historyStoriesAll.add(newStory);
      }
    }
    catch (Exception e) {
      println("could not load year file: " + i);
    }
  }
  println("finished loading " + historyStoriesAll.size() + " total stories");
} // end loadStories


//
void loadBuckets() {
  String[] allLines = loadStrings(baseBucketFile);
  Bucket currentBucket = null;
  for (int i = 0; i < allLines.length; i++) {
    if (allLines[i].contains("+")) {
      String phrase = allLines[i].replace("+", "").trim().toLowerCase();
      Bucket newBucket = new Bucket(phrase);
      currentBucket = newBucket;
      bucketsAll.add(newBucket);
      bucketsHM.put(phrase, newBucket);
    }
    else {
      if (currentBucket != null) {
        String phrase = allLines[i].trim().toLowerCase();
        if (phrase.length() > 0) currentBucket.addPhrase(phrase);
      }
    }
  }
  println("finished loading " + bucketsAll.size());
} // end loadBuckets




//
//
//
//
//

