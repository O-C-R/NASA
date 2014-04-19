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

    // save top and bottom and middles
    if (splabels.get(k).topSpline != null) json.setJSONObject("topSpline", splabels.get(k).topSpline.getJSON());
    if (splabels.get(k).bottomSpline != null) json.setJSONObject("bottomSpline", splabels.get(k).bottomSpline.getJSON());
    if (splabels.get(k).middleMain != null) {
      if (splabels.get(k).middleMain.size() == 2) {
        json.setJSONObject("middleTop", splabels.get(k).middleMain.get(0).getJSON());
        json.setJSONObject("middleBottom", splabels.get(k).middleMain.get(1).getJSON());
      }
    }


    String exportName = "splines-"+ splabels.get(k).bucketName + "-" + width + "-" + height;
    saveJSONObject(json, "splines/" + exportName + ".json");
    println(" finished exporting splabel: " + exportName);
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
      println("    added " + sp.orderedTopSplines.size() + " top splines");

      JSONArray bottoms = json.getJSONArray("bottoms");
      for (int i = 0; i < bottoms.size(); i++) {
        JSONArray layer = bottoms.getJSONArray(i);
        ArrayList<Spline> layerSplines = new ArrayList<Spline>();
        for (int j = 0; j < layer.size(); j++) {
          layerSplines.add(new Spline(layer.getJSONObject(j)));
        }
        sp.orderedBottomSplines.add(layerSplines);
      }
      println("    added " + sp.orderedBottomSplines.size() + " bottom splines");


      if (json.hasKey("middleTop") && json.hasKey("middleBottom")) {
        sp.middleMain = new ArrayList<Spline>();
        sp.middleMain.clear();
        sp.middleMain.add(new Spline(json.getJSONObject("middleTop")));
        sp.middleMain.add(new Spline(json.getJSONObject("middleBottom")));
      }

      if (json.hasKey("topSpline")) sp.topSpline = new Spline(json.getJSONObject("topSpline"));
      if (json.hasKey("bottomSpline")) sp.topSpline = new Spline(json.getJSONObject("bottomSpline"));

      println("  done reading in " + sp.bucketName + " orderedTopSplines: " + sp.orderedTopSplines.size() + " orderedBottomSplines: " + sp.orderedBottomSplines.size());
    }
    catch (Exception e) {
      println("could not load/find " + targetJSONFile);
    }
  } 
} // end readInSplinesForSpLabels


//
//
//
//
//

