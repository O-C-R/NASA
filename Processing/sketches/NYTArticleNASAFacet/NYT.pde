// 
class NYT {
  String baseURL = "";
  String queryString = "";

  String q = ""; // query term
  String fq = ""; // ****** filtered search query. see http://developer.nytimes.com/docs/read/article_search_api_v2#filters
  String beginDate = ""; // YYYYMMDD
  String endDate = ""; // YYYYMMDD
  String sort = ""; // newest, oldest.  default is by relevance
  String[] f1 = new String[0]; // fields to be returned by results.  see http://developer.nytimes.com/docs/read/article_search_api_v2
  int page = 0; // sets of 10
  String responseFormat = ".json"; // keep as json.  other option is jsonp
  String apiKey = "";

  //
  void makeQueryString() {
    queryString = baseURL + responseFormat + "?";
    queryString += "api-key=" + apiKey;
    if (q.length() > 0) queryString += "&q=" + q;
    if (fq.length() > 0) queryString += "&fq=" + fq; // see documention for this
    if (beginDate.length() > 0) queryString += "&begin_date=" + beginDate;
    if (endDate.length() > 0) queryString += "&end_date=" + endDate;
    if (sort.length() > 0) queryString += "&sort=" + sort;
    if (f1.length > 0) {
      queryString += "&f1=";
      for (int i = 0; i < f1.length; i++) {
        queryString += f1[i];
        if (i < f1.length - 1) queryString += ",";
      }
    }
    if (page > 0) queryString += "&page=" + page;
    
    

    queryString = queryString.replace(" ", "%20");
  } // end makeQueryString

  //
  JSONObject getQuery() {
    JSONObject result = null;
    try {
      makeQueryString();
      //println(queryString);
      result = loadJSONObject(queryString);
      delay(390); // to not exceed the qps
    }
    catch (Exception e) {
      println("problem with query: " + queryString);
    }
    return result;
  } // end getQuery
} // end class NYT


// 
class ArticleNYT extends NYT {
  //
  ArticleNYT() {
    baseURL = "http://api.nytimes.com/svc/search/v2/articlesearch";
    apiKey = nytArticleKey;
  } // end constructor
} // end class ArticleNYT

// 
// 
// 
// 
// 
// 

