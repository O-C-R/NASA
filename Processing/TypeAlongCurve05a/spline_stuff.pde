//
void makeMasterSpLabels() {
  if (bucketDataPoints.length <= 1) return; // needs at least two buckets

  int manualLayerControlUpIndex = 0; // when doing things manually, this will tell the system when to stop going up and go down instead

  // reorder the buckets by max value?
  if (!manualLayerControl) {
    // reorder the bucket data points and the bucketsAL
    ArrayList<float[]> newBucketDataPointsAL = new ArrayList<float[]>();
    ArrayList<Bucket> newBucketsAL = new ArrayList<Bucket>();
    for (int i = 0; i < bucketsAL.size(); i++) {
      if (i == 0) {
        newBucketsAL.add(bucketsAL.get(i));
        newBucketDataPointsAL.add(bucketDataPoints[i]);
      }
      else {
        float tempSumThis = 0f;
        for (float f : bucketDataPoints[i]) tempSumThis += f;
        boolean foundSpot = false;
        for (int j = 0; j < newBucketsAL.size(); j++) {
          float tempSumOther = 0f;
          float[] otherDataPt = newBucketDataPointsAL.get(j);
          for (float f : otherDataPt) tempSumOther += f;
          if (tempSumThis > tempSumOther) {
            newBucketsAL.add(j, bucketsAL.get(i));
            newBucketDataPointsAL.add(j, bucketDataPoints[i]);
            foundSpot = true;
            break;
          }
        }
        if (!foundSpot) {
          newBucketsAL.add(bucketsAL.get(i));
          newBucketDataPointsAL.add(bucketDataPoints[i]);
        }
      }
    }
    bucketDataPoints = new float[newBucketDataPointsAL.size()][0];
    bucketsAL = newBucketsAL;
    for (int i = 0; i < newBucketDataPointsAL.size(); i++) {
      bucketDataPoints[i] = newBucketDataPointsAL.get(i);
    }
  }
  else {
    int middleIndex = floor((float)bucketsAL.size() / 2);
    if (manualMiddleBucketName.length() > 0) { // if manually defing the bucket in the middle...
      for (int i = 0; i < bucketsAL.size(); i++) {
        if (bucketsAL.get(i).name.equals(manualMiddleBucketName)) {
          middleIndex = i;
          break;
        }
      }
    }
    ArrayList<Bucket> newBucketsAL = new ArrayList<Bucket>();
    newBucketsAL.add(bucketsAL.get(middleIndex));
    manualLayerControlUpIndex = middleIndex;
    for (int i = middleIndex - 1; i >= 0; i--) newBucketsAL.add(bucketsAL.get(i));
    for (int i = middleIndex + 1; i < bucketsAL.size(); i++) newBucketsAL.add(bucketsAL.get(i));
    bucketsAL = newBucketsAL;
  }

  // first find the max sum of data assuming they all have same number of points
  float maxDataSum = 0;
  float middleHeight = 0;
  float heightPerUnit = 0;
  float widthPerDataPoint = 0;
  for (int j = 0; j < bucketDataPoints[0].length; j++) {
    float thisSum = 0;
    for (int i = 0; i < bucketDataPoints.length; i++) {
      thisSum += bucketDataPoints[i][j];
    }
    maxDataSum = (maxDataSum > thisSum ? maxDataSum : thisSum);
  }
  if (maxDataSum <= 1) return;
  heightPerUnit = (height - padding[0] - padding[2]) / (maxDataSum - 1);
  widthPerDataPoint = (width - padding[1] - padding[3]) / (bucketDataPoints[0].length - 1);
  middleHeight = padding[0] + (height - padding[0] - padding[2]) / 2;
  println("maxDataSum: " + maxDataSum + " heightPerUnit: " + heightPerUnit + " widthPerDataPoint: " + widthPerDataPoint);

  // make the actual splines
  ArrayList<SpLabel> topSpLabels = new ArrayList<SpLabel>();
  ArrayList<SpLabel> bottomSpLabels = new ArrayList<SpLabel>();



  for (int i = 0; i < bucketDataPoints.length; i++) {
    Bucket targetBucket = bucketsAL.get(i);
    SpLabel sp = new SpLabel(targetBucket.name);
    sp.c = targetBucket.c; // assign the bucket color to the splabel
    float x = padding[3];
    float y = 0f;
    if (i == 0) {
      Spline top = new Spline();
      Spline bottom = new Spline();
      for (int j = 0; j < bucketDataPoints[i].length; j++) {
        y = -((float)bucketDataPoints[i][j] / 2) * heightPerUnit + middleHeight;
        top.addCurvePoint(new PVector(x, y));
        y = ((float)bucketDataPoints[i][j] / 2) * heightPerUnit + middleHeight;
        bottom.addCurvePoint(new PVector(x, y));
        sp.saveMaxHeight(2 * abs(y - middleHeight));
        x += widthPerDataPoint; // ***** add in some variation here so that the intersection works better >> BUG!
      }      

      top.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
      bottom.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);

      sp.topSpline = top;
      sp.bottomSpline = bottom;
      sp.isOnTop = true;
      sp.isOnBottom = true;
      sp.data = bucketDataPoints[i];

      // mark this one as the middle one in case the divide is employed later
      sp.isMiddleSpLabel = true;
    }
    else {
      // determine if should go up or down based on the min/max
      float topMax = 0f;
      float bottomMax = 0f;
      for (int j = 0; j < bucketDataPoints[i].length; j++) {
        float thisSum = 0;
        thisSum += bucketDataPoints[i][j];
        for (SpLabel sp2 : topSpLabels) {
          thisSum += sp2.data[j];
        }
        topMax = (topMax > thisSum ? topMax : thisSum);
      }
      for (int j = 0; j < bucketDataPoints[i].length; j++) {
        float thisSum = 0;
        thisSum += bucketDataPoints[i][j];
        for (SpLabel sp2 : bottomSpLabels) {
          thisSum += sp2.data[j];
        }
        bottomMax = (bottomMax > thisSum ? bottomMax : thisSum);
      }

      if ((!manualLayerControl && topMax > bottomMax) || (manualLayerControl && i > manualLayerControlUpIndex)) {
        //println("doing bottom");
        Spline top = bottomSpLabels.get(bottomSpLabels.size() - 1).bottomSpline;
        Spline bottom = new Spline();
        for (int j = 0; j < bucketDataPoints[i].length; j++) {
          float previousYPosition = top.getPointByAxis("x", new PVector(x, 0)).get(0).y;
          y = ((float)bucketDataPoints[i][j]) * heightPerUnit + previousYPosition;
          bottom.addCurvePoint(new PVector(x, y));
          sp.saveMaxHeight(abs(y - previousYPosition));
          x += widthPerDataPoint;
        }      
        bottom.makeFacetPoints(.15f, 10f, 120, true);
        sp.topSpline = top;
        sp.bottomSpline = bottom;
        sp.isOnTop = false;
        sp.isOnBottom = true;
      }
      else if ((!manualLayerControl && topMax <= bottomMax) || (manualLayerControl && i <= manualLayerControlUpIndex)) {
        //println("doing top");
        Spline top = new Spline();
        Spline bottom = topSpLabels.get(topSpLabels.size() - 1).topSpline;
        for (int j = 0; j < bucketDataPoints[i].length; j++) {
          float previousYPosition = bottom.getPointByAxis("x", new PVector(x, 0)).get(0).y;
          y = -((float)bucketDataPoints[i][j]) * heightPerUnit + previousYPosition;
          top.addCurvePoint(new PVector(x, y));
          sp.saveMaxHeight(abs(y - previousYPosition));
          x += widthPerDataPoint;
        }      
        top.makeFacetPoints(.15f, 10f, 120, true);
        sp.topSpline = top;
        sp.bottomSpline = bottom;
        sp.isOnTop = true;
        sp.isOnBottom = false;
      }
    }
    sp.data = bucketDataPoints[i];
    //splabels.add(sp);
    if (sp.isOnBottom) bottomSpLabels.add(sp);
    if (sp.isOnTop) topSpLabels.add(sp);
  }
  splabels = orderSpLabels(topSpLabels, bottomSpLabels);
} // end makeMasterSplines



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
//
//
//
//
//

