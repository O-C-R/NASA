//
class PhraseReference {
  String phrase = "";
  ArrayList<NYTStory> stories = new ArrayList<NYTStory>();
  int storyCount = 0;

  //
  PhraseReference(String phrase) {
    this.phrase = phrase;
  } // end constructor

  //
  void addNYTStory(NYTStory in) {
    if (!stories.contains(in)) {
      // check text
      boolean textAlreadyIn = false;
      for (NYTStory nyt : stories) {
        if (nyt.abstr.length() > 0) {
          if (nyt.abstr.equals(in.abstr)) {
            textAlreadyIn = true;
            break;
          }
        }
        else {
          if (nyt.snippet.equals(in.snippet)) {
            textAlreadyIn = true;
            break;
          }
        }
      }
      if (!textAlreadyIn) stories.add(in);
    }
  } // end addNYTStory

  //
  String toString() {
    String builder = "\n\n     xxxx_PHRASE: " + phrase + "\n";
    builder += " total stories: " + stories.size();
    for (NYTStory nyt : stories) {
      builder += "\n -- " + nyt.id;
      //builder += "\n -- " + nyt.leadParagraph;
      builder += "\n -page:" + nyt.printPage + "- " + nyt.abstr;
    }
    return builder;
  } // end toString

  //
  JSONObject getJSON() {
    JSONObject json = new JSONObject();
    json.setString("phrase", phrase);
    JSONArray storiesAr = new JSONArray();
    for (NYTStory nyt : stories) {
      storiesAr.setJSONObject(storiesAr.size(), nyt.json);
    }
    json.setJSONArray("stories", storiesAr);
    return json;
  } // end getJSON
} // end class PhaseReference

//
//
//
//
//

