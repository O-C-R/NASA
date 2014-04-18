//

void exportSplines() {
  println("exporting splabel splines");

  for (int k = 0; k < splabels.size(); k++) {
    JSONObject json = new JSONObject();
    json.setString("name", splabels.get(k).bucketName);
    JSONArray tops = new JSONArray();
    for (int i = 0; i < splabels.get(k).orderedTopSplines.size(); i++) {
      JSONArray layer = new JSONArray();
      for (int j = 0; j < splabels.get(k).orderedTopSplines.get(i).size(); j++) {
        layer.setJSONObject(j, splabels.get(k).orderedTopSplines.get(i).get(j).getJSON());
      }
      tops.setJSONArray(i, layer);
    }
    json.setJSONArray("tops", tops);
    JSONArray bottoms = new JSONArray();
    for (int i = 0; i < splabels.get(k).orderedBottomSplines.size(); i++) {
      JSONArray layer = new JSONArray();
      for (int j = 0; j < splabels.get(k).orderedBottomSplines.get(i).size(); j++) {
        layer.setJSONObject(j, splabels.get(k).orderedBottomSplines.get(i).get(j).getJSON());
      }
      bottoms.setJSONArray(i, layer);
    }
    json.setJSONArray("bottoms", bottoms);    
    saveJSONObject(json, "splines/splines-"+ splabels.get(k).bucketName + "-" + width + "-" + height + ".json");
  }
  println("done exporting splabel splines");
} // end exportSplines


//
void readInSplinesForSpLabels() {
  println("reading in splabels");
  for (SpLabel sp : splabels) {
    String targetJSONFile = "splines/splines-"+ sp.bucketName + "-" + width + "-" + height + ".json";
    try {
      JSONObject json = loadJSONObject(targetJSONFile);
      println("  reading in for " + sp.bucketName);
      sp.orderedTopSplines = new ArrayList<ArrayList<Spline>>();
      sp.orderedBottomSplines = new ArrayList<ArrayList<Spline>>();
      JSONArray tops = json.getJSONArray("tops");
      for (int i = 0; i < tops.size(); i++) {
        JSONArray layer = tops.getJSONArray(i);
        ArrayList<Spline> layerSplines = new ArrayList<Spline>();
        for (int j = 0; j < layer.size(); j++) {
          layerSplines.add(new Spline(layer.getJSONObject(j)));
        }
        sp.orderedTopSplines.add(layerSplines);
      }

      JSONArray bottoms = json.getJSONArray("bottoms");
      for (int i = 0; i < bottoms.size(); i++) {
        JSONArray layer = bottoms.getJSONArray(i);
        ArrayList<Spline> layerSplines = new ArrayList<Spline>();
        for (int j = 0; j < layer.size(); j++) {
          layerSplines.add(new Spline(layer.getJSONObject(j)));
        }
        sp.orderedBottomSplines.add(layerSplines);
      }
      println("  done reading in " + sp.bucketName);
    }
    catch (Exception e) {
      println("could not load/find " + targetJSONFile);
    }
  } 

  /*
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
   */
} // end readInSplinesForSpLabels


//
//
//
//
//

