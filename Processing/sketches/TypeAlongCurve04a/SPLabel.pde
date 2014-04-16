// combination of Spline and Label = SpLabel

class SpLabel {
  String bucketName = "";
  ArrayList<Label> labels = new ArrayList<Label>();
  Spline topSpline = null; // top masterSpline
  Spline bottomSpline = null; // bottom masterSpline
  Spline topNeighborSpline = null; // if there is a SpLabel above it, this will be the first spline above the topSpline
  Spline bottomNeighborSpline = null; // same for the bottom

  Spline variationSpline = null; // this is the one that sort of bounces within the top and bottom splines.  used to distribute the spacing of the middleSplines
  float minimumVariation = .01; // will not go within this % of the edge
  float variationNumber = .02; // control the noise variation.. arbitrary, needs testing
  float randomNumber = random(100); // used as a sort of seed

  // deal with a middle split
  boolean isMiddleSpLabel = false;
  Spline middleAdjustSpline = null; // if this is the middle spline, then this will be used to calculate the height instead of the top neighbor for the middle spline


  // skipZone and
  HashMap<Integer, Float> skipZones = new HashMap<Integer, Float>(); // ok because the years serve as the mapped x marker.  round to integer



  float[] data = new float[0];
  ArrayList<Spline> middleSplines = new ArrayList<Spline>();

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
  void blendSPLabelSplinesByPercent(int count, float splineCPDistance) {
    if (variationSpline == null) middleSplines = blendSplinesByDistance(topSpline, bottomSpline, count, splineCPDistance);
    else middleSplines = blendSplinesByDistanceWithWeight(topSpline, bottomSpline, count, splineCPDistance, variationSpline);
  } // end blendSPLabelSplinesByPercent

  //
  void blendSPLabelSplinesVertically(int count, float splineCPDistance) {
    if (variationSpline == null) {
      middleSplines = blendSplinesVertically(topSpline, bottomSpline, count, splineCPDistance);
      println("made middleSplines size of: " + middleSplines.size());
    }
    else {
      middleSplines = blendSplinesVerticallyWithWeight(topSpline, bottomSpline, count, splineCPDistance, variationSpline);
      println("made middleSplines size of: " + middleSplines.size());
    }
  } // end blendSPLabelSplinesVertically 

  //
  // this is the one that wiggles between the top and bottom
  void makeVariationSpline() {
    variationSpline = new Spline();
    int divisions = 14 * (int)((float)topSpline.totalDistance / (topSpline.curvePoints.size()));
    for (int i = 0; i < divisions; i++) {
      float thisPercent = map(i, 0, divisions - 1, 0, 1);
      PVector pointA = topSpline.getPointAlongSpline(thisPercent).get(0);
      PVector dirA = pointA.get();
      dirA.y += 1; // make it point vertically
      ArrayList<PVector> intersect = bottomSpline.getPointByIntersection(pointA, dirA);
      if ( intersect == null) continue; // cutout if no middle
      PVector pointB = intersect.get(0);

      //float countPercent = map(noise(i * variationNumber + randomNumber), 0, 1, minimumVariation, 1 - minimumVariation); // this is what actually controls the variation
      // for now make it the middle
      float countPercent = .5;

      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      variationSpline.addCurvePoint(newPointA);
    }
    variationSpline.makeFacetPoints(topSpline.minAngleInDegrees, topSpline.minDistance, topSpline.divisionAmount, topSpline.flipUp);
  } // end makeVariationSpline


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
    // if it is the middle line and skipMiddleLine is on, then return null
    if (isMiddleSpLabel && skipMiddleLine && middleSplines.size() > 0) {
      if (s == middleSplines.get(floor((float)middleSplines.size() / 2))) {
        return null;
      }
    }

    Label newLabel = new Label(label, textAlign);

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
    for (Spline s : middleSplines) s.display();

    fill(c);
    textAlign(LEFT);
    textSize(14);
    if (isOnTop) text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight + " id: " + tempNumericalId + " dist: " + topSpline.totalDistance, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).x, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).y);
    if (isOnBottom) text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight + " id: " + tempNumericalId + " dist: " + bottomSpline.totalDistance, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).x, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).y);
  } // end displaySplines

  //
  void displayVariationSpline() {
    noFill();
    stroke(255, 0, 0, 50);
    strokeWeight(1);
    if (variationSpline != null) variationSpline.display();
  } // end displayVariationSpline

  //
  void displayFacetPoints() {
    stroke(0, 50);
    strokeWeight(1);
    if (isOnTop) topSpline.displayFacetPoints();
    if (isOnBottom) bottomSpline.displayFacetPoints();
    for (Spline s : middleSplines) s.displayFacetPoints();
  } // end displayFacetPoints

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

