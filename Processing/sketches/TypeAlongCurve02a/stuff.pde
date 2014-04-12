//
ArrayList<Spline> blendSplinesByDistanceWithWeight(Spline a, Spline b, int totalCount, float distance, Spline weightSpline) {

  int divisionPoints = (int)(a.totalDistance / distance + 1);

  if (divisionPoints < 3 || totalCount < 1) return null;
  ArrayList<Spline> newSplines = new ArrayList<Spline>();
  for (int i = 0; i < totalCount; i++) newSplines.add(new Spline());

  // these numbers are not exact.. the larger the maximumPercent the [slightly] larger the difference
  float minimumPercent = .1; // for when the distance from point to line is equal to the distance from a to b
  float maximumPercent = 5.93; // when a line is on top of the variation line.  

  for (int i = 1; i <= divisionPoints; i++) {
    float thisPercent = map(i, 1, divisionPoints, 0, 1);
    PVector pointA = a.getPointAlongSpline(thisPercent).get(0);
    PVector pointB = b.getPointAlongSpline(thisPercent).get(0);
    PVector weightedSplinePoint = null;
    ArrayList<PVector> intersectionPoint = weightSpline.getPointByIntersection(pointA, pointB);

    if (intersectionPoint != null) weightedSplinePoint = intersectionPoint.get(0);
    else {
      weightedSplinePoint = pointA.get();
      weightedSplinePoint.add(pointB.get());
      weightedSplinePoint.div(2);
    } 

    float[] distances = new float[totalCount + 2]; // +2 for the first and last distances
    float distancesSum = 0f; // sum of the distances[]
    float abDist = pointA.dist(pointB);

    float minDistance = minimumPercent * abDist; // minimum distance for a weighted spline
    float maxDistance = maximumPercent * abDist; // max distance 


    for (int j = 0; j <= totalCount + 1; j++) {
      if (j == 0) {
        float distToWeightedPoint = pointA.dist(weightedSplinePoint);
        //distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
        distToWeightedPoint = map(sqrt(distToWeightedPoint), 0, sqrt(abDist), maxDistance, minDistance);
        //distToWeightedPoint = 5;
        //distToWeightedPoint = 1 + (totalCount - j);
        distances[j] = distToWeightedPoint;
        distancesSum += distToWeightedPoint;
      }
      else if (j >= 1 && j <= totalCount) {
        float countPercent = map(j, 0, totalCount + 1, 0, 1);
        PVector newPointA = pointA.get();
        newPointA.mult(1 - countPercent);
        PVector newPointB = pointB.get();
        newPointB.mult(countPercent);
        newPointA.add(newPointB); // this is where the thing would be normally
        float distToWeightedPoint = newPointA.dist(weightedSplinePoint);
        //distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
        distToWeightedPoint = map(sqrt(distToWeightedPoint), 0, sqrt(abDist), maxDistance, minDistance);
        //distToWeightedPoint = 5;
        //distToWeightedPoint = 1 + (totalCount - j);
        distances[j] = distToWeightedPoint;
        distancesSum += distToWeightedPoint;
      }
      else {
        /*
        float distToWeightedPoint = pointB.dist(weightedSplinePoint);
         distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
         distToWeightedPoint = 5;
         distances[j] = distToWeightedPoint;
         distancesSum += distToWeightedPoint;
         */
      }
    }

    float runningSum = 0f; //distances[0];
    for (int j = 1; j <= totalCount; j++) {
      runningSum += distances[j];
      float countPercent = runningSum / distancesSum;
      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      newSplines.get(j - 1).addCurvePoint(newPointA);
    }
  }

  for (Spline s : newSplines) s.makeFacetPoints(a.minAngleInDegrees, a.minDistance, a.divisionAmount, a.flipUp);

  return newSplines;
} // end blendSplinesByDistanceWithWeight


//
ArrayList<Spline> blendSplinesByDistance(Spline a, Spline b, int totalCount, float distance) {
  int divisionPoints = (int)(a.totalDistance / distance + 1);
  return blendSplinesByDivisionPoints(a, b, totalCount, divisionPoints);
} // end blendSplinesByDistance

//
/**
 This will use two existing splines to generate a series of new splines
 minimum divisionPoints as 3
 minimum totalCount as 1
 */
ArrayList<Spline> blendSplinesByDivisionPoints(Spline a, Spline b, int totalCount, int divisionPoints) {
  if (divisionPoints < 3 || totalCount < 1) return null;
  ArrayList<Spline> newSplines = new ArrayList<Spline>();
  for (int i = 0; i < totalCount; i++) newSplines.add(new Spline());
  for (int i = 1; i <= divisionPoints; i++) {
    float thisPercent = map(i, 1, divisionPoints, 0, 1);
    PVector pointA = a.getPointAlongSpline(thisPercent).get(0);
    PVector pointB = b.getPointAlongSpline(thisPercent).get(0);
    for (int j = 1; j <= totalCount; j++) {
      float countPercent = map(j, 0, totalCount + 1, 0, 1);
      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      newSplines.get(j - 1).addCurvePoint(newPointA);
    }
  } 
  for (Spline s : newSplines) s.makeFacetPoints(a.minAngleInDegrees, a.minDistance, a.divisionAmount, a.flipUp);
  return newSplines;
} // end blendSplines



//
ArrayList<Spline> blendSplinesVertically(Spline a, Spline b, int totalCount, float distance) {
  int divisionPoints = (int)(a.totalDistance / distance + 1);
  ArrayList<Spline> newSplines = new ArrayList<Spline>();
  // assume a is the main divisor
  for (int i = 0; i < totalCount; i++) newSplines.add(new Spline());
  for (int i = 1; i <= divisionPoints; i++) {
    float thisPercent = map(i, 1, divisionPoints, 0, 1);
    PVector pointA = a.getPointAlongSpline(thisPercent).get(0);
    PVector dirA = pointA.get();
    dirA.y += 1; // make it point vertically
    ArrayList<PVector> intersect = b.getPointByIntersection(pointA, dirA);
    if ( intersect == null) continue; // cutout if no middle
    PVector pointB = intersect.get(0);
    for (int j = 1; j <= totalCount; j++) {
      float countPercent = map(j, 0, totalCount + 1, 0, 1);
      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      newSplines.get(j - 1).addCurvePoint(newPointA);
    }
  }
  for (Spline s : newSplines) s.makeFacetPoints(a.minAngleInDegrees, a.minDistance, a.divisionAmount, a.flipUp);
  return newSplines;
} // end blendSplinesVertically 

//
ArrayList<Spline> blendSplinesVerticallyWithWeight(Spline a, Spline b, int totalCount, float distance, Spline weightSpline) {
  int divisionPoints = (int)(a.totalDistance / distance + 1);

  if (divisionPoints < 3 || totalCount < 1) return null;
  ArrayList<Spline> newSplines = new ArrayList<Spline>();
  for (int i = 0; i < totalCount; i++) newSplines.add(new Spline());

  // these numbers are not exact.. the larger the maximumPercent the [slightly] larger the difference
  float minimumPercent = .1; // for when the distance from point to line is equal to the distance from a to b
  float maximumPercent = 5.93; // when a line is on top of the variation line.  

  for (int i = 1; i <= divisionPoints; i++) {
    float thisPercent = map(i, 1, divisionPoints, 0, 1);

    PVector pointA = a.getPointAlongSpline(thisPercent).get(0);
    PVector dirA = pointA.get();
    dirA.y += 1; // make it point vertically
    ArrayList<PVector> intersect = b.getPointByIntersection(pointA, dirA);
    if ( intersect == null) continue; // cutout if no middle
    PVector pointB = intersect.get(0);

    PVector weightedSplinePoint = null;
    ArrayList<PVector> intersectionPoint = weightSpline.getPointByIntersection(pointA, pointB);

    if (intersectionPoint != null) weightedSplinePoint = intersectionPoint.get(0);
    else {
      weightedSplinePoint = pointA.get();
      weightedSplinePoint.add(pointB.get());
      weightedSplinePoint.div(2);
    } 

    float[] distances = new float[totalCount + 2]; // +2 for the first and last distances
    float distancesSum = 0f; // sum of the distances[]
    float abDist = pointA.dist(pointB);

    float minDistance = minimumPercent * abDist; // minimum distance for a weighted spline
    float maxDistance = maximumPercent * abDist; // max distance 


    for (int j = 0; j <= totalCount + 1; j++) {
      if (j == 0) {
        float distToWeightedPoint = pointA.dist(weightedSplinePoint);
        //distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
        distToWeightedPoint = map(sqrt(distToWeightedPoint), 0, sqrt(abDist), maxDistance, minDistance);
        //distToWeightedPoint = 5;
        //distToWeightedPoint = 1 + (totalCount - j);
        distances[j] = distToWeightedPoint;
        distancesSum += distToWeightedPoint;
      }
      else if (j >= 1 && j <= totalCount) {
        float countPercent = map(j, 0, totalCount + 1, 0, 1);
        PVector newPointA = pointA.get();
        newPointA.mult(1 - countPercent);
        PVector newPointB = pointB.get();
        newPointB.mult(countPercent);
        newPointA.add(newPointB); // this is where the thing would be normally
        float distToWeightedPoint = newPointA.dist(weightedSplinePoint);
        //distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
        distToWeightedPoint = map(sqrt(distToWeightedPoint), 0, sqrt(abDist), maxDistance, minDistance);
        //distToWeightedPoint = 5;
        //distToWeightedPoint = 1 + (totalCount - j);
        distances[j] = distToWeightedPoint;
        distancesSum += distToWeightedPoint;
      }
      else {
        /*
        float distToWeightedPoint = pointB.dist(weightedSplinePoint);
         distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
         distToWeightedPoint = 5;
         distances[j] = distToWeightedPoint;
         distancesSum += distToWeightedPoint;
         */
      }
    }

    float runningSum = 0f; //distances[0];
    for (int j = 1; j <= totalCount; j++) {
      runningSum += distances[j];
      float countPercent = runningSum / distancesSum;
      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      newSplines.get(j - 1).addCurvePoint(newPointA);
    }
  }

  for (Spline s : newSplines) {
    s.makeFacetPoints(a.minAngleInDegrees, a.minDistance, a.divisionAmount, a.flipUp);
    //println("new spline dist: " + s.totalDistance);
  }
  return newSplines;
} // end blendSplinesVerticallyWithWeight


//
float getXFromYear(int yearIn, Term t, PGraphics pg) {
  float x = map(yearIn, yearRange[0], yearRange[1], padding[3], pg.width - padding[1]); 
  return x;
} // end getXFromYear


// mark the x locations of phrases
boolean termIsAlreadyAtX(int x, Term t) {
  if (!usedTermsAtX.containsKey(x)) return false;
  else {
    HashMap<String, Integer> oldHM = (HashMap<String, Integer>) usedTermsAtX.get(x);
    if (oldHM.containsKey(t.term)) return true;
    else return false;
  }
} // end termIsAlreadyAtX

//
void markTermAtX(int x, Term t) {
  if (!usedTermsAtX.containsKey(x)) usedTermsAtX.put(x, new HashMap<String, Integer>());
  HashMap<String, Integer> oldHM = (HashMap<String, Integer>) usedTermsAtX.get(x);
  oldHM.put(t.term, 0);
  usedTermsAtX.put(x, oldHM);
} // end markTermAtX



//
//
//
//
//
//

