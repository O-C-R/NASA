void makeFakeBucketData(int pointsToMake) {
  for (int i = 0; i < fakeBucketData.length; i++) {
    fakeBucketData[i] = new int[pointsToMake];
    //int[] dataPoints = new int[pointsToMake];
    float seed = random(100);
    for (int j = 0; j < pointsToMake; j++) {
      fakeBucketData[i][j] = (int)(300 * noise(j * .1 + seed));
    }
  }
  println("generated " + fakeBucketData.length + " new fake buckets of data");
  for (int i = 0; i < fakeBucketData.length; i++) {
    for (int j = 0; j < fakeBucketData[i].length; j++) {
      print(nf(fakeBucketData[i][j], 3) + " ");
    } 
    println("_");
  }
} // end makeFakeBucketData

//
void makeMasterSpLabels(PGraphics pg) {
  if (fakeBucketWords.length <= 1) return;
  float[] padding = {
    50f, 250f, 50f, 200f
  };

  // first find the max sum of data assuming they all have same number of points
  float maxDataSum = 0;
  float middleHeight = 0;
  float heightPerUnit = 0;
  float widthPerDataPoint = 0;
  for (int j = 0; j < fakeBucketData[0].length; j++) {
    float thisSum = 0;
    for (int i = 0; i < fakeBucketWords.length; i++) {
      thisSum += fakeBucketData[i][j];
    }
    maxDataSum = (maxDataSum > thisSum ? maxDataSum : thisSum);
  }
  if (maxDataSum <= 1) return;
  heightPerUnit = (pg.height - padding[0] - padding[2]) / (maxDataSum - 1);
  widthPerDataPoint = (pg.width - padding[1] - padding[3]) / (fakeBucketData[0].length - 1);
  middleHeight = padding[0] + (pg.height - padding[0] - padding[2]) / 2;
  println("maxDataSum: " + maxDataSum + " heightPerUnit: " + heightPerUnit + " widthPerDataPoint: " + widthPerDataPoint);

  // make the actual splines
  ArrayList<SpLabel> topSpLabels = new ArrayList<SpLabel>();
  ArrayList<SpLabel> bottomSpLabels = new ArrayList<SpLabel>();

  for (int i = 0; i < fakeBucketWords.length; i++) {
    SpLabel sp = new SpLabel(fakeBucketWords[i]);
    float x = padding[3];
    float y = 0f;
    if (i == 0) {
      Spline top = new Spline();
      Spline bottom = new Spline();
      for (int j = 0; j < fakeBucketData[i].length; j++) {
        y = -((float)fakeBucketData[i][j] / 2) * heightPerUnit + middleHeight;
        top.addCurvePoint(new PVector(x, y));
        y = ((float)fakeBucketData[i][j] / 2) * heightPerUnit + middleHeight;
        bottom.addCurvePoint(new PVector(x, y));
        sp.saveMaxHeight(2 * abs(y - middleHeight));
        x += widthPerDataPoint;
      }      

      top.makeFacetPoints(.15f, 10f, 120, true);
      bottom.makeFacetPoints(.15f, 10f, 120, true);
      sp.topSpline = top;
      sp.bottomSpline = bottom;
      sp.isOnTop = true;
      sp.isOnBottom = true;
      sp.data = fakeBucketData[i];
    }
    else {
      // determine if should go up or down based on the min/max
      float topMax = 0f;
      float bottomMax = 0f;
      for (int j = 0; j < fakeBucketData[i].length; j++) {
        float thisSum = 0;
        thisSum += fakeBucketData[i][j];
        for (SpLabel sp2 : topSpLabels) {
          thisSum += sp2.data[j];
        }
        topMax = (topMax > thisSum ? topMax : thisSum);
      }
      for (int j = 0; j < fakeBucketData[i].length; j++) {
        float thisSum = 0;
        thisSum += fakeBucketData[i][j];
        for (SpLabel sp2 : bottomSpLabels) {
          thisSum += sp2.data[j];
        }
        bottomMax = (bottomMax > thisSum ? bottomMax : thisSum);
      }

      if (topMax > bottomMax) {
        //println("doing bottom");
        Spline top = bottomSpLabels.get(bottomSpLabels.size() - 1).bottomSpline;
        Spline bottom = new Spline();
        for (int j = 0; j < fakeBucketData[i].length; j++) {
          float previousYPosition = top.getPointByAxis("x", new PVector(x, 0)).get(0).y;
          y = ((float)fakeBucketData[i][j]) * heightPerUnit + previousYPosition;
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
        for (int j = 0; j < fakeBucketData[i].length; j++) {
          float previousYPosition = bottom.getPointByAxis("x", new PVector(x, 0)).get(0).y;
          y = -((float)fakeBucketData[i][j]) * heightPerUnit + previousYPosition;
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
    sp.data = fakeBucketData[i];
    splabels.add(sp);
    if (sp.isOnBottom) bottomSpLabels.add(sp);
    if (sp.isOnTop) topSpLabels.add(sp);
  }
} // end makeMasterSplines


//
void splitMasterSpLabels(float maxLineHeight, float splineCPDistance) {
  println("in splitMasterSpLabels");
  for (SpLabel sp : splabels) {
    int dividingNumber = ceil(sp.maxHeight / maxLineHeight);
    sp.blendSplines(dividingNumber, splineCPDistance);
  }
} // end splitMasterSpLabels

//
//
//
//
//
//
//

