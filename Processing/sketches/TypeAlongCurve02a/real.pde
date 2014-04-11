//
void makeBucketDataPoints(int pointsToMake) {
  for (int i = 0; i < bucketDataPoints.length; i++) {
    bucketDataPoints[i] = new float[pointsToMake];
    /*
    float seed = random(100);
    for (int j = 0; j < pointsToMake; j++) {
      bucketDataPoints[i][j] = (100 * noise(j * .1 + seed));
    }
    */
    Bucket targetBucket = bucketsAL.get(i);
    for (int j = 0; j < pointsToMake; j++) {
      if (j < targetBucket.seriesSum.length) {
      bucketDataPoints[i][j] = targetBucket.seriesSum[j];
      }
      else {
       bucketDataPoints[i][j] = 0f;
      } 
    }
  }
  println("generated " + bucketDataPoints.length + " new fake buckets of data");
  for (int i = 0; i < bucketDataPoints.length; i++) {
    for (int j = 0; j < bucketDataPoints[i].length; j++) {
      print(nf(bucketDataPoints[i][j], 0, 3) + " ");
    } 
    println("_");
  }
} // end makeBucketDataPoints

//
void makeMasterSpLabels(PGraphics pg) {
  if (bucketDataPoints.length <= 1) return;

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
  heightPerUnit = (pg.height - padding[0] - padding[2]) / (maxDataSum - 1);
  widthPerDataPoint = (pg.width - padding[1] - padding[3]) / (bucketDataPoints[0].length - 1);
  middleHeight = padding[0] + (pg.height - padding[0] - padding[2]) / 2;
  println("maxDataSum: " + maxDataSum + " heightPerUnit: " + heightPerUnit + " widthPerDataPoint: " + widthPerDataPoint);

  // make the actual splines
  ArrayList<SpLabel> topSpLabels = new ArrayList<SpLabel>();
  ArrayList<SpLabel> bottomSpLabels = new ArrayList<SpLabel>();

  for (int i = 0; i < bucketDataPoints.length; i++) {
    Bucket targetBucket = bucketsAL.get(i);
    SpLabel sp = new SpLabel(targetBucket.name);
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
        x += widthPerDataPoint;
      }      

      top.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
      bottom.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);

      sp.topSpline = top;
      sp.bottomSpline = bottom;
      sp.isOnTop = true;
      sp.isOnBottom = true;
      sp.data = bucketDataPoints[i];
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

      if (topMax > bottomMax) {
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
      else {
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
// this will not only order the terms by highest count to lowest, but will also order their year frequency from most to least so 
//  when placing the terms they can check the first section, then the second, etc. until either a place is found or the yearly frequency is below a given threshold
void orderBucketTerms() {
  for (Bucket b : bucketsAL) {
   b.orderTerms(); 
  }
} // end orderBucketTerms 



//
//
//
//
//
//
//



//
//
//
//
//
//

