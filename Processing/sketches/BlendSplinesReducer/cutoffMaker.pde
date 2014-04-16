
//
ArrayList<Spline> makeCutoffSplines(Spline top, Spline middleTop, Spline middleBottom, Spline bottom, float minHeight, float maxHeightPercent) {
  float sweeptingAngle = PI / 3;// total sweep
  int totalSweepCount = 5; // how many divisions to make



  ArrayList<Spline> cutoffs = new ArrayList<Spline>();
  // work down.  use the closest point to the curve points as the standard
  boolean foundFirstSpot = false;
  for (int i = 1; i < middleBottom.curvePoints.size() - 1; i++) {
    ArrayList<PVector> closestPtOnSpline = middleBottom.getPointByClosestPoint(middleBottom.curvePoints.get(i));
    if (closestPtOnSpline == null) continue;
    else {
      PVector intersect = getClosestIntersection(closestPtOnSpline.get(0), closestPtOnSpline.get(2), bottom, sweeptingAngle, totalSweepCount);
    }
  }


  // then work up

  return cutoffs;
} // end makeCutoffSplines

//
PVector getClosestIntersection(PVector pt, PVector direction, Spline target, float sweepingAngle, int totalSweepCount) {
  PVector intersection = null;
  for (int k = 0; k < totalSweepCount; k++) {
    PVector lineStart = pt.get();
    PVector lineEnd = pt.get();
    PVector rotatedEnd = OCR3D.rotateUnitVector2D(direction, map(k, 0, totalSweepCount - 1, -sweepingAngle / 2, sweepingAngle / 2));
    if (rotatedEnd == null) continue;
    lineEnd.add(rotatedEnd);
    ArrayList<PVector> thisIntersect =  target.getPointByIntersection(lineStart, lineEnd);
    if (thisIntersect == null) continue;
    
    stroke(0, 255, 12);
    ellipse(thisIntersect.get(0).x, thisIntersect.get(0).y, 3, 3);
    stroke(0, 127);
    line(thisIntersect.get(0).x, thisIntersect.get(0).y, pt.x, pt.y);
  }
  return intersection;
} // end getClosestIntersection 

////////
//
//
//
//
//
//

