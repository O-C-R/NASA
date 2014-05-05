//
void makeSpLabelHeights(SpLabel sp) {


  /*
  if (sp.orderedTopSplines.size() == 0 && sp.orderedBottomSplines.size() == 0) {
   makeOrderedLists(sp, distributionType);
   } // end if to check whether or not to make the ordered lists or if it is already done
   */


  println("making heights for " + sp.bucketName + " with orderedTopSplines: " + sp.orderedTopSplines.size() + " and orderedBottomSplines: " + sp.orderedBottomSplines.size());

  // actually make the heights
  // try the tops
  ArrayList<Spline> thisList = null;
  ArrayList<Spline> otherList = null;
  ArrayList<Spline> boundSplines = new ArrayList<Spline>();
  boundSplines.add(sp.topSpline);

  for (int i = 0; i < sp.orderedTopSplines.size(); i++) {
    thisList = new ArrayList<Spline>();
    otherList = new ArrayList<Spline>();
    thisList = (ArrayList<Spline>)sp.orderedTopSplines.get(i).clone();

    if (i < sp.orderedTopSplines.size() - 1) otherList = (ArrayList<Spline>)sp.orderedTopSplines.get(i + 1).clone();
    // do something about the 0 spline position.. // add half?
    if (i == 0) {
        for (int j = i + 2; j < floor((float)sp.orderedTopSplines.size()); j ++) {
        otherList.addAll(sp.orderedTopSplines.get(j));
      }
    }

    for (int j = 0; j < thisList.size(); j++) {
      print(" " + sp.bucketName + " -i: " + i + " -j: " + j + " ___ ");
      makeHeightsFromSplineArray(thisList.get(j), otherList, boundSplines, PI/3, 3, true);
      println("done");
    }
    if (i == 2) {
      //println("MANUAL BREAK FOR HEIGHT TOP");
      //break;
    }
  }

  // TEMP SKIP DEBUGGGGG
  // try the bottoms
  boundSplines.clear();
  boundSplines = new ArrayList<Spline>();
  boundSplines.add(sp.bottomSpline);
  for (int i = 0; i < sp.orderedBottomSplines.size() - 1; i++) {
    thisList = new ArrayList<Spline>();
    otherList = new ArrayList<Spline>();
    thisList = (ArrayList<Spline>)sp.orderedBottomSplines.get(i).clone();
    if (i < sp.orderedBottomSplines.size() - 1) otherList = (ArrayList<Spline>)sp.orderedBottomSplines.get(i + 1).clone();

    if (i == 0) {
        for (int j = i + 2; j < floor((float)sp.orderedBottomSplines.size()); j ++) {
        otherList.addAll(sp.orderedBottomSplines.get(j));
      }
    }

    for (int j = 0; j < thisList.size(); j++) {
      print(" " + sp.bucketName + " -i: " + i + " -j: " + j + " ___ ");
      makeHeightsFromSplineArray(thisList.get(j), otherList, boundSplines, PI/3, 3, false);
      println("done");
    }
    if (i == 2) {
      //println("MANUAL BREAK FOR HEIGHT BOTTOM");
      //break;
    }
  }







  /*
    // try the tops
   for (int i = 0; i < sp.orderedTopSplines.size() - 1; i++) {
   ArrayList<Spline> thisList = sp.orderedTopSplines.get(i);
   ArrayList<Spline> otherList = sp.orderedTopSplines.get(i + 1);
   for (int j = 0; j < thisList.size(); j++) {
   makeHeightsFromSplineArray(thisList.get(j), otherList, PI/3, 3, true);
   }
   println("  " + sp.bucketName + " -- orderedTopSplines: " + i);
   }
   
   
   // try the bottoms
   for (int i = 0; i < sp.orderedBottomSplines.size() - 1; i++) {
   ArrayList<Spline> thisList = sp.orderedBottomSplines.get(i);
   ArrayList<Spline> otherList = sp.orderedBottomSplines.get(i + 1);
   for (int j = 0; j < thisList.size(); j++) {
   makeHeightsFromSplineArray(thisList.get(j), otherList, PI/3, 3, false);
   }
   println("  " + sp.bucketName + " -- orderedBottomSplines: " + i);
   }
   */
} // end makeSpLabelHeights


//
// this will go through and assign heights to the targetspline based on its normal and the minimum
//  intersection distance given a certain range of rays
void makeHeightsFromSplineArray(Spline targetSpline, ArrayList<Spline> otherSplines, ArrayList<Spline> boundSplines, float sweepingAngle, int totalSweepCount, boolean goUp) {
  if (!targetSpline.facetsMade) return; // skip out if the thing isnt faceted

  PVector targetFacetPoint, targetUp, lineEnd, rotatedEnd;
  float amountToRotate;
  ArrayList<PVector> intersectionPoints, intersection;
  ArrayList<Float> intersectionDistances;

  otherSplines.addAll(boundSplines);

  targetSpline.useUpHeight = goUp; // save whether or not to use up or be reversed

  int lastPercent = -1;
  for (int i = 0; i < targetSpline.facetPoints.length; i+=1) {
    int thisPercent = floor(100 * (float)i / targetSpline.facetPoints.length);
    if (thisPercent != lastPercent) {
      print(".");
      lastPercent = thisPercent;
    }

    targetFacetPoint = targetSpline.facetPoints[i].get();
    targetUp = targetSpline.facetUps[i].get();
    if (!goUp) targetUp.mult(-1);

    intersectionPoints = new ArrayList<PVector>();
    intersectionDistances = new ArrayList<Float>();

    for (int k = 0; k < totalSweepCount; k++) {
      lineEnd = targetFacetPoint.get();
      amountToRotate = map(k, 0, totalSweepCount - 1, -sweepingAngle/2, sweepingAngle/2);
      if (Float.isNaN(amountToRotate)) amountToRotate = 0f;

      rotatedEnd = OCR3D.rotateUnitVector2D(targetUp, amountToRotate);

      rotatedEnd.mult(100);

      lineEnd.add(rotatedEnd);

      stroke(255, 30);
      //line(targetFacetPoint.x, targetFacetPoint.y, lineEnd.x, lineEnd.y);

      // collect the intersection points from all of the other splines.. room for optimization here
      int tempCount = 0;
      for (Spline other : otherSplines) {
        intersection = other.getPointByIntersection(targetFacetPoint, lineEnd);

        if (intersection != null) {
          // check if it is going in the 'right' direction.  if it is then add it to the collection
          intersectionPoints.add(intersection.get(0));
          intersectionDistances.add(intersection.get(0).dist(targetFacetPoint));
        }
      }
    }

    // go through and pick out the closest intersection point that isnt 0
    PVector closest = null;
    float closestDist = 10f;
    boolean started = false;
    if (intersectionPoints.size() > 0) {
      for (int j = 0; j < intersectionPoints.size(); j++) {
        if (!started || (intersectionDistances.get(j) < closestDist && intersectionDistances.get(j) > -1)) {
          closest = intersectionPoints.get(j);
          closestDist = intersectionDistances.get(j);
          started = true;
        }
      }
    }

    stroke(255, 0, 0);
    noFill();
    if (closest != null) {
      //ellipse(closest.x, closest.y, 5, 5);
    }

    // whether or not the closest pt exists, save it to the targetSpline
    float newHt = -1f;
    if (closest != null) newHt = closest.dist(targetFacetPoint);
    targetSpline.facetHeights = (float[])append(targetSpline.facetHeights, newHt);

    stroke(255, 150);
    if (closest != null) {
      //line(closest.x, closest.y, targetFacetPoint.x, targetFacetPoint.y);
      //println(newHt + " -- " + closest + " -- " + targetFacetPoint);
    }
  } // end i facetPoints
  // go back through and find any null points.  average them out
} // end makeHeights


//
void makeOrderedLists(SpLabel sp, int distributionType) {
  if (distributionType == MAKE_SPLINES_MIXED) {
    // make the orderedTopSplines, start from middle and go up
    ArrayList<Spline> splineList = new ArrayList<Spline>();
    splineList.add(sp.middleMain.get(1));
    sp.orderedTopSplines.add(splineList);
    splineList = new ArrayList<Spline>();
    splineList.add(sp.middleMain.get(0));
    sp.orderedTopSplines.add(splineList);

    for (int i = 0; i < sp.middleTops.size(); i++) {
      splineList = new ArrayList<Spline>();
      if (sp.middleTops.get(i).size() > 0) {
        splineList.addAll(sp.middleTops.get(i));
        sp.orderedTopSplines.add(splineList);
      }
    }
    // skip top
    //splineList = new ArrayList<Spline>();
    //splineList.add(sp.topSpline);
    //sp.orderedTopSplines.add(splineList);

    // make the orderedBottomSplines.  start from the middle and go down.  make a copy of the bottom middle spline
    splineList = new ArrayList<Spline>();
    splineList.add(sp.middleMain.get(1).getCopy());
    sp.orderedBottomSplines.add(splineList);
    for (int i = 0; i < sp.middleBottoms.size(); i++) {
      splineList = new ArrayList<Spline>();
      if (sp.middleBottoms.get(i).size() > 0) {
        splineList.addAll(sp.middleBottoms.get(i));
        sp.orderedBottomSplines.add(splineList);
      }
    }
    // skip bottom
    //splineList = new ArrayList<Spline>();
    //splineList.add(sp.bottomSpline);
    //sp.orderedBottomSplines.add(splineList);
  }
  else if (distributionType == MAKE_SPLINES_TOP_ONLY) { // meaning it will make the height lines go from the bottom up
    // bottom
    ArrayList<Spline> splineList = new ArrayList<Spline>();
    splineList.add(sp.bottomSpline);
    sp.orderedTopSplines.add(splineList);
    // bottomMiddles
    for (int i = sp.middleBottoms.size() - 1; i >= 0; i--) {
      splineList = new ArrayList<Spline>();
      if (sp.middleBottoms.get(i).size() > 0) {
        splineList.addAll(sp.middleBottoms.get(i));
        sp.orderedTopSplines.add(splineList);
      }
    }
    // middle bottom
    splineList = new ArrayList<Spline>();
    splineList.add(sp.middleMain.get(1));
    sp.orderedTopSplines.add(splineList);
    // middle top
    splineList = new ArrayList<Spline>();
    splineList.add(sp.middleMain.get(0));
    sp.orderedTopSplines.add(splineList);
    // upperTops
    for (int i = 0; i < sp.middleTops.size(); i++) {
      splineList = new ArrayList<Spline>();
      if (sp.middleTops.get(i).size() > 0) {
        splineList.addAll(sp.middleTops.get(i));
        sp.orderedTopSplines.add(splineList);
      }
    }
    // skip the top
  }
  else if (distributionType == MAKE_SPLINES_BOTTOM_ONLY) { // meaning it will make the height lines go from the bottom up
    // top
    ArrayList<Spline> splineList = new ArrayList<Spline>();
    splineList.add(sp.topSpline);
    sp.orderedBottomSplines.add(splineList);
    // upperTops
    for (int i = sp.middleTops.size() - 1; i >= 0; i--) {
      splineList = new ArrayList<Spline>();
      if (sp.middleTops.get(i).size() > 0) {
        splineList.addAll(sp.middleTops.get(i));
        sp.orderedBottomSplines.add(splineList);
      }
    }
    // middle top
    splineList = new ArrayList<Spline>();
    splineList.add(sp.middleMain.get(0));
    sp.orderedBottomSplines.add(splineList);
    // middle bottom
    splineList = new ArrayList<Spline>();
    splineList.add(sp.middleMain.get(1));
    sp.orderedBottomSplines.add(splineList);
    // bottomMiddles
    for (int i = 0; i < sp.middleBottoms.size(); i++) {
      splineList = new ArrayList<Spline>();
      if (sp.middleBottoms.get(i).size() > 0) {
        splineList.addAll(sp.middleBottoms.get(i));
        sp.orderedBottomSplines.add(splineList);
      }
    }
    // skip bottom
  }
} // end makeOrderedLists


//
//
//
//
//
//

