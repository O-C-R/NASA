//
class Search {
  String beginDate = "";
  String endDate = "";
  String searchTerm = "";
  int year = 0;
  int month = 0;
  int hits = 0;

  ArticleNYT anyt = null;
  int limit = -1; // page limit, -1 for until done

  ArrayList<Result> results = new ArrayList<Result>();

  //
  Search (String searchTerm, String beginDate, String endDate, int year, int month) {
    this.searchTerm = searchTerm;
    this.beginDate = beginDate;
    this.endDate = endDate;
    this.year = year;
    this.month = month;
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
    //println("made Search for " + searchTerm + " between " + beginDate + " and " + endDate);
  } // end makeQuery

  //
  void makeResults() {
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

        JSONObject meta = response.getJSONObject("meta");
        hits = meta.getInt("hits");
        results.add(new Result(year, month, hits));
        problem = false;
      }
      catch (Exception e) {
        problem = true;
        print("x");
        problemCount++;
        delay(1000);
      }
      if (!problem || problemCount > 4) break;
    }
  } // end makeResults

  //
  String toString() {
    String builder = "SEARCH: " + searchTerm + " between " + beginDate + " and " + endDate + "\n";
    builder += " results: " + results.size();
    return builder;
  } // end toString

  //
  JSONArray makeYearlyTotals() {
    JSONArray resultsByYearArray = new JSONArray();
    HashMap<Integer, Result> yrResults = new HashMap<Integer, Result>();
    for (int i = 0; i < results.size(); i++) {
      if (!yrResults.containsKey(results.get(i).year)) yrResults.put(results.get(i).year, new Result(results.get(i).year, -1, 0));
      Result oldResult = (Result)yrResults.get(results.get(i).year);
      oldResult.count += results.get(i).count;
      yrResults.put(results.get(i).year, oldResult);
    }
    ArrayList<Result> yearlyResults = new ArrayList<Result>();
    for (Map.Entry me : yrResults.entrySet()) yearlyResults.add((Result)me.getValue());
    yearlyResults = OCRUtils.sortObjectArrayListSimple(yearlyResults, "year");
    return makeJSONArrayFromResultList(yearlyResults);
  } // end makeYearlyTotals

    // 
  JSONArray makeMonthlyTotals() {
    return makeJSONArrayFromResultList(results);
  } // end makeMonthlyTotals

    //
  JSONArray makeJSONArrayFromResultList(ArrayList<Result> resultsIn) {
    JSONArray resultsArray = new JSONArray();
    for (int i = 0; i < resultsIn.size(); i++) {
      JSONObject result = new JSONObject();
      result.setInt("year", resultsIn.get(i).year);
      result.setInt("month", resultsIn.get(i).month);
      result.setInt("count", resultsIn.get(i).count);
      resultsArray.setJSONObject(i, result);
    }
    return resultsArray;
  } // end makeJSONArrayFromResultList

  // 
  void output() {
    JSONObject output = new JSONObject();
    output.setJSONArray("results_by_month", makeMonthlyTotals());
    output.setJSONArray("results_by_year", makeYearlyTotals());
    output.setString("query_string", anyt.queryString);
    output.setString("begin_date", beginDate);
    output.setString("end_date", endDate);
    output.setString("search_term", searchTerm);
    output.setInt("total_queries", results.size());
    int totalHits = 0;
    for (Result r : results) totalHits += r.count; 
    output.setInt("total_hits", totalHits);
    //saveJSONObject(output, searchOutputDirectory + searchTerm + "/" + beginDate + "-" + endDate + ".json");
    saveJSONObject(output, searchOutputDirectory + searchTerm.replace(' ', '_') + "-" + beginDate + "-" + endDate + ".json");
  } // end output
} // end class Search

//
//
//
//

