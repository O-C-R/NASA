import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;

import java.util.Map;


Spline top, bottom;
ArrayList<Spline> middleMain = new ArrayList<Spline>();
ArrayList<Spline> middles = new ArrayList<Spline>();

ArrayList<Spline> children = new ArrayList<Spline>();


float splineMinAngleInDegrees = .05f; // .02 for high
float splineMinDistance = 13f; // minimum distance between makeing a facet
int splineDivisionAmount = 150; // how many divisions should initially be made
boolean splineFlipUp = true; // whether or not to flip the thing

float minimumSplineSpacing = 12; // 4f;
float maximumPercentSplineSpacing = .25;
float childMaxPercentMultiplier = 1.85; // 2 woudl be the same as the parent
float testSplineSpacing = minimumSplineSpacing;

float[] padding = {
  20, 20, 20, 20
};

//
void setup() {
  size(1200, 500); 

  randomSeed(1849);
  //noiseSeed(1982);
  noiseSeed(2133);

  int pts = 15;
  top = new Spline();
  for (int i = 0; i < pts; i++) {
    float x = map(i, 0, pts - 1, padding[3], width - padding[1]);
    float y = 30 + 70 * noise(10 + i * 1) + 40;
    top.addCurvePoint(new PVector(x, y));
  }


  bottom = new Spline();
  for (int i = 0; i < pts; i++) {
    float x = top.curvePoints.get(i + 1).x; //map(i, 0, pts - 1, padding[3], width - padding[1]);
    float y = top.curvePoints.get(i + 1).y + 1 * 280 * noise(2 * i + 14) + testSplineSpacing;
    bottom.addCurvePoint(new PVector(x + random(-1, 1), y));  // ******* A BIT OF RANDOM NEEDED HERE BECAUSE CANNOT DETECT INTERSECTIONS ALL THE TIME IF THE XS ARE THE SAME.. . BUG
  }

  top.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
  bottom.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);

  middleMain = middleMakerVertical(top, bottom, minimumSplineSpacing, maximumPercentSplineSpacing);

  // bottom
  ArrayList<Spline> lastGeneration = makeCutoffSplines2(bottom, middleMain.get(1), minimumSplineSpacing, childMaxPercentMultiplier * maximumPercentSplineSpacing, false);

  children.addAll(lastGeneration);
  for (int k = 0; k < 17; k++) {
    ArrayList<Spline> temp = new ArrayList<Spline>();
    for (int i = 0; i < lastGeneration.size(); i++) {
      ArrayList<Spline> newGeneration = makeCutoffSplines2(bottom, lastGeneration.get(i), minimumSplineSpacing, childMaxPercentMultiplier * maximumPercentSplineSpacing, false);
      children.addAll(newGeneration);
      temp.addAll(newGeneration);
    }
    println("k: " + k + " temp.size(): " + temp.size());
    lastGeneration = temp;
    if (temp.size() == 0) break;
  }
  
  // top
  lastGeneration = makeCutoffSplines2(top, middleMain.get(0), minimumSplineSpacing, childMaxPercentMultiplier * maximumPercentSplineSpacing, true);

  children.addAll(lastGeneration);
  for (int k = 0; k < 17; k++) {
    ArrayList<Spline> temp = new ArrayList<Spline>();
    for (int i = 0; i < lastGeneration.size(); i++) {
      ArrayList<Spline> newGeneration = makeCutoffSplines2(top, lastGeneration.get(i), minimumSplineSpacing, childMaxPercentMultiplier * maximumPercentSplineSpacing, true);
      children.addAll(newGeneration);
      temp.addAll(newGeneration);
    }
    println("k: " + k + " temp.size(): " + temp.size());
    lastGeneration = temp;
    if (temp.size() == 0) break;
  }


  loop();
} // end setup

//
void draw() {
  //background(255);
  fill(0);
  text(frameCount, 20, 20);

  stroke(0, 255, 0);
  noFill();
  top.display();
  top.displayFacetPoints();
  stroke(255, 0, 0);
  bottom.display();
  //bottom.displayFacetPoints();


  stroke(0, 0, 255);
  for (Spline s : middleMain) {
    s.display();
    //s.displayFacetPoints();
  }

  stroke(100, 120, 200);
  for (Spline s : children) {
    s.display();
  }

  noLoop();
} // end draw

//
void keyReleased() {
  if (key == 'r') loop();
  if (key == 'b') {
    middles = blendSplinesVerticalReduce(top, bottom);
  }
  if (key == 'p') saveFrame("output/" + OCRUtils.getTimeStampWithDate() + ".png");
} // end keyReleased




//
//
//
//

