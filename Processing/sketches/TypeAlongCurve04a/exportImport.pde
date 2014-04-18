//
void exportSplines() {
  println("exporting splabel splines");
  JSONObject json = new JSONObject();
  JSONArray jsonAR = new JSONArray();
  for (int i = 0; i < splabels.size(); i++) {
    JSONObject spl = new JSONObject();
    spl.setString("name", splabels.get(i).bucketName);
    spl.setJSONObject("topSpline", splabels.get(i).topSpline.makeJSONFromCurvePoints());
    spl.setJSONObject("bottomSpline", splabels.get(i).bottomSpline.makeJSONFromCurvePoints());
    println("done with top and bottom");
    if (splabels.get(i).middleMain != null) {
      spl.setJSONObject("topMiddleSpline", splabels.get(i).middleMain.get(0).makeJSONFromCurvePoints());
      spl.setJSONObject("bottomMiddleSpline", splabels.get(i).middleMain.get(1).makeJSONFromCurvePoints());
    }
    println("done with main middle top and bottom");
    if (splabels.get(i).middleTops != null) {
      JSONArray middleTopsAROuter = new JSONArray();
      for (int j = 0; j < splabels.get(i).middleTops.size(); j++) {
        JSONArray middleTopsARInner = new JSONArray();
        for (int k = 0; k < splabels.get(i).middleTops.get(j).size(); k++) {
          println("i: " + i + " j: " + j + " k: " + k);
          middleTopsARInner.setJSONObject(k, splabels.get(i).middleTops.get(j).get(k).makeJSONFromCurvePoints());
        }
        middleTopsAROuter.setJSONArray(j, middleTopsARInner);
      }
      spl.setJSONArray("middleTops", middleTopsAROuter);
    }

    if (splabels.get(i).middleBottoms != null) {
      JSONArray middleBottomsAROuter = new JSONArray();
      for (int j = 0; j < splabels.get(i).middleBottoms.size(); j++) {
        JSONArray middleBottomsARInner = new JSONArray();
        for (int k = 0; k < splabels.get(i).middleBottoms.get(j).size(); k++) {
          middleBottomsARInner.setJSONObject(k, splabels.get(i).middleBottoms.get(j).get(k).makeJSONFromCurvePoints());
        }
        middleBottomsAROuter.setJSONArray(j, middleBottomsARInner);
      }
      spl.setJSONArray("middleBottoms", middleBottomsAROuter);
    }
    jsonAR.setJSONObject(i, spl);
  }
  json.setJSONArray("splabels", jsonAR);
  saveJSONObject(json, "splines/splines"+ width + "-" + height + ".json");
} // end exportSplines


//
void readInSplinesForSpLabels() {
  String targetJSONFile = "splines/splines"+ width + "-" + height + ".json";
  try {
    JSONObject existingFile = loadJSONObject(targetJSONFile);
    HashMap<String, JSONObject> existingObjects = new HashMap<String, JSONObject>();
    JSONArray existingSps = existingFile.getJSONArray("splabels");
    for (int i = 0; i < existingSps.size(); i++) {
      JSONObject json = existingSps.getJSONObject(i);
      existingObjects.put(json.getString("name"), json);
    }
    println("loaded a total of " + existingObjects.size() + " objects to hm");

    // go through splabels and find a matching json
    for (SpLabel sp : splabels) {
      if (existingObjects.containsKey(sp.bucketName)) {
        JSONObject json = (JSONObject)existingObjects.get(sp.bucketName);
        // note: assume that the top and bottom splines are already made?.. naw
        if (json.hasKey("topSpline")) {
          sp.topSpline = new Spline(json.getJSONObject("topSpline"));
          sp.topSpline.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
        }

        if (json.hasKey("bottomSpline")) {
          sp.bottomSpline = new Spline(json.getJSONObject("bottomSpline"));
          sp.bottomSpline.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
        }
        if (json.hasKey("topMiddleSpline") && json.hasKey("bottomMiddleSpline")) {
          sp.middleMain = new ArrayList<Spline>();
          sp.middleMain.add(new Spline(json.getJSONObject("topMiddleSpline")));
          sp.middleMain.get(sp.middleMain.size() - 1).makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
          sp.middleMain.add(new Spline(json.getJSONObject("bottomMiddleSpline")));
          sp.middleMain.get(sp.middleMain.size() - 1).makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
          println("loaded top and bottom middle splines");
        }
        if (json.hasKey("middleTops")) {
          sp.middleTops = new ArrayList<ArrayList<Spline>>();
          JSONArray middleTopsAROuter = json.getJSONArray("middleTops");
          for (int j = 0; j < middleTopsAROuter.size(); j++) {
            ArrayList<Spline> middles = new ArrayList<Spline>();
            JSONArray middleTopsARInner = middleTopsAROuter.getJSONArray(j);
            for (int k = 0; k < middleTopsARInner.size(); k++) {
              middles.add(new Spline(middleTopsARInner.getJSONObject(k)));
              middles.get(middles.size() - 1).makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
            }
            sp.middleTops.add(middles);
          }
        }
         if (json.hasKey("middleBottoms")) {
          sp.middleBottoms = new ArrayList<ArrayList<Spline>>();
          JSONArray middleBottomsAROuter = json.getJSONArray("middleBottoms");
          for (int j = 0; j < middleBottomsAROuter.size(); j++) {
            ArrayList<Spline> middles = new ArrayList<Spline>();
            JSONArray middleBottomsARInner = middleBottomsAROuter.getJSONArray(j);
            for (int k = 0; k < middleBottomsARInner.size(); k++) {
              middles.add(new Spline(middleBottomsARInner.getJSONObject(k)));
              middles.get(middles.size() - 1).makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
            }
            sp.middleBottoms.add(middles);
          }
        }
      }
    }
  }
  catch (Exception e) {
    println("could not load/find " + targetJSONFile);
  }
} // end readInSplinesForSpLabels


//
//
//
//
//

