class Flare {
  ArrayList<ArrayList<FlareSpline>> flareSplines = new ArrayList<ArrayList<FlareSpline>> (); // total number determined by flareLayers

  String name = "";
  Spline baseSpline = null; // the one where the hairs come out of

  boolean isTopFlare = false;

  boolean goUp = true;
  boolean goLeft = true;



  //
  Flare(String name, Spline baseSpline, boolean isTopFlare, boolean goUp, boolean goLeft) {
    this.name = name;
    this.baseSpline = baseSpline;
    this.isTopFlare = isTopFlare;
    this.goUp = goUp;
    this.goLeft = goLeft;
  } // end constructor

  //
  Flare(JSONObject json) {
    if (json.hasKey("name")) name = json.getString("name");
    if (json.hasKey("baseSpline")) baseSpline = new Spline(json.getJSONObject("baseSpline"));
    if (json.hasKey("isTopFlare")) isTopFlare = json.getBoolean("isTopFlare");
    if (json.hasKey("goUp")) goUp = json.getBoolean("goUp");
    if (json.hasKey("goLeft")) goLeft = json.getBoolean("goLeft");
    if (json.hasKey("flareSplines")) {
      JSONArray jar = json.getJSONArray("flareSplines");
      for (int i = 0; i < jar.size(); i++) {
        Spline newSpline = new Spline(jar.getJSONObject(i));
        if (newSpline.totalDistance == 0 || newSpline.curvePoints.size() < 2) continue;
        makeFlareSpline(newSpline);
      }
    }
  } // end JSONConstructor

  //
  JSONObject getJSON() {
    println("in getJSON for " + name);
    JSONObject json = new JSONObject();
    json.setString("name", name);
    json.setJSONObject("baseSpline", baseSpline.getJSON());
    json.setBoolean("isTopFlare", isTopFlare);
    json.setBoolean("goUp", isTopFlare);
    json.setBoolean("goLeft", isTopFlare);
    println("  after goLeft");
    JSONArray flareSplinesAR = new JSONArray();
    int count = 0; 
    for (int i = 0; i < flareSplines.size(); i++) {
      for (int k = 0; k < flareSplines.get(i).size(); k++) {
        try {
          JSONObject flareSplineJSON = flareSplines.get(i).get(k).getJSON();
          flareSplinesAR.setJSONObject(count, flareSplineJSON);
          count++;
          //println("success at exporting " + i + " - " + k);
        }
        catch (Exception e) {
          //println("problem getting spline for " + name + " at i: " + i + " k: " + k + " with curvePoints: " + flareSplines.get(i).get(k).spline.curvePoints.size() + " of total flareSplines: " + flareSplines.get(i).size());
        }
      }
    }
    json.setJSONArray("flareSplines", flareSplinesAR);
    return json;
  } // end getJSON


  //
  void makeFlareSpline(Spline s) {
    if (flareSplines.size() != flareLayers) {
      for (int i = 0; i < flareLayers; i++) flareSplines.add(new ArrayList<FlareSpline>());
    }
    float totalOptions = 0;
    for (int i = 0; i < flareLayers; i++) {
      totalOptions += (i + 1) * (i + 1);
    }
    float randomValue = random(totalOptions);
    int index = 0;
    float flareSplineColor = 0f;
    float heightMultiplier = 0f;
    float oldTotal = 0f; 
    for (int i = 0; i < flareLayers; i++) {
      oldTotal += (i + 1) * (i + 1);
      if (randomValue < oldTotal) {
        index = i;
        float powNumber = .3;
        flareSplineColor = map(pow(randomValue, powNumber), 0, pow(totalOptions, powNumber), fullGrayColor, lowestGrayColor);
        heightMultiplier = map(pow(randomValue, powNumber), 0, pow(totalOptions, powNumber), 2, .75);
        break;
      }
    }
    for (int i = 0; i < s.facetHeights.length; i++) s.facetHeights[i] *= heightMultiplier;
    FlareSpline fs = new FlareSpline(s, flareSplineColor);
    flareSplines.get(index).add(fs);
  } // end makeFlareSpline

  //
  void display() {
    for (int i = flareSplines.size() - 1; i >= 0; i--) {
      for (FlareSpline fs : flareSplines.get(i)) {
        fs.display();
      }
    }
  } // end display

    //
  void displaySplines() {
    for (int i = flareSplines.size() - 1; i >= 0; i--) {
      for (FlareSpline fs : flareSplines.get(i)) {
        fs.displaySplines();
      }
    }
  } // end displaySplines

    //
  void displayFacetPoints() {
    for (int i = flareSplines.size() - 1; i >= 0; i--) {
      for (FlareSpline fs : flareSplines.get(i)) {
        fs.displayFacetPoints();
      }
    }
  } // end displayFacetPoints
  //
  void displayHeights() {
    for (int i = flareSplines.size() - 1; i >= 0; i--) {
      for (FlareSpline fs : flareSplines.get(i)) {
        fs.displayHeights();
      }
    }
  } // end displayFacetPoints

    //
  void printLabelCounts() {
    for (int i = 0; i < flareSplines.size(); i++) {
      ArrayList<FlareSpline> fs = flareSplines.get(i);
      int count = 0;
      for (FlareSpline f : fs) {
        count += f.labels.size();
        //println("  flareSpline.  totalDistance: " + f.spline.totalDistance + " curvePoints.size(): " + f.spline.curvePoints.size());
      }
      println("flare " + name + " level: " + i + " label count of " + count + " and flareCount of: " + fs.size());
    }
  } // end printLabelcounts
} // end class Flare






//
class FlareSpline {
  Spline spline = null;
  float splineGray = 0f;

  ArrayList<Label> labels = new ArrayList<Label>();

  //
  FlareSpline(Spline spline, float splineGray) {
    this.spline = spline;
    this.splineGray = splineGray;
  } // end constructor

  //
  void addLabel(Label l) {
    labels.add(l);
  } // end addLabel

    //
  Label getLastLabel() {
    if (labels.size() == 0) return null;
    else return labels.get(labels.size() - 1);
  } // end getLastLabel

  //
  float getLastDistance(boolean leftAligned) {
    if (labels.size() == 0) return 0f;
    else {
      Label lastLabel = labels.get(labels.size() - 1);
      if (leftAligned) return lastLabel.endDistance;
      else return lastLabel.startDistance;
    }
  } // end getLastDistance

    //
  void display() {
    for (Label l : labels) {
      l.fillAlpha = 1f;  
      l.display((int)splineGray);
    }
  } // end display

    //
  void displaySplines() {
    stroke(splineGray);
    spline.display();
  } // end displaySplines
  //
  void displayFacetPoints() {
    stroke(splineGray);
    spline.displayFacetPoints();
  } // end displayFacetPoints
  //
  void displayHeights() {
    stroke(255, 50);
    spline.displayHeights();
  } // end displayHeights

    //
  JSONObject getJSON() {
    JSONObject json = new JSONObject();
    json = spline.getJSON();
    return json;
  } // end getJSON
} // end class FlareSpline

//
//
//
//
//
//

