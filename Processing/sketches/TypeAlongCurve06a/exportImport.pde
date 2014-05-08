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


  // save the flares
  if (flares != null && flares.size() > 0) {
    println("exporting flares");
    for (Flare f : flares) {
      JSONObject flareJSON = f.getJSON();
      String exportName = "flares-"+ f.name + "-" + width + "-" + height;
      saveJSONObject(flareJSON, "splines/" + exportName + ".json");
    }
    println("done exporting flares");
  }
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
      if (json.hasKey("bottomSpline")) sp.bottomSpline = new Spline(json.getJSONObject("bottomSpline"));

      println("  done reading in " + sp.bucketName + " orderedTopSplines: " + sp.orderedTopSplines.size() + " orderedBottomSplines: " + sp.orderedBottomSplines.size());
    }
    catch (Exception e) {
      println("could not load/find " + targetJSONFile);
    }
  }

  // try to read in the flares
  // not that there are only two:
  String[] flareNames = {
    "topFlare", 
    "bottomFlare"
  };
  flares.clear();
  for (String s : flareNames) {
    String targetJSONFile = "splines/flares-"+ s + "-" + width + "-" + height + ".json";
    try {
      JSONObject json = loadJSONObject(targetJSONFile);
      Flare f = new Flare(json);
      flares.add(f);
      int tempCount = 0;
      for (ArrayList<FlareSpline> fss : f.flareSplines) tempCount+=fss.size();
      println("loaded flare: " + f.name + " with " + tempCount + " flareSplines");
    }
    catch (Exception e) {
      println("could not load/find " + targetJSONFile);
    }
  }
} // end readInSplinesForSpLabels



// 
void exportLabels() {
  println("in exportLabels");
  long startTime = millis();
  JSONObject json = new JSONObject();

  int goodExports = 0;

  JSONArray splabelsAR = new JSONArray();
  for (int j = 0; j < splabels.size(); j++) {
    JSONObject splabelLabels = new JSONObject();
    splabelLabels.setString("bucketName", splabels.get(j).bucketName);
    JSONArray labelsAR = new JSONArray();
    for (int i = 0; i < splabels.get(j).labels.size(); i++) {
      Label l = splabels.get(j).labels.get(i);
      labelsAR.setJSONObject(i, l.getJSON());
      goodExports++;
    }
    splabelLabels.setJSONArray("labels", labelsAR);
    splabelsAR.setJSONObject(j, splabelLabels);
  }
  json.setJSONArray("splabels", splabelsAR);

  saveJSONObject(json, "labels/labels-" + width + "-" + height + ".json");


  println("done exporting " + goodExports + " labels in " + (int)(((float)millis() - startTime) / 1000) + " seconds");
} // end exportLabels

//
void importLabels() {
  println("in import");
  long startTime = millis();
  int importCount = 0;
  int switchCount = 0;

  HashMap<String, String> labelBlockHM = new HashMap<String, String>(); // label.baseText+bucketName, replacement label text
  labelBlockHM.put("test+space_shuttle", "my replacement");
  //labelBlockHM.put("filtering data+", "making awesome");
  //labelBlockHM.put("two countries+russia", "supercool");
  //labelBlockHM.put("lunar landing+research_and_development", "supercool");


  println("in importLabels");
  try {
    JSONObject json = loadJSONObject("labels/labels-" + width + "-" + height + ".json");

    JSONArray splabelsAR = json.getJSONArray("splabels");
    for (int k = 0; k < splabelsAR.size(); k++) {
      JSONObject splabelJSON = splabelsAR.getJSONObject(k); 
      String splabelName =  splabelJSON.getString("bucketName");
      SpLabel sp = null;
      for (int i = 0; i < splabels.size(); i++) {
        if (splabels.get(i).bucketName.equals(splabelName)) {
          sp = splabels.get(i);
          break;
        }
      }
      if (sp == null) continue;


      JSONArray jar = splabelJSON.getJSONArray("labels");
      for (int i = 0; i < jar.size(); i++) {
        Label l = new Label(jar.getJSONObject(i));

        //println("l.baseText: " + l.baseText);
        //println(labelBlockHM);
        print("_" + l.baseText);

        // check if it's cool or not.  if it isnt then make a new replacement label 
        if (labelBlockHM.containsKey(l.baseText + "+" + l.bucketName)) { 
          String newText = (String)labelBlockHM.get(l.baseText + "+" + l.bucketName);
          println("making new replacement label for " + l.baseText + " of " + l.bucketName + " as: " + newText);
          // make replacement term
          Term replacementTerm = new Term();
          replacementTerm.term = newText;
          replacementTerm.fillAlphaPercent = l.fillAlpha;

          Label newLabel = new Label(replacementTerm, newText, LABEL_ALIGN_CENTER, l.labelAlignVertical, sp.bucketName);
          float newDistancePercent = (l.startDistance + l.endDistance) / 2;
          newDistancePercent /= l.spline.totalDistance;
          newLabel.assignSplineAndLocation(l.spline, newDistancePercent);
          newLabel.makeLetters(-1);
          newLabel.spaceLettersFromCenter();
          l = newLabel;
          switchCount++;
        }

        // add to a particular bucket or something here
        sp.addLabel(l);
        // do something about removing the term from the splabel/bucket
        Bucket b = (Bucket)bucketsHM.get(l.bucketName);
        b.takeOutTerm(l.term);
        importCount++;
      }
    }
  }
  catch (Exception e) {
    println("problem importing labels");
  }

  println("_X");

  println("done importing " + importCount + " labels in " + (int)(((float)millis() - startTime) / 1000) + " seconds");
  println(" switched out: " + switchCount + " labels");
} // end importLabels

//
//
//
//
//

