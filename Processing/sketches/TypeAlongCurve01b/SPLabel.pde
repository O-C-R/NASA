// combination of Spline and Label = SpLabel

class SpLabel {
  String bucketName = "";
  ArrayList<Label> labels = new ArrayList<Label>();
  Spline topSpline = null; // top masterSpline
  Spline bottomSpline = null; // bottom masterSpline
  Spline topNeighborSpline = null; // if there is a SpLabel above it, this will be the first spline above the topSpline
  Spline bottomNeighborSpline = null; // same for the bottom

  Spline variationSpline = null; // this is the one that sort of bounces within the top and bottom splines.  used to distribute the spacing of the middleSplines
  float minimumVariation = .1; // will not go within this % of the edge
  float variationNumber = .1; // control the noise variation.. arbitrary, needs testing
  float randomNumber = random(100); // used as a sort of seed


  int[] data = new int[0];
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
  void blendSplines(int count, float splineCPDistance) {
    if (variationSpline == null) middleSplines = blendSplinesByDistance(topSpline, bottomSpline, count, splineCPDistance);
    else middleSplines = blendSplinesByDistanceWithWeight(topSpline, bottomSpline, count, splineCPDistance, variationSpline);
  } // end blendSplines

  //
  // this is the one that wiggles between the top and bottom
  void makeVariationSpline() {
    int topCurvePoints = topSpline.curvePoints.size();
    int bottomCurvePoints = bottomSpline.curvePoints.size();
    int curvePointsToUse = (int)(1 * (bottomCurvePoints < topCurvePoints ? bottomCurvePoints : topCurvePoints)); // make it twice as dense as the spline with the least curve points
    variationSpline = new Spline();
    for (int i = 0; i < curvePointsToUse; i++) {
      float percent = map(i, 0, curvePointsToUse - 1, 0, 1);
      PVector topPt = topSpline.getPointAlongSpline(percent).get(0).get();
      PVector bottomPt = bottomSpline.getPointAlongSpline(percent).get(0).get();

      float targetPercent = map(noise(i * variationNumber + randomNumber), 0, 1, minimumVariation, 1 - minimumVariation); // this is what actually controls the variation

        topPt.mult(targetPercent);
      bottomPt.mult(1 - targetPercent);

      PVector newPoint = PVector.add(topPt, bottomPt);
      variationSpline.addCurvePoint(newPoint);
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
            if (i > 0) buddySplineTop = middleSplines.get(i - 1);
            else buddySplineTop = topSpline;
          }
          else {
            buddySplineTop = middleSplines.get(i - 1);
            buddySplineBottom = middleSplines.get(i + 1);
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
  void display(PGraphics pg) {
    for (Label l : labels) {
      l.display(pg);
    }
  } // end display

  //
  void displaySplines(PGraphics pg) {
    pg.noFill();
    pg.stroke(c, 100);
    pg.strokeWeight(2);
    if (isOnTop) topSpline.display(pg);
    if (isOnBottom) bottomSpline.display(pg);
    pg.strokeWeight(1);
    for (Spline s : middleSplines) s.display(pg);

    pg.fill(c);
    pg.textAlign(LEFT);
    if (isOnTop) pg.text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight + " id: " + tempNumericalId, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).x, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).y);
    if (isOnBottom) pg.text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight + " id: " + tempNumericalId, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).x, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).y);
  } // end displaySplines

  //
  void displayVariationSpline(PGraphics pg) {
    pg.noFill();
    pg.stroke(255, 0, 0, 50);
    pg.strokeWeight(1);
    if (variationSpline != null) variationSpline.display(pg);
  } // end displayVariationSpline

  //
  void displayFacetPoints(PGraphics pg) {
    pg.stroke(0, 50);
    pg.strokeWeight(1);
    if (isOnTop) topSpline.displayFacetPoints(pg);
    if (isOnBottom) bottomSpline.displayFacetPoints(pg);
    for (Spline s : middleSplines) s.displayFacetPoints(pg);
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

