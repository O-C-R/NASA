import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;


// assume this is in order already or whatever
String[] fakeBucketWords = {
  "alphabet", 
  "belt buckle", 
  "charlie", 

  "doodlebug", 

  "eeg machine", 
  /*  
   "facebook",
   "gamora"
   */
};
int[][] fakeBucketData = new int[fakeBucketWords.length][0];

ArrayList<Spline> splines = new ArrayList<Spline>();

ArrayList<SpLabel> splabels = new ArrayList<SpLabel>(); 

ArrayList<Label> labels = new ArrayList<Label>();

float defaultFontSize = 16f;
PFont font;

//
void setup() {
  size(1700, 500);
  OCRUtils.begin(this);
  background(255);
  randomSeed(1667);

  font = createFont("Helvetica", defaultFontSize);


  makeFakeBucketData(30);

  makeMasterSpLabels(g);

  splitMasterSpLabels(20, 30); // maxHeight, spline cp distance

  /*
  float y = 100;
   for (int i = 0; i < 2; i++) {
   Spline newSpline = new Spline();
   float x = 200;
   //newSpline.addCurvePoint(new PVector(100, y));
   //newSpline.addCurvePoint(new PVector(140, y));
   while (true) {
   newSpline.addCurvePoint(new PVector(x, y + (i % 2 == 0 ? 1 : -1) * 300 * (noise(.005 * x + y) - .5)));
   x += 150;
   if (x >= width - 200) break;
   }
   //newSpline.addCurvePoint(new PVector(width - 140, y));
   //newSpline.addCurvePoint(new PVector(width - 100, y));
   newSpline.makeFacetPoints(.15f, 10f, 120, true);
   splines.add(newSpline);
   y += 240;
   }
   
   int firstIndexOfSplineToBlend = 0;
   ArrayList<Spline> blend = blendSplinesByDistance(splines.get(firstIndexOfSplineToBlend), splines.get(firstIndexOfSplineToBlend + 1), 13, 20);
   splines.addAll(firstIndexOfSplineToBlend + 1, blend); // insert into the position
   
   // now that all splines are made, make SpLabels
   for (int i = 0; i < splines.size(); i++) {
   } 
   
   
   Label newLabel = new Label("hello world.  this is my super awesome text on a path");
   newLabel.assignSplineAndLocation(splines.get(4), .5);
   //newLabel.makeLetters();
   labels.add(newLabel);
   */

  /*
  Label newLabel2 = new Label("The wildly popular Ultimaker 2 3D printer is back in stock!");
   newLabel2.assignSplineAndLocation(splines.get(1), .5);
   newLabel2.labelAlign = LABEL_ALIGN_CENTER;
   //newLabel.makeLetters();
   labels.add(newLabel2);
   
   Label newLabel3 = new Label("The department is hosting its annual summer intensive program this June");
   newLabel3.assignSplineAndLocation(splines.get(2), .5);
   newLabel3.labelAlign = LABEL_ALIGN_RIGHT;
   //newLabel.makeLetters();
   labels.add(newLabel3);
   */
} // end setup

//
void draw() {

  background(255);

  for (Spline s : splines) {
    noFill();
    stroke(0, 100);
    strokeWeight(2);
    s.display(g);
    strokeWeight(1);
    s.displayCurvePoints(g);
    noFill();
    strokeWeight(1);
    stroke(0, 0, 255);
    //s.displayFacetPoints(g);
  }

  for (SpLabel sp : splabels) {
    sp.displaySplines(g);
  }


  /*
  float newPercent = labels.get(0).spline.getPercentByAxis("x", new PVector(mouseX, mouseY));
   
   labels.get(0).assignSplineAndLocation(labels.get(0).spline, newPercent);
   if (keyPressed && keyCode == SHIFT) labels.get(0).labelAlign = LABEL_ALIGN_RIGHT;
   else if (keyPressed && key == ' ') labels.get(0).labelAlign = LABEL_ALIGN_CENTER;
   else labels.get(0).labelAlign = LABEL_ALIGN_LEFT;
   labels.get(0).makeLetters();
   
   
   for (Label l : labels) {
   l.assignSplineAndLocation(l.spline, newPercent);
   l.makeLetters();
   }
   
   fill(0);
   for (Label l : labels) {
   l.display(g);
   }
   
   for (int i = 0; i < splines.size(); i++) {
   PVector loc = splines.get(i).curvePoints.get(1);
   fill(255, 0, 0);
   textSize(14);
   text(i, loc.x, loc.y);
   }
   */


  /*
  noFill();
   stroke(0, 100);
   strokeWeight(3);
   test.display(g);
   test.displayCurvePoints(g);
   noFill();
   strokeWeight(1);
   stroke(0, 0, 255);
   test.displayFacetPoints(g);
   */

  /*
  ArrayList<PVector> pt = test.getPointAlongSpline(map(mouseX, 0, width, 0, 1));
   noFill();
   stroke(255, 0, 0);
   ellipse(pt.get(0).x, pt.get(0).y, 10, 10);
   PVector up = pt.get(1).get();
   up.mult(30);
   up.add(pt.get(0));
   line(pt.get(0).x, pt.get(0).y, up.x, up.y);
   PVector right = pt.get(2).get();
   right.mult(50);
   right.add(pt.get(0));
   line(pt.get(0).x, pt.get(0).y, right.x, right.y);
   */

  /*
  ArrayList<PVector> pt;
   if (keyPressed && keyCode == SHIFT) pt = test.getPointByAxis("y", new PVector(mouseX, mouseY));
   else pt = test.getPointByAxis("x", new PVector(mouseX, mouseY));
   if (pt != null) {
   noFill();
   stroke(255, 0, 0);
   ellipse(pt.get(0).x, pt.get(0).y, 10, 10);
   }
   */

  //test.getPointByClosestPoint(new PVector(mouseX, mouseY));
} // end draw

//
void keyReleased() {  
  if (key == 'p') {
    String timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame("output/" + timeStamp + ".png");
  }
  if (keyCode == UP || keyCode == DOWN) {
    labels.get(0).spline = splines.get((int)random(splines.size()));
  }
} // end keyReleased

//
void mouseReleased() {
} // end mouseReleased

//
//
//
//

