//
class Gram {
  JSONObject originalJSON;
  int totalCount = 0;
  ArrayList<Integer> years = new ArrayList<Integer>();
  ArrayList<Integer> counts = new ArrayList<Integer>(); // should line up with years
  HashMap<Integer, Integer> yearsCounts = new HashMap<Integer, Integer>();

  int totalHits = 0;
  String searchTerm = "";
  int yearsPolled = 0;

  ArrayList<PVector> graphPoints = null;
  color c;

  boolean selected = false;
  Label label;

  //
  Gram(JSONObject json) {
    originalJSON = json;
    totalHits = json.getInt("total_hits");
    searchTerm = json.getString("search_term");
    yearsPolled = json.getInt("total_queries");
    JSONArray yearsAR = json.getJSONArray("results_by_year");
    for (int i = 0; i < yearsAR.size(); i++) {
      JSONObject result = yearsAR.getJSONObject(i);
      int yr = result.getInt("year");
      int ct = result.getInt("count");
      totalCount += ct;
      years.add(yr);
      counts.add(ct);
      yearsCounts.put((Integer)yr, (Integer)ct);
    }
    // make the color
    int colorNumber = 0;
    for (int i = 0; i < searchTerm.length(); i++) colorNumber += searchTerm.charAt(i);
    c = color(colorNumber % 360, 360, 360);
  } // end constructor

  //
  void graph(PGraphics pg) {
    pg.noFill();
    if (selected) {
      pg.stroke(0);
      pg.strokeWeight(1.5);
    }
    else {
      pg.stroke(c);
      pg.strokeWeight(1);
    }
    int count = 0;
    pg.beginShape();
    for (PVector p : graphPoints) {
      if (curvesOn && count == 0) curveVertex(p.x, p.y);
      if (curvesOn) curveVertex(p.x, p.y);
      else vertex(p.x, p.y);
      if (curvesOn && count == graphPoints.size() - 1) curveVertex(p.x, p.y);
      count++;
    }
    pg.endShape();
    pg.strokeWeight(1);
  } // end graph

  //
  String toString() {
    String builder = "term: " + searchTerm + " years.size(): " + years.size() + " totalCount: " + totalCount + "\n" ;
    for (int i = 0; i < years.size(); i++) {
      if (yearsCounts.containsKey(years.get(i))) {
        builder += years.get(i) + "-" + nf((Integer)yearsCounts.get(years.get(i)), 4) + " ";
        if (years.get(i) % 20 == 0) builder += "\n";
      }
    }
    return builder;
  } // end toString
} // end class Gram

//
//
//
//
//
//

