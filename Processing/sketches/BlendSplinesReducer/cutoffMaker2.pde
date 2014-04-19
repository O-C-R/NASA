//
// assum 2d
ArrayList<Spline> makeCutoffSplines2(Spline boundary, Spline parent, float minHeight, float maxHeightPercent, boolean goingUp) {
  ArrayList<Spline> children = new ArrayList<Spline>();

  boolean foundFirstSpot = false;

  Spline child = null;

  for (int i = 1; i < parent.curvePoints.size() - 1; i++) {
    ArrayList<PVector> closestPtOnSpline = parent.getPointByClosestPoint(parent.curvePoints.get(i));
    if (closestPtOnSpline == null) continue;
    else {
      PVector direction = new PVector(0, (goingUp ? -1 : 1));
      direction.add(closestPtOnSpline.get(0));
      ArrayList<PVector> intersection = boundary.getPointByIntersection(closestPtOnSpline.get(0), direction);
      if (!foundFirstSpot) {
        foundFirstSpot = true;
        child = new Spline();
      }
      if (intersection == null) {
        // save out this child and start a new one
        if (child.curvePoints.size() >= 3) {
          child.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
          children.add(child);
          child = null;
        }
        foundFirstSpot = false; // reset
        continue;
      }

      PVector newPt = makeWeightedPoint(closestPtOnSpline.get(0), intersection.get(0), minHeight, maxHeightPercent);
      //ellipse(newPt.x, newPt.y, 3, 3);
      //line(newPt.x, newPt.y, closestPtOnSpline.get(0).x, closestPtOnSpline.get(0).y);

      if (newPt != null) child.addCurvePoint(newPt);
      else {
        if (child.curvePoints.size() >= 3) {
          child.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
          children.add(child);
          child = null;
          foundFirstSpot = false; // reset
        }
      }
    }
  }

  // deal with last child
  if (child != null && child.curvePoints.size() >=3) {
    child.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
    children.add(child);
    //println(" adding child with " + child.curvePoints.size() + " curve points");
  }

  //println("made: " + children.size() + " children");
  return children;
} // end makeCutoffSplines



//
//
//
//

