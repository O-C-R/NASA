ArrayList<Spline> middleMakerVertical (Spline a, Spline b, float minHeight, float maxHeightPercent) {
  if (!a.facetsMade || !b.facetsMade) return null;

  ArrayList<Spline> middle = new ArrayList<Spline>();

  int splineSkip = 27;

  PVector dir, ptA, ptB;
  dir = ptA = ptB = null;

  // use a.minDistance to calc the distance, or skip every say splineSkip facet points
  float lastDistance = 0f;
  // get the first mid point
  int facetStartIndex = 0;

  while (true) {
    ptA = a.facetPoints[facetStartIndex];
    dir = ptA.get();
    dir.y += 1;
    ArrayList<PVector> intersection = b.getPointByIntersection(ptA, dir);
    if (intersection != null) {
      ptB = intersection.get(0);
      lastDistance = a.runningDistances[facetStartIndex];
      break;
    }
    facetStartIndex++;
    if (facetStartIndex >= a.facetPoints.length) break;
  }
  facetStartIndex++; // increment

  if (ptB == null) return null;

  ArrayList<PVector> tempMidPts = makeMidPoints(ptA, ptB, minHeight, maxHeightPercent);

  ArrayList<PVector> midTopPts = new ArrayList<PVector>();
  ArrayList<PVector> midBottomPts = new ArrayList<PVector>();
  midTopPts.add(tempMidPts.get(0));
  midBottomPts.add(tempMidPts.get(1));

  // make the other middle points
  int count = 0;
  while (true) {
    for (int i = facetStartIndex; i < facetStartIndex + splineSkip; i++) {
      if (i < a.facetPoints.length - 2) {
        if (a.runningDistances[i] - lastDistance <= a.minDistance) {
          continue;
        }
        else {
          // go back one if it can
          facetStartIndex = i;
          break;
        }
      }
      else {
        facetStartIndex = i;
        break;
      }
    }

    ptA = a.facetPoints[facetStartIndex];
    dir = ptA.get();
    dir.y += 1;
    ArrayList<PVector> intersection = b.getPointByIntersection(ptA, dir);
    if (intersection != null) {
      ptB = intersection.get(0);
      lastDistance = a.runningDistances[facetStartIndex];
    }

    if (intersection == null || ptB == null) {
      println("breaking out of loop at count: " + count);
      println(ptB);
      println(intersection);
      break; // done with loop
    }

    // otherwise
    tempMidPts = makeMidPoints(ptA, ptB, minHeight, maxHeightPercent);
    midTopPts.add(tempMidPts.get(0));
    midBottomPts.add(tempMidPts.get(1));
    facetStartIndex++;

    count++;
    if (facetStartIndex == a.facetPoints.length - 1) break; // end of while
  }

  Spline middleTop = new Spline();
  Spline middleBottom = new Spline();

  for (int i = 0; i < midTopPts.size(); i++) {
    stroke(0, 255, 255);
    ellipse(midTopPts.get(i).x, midTopPts.get(i).y, 3, 3);
    middleTop.addCurvePoint(midTopPts.get(i));
    stroke(255, 0, 255);
    ellipse(midBottomPts.get(i).x, midBottomPts.get(i).y, 3, 3);
    middleBottom.addCurvePoint(midBottomPts.get(i));
  }

  middleTop.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
  middleBottom.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);

  middle.add(middleTop);
  middle.add(middleBottom);
  return middle;
} // end middleMaker

//
// this simply finds the VERTICAL midpoints.  does not do perpendicular calcs because I didn't want to right now... 
ArrayList<PVector> makeMidPoints(PVector a, PVector b, float minHeight, float maxHeightPercent) {
  ArrayList<PVector> midPts = new ArrayList<PVector>();
  float dist = a.dist(b);
  PVector dir = PVector.sub(b, a);
  PVector dir2 = dir.get();
  float distA = 0f;
  float distB = 1f;

  if (dist * maxHeightPercent >= minHeight) {
    // everything's cool
    distA = .5 - maxHeightPercent / 2;
    distB = .5 + maxHeightPercent / 2;
  } 
  else if (dist < minHeight) {
    // do nothing
  }
  else {
    // % height is smaller than min height, so use min height
    float newPercent = minHeight / dist;
    distA = .5 - newPercent / 2;
    distB = .5 + newPercent / 2;
  }

  dir.mult(distA);
  dir2.mult(distB);
  midPts.add(PVector.add(a, dir));
  midPts.add(PVector.add(a, dir2));
  return midPts;
} // end makeMidPoints


//
// this simply finds the VERTICAL weighted point, nextled on a, targeted towards b
PVector makeWeightedPoint(PVector a, PVector b, float minHeight, float maxHeightPercent) {
  PVector newPt = a.get();
  float dist = a.dist(b);
  PVector dir = PVector.sub(b, a);
  dir.normalize();
  float distA = 0f;

  if (dist * maxHeightPercent >= minHeight) {
    // everything's cool
    distA = maxHeightPercent * dist;
  } 
  else if (dist < minHeight) {
    // do nothing
    newPt = null;
  }
  else {
    // % height is smaller than min height, so use min height
    float newPercent = minHeight / dist;
    distA = newPercent * dist;
  }

  if (newPt == null) return newPt;

  dir.mult(distA);
  newPt.add(dir);

  return newPt;
} // end makeMidPoints



//
//
//
//

