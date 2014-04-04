import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;

Spline test;
Spline test2 = null;
Spline test3 = null;


ArrayList<Spline> splines = new ArrayList<Spline>();

ArrayList<Label> labels = new ArrayList<Label>();

float defaultFontSize = 16f;
PFont font;

//
void setup() {
  size(1200, 500);
  OCRUtils.begin(this);
  background(255);
  randomSeed(1667);

  font = createFont("Helvetica", defaultFontSize);

  float y = 100;
  for (int i = 0; i < 3; i++) {
    Spline newSpline = new Spline();
    float x = 100;
    newSpline.addCurvePoint(new PVector(0, y));
    newSpline.addCurvePoint(new PVector(50, y));
    while (true) {
      newSpline.addCurvePoint(new PVector(x, y + 100 * (noise(.01 * (y + x)) - .5)));
      x += 50;
      if (x >= width - 50) break;
    }
    newSpline.addCurvePoint(new PVector(width - 50, y));
    newSpline.addCurvePoint(new PVector(width, y));
    newSpline.makeFacetPoints(.15f, 10f, 120, true);
    splines.add(newSpline);
    y += 40;
  }
  test = new Spline();


  Label newLabel = new Label("hello world.  this is my super awesome text on a path");
  newLabel.assignSplineAndLocation(splines.get(0), .5);
  //newLabel.makeLetters();
  labels.add(newLabel);
  
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
} // end setup

//
void draw() {
  background(255);

  for (Spline s : splines) {
    noFill();
    stroke(0, 100);
    strokeWeight(3);
    s.display(g);
    //s.displayCurvePoints(g);
    noFill();
    strokeWeight(1);
    stroke(0, 0, 255);
    //s.displayFacetPoints(g);
  }

  float newPercent = splines.get(0).getPercentByAxis("x", new PVector(mouseX, mouseY));



  //labels.get(0).assignSplineAndLocation(splines.get(0), newPercent);
  //if (keyPressed && keyCode == SHIFT) labels.get(0).labelAlign = LABEL_ALIGN_RIGHT;
  //else if (keyPressed && key == ' ') labels.get(0).labelAlign = LABEL_ALIGN_CENTER;
  //else labels.get(0).labelAlign = LABEL_ALIGN_LEFT;
  //labels.get(0).makeLetters();
  
  for (Label l : labels) {
    l.assignSplineAndLocation(l.spline, newPercent);
   l.makeLetters(); 
  }

  fill(0);
  for (Label l : labels) {
    l.display(g);
  }

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
} // end keyReleased

//
void mouseReleased() {
  test.addCurvePoint(new PVector(mouseX, mouseY));
  test.display(g);
  test.displayCurvePoints(g);
} // end mouseReleased

//
//
//
//

