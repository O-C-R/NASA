

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

