//
void makeSpLabelHeights(SpLabel sp) {
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
} // end makeSpLabelHeights


//
// this will go through and assign heights to the targetspline based on its normal and the minimum
//  intersection distance given a certain range of rays
void makeHeightsFromSplineArray(Spline targetSpline, ArrayList<Spline> otherSplines, float sweepingAngle, int totalSweepCount, boolean goUp) {
  if (!targetSpline.facetsMade) return; // skip out if the thing isnt faceted

  PVector targetFacetPoint, targetUp, lineEnd, rotatedEnd;
  float amountToRotate;
  ArrayList<PVector> intersectionPoints, intersection;
  ArrayList<Float> intersectionDistances;
  
  targetSpline.useUpHeight = goUp; // save whether or not to use up or be reversed

  for (int i = 0; i < targetSpline.facetPoints.length; i+=1) {
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
      for (Spline other : otherSplines) {
        intersection = other.getPointByIntersection(targetFacetPoint, lineEnd);
        if (intersection != null) {
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
        if (!started || intersectionDistances.get(j) < closestDist) {
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

  //
  /*
  float lastGoodHeight = -1;
  int lastGoodIndex = 0;
  boolean atStart = true;
  for (int i = 0; i < targetSpline.facetHeights.length; i++) {
    if (targetSpline.facetHeights[i] == -1) {
      // check first one
      if (atStart) {
        for (int j = i + 1; j < targetSpline.facetHeights.length; j++) {
          if (targetSpline.facetHeights[j] > 0) {
            targetSpline.facetHeights[i] = targetSpline.facetHeights[j];
            lastGoodHeight = targetSpline.facetHeights[j];
            if (atStart) atStart = false;
          }
        }
      }
      else {
        float nextHeight = -1f;
        int count = 0;
        int nextGoodIndex = 0;
        for (int j = i + 1; j < targetSpline.facetHeights.length; j++) {
          count++;
          if (targetSpline.facetHeights[j] > 0) {
            nextHeight = targetSpline.facetHeights[j];
            nextGoodIndex = j;
            break;
          }
        }
        if (nextHeight == -1) {
          // meaning no other value was found, use last value
          targetSpline.facetHeights[i] = lastGoodHeight;
        }
        else {
          //println("i: " + i + " lastGoodHeight: " + lastGoodHeight + " lastGoodIndex: "+ lastGoodIndex + " count: " + count + " nextHeight: " + nextHeight);
          targetSpline.facetHeights[i] = ((((float)(nextGoodIndex - lastGoodIndex) - count) * nextHeight) / (nextGoodIndex - lastGoodIndex) + (float)(count) * lastGoodHeight / (nextGoodIndex - lastGoodIndex));
        }
      }
    }
    else {
      lastGoodHeight = targetSpline.facetHeights[i];
      lastGoodIndex = i;
    }
  }
  */
} // end makeHeights

//
//
//
//
//
//

