//
class Search {
  String beginDate = "";
  String endDate = "";
  String searchTerm = "";
  int year = 0;
  int month = 0;
  int hits = 0;

  String fq;

  ArticleNYT anyt = null;
  int limit = -1; // page limit, -1 for until done

  ArrayList<JSONObject> results = new ArrayList<JSONObject>();
  int totalPages = 0;

  //
  Search (String searchTerm, String fq, String beginDate, String endDate, int year, int month) {
    this.searchTerm = searchTerm;
    this.beginDate = beginDate;
    this.endDate = endDate;
    this.year = year;
    this.month = month;
    this.fq = fq;
    //println("NEW SEARCH for dates: " + beginDate + " " + endDate + " year " + year + " month: " + month);
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

    anyt.fq = fq;

    //println("made Search for " + searchTerm + " between " + beginDate + " and " + endDate);
  } // end makeQuery

  //
  void makeResults() {
    println("in makeResults for " + searchTerm + " between " + beginDate + " and " + endDate);
    boolean problem = false;
    int problemCount = 0;
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
          hits = meta.getInt("hits");
          println(" totalHits: " + hits);
        }
        problem = false;
      }
      catch (Exception e) {
        problem = true;
        print("x");
        problemCount++;
        delay(1000);
      }

      if (newResults != null && !problem && newResults.size() > 0) {
        pageCounter++;
        totalPages++;
        for (int i = 0; i < newResults.size(); i++) {
          results.add(newResults.getJSONObject(i));
        }
        if (pageCounter % 10 == 0) print(pageCounter);
        else print(".");
      }
      else if (newResults!= null && newResults.size() == 0) {
        break;
        // cut out if there isnt a problem and there arent any results
      }
      else if (problem) {
        if (problemCount > 10) break;// cut out if there are too many problems
      }
    }
    // output the results
    output();
    println("_");
    println("end of makeResults for " + totalPages + " total pages.  total hits: " + hits + " and results: " + results.size());
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

    if (fq.length() > 0) {
      String fqName = fq.replace(" ", "_");
      fqName = split(fqName, "\"")[1];
      fqName = fqName.replace(",", "");
      saveJSONObject(output, searchOutputDirectory + "fq/" + fqName + "/" + beginDate + "-" + endDate + "-" + nf(results.size(), 4) + ".json");
    }
    else {
      String searchName = searchTerm.replace("\"", "");
      searchName = searchName.replace(" ", "_");
      saveJSONObject(output, searchOutputDirectory + "search/" + searchName + "/" + beginDate + "-" + endDate + "-" + nf(results.size(), 4) + ".json");
    }
  } // end output
} // end class Search

//
//
//
//

