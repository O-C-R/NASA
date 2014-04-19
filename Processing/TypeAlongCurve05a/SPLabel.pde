// combination of Spline and Label = SpLabel

class SpLabel {
  String bucketName = "";
  ArrayList<Label> labels = new ArrayList<Label>();
  Spline topSpline = null; // top masterSpline
  Spline bottomSpline = null; // bottom masterSpline
  //Spline topNeighborSpline = null; // if there is a SpLabel above it, this will be the first spline above the topSpline
  //Spline bottomNeighborSpline = null; // same for the bottom

  float minimumVariation = .01; // will not go within this % of the edge
  float variationNumber = .02; // control the noise variation.. arbitrary, needs testing
  float randomNumber = random(100); // used as a sort of seed

  // deal with a middle split
  boolean isMiddleSpLabel = false;
  Spline middleAdjustSpline = null; // if this is the middle spline, then this will be used to calculate the height instead of the top neighbor for the middle spline


  // skipZone and
  HashMap<Integer, Float> skipZones = new HashMap<Integer, Float>(); // ok because the years serve as the mapped x marker.  round to integer

  // MIDDLE SPLINES
  ArrayList<Spline>middleMain = null; // the two main lines that go in the middle of the splabel
  ArrayList<ArrayList<Spline>> middleTops = null; // when making the children and grandchildren they will be stored here
  ArrayList<ArrayList<Spline>> middleBottoms = null;

  ArrayList<ArrayList<Spline>> orderedTopSplines = new ArrayList<ArrayList<Spline>>();
  ArrayList<ArrayList<Spline>> orderedBottomSplines = new ArrayList<ArrayList<Spline>>();


  float[] data = new float[0];
  //ArrayList<Spline> middleSplines = new ArrayList<Spline>();

  int tempNumericalId = -1;

  // tell whether or not this SpLabel is on the upper or lower half.  true if it is the middle one
  boolean isOnTop = false; 
  boolean isOnBottom = false;

  float maxHeight = 0;  

  color c = color(random(255), random(255), random(255));

  // 
  SpLabel(String bucketName) {
    this.bucketName = bucketName;
  } // end constructor

  //
  void saveMaxHeight(float h) {
    maxHeight = (maxHeight > h ? maxHeight : h);
  } // end saveMaxHeight

  //
  void blendSPLabelSplinesVertically(int count, float splineCPDistance, float maximumPercentSplineSpacing, int distributionType) {
    /*
    if (variationSpline == null) {
     middleSplines = blendSplinesVertically(topSpline, bottomSpline, count, splineCPDistance);
     println("made middleSplines size of: " + middleSplines.size());
     }
     else {
     middleSplines = blendSplinesVerticallyWithWeight(topSpline, bottomSpline, count, splineCPDistance, variationSpline);
     println("made middleSplines size of: " + middleSplines.size());
     }
     */

    middleMain = middleMakerVertical(topSpline, bottomSpline, splineCPDistance, maximumPercentSplineSpacing);

    // do the top and the bottom
    // bottom first


    ArrayList<Spline> lastGeneration = makeCutoffSplines2(bottomSpline, middleMain.get(1), minimumSplineSpacing, childMaxPercentMultiplier * maximumPercentSplineSpacing, false);
    if (lastGeneration != null) {
      if (middleBottoms == null) middleBottoms = new ArrayList<ArrayList<Spline>>();
      middleBottoms.add(lastGeneration);
    }

    for (int k = 0; k < 200; k++) { // arbitrary limit
      ArrayList<Spline> temp = new ArrayList<Spline>();
      for (int i = 0; i < lastGeneration.size(); i++) {
        ArrayList<Spline> newGeneration = makeCutoffSplines2(bottomSpline, lastGeneration.get(i), minimumSplineSpacing, childMaxPercentMultiplier * maximumPercentSplineSpacing, false);
        temp.addAll(newGeneration);
      }
      middleBottoms.add(temp);
      println("k: " + k + " bottom temp.size(): " + temp.size());
      lastGeneration = temp;
      if (temp.size() == 0) break;
    }



    lastGeneration = makeCutoffSplines2(topSpline, middleMain.get(0), minimumSplineSpacing, childMaxPercentMultiplier * maximumPercentSplineSpacing, false);
    if (lastGeneration != null) {
      if (middleTops == null) middleTops = new ArrayList<ArrayList<Spline>>();
      middleTops.add(lastGeneration);
    }
    for (int k = 0; k < 200; k++) { // arbitrary limit
      ArrayList<Spline> temp = new ArrayList<Spline>();
      for (int i = 0; i < lastGeneration.size(); i++) {
        ArrayList<Spline> newGeneration = makeCutoffSplines2(topSpline, lastGeneration.get(i), minimumSplineSpacing, childMaxPercentMultiplier * maximumPercentSplineSpacing, false);
        temp.addAll(newGeneration);
      }
      middleTops.add(temp);
      println("k: " + k + " top temp.size(): " + temp.size());
      lastGeneration = temp;
      if (temp.size() == 0) break;
    }

    makeOrderedLists(this, distributionType);

    println("done making divisions");
  } // end blendSPLabelSplinesVertically 




  // TO DO FUNCTIONS
  //
  public Label makeCharLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s) {
    return makeLabel(label, textAlign, targetDistance, wiggleRoom, s, false, true);
  } // end makeCharLabel

  //
  // unfinished
  public Label makeStraightLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s) {
    return makeLabel(label, textAlign, targetDistance, wiggleRoom, s, true, false);
  } // end makeStrighLabel 

  //
  private Label makeLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s, boolean straightText, boolean varySize) {
    /*
    // if it is the middle line and skipMiddleLine is on, then return null
     if (isMiddleSpLabel && skipMiddleLine && middleSplines.size() > 0) {
     if (s == middleSplines.get(floor((float)middleSplines.size() / 2))) {
     return null;
     }
     }
     
     Label newLabel = new Label(label, textAlign);
     */

    /*
    // first determine which splines are above and below the given one
     Spline buddySplineTop = null;
     Spline buddySplineBottom = null;
     if (s == topSpline) {
     buddySplineTop = topNeighborSpline;
     if (middleSplines.size() > 0) buddySplineBottom = middleSplines.get(0);
     else buddySplineBottom = bottomSpline;
     }
     else if (s == bottomSpline) {
     buddySplineBottom = bottomNeighborSpline;
     if (middleSplines.size() > 0) buddySplineTop = middleSplines.get(middleSplines.size() - 1);
     else buddySplineTop = topSpline;
     }
     else {
     for (int i = 0; i < middleSplines.size(); i++) {
     if (middleSplines.get(i) == s) {
     if (i == 0) {
     buddySplineTop = topSpline;
     if (i < middleSplines.size() - 1) buddySplineBottom = middleSplines.get(i + 1);
     else buddySplineBottom = bottomSpline;
     }
     else if (i == middleSplines.size() - 1) {
     buddySplineBottom = bottomSpline;
     if (i > 0) {
     buddySplineTop = middleSplines.get(i - 1);
     }
     else buddySplineTop = topSpline;
     }
     else {
     // check for a dividing middle spline
     if (isMiddleSpLabel && middleAdjustSpline != null && i == (floor((float)middleSplines.size() / 2))) {
     buddySplineTop = middleAdjustSpline;
     }
     else {
     buddySplineTop = middleSplines.get(i - 1);
     buddySplineBottom = middleSplines.get(i + 1);
     }
     }
     break;
     }
     }
     }
     */


    /*

     boolean validLabel = false;
     // then go through and find the maximum or minimum heights to use if !varySize
     if (!varySize) {
     }
     // or do the character assignment if !straightText and varySize
     else {
     newLabel.assignSplineAndLocation(s, buddySplineTop, buddySplineBottom, (targetDistance / s.totalDistance));
     newLabel.makeLetters(-1); // -1 for variable sizing
     validLabel = true;
     }
     
     //if (validLabel) labels.add(newLabel);
     
     if (validLabel) return newLabel;
     else return null;
     */
    return null;
  } // end makeLabel

    //
  public void addLabel(Label labelIn) {
    labels.add(labelIn);
  } // end addLabel


  //
  // this will check whether or not a starting distance and ending distance are free for population
  boolean spacingIsOpen(Spline targetSpline, float startDistance, float endDistance) {
    if (startDistance < 0) return false;
    if (endDistance > targetSpline.totalDistance) return false;
    for (Label l : labels) {
      if (l.spline == targetSpline) {
        if ((l.startDistance >= startDistance && l.startDistance <= endDistance) || (l.endDistance >= startDistance && l.endDistance <= endDistance)) return false;
        if ((l.startDistance <= startDistance && l.endDistance >= endDistance)) return false;
      }
    } 
    return true;
  } // end spacingIsOpen

  //
  void markSkipZone(float x, float textWidth) {
    int skipX = (int)x;
    if (skipZones.containsKey(skipX)) {
      Float oldWidth = (Float)skipZones.get(skipX);
      if (textWidth < oldWidth) {
        skipZones.put(skipX, textWidth);
        //println("updated skip zone.  skipZones.size(): " + skipZones.size());
      }
    }
    else {
      skipZones.put(skipX, textWidth);
      //println("marked newskip zone.  skipZones.size(): " + skipZones.size());
    }
  } // end markSkipZone

  //
  boolean shouldSkip(float x, float textWidth) {
    int skipX = (int)x;
    if (skipZones.containsKey(skipX)) {
      Float oldWidth = (Float)skipZones.get(skipX);
      //println(skipZones);
      if (textWidth >= oldWidth) return true;
    }
    return false;
  } // end shouldSkip


  //
  // try to get the label closest to a distance based on left or right
  Label getClosestLabel(Spline targetSpline, float targetDistance, boolean rightSide) {
    Label closestLabel = null;
    ArrayList<Label> options = new ArrayList<Label>();
    for (Label l : labels) {
      if (l.spline == targetSpline) {
        if (rightSide) {
          if (l.startDistance > targetDistance) options.add(l);
        }
        else {
          if (l.endDistance < targetDistance) options.add(l);
        }
      }
    }

    if (options.size() == 0) return null;

    float lastClosestDistance = 0f;
    for (int i = 0; i < options.size(); i++) {
      if (i == 0) {
        closestLabel = options.get(i);
        lastClosestDistance = abs((rightSide ? options.get(i).startDistance : options.get(i).endDistance) - targetDistance);
      }
      else {
        float thisDistance = abs((rightSide ? options.get(i).startDistance : options.get(i).endDistance) - targetDistance);
        if (thisDistance < lastClosestDistance) {
          closestLabel = options.get(i);
          lastClosestDistance = thisDistance;
        }
      }
    }
    return closestLabel;
  } // end getClosestLabel

    //
  void display() {
    for (Label l : labels) {
      l.display();
    }
  } // end display

    //
  void displaySplines() {
    noFill();
    stroke(c, 100);
    strokeWeight(2);
    if (isOnTop) topSpline.display();
    if (isOnBottom) bottomSpline.display();
    strokeWeight(1);
    //for (Spline s : middleSplines) s.display();

    if (middleMain != null) {
      stroke(c, 100);
      middleMain.get(0).display();
      stroke(c, 100);
      middleMain.get(1).display();
    }    

    /*
    if (middleTops != null) {
     for (ArrayList<Spline> tops : middleTops) {
     for (Spline s : tops) s.display();
     }
     }
     if (middleBottoms != null) {
     for (ArrayList<Spline> bottoms : middleBottoms) {
     for (Spline s : bottoms) s.display();
     }
     }
     */
    if (orderedTopSplines != null) {
      for (ArrayList<Spline> tops : orderedTopSplines) {
        for (Spline s : tops) s.display();
      }
    }
    if (orderedBottomSplines != null) {
      for (ArrayList<Spline> tops : orderedBottomSplines) {
        for (Spline s : tops) s.display();
      }
    }

    fill(c);
    textAlign(LEFT);
    textSize(14);
    if (isOnTop) text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight + " id: " + tempNumericalId + " dist: " + topSpline.totalDistance, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).x, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).y);
    if (isOnBottom) text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight + " id: " + tempNumericalId + " dist: " + bottomSpline.totalDistance, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).x, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).y);
  } // end displaySplines


  //
  void displayFacetPoints() {
    stroke(0, 50);
    strokeWeight(1);
    if (isOnTop) topSpline.displayFacetPoints();
    if (isOnBottom) bottomSpline.displayFacetPoints();
    //for (Spline s : middleSplines) s.displayFacetPoints();
    if (middleMain != null) {
      stroke(0, 30);
      middleMain.get(0).displayFacetPoints();
      stroke(c, 100);
      middleMain.get(1).displayFacetPoints();
    }
  } // end displayFacetPoints

    //
  void displayHeights() {
    stroke(0, 255, 110, 150);
    noFill();
    //for (ArrayList<Spline> spList : orderedTopSplines) {
    for (int i = 0; i < orderedTopSplines.size(); i++) {
      for (Spline sp : orderedTopSplines.get(i)) {
        //sp.display();
        sp.displayHeights();
      }
    }

    stroke(255, 0, 0, 150);
    for (int i = 0; i < orderedBottomSplines.size(); i++) {
      for (Spline sp : orderedBottomSplines.get(i)) {
        //sp.display();
        sp.displayHeights();
      }
    }
  } // end displayHeights

    //
  void makeNewLabel() {
  } // end makeNewLabel



    //
  // go through all splines and see what's available?
  // do this by taking adding half the dist to top and half the dist to bottom
  // if no above or below then double the one that does exist
  float findAvailableHeightForX(float x) {
    float available = defaultFontSize;

    return available;
  } // end findAvailableHeightForX
} // end class SpLabel

//
//
//
//
//
//

