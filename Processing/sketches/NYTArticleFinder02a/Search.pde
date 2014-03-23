//
class Search {
  String beginDate = "";
  String endDate = "";
  String searchTerm = "";

  ArticleNYT anyt = null;
  int limit = -1; // page limit, -1 for until done

  ArrayList<Result> results = new ArrayList<Result>();

  //
  Search (String searchTerm, String beginDate, String endDate) {
    this.searchTerm = searchTerm;
    this.beginDate = beginDate;
    this.endDate = endDate;
    makeQuery();
  } // end constructor

  //
  Search (JSONObject json) {
    // tbd
  } // end constructor

  //
  void makeQuery() {
    anyt = new ArticleNYT();
    anyt.q = searchTerm;
    anyt.beginDate = beginDate;
    anyt.endDate = endDate;
    anyt.sort = "oldest";
    //println("made Search for " + searchTerm + " between " + beginDate + " and " + endDate);
  } // end makeQuery

  //
  void makeResults() {
    println("in makeResults for " + searchTerm + " between " + beginDate + " and " + endDate);

    int pageCounter = 0;
    while (true) {
      anyt.page = pageCounter;
      JSONArray newResults = null;
      try {
        JSONObject result = anyt.getQuery();
        JSONObject response = result.getJSONObject("response");
        newResults = response.getJSONArray("docs");
        if (pageCounter == 0) {
          JSONObject meta = response.getJSONObject("meta");
          println("  total results: " + meta.getInt("hits"));
        }
        print(".");
      }
      catch (Exception e) {
      } 
      /*
      pageCounter++;
      if (newResults != null) {
        for (int i = 0; i < newResults.size(); i++) {
          results.add(newResults.getJSONObject(i));
        }
      }
      if ((limit > 0 && pageCounter >= limit || pageCounter == 100) || newResults.size() == 0) break; // page cannot go beyond 100
      */
      break;
    }
    println("__");
    //println("end of makeResults with total results as: " + results.size());
  } // end makeResults

  //
  String toString() {
    String builder = "SEARCH: " + searchTerm + " between " + beginDate + " and " + endDate + "\n";
    builder += " results: " + results.size();
    return builder;
  } // end toString


  // 
  void output() {
    JSONObject output = new JSONObject();
    JSONArray resultsArray = new JSONArray();
    for (int i = 0; i < results.size(); i++) {
      resultsArray.setJSONObject(i, results.get(i));
    }
    output.setJSONArray("results", resultsArray);
    output.setString("query_string", anyt.queryString);
    output.setString("begin_date", beginDate);
    output.setString("end_date", endDate);
    output.setString("search_term", searchTerm);
    output.setInt("total_results", results.size());
    saveJSONObject(output, searchOutputDirectory + searchTerm + "/" + beginDate + "-" + endDate + ".json");
  } // end output
} // end class Search

//
//
//
//

