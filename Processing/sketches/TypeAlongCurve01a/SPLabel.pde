// combination of Spline and Label = SpLabel

class SpLabel {
  String bucketName = "";
  ArrayList<Label> labels = new ArrayList<Label>();
  Spline topSpline = null; // top masterSpline
  Spline bottomSpline = null; // bottom masterSpline
  Spline topNeighborSpline = null; // if there is a SpLabel above it, this will be the first spline above the topSpline
  Spline bottomNeighborSpline = null; // same for the bottom
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
    middleSplines = blendSplinesByDistance(topSpline, bottomSpline, count, splineCPDistance);
  } // end blendSplines



  // TO DO FUNCTIONS
  //
  public void makeCharLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s) {
    makeLabel(label, textAlign, targetDistance, wiggleRoom, s, false, true);
  } // end makeCharLabel

  //
  public void makeStraightLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s) {
    makeLabel(label, textAlign, targetDistance, wiggleRoom, s, true, false);
  } // end makeStrighLabel 

  //
  private void makeLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s, boolean straightText, boolean varySize) {
    Label newLabel = new Label(label);

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
    
    if (validLabel) labels.add(newLabel);
  } // end makeLabel


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

    /*
    if (topNeighborSpline != null) {
     pg.line(middleSplines.get(0).curvePoints.get(1).x, middleSplines.get(0).curvePoints.get(1).y, topNeighborSpline.curvePoints.get(5).x, topNeighborSpline.curvePoints.get(5).y);  
     }
     if (bottomNeighborSpline != null) {
     pg.line(middleSplines.get(middleSplines.size() - 1).curvePoints.get(1).x, middleSplines.get(middleSplines.size() - 1).curvePoints.get(1).y, bottomNeighborSpline.curvePoints.get(5).x, bottomNeighborSpline.curvePoints.get(5).y);
     }
     */
  } // end displaySplines

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

