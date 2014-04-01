//
void outputStories() {
  int minStoriesForPhraseOutput = 2; // phrase must at least have n stories to be considered

  String outputLocation = "output/" + yearRange[0] + "-" + yearRange[1] + "_" + timeStamp + ".json";
  JSONObject json = new JSONObject();

  ArrayList<PhraseReference> prAL = new ArrayList<PhraseReference>();
  for (Map.Entry me : phraseKeeper.entrySet()) {
    PhraseReference pr = (PhraseReference)me.getValue();
    if (pr.stories.size() >= minStoriesForPhraseOutput) {
      pr.storyCount = pr.stories.size();
      prAL.add(pr);
    }
  }

  prAL = OCRUtils.sortObjectArrayListSimple(prAL, "storyCount");
  prAL = OCRUtils.reverseArrayList(prAL);

  json.setInt("phrase", prAL.size());
  JSONArray prJSONArray = new JSONArray();
  for (int i = 0; i < prAL.size(); i++) {
    prJSONArray.setJSONObject(i, prAL.get(i).getJSON());
  }
  json.setJSONArray("phrases", prJSONArray);

  saveJSONObject(json, outputLocation);
} // end outputStories

