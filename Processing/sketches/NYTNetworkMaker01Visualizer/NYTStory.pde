//
class NYTStory {
  JSONObject json;
  String id = "";
  HashMap<String, Integer> keywords = new HashMap<String, Integer>(); // just the value, not the name
  String abstr = ""; // abstract
  String headline = "";
  int printPage = -1;
  String printPageString = ""; // because sometimes there are wacky chars
  Calendar pubDate = null;
  String pubDateString = "";
  String webURL = "";
  String snippet = "";
  String documentType = "";
  int wordCount = -1;
  String leadParagraph = "";
  

  boolean isValid = false;
  
  PVector tempPosition = new PVector(); // when needed
  
  PVector pos = null; // for mapping

  //
  NYTStory (JSONObject json) {
    this.json = json;
    id = getStringFromJSON(json, "_id");

    try {
      if (json.hasKey("keywords")) {
        JSONArray keywordArray = json.getJSONArray("keywords");
        for (int i = 0; i < keywordArray.size(); i++) {
          JSONObject keywordObject = keywordArray.getJSONObject(i);
          keywords.put(keywordObject.getString("value"), 0);
        }
      }

      abstr = getStringFromJSON(json, "abstract");
      if (json.hasKey("headline")) {
        JSONObject headlineObject = json.getJSONObject("headline");
        headline = getStringFromJSON(headlineObject, "main");
      }

      if (json.hasKey("print_page")) {
        printPageString = json.getString("print_page");
        try {
          printPage = Integer.parseInt(printPageString);
        }
        catch (Exception e) {
        }
      }

      if (json.hasKey("pub_date")) {
        try {
          String timeString = json.getString("pub_date");
          pubDate = getCalFromNYTPubTime(timeString);
          pubDateString = getNicePubDateString(pubDate);
        }
        catch (Exception e) {
        }
      }

      webURL = getStringFromJSON(json, "web_url");
      snippet = getStringFromJSON(json, "snippet");
      documentType = getStringFromJSON(json, "document_type");

      if (json.hasKey("word_count")) {
        try {
          wordCount = json.getInt("word_count");
        }
        catch (Exception e) {
        }
      }

      leadParagraph = getStringFromJSON(json, "lead_paragraph");

      isValid = true; // if it can get to the end then it is a valid NYTStory
    }
    catch (Exception e) {
    }
  } // end constructor

  //
  void display(PGraphics pg) {
    if (pos != null) {
      
    }
  } // end display

  //
  String getStringFromJSON(JSONObject json, String attrName) {
    String str = "";
    if (json.hasKey(attrName)) {
      try {
        str = json.getString(attrName);
      }
      catch (Exception e) {
      }
    }
    return str;
  } // end getStringFromJSON

  //
  String toString() {
    String builder = "Story: " + id + "\n";
    String keywordsString = "";
    for (Map.Entry me : keywords.entrySet()) keywordsString += (String)me.getKey() + " ";
    builder += " keywords: " + keywordsString + "\n";
    builder += " headline: " + headline + "\n";
    builder += " page: " + printPage + "   wordCount: " + wordCount + "   pubDate: " + pubDateString;
    return builder;
  } // end toString
  
  //
  JSONObject getJSON() {
    return json;
  } // end getJSON
} // end class NYTStory

//
//
//
//
//

