// combination of Spline and Label = SpLabel

class SpLabel {
  String bucketName = "";
  ArrayList<Label> labels = new ArrayList<Label>();
  Spline topSpline = null;
  Spline bottomSpline = null;
  int[] data = new int[0];
  ArrayList<Spline> middleSplines = new ArrayList<Spline>();

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

  //
  void display(PGraphics pg) {
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
    if (isOnTop) pg.text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).x, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).y);
    if (isOnBottom) pg.text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).x, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).y);
    
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

