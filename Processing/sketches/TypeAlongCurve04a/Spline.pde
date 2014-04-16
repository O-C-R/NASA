class Spline {
  ArrayList<PVector> curvePoints = new ArrayList<PVector>(); // for base curve
  PVector[] facetPoints = new PVector[0]; 
  PVector[] facetUps = new PVector[0]; // which way is 'up' for each facetPoint.  normalized
  PVector[] facetRights = new PVector[0]; // which way is 'right' for each facetPoint.  normalized
  float[] distances = new float[0];
  float[] runningDistances = new float[0];
  float totalDistance = 0f;

  // retain the facet values
  float minAngleInDegrees = 0f;
  float minDistance = 0f; // for when extending the curve, this will be roughly the base distance? 
  // unless there is a facet point closer than this
  int divisionAmount = 1;
  boolean flipUp = false;

  boolean facetsMade = false;

  //
  // in this version the curvepoints will actually not try to double up,
  //  but instead will try to work backwards to establish the 'correct' first and last points
  void addCurvePoint(PVector p) {
    if (curvePoints.size() == 2) {
      // add first point after two have already been established
      PVector startingPoint = makeExtensionPoint(p, curvePoints.get(1), curvePoints.get(0));
      curvePoints.add(0, startingPoint);
    }
    if (curvePoints.size() > 3) {
      // remove false ending point
      curvePoints.remove(curvePoints.size() - 1);
    }

    curvePoints.add(p);

    if (curvePoints.size() > 2) {
      // add false ending point
      PVector endingPoint = makeExtensionPoint(curvePoints.get(curvePoints.size() - 3), curvePoints.get(curvePoints.size() - 2), p);
      curvePoints.add(endingPoint);
    }
  } // end addCurvePoint


    //
  PVector makeExtensionPoint(PVector a, PVector b, PVector c) {
    PVector ext = new PVector();
    PVector angleABVec = PVector.sub(b, a);
    PVector angleBCVec = PVector.sub(c, b);
    float signedAngle = atan2( angleABVec.x * angleBCVec.y - angleABVec.y* angleBCVec.x, angleABVec.x * angleBCVec.x + angleABVec.y * angleBCVec.y );

    float angleAB = HALF_PI;
    float angleBC = HALF_PI;
    if (a.x - b.x != 0) angleAB = atan((a.y - b.y) / (a.x - b.x));
    else {
      if (b.y < a.y) angleAB += PI;
    }
    if (b.x - c.x != 0) angleBC = atan((b.y - c.y) / (b.x - c.x));
    else {
      if (c.y < b.y) angleBC += PI;
    }

    angleAB += TWO_PI;
    if (a.x > b.x) angleAB += PI;
    angleAB %= TWO_PI;
    angleBC += TWO_PI;
    if (b.x > c.x) angleBC += PI;
    angleBC %= TWO_PI;

    float newAngle = angleBC + signedAngle;
    float abDist = a.dist(b);
    float bcDist = b.dist(c);
    float newDist = bcDist * .75 + abDist * .25;
    ext = new PVector(cos(newAngle) * newDist, sin(newAngle) * newDist);
    ext.add(c);

    return ext;
  } // end makeExtensionPoint


    //
  void makeFacetPoints(float minAngleInDegrees, float minDistance, int divisionAmount, boolean flipUp) {

    this.minAngleInDegrees = minAngleInDegrees;
    this.minDistance = minDistance; 
    this.divisionAmount = divisionAmount;
    this.flipUp = flipUp;
    // simple way ? 
    float minAngleInRadians = ((float)Math.PI * minAngleInDegrees / 180);
    ArrayList<PVector> pts = new ArrayList<PVector>();
    PVector ptA, ptB, ptC, ptD;

    if (curvePoints.size() <= 3) return; // skip out if not enough points  

    // add all of the points so that the facet can be made, 
    // but make sure that the curvePoints.get(0) pt and curvePoints.get(curvePoints.size() - 2) points are marked
    // and then eliminated from the facets
    int startPtsIndex, endPtsIndex;
    startPtsIndex = endPtsIndex = 0;

    pts.add(curvePoints.get(0));
    for (int i = 0; i < curvePoints.size() - 1; i++) {
      if (i == 0) ptA = curvePoints.get(0);
      else ptA = curvePoints.get(i - 1);
      ptB = curvePoints.get(i);
      ptC = curvePoints.get(i + 1);
      if (i == curvePoints.size() - 2) ptD = curvePoints.get(curvePoints.size() - 1);
      else ptD = curvePoints.get(i + 2);
      if (i > 0) pts.add(ptB.get());
      if (i == 1) startPtsIndex = pts.size() - 1;
      if (i == curvePoints.size() - 2) endPtsIndex = pts.size() - 1;
      pts.addAll(divideCurve(divisionAmount, ptA, ptB, ptC, ptD));
    }
    pts.add(curvePoints.get(curvePoints.size() - 1).get());

    facetPoints = new PVector[0];
    facetUps = new PVector[0];
    facetRights = new PVector[0];
    distances = new float[0];
    facetPoints = (PVector[])append(facetPoints, pts.get(0).get());
    distances = (float[])append(distances, 0);
    runningDistances = new float[0];
    totalDistance = 0f;
    PVector lastPoint = pts.get(0).get();
    PVector nextPoint, nextNextPoint;
    PVector dirA, dirB;
    float angleBetween = 0f;
    float dist = 0f;



    // keep track of the start and stop facet indices
    int startFacetIndex, endFacetIndex;
    startFacetIndex = endFacetIndex = 0;

    for (int i = 1; i < pts.size() - 2; i++) {
      nextPoint = pts.get(i);
      nextNextPoint = pts.get(i + 1);
      dirA = PVector.sub(nextPoint, lastPoint);
      dirB = PVector.sub(nextNextPoint, lastPoint);
      angleBetween = PVector.angleBetween(dirA, dirB);
      dist = lastPoint.dist(nextPoint);

      if (dist < minDistance && angleBetween < minAngleInRadians && i != startPtsIndex && i != endPtsIndex) continue;
      else {
        if (abs(i - startPtsIndex) <= 3) startFacetIndex = constrain(facetRights.length - 3, 0, facetRights.length); // some wiggle room
        else if (abs(i - endPtsIndex) <= 3) endFacetIndex = constrain(facetRights.length + 3, 0, facetRights.length);

        PVector right = PVector.sub(nextPoint, lastPoint);
        right.normalize();
        if (i == 1) {
          facetRights = (PVector[])append(facetRights, right);
        }
        facetRights = (PVector[])append(facetRights, right);
        PVector up = new PVector(-right.y, right.x);
        if (flipUp) up.mult(-1);
        if (i == 1) {
          facetUps = (PVector[])append(facetUps, up);
        }
        facetUps = (PVector[])append(facetUps, up);
        distances = (float[])append(distances, lastPoint.dist(nextPoint));
        lastPoint = nextPoint;
        facetPoints = (PVector[])append(facetPoints, nextPoint);
      }
    }
    PVector right = PVector.sub(pts.get(pts.size() - 1), lastPoint);
    right.normalize();

    facetRights = (PVector[])append(facetRights, right);
    facetRights = (PVector[])append(facetRights, right);

    PVector up = new PVector(-right.y, right.x);
    if (flipUp) up.mult(-1);

    facetUps = (PVector[])append(facetUps, up);
    facetUps = (PVector[])append(facetUps, up);

    PVector[] newFacetPoints = new PVector[0];
    PVector[] newFacetRights = new PVector[0]; 
    PVector[] newFacetUps = new PVector[0];
    boolean gotStart = false;
    // a bit messy but it works
    for (int k = constrain(startFacetIndex, 0, facetPoints.length); k <= constrain(endFacetIndex + 3, 0, facetPoints.length - 1); k++) {
      if (!gotStart && facetPoints[k].dist(curvePoints.get(1)) == 0) gotStart = true;
      if (gotStart) {
        newFacetPoints = (PVector[])append(newFacetPoints, facetPoints[k]);
        newFacetRights = (PVector[])append(newFacetRights, facetRights[k]);
        newFacetUps = (PVector[])append(newFacetUps, facetUps[k]);
      }
      //println("facetPoints.length: " + facetPoints.length + " k: " + k + " dist: " + facetPoints[k].dist(curvePoints.get(curvePoints.size() - 2)));
      if (facetPoints[k].dist(curvePoints.get(curvePoints.size() - 2)) == 0) break; // cut out after getting the last point
    }
    facetPoints = newFacetPoints;
    facetRights = newFacetRights;
    facetUps = newFacetUps;

    facetsMade = true;

    makeDistances();
    //println("total distance after makeFacetPoints: " + totalDistance);
  } // end makeFacetPoints

    //
  void makeDistances() {
    distances = new float[0];
    runningDistances = new float[0];
    totalDistance = 0f;
    int tempCount = 0;
    if (facetPoints.length > 0) {
      for (int i = 1; i < facetPoints.length; i++) {
        if (i == 1) {
          distances = (float[])append(distances, 0f);
          runningDistances = (float[])append(runningDistances, 0f);
        }

        float dist = facetPoints[i].dist(facetPoints[i - 1]);
        if (Float.isNaN(dist)) dist = 0;
        distances = (float[])append(distances, dist);
        runningDistances = (float[])append(runningDistances, dist + runningDistances[runningDistances.length - 1]);
        totalDistance += dist;
        tempCount++;
      }
    }
    //println("end of makeDistances: " + totalDistance + " tempCount: " + tempCount + " runningDistances.length: " + runningDistances.length);
  } // end makeDistancesFromFacets


  //
  ArrayList<PVector> getPointAlongSpline(float percentIn) {
    ArrayList<PVector> newPoint = new ArrayList<PVector>();
    newPoint.add(new PVector()); // 0 will be the interpolated point
    newPoint.add(new PVector()); // 1 will be the interpolated up
    newPoint.add(new PVector()); // 2 will be the interpolated right
    if (!facetsMade) return newPoint;
    newPoint.clear();

    float targetDistance = percentIn * totalDistance;
    float low, high;
    for (int i = 0; i < runningDistances.length - 1; i++) {
      low = runningDistances[i];
      high = runningDistances[i + 1];
      if (targetDistance == low) {
        newPoint.add(facetPoints[i]);
        newPoint.add(facetUps[i]);
        newPoint.add(facetRights[i]);
        break;
      }
      else if (targetDistance == high) {
        newPoint.add(facetPoints[i + 1]);
        newPoint.add(facetUps[i + 1]);
        newPoint.add(facetRights[i + 1]);
        break;
      }
      else if (targetDistance > low && targetDistance < high) {
        // find the percentage towards low vs high
        // use that to figure the new point, up, and right
        float diff = high - low;
        float percentHigh = (targetDistance - low) / diff;
        float percentLow = 1 - percentHigh;
        PVector a = facetPoints[i].get();
        PVector b = facetPoints[i + 1].get();
        a.mult(percentLow);
        b.mult(percentHigh);
        PVector c = PVector.add(a, b);
        newPoint.add(c);
        a = facetUps[i].get();
        b = facetUps[i + 1].get();
        a.mult(percentLow);
        b.mult(percentHigh);
        c = PVector.add(a, b);
        newPoint.add(c);
        a = facetRights[i].get();
        b = facetRights[i + 1].get();
        a.mult(percentLow);
        b.mult(percentHigh);
        c = PVector.add(a, b);
        newPoint.add(c);
        break;
      }
      // otherwise continue
    }

    return newPoint;
  } // end getPointAlongSpline

  //
  float getPercentByAxis(String axisIn, PVector ptIn) {
    float targetPercent = 0f;
    PVector a, b;
    boolean foundSpot = false;
    float low, high, dist, distA, diff, addition, newDist;
    float percentHigh, percentLow;
    for (int i = 0; i < facetPoints.length - 1; i++) {
      a = facetPoints[i];
      b = facetPoints[i + 1];
      if (axisIn.equals("x")) {
        if (ptIn.x >= a.x && ptIn.x <= b.x) {
          low = runningDistances[i];
          high = runningDistances[i + 1];
          diff = high - low;
          dist = abs(a.x - b.x);
          distA = abs(ptIn.x - a.x);
          addition = diff * distA / dist;
          newDist = low + addition;
          targetPercent = newDist / totalDistance;
          foundSpot = true;
          break;
        }
      }
      else {
        if (ptIn.y >= a.y && ptIn.y <= b.y) {
          low = runningDistances[i];
          high = runningDistances[i + 1];
          diff = high - low;
          dist = abs(a.y - b.y);
          distA = abs(ptIn.y - a.y);
          addition = diff * distA / dist;
          newDist = low + addition;
          targetPercent = newDist / totalDistance;
          foundSpot = true;
          break;
        }
      }
    }
    return targetPercent;
  } // end getPercentByAxis

  //
  ArrayList<PVector> getPointByAxis(String axisIn, PVector ptIn) {
    float targetPercent = getPercentByAxis(axisIn, ptIn);
    return getPointAlongSpline(targetPercent);
  } // end getPointByAxis

  //
  ArrayList<PVector> getPointByIntersection(PVector startLine, PVector endLine) {
    float targetPercent = 0f;
    if (!facetsMade) return null;
    // slow and thoughtless but should work
    PVector closestPt = null;
    float thisDist = 0f;
    float closestDist = 0f;
    PVector thisPt, a, b, intersectPoint;
    for (int i = 0; i < facetPoints.length - 1; i++) {
      a = facetPoints[i];
      b = facetPoints[i + 1];
      thisPt = OCR3D.find2DRaySegmentIntersection(startLine, endLine, a, b);
      if (thisPt != null) {
        thisDist = startLine.dist(thisPt); 
        if (thisDist < closestDist || closestPt == null) {
          closestDist = thisDist;
          closestPt = thisPt;
          float distA = thisPt.dist(a);
          float distTotal = a.dist(b);
          float percentA = distA / distTotal;
          float targetDist = runningDistances[i] + percentA * distTotal;
          targetPercent = targetDist / totalDistance;
          thisDist = targetDist; // for debug
        }
      }
    }

    if (closestPt == null) return null;

    if (Float.isNaN(targetPercent)) {
      println("FOUND XXX NAN targetDist: " + thisDist + " totalDistance: " + totalDistance);
      return null;
    }

    //noFill();
    //stroke(255, 0, 255);
    //ellipse(closestPt.x, closestPt.y, 10, 10);

    return getPointAlongSpline(targetPercent);
  } // end getPointByIntersection

  //
  ArrayList<PVector> getPointByClosestPoint(PVector ptIn) {
    float targetPercent = 0f;
    if (!facetsMade) return null;

    float closestDist = 0f;
    float thisDist = 0f;
    PVector closestPt = new PVector();
    PVector thisPt, a, b, modifiedPt;
    for (int i = 0; i < facetPoints.length - 1; i++) {
      a = facetPoints[i];
      b = facetPoints[i + 1];
      thisPt = OCR3D.findPointLineConnection(ptIn, a, b);
      // check that the pt lies on the line.  if not cap it at the endpoint
      modifiedPt = checkPtSegment(thisPt, a, b);

      thisDist = ptIn.dist(modifiedPt); 
      if (thisDist < closestDist || i == 0) {
        closestDist = thisDist;
        closestPt = modifiedPt;

        float distA = modifiedPt.dist(a);
        float distTotal = a.dist(b);
        float percentA = distA / distTotal;
        float targetDist = runningDistances[i] + percentA * distTotal;
        targetPercent = targetDist / totalDistance;
      }
    }
    return getPointAlongSpline(targetPercent);
  } // end getPointByClosestPoint



    //
  ArrayList<PVector> getPointByDistance(float distanceIn) {
    float targetPercent = 0f;
    if (!facetsMade) return null;
    targetPercent = distanceIn / totalDistance;
    targetPercent = constrain(targetPercent, 0, 1);
    return getPointAlongSpline(targetPercent);
  } // end getPointByDistance



  //
  // make it so that it caps it to the endpts of the segment
  // terrible amount of calculations
  PVector checkPtSegment(PVector pt, PVector a, PVector b) {
    boolean awesome = pointIsOnSegment(pt, a, b);
    if (awesome) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255, 0, 0);
    }
    line(a.x, a.y, b.x, b.y);
    ellipse(pt.x, pt.y, 3, 3);

    if (awesome) return pt;
    else {
      float aDist = a.dist(pt);
      float bDist = b.dist(pt);
      if (aDist < bDist) return a;
      else return b;
    }
  } // end checkPtSegment

  //
  boolean pointIsOnSegment(PVector pt, PVector a, PVector b) {
    if (a.x > b.x) {
      if (pt.x < b.x || pt.x > a.x) return false;
    }
    else {
      if (pt.x < a.x || pt.x > b.x) return false;
    }
    if (a.y > b.y) {
      if (pt.y < b.y || pt.y > a.y) return false;
    }
    else {
      if (pt.y < a.y || pt.y > b.y) return false;
    }
    return true;
  } // end pointIsOnSegment


  //
  // return a segment of the spline
  // note this will create new curvePoints from the facet points
  Spline getClip(float startPercent, float endPercent) {
    startPercent = constrain(startPercent, 0, 1);
    endPercent = constrain(endPercent, 0, 1);
    if (endPercent < startPercent) {
      float temp = startPercent;
      startPercent = endPercent;
      endPercent = startPercent;
    }
    PVector[] newFacetPoints = new PVector[0];
    PVector[] newFacetUps = new PVector[0];
    PVector[] newFacetRights = new PVector[0];
    // get middle points first
    float targetLow = startPercent * totalDistance;
    float targetHigh = endPercent * totalDistance;
    println("tring to get high from: " + targetHigh + " and low: " + targetLow + " out of totalDist: " + totalDistance);
    float low, high;
    int code = -1;
    int lastCode = -1;
    final int CODE_SURROUNDED = 0;
    final int CODE_START = 1;
    final int CODE_END = 2;
    final int CODE_INSIDE = 3;
    for (int i = 0; i < runningDistances.length - 1; i++) {
      low = runningDistances[i];
      high = runningDistances[i + 1];
      if (targetLow <= low && targetHigh >= high) {
        code = CODE_SURROUNDED;
      }
      else if (targetLow > low && targetHigh >= high) {// check low halfway in bounds
        code = CODE_START;
      }
      else if (targetLow <= low && targetHigh < high) { // check high halfway in bounds
        code = CODE_END;
      }
      else if (true) { // check for both low and high within one segment
        code = CODE_INSIDE;
      }

      // actually do something here
      if (code == CODE_SURROUNDED) {
        if (lastCode == CODE_START) {
          println("STARTING");
          if (i > 0) {
            float lastLow = runningDistances[i - 1];
            float lastHigh = runningDistances[i];
            float lowPercent = (targetLow - lastLow) / (lastHigh - lastLow);
            PVector a = facetPoints[i - 1].get();
            PVector b = facetPoints[i].get();
            a.mult(1 - lowPercent);
            b.mult(lowPercent);
            PVector newPos = PVector.add(a, b);
            a = facetUps[i - 1].get();
            b = facetUps[i].get();
            a.mult(1 - lowPercent);
            b.mult(lowPercent);
            PVector newUp = PVector.add(a, b);
            a = facetRights[i - 1].get();
            b = facetRights[i].get();
            a.mult(1 - lowPercent);
            b.mult(lowPercent);
            PVector newRight = PVector.add(a, b);
            newFacetPoints = (PVector[])append(newFacetPoints, newPos);
            newFacetUps = (PVector[])append(newFacetUps, newUp);
            newFacetRights = (PVector[])append(newFacetRights, newRight);
          }
        }
        newFacetPoints = (PVector[])append(newFacetPoints, facetPoints[i].get());
        newFacetUps = (PVector[])append(newFacetUps, facetUps[i].get());
        newFacetRights = (PVector[])append(newFacetRights, facetRights[i].get());
        println("SURROUNDED");
      }
      else if (code == CODE_END) {
        if (lastCode == CODE_SURROUNDED) {
          println("ENDING");
          newFacetPoints = (PVector[])append(newFacetPoints, facetPoints[i].get());
          newFacetUps = (PVector[])append(newFacetUps, facetUps[i].get());
          newFacetRights = (PVector[])append(newFacetRights, facetRights[i].get());


          float nextLow = runningDistances[i];
          float nextHigh = runningDistances[i + 1];
          float lowPercent = (targetHigh - nextLow) / (nextHigh - nextLow);
          PVector a = facetPoints[i].get();
          PVector b = facetPoints[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newPos = PVector.add(a, b);
          a = facetUps[i].get();
          b = facetUps[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newUp = PVector.add(a, b);
          a = facetRights[i].get();
          b = facetRights[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newRight = PVector.add(a, b);
          newFacetPoints = (PVector[])append(newFacetPoints, newPos);
          newFacetUps = (PVector[])append(newFacetUps, newUp);
          newFacetRights = (PVector[])append(newFacetRights, newRight);
        }
      }
      else if (code == CODE_INSIDE) {
        println("INSIDE");

        for (int k = 0; k < 2; k++) {
          float thisLow = runningDistances[i];
          float thisHigh = runningDistances[i + 1];
          float lowPercent = ((k == 0 ? targetLow : targetHigh) - thisLow) / (thisHigh - thisLow);
          PVector a = facetPoints[i].get();
          PVector b = facetPoints[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newPos = PVector.add(a, b);
          a = facetUps[i].get();
          b = facetUps[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newUp = PVector.add(a, b);
          a = facetRights[i].get();
          b = facetRights[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newRight = PVector.add(a, b);
          newFacetPoints = (PVector[])append(newFacetPoints, newPos);
          newFacetUps = (PVector[])append(newFacetUps, newUp);
          newFacetRights = (PVector[])append(newFacetRights, newRight);
        }
        break;
      }
      lastCode = code;
    }

    Spline newSpline = new Spline();
    newSpline.facetPoints = newFacetPoints;
    newSpline.facetUps = newFacetUps;
    newSpline.facetRights = newFacetRights;
    for (PVector p : newSpline.facetPoints) newSpline.addCurvePoint(p.get());

    newSpline.makeDistances();
    newSpline.minAngleInDegrees = minAngleInDegrees;
    newSpline.minDistance = minDistance;
    newSpline.divisionAmount = divisionAmount;
    newSpline.flipUp = flipUp;
    if (newSpline.totalDistance > 0) newSpline.facetsMade = true;

    println(newSpline.totalDistance + " newFacetPoints.length: " + newFacetPoints.length);
    return newSpline;
  } // end getClip

  // 
  void clipMe(float startPercent, float endPercent) {
    Spline newSpline = getClip(startPercent, endPercent);
    // copy things over
    curvePoints = newSpline.curvePoints;
    facetPoints = newSpline.facetPoints; 
    facetUps = newSpline.facetUps;
    facetRights = newSpline.facetRights;
    distances = newSpline.distances;
    runningDistances = newSpline.runningDistances;
    totalDistance = newSpline.totalDistance;
  } // end clipMe

    //
  // extend the spline if necessary..  for now do a simple curve based on the
  // doesnt quite work yet..... 
  void extend(float len) {
    if (curvePoints.size() < 3) return; // cut out if not enough points
    println("trying to extend curve by : " + len);
    float eachSideLength = len / 2;
    //makeExtensionPoint
    float oldTotalDistance = totalDistance;
    float targetHalfDistance = oldTotalDistance + eachSideLength;
    float targetFullDistance = oldTotalDistance + len;
    int manualBreak = 0;

    // clean it up a bit first...
    makeFacetPoints(minAngleInDegrees, minDistance, divisionAmount, flipUp);

    // do the end
    while (true) {
      PVector newEnd = makeExtensionPoint(curvePoints.get(curvePoints.size() - 4), curvePoints.get(curvePoints.size() - 3), curvePoints.get(curvePoints.size() - 2));
      ArrayList<PVector> curvePointsCopy = (ArrayList<PVector>)curvePoints.clone();
      curvePoints.clear();
      for (int i = 1; i < curvePointsCopy.size() - 1; i++) addCurvePoint(curvePointsCopy.get(i).get());
      addCurvePoint(newEnd);
      makeFacetPoints(minAngleInDegrees, minDistance, divisionAmount, flipUp);
      //println("distance: " + totalDistance + " target: " + targetHalfDistance * 2);
      if (totalDistance >= targetHalfDistance) break;
      manualBreak++;
      if (manualBreak > 200) break;
    }
    // clip it 
    float targetPercentEnd = (targetHalfDistance) / totalDistance;
    clipMe(0, targetPercentEnd);    


    // do the start 
    while (true) {
      PVector newStart = makeExtensionPoint(curvePoints.get(3), curvePoints.get(2), curvePoints.get(1));
      //PVector newEnd = makeExtensionPoint(curvePoints.get(curvePoints.size() - 4), curvePoints.get(curvePoints.size() - 3), curvePoints.get(curvePoints.size() - 2));
      ArrayList<PVector> curvePointsCopy = (ArrayList<PVector>)curvePoints.clone();
      curvePoints.clear();
      addCurvePoint(newStart);
      for (int i = 1; i < curvePointsCopy.size() - 1; i++) addCurvePoint(curvePointsCopy.get(i).get());
      //addCurvePoint(newEnd);
      makeFacetPoints(minAngleInDegrees, minDistance, divisionAmount, flipUp);
      //println("distance: " + totalDistance + " target: " + targetHalfDistance * 2);
      if (totalDistance >= targetFullDistance) break;
      manualBreak++;
      if (manualBreak > 220) break;
    }
    // clip it 
    float targetPercentStart = (targetFullDistance) / totalDistance;
    clipMe((1 - targetPercentStart), 1);

    if (totalDistance > 0) facetsMade = true;
    println("finishd with extend!  new distance: " + totalDistance + " for target of: " + (targetFullDistance) + " and half: " + targetHalfDistance + " manualBreak: " + manualBreak);
  } // end extend

  //
  // move the thing somewhere else
  void shift(PVector shift) {
    for (PVector p : curvePoints) p.add(shift);
    for (PVector p : facetPoints) p.add(shift);
  } // end shift

    //
  void flip() {
    for (PVector p : facetUps) p.mult(-1);
  } // end flip

  // 
  void reverseDirection() {
    ArrayList<PVector> curvePointsNew = new ArrayList<PVector>(); // for base curve
    PVector[] facetPointsNew = new PVector[0]; 
    PVector[] facetUpsNew = new PVector[0]; // which way is 'up' for each facetPoint.  normalized
    PVector[] facetRightsNew = new PVector[0]; // which way is 'right' for each facetPoint.  normalized
    for (int i = curvePoints.size() - 1; i >= 0; i--) curvePointsNew.add(curvePoints.get(i));
    for (int i = facetPoints.length - 1; i >= 0; i--) {
      facetPointsNew = (PVector[])append(facetPointsNew, facetPoints[i]);
      facetUpsNew = (PVector[])append(facetUpsNew, facetUps[i]);
      facetRightsNew = (PVector[])append(facetRightsNew, facetRights[i]);
    }
    curvePoints = curvePointsNew;
    facetPoints = facetPointsNew;
    facetUps = facetUpsNew;
    facetRights = facetRightsNew;
    makeDistances();
  } // end reverse


  // 
  // pattern defined as 0 for eliminate, 1 for keep
  void cull(int[] pattern) {
    ArrayList<PVector> newCurvePoints = new ArrayList<PVector>();
    for (int i = 0; i < curvePoints.size(); i++) {
      if (pattern[i % pattern.length] == 1) newCurvePoints.add(curvePoints.get(i));
    }
    if (newCurvePoints.size() >= 2) curvePoints = newCurvePoints;
  } // end cull

  //
  // doesnt really work as expected
  void multiply(int amt) {
    ArrayList<PVector> newCurvePoints = new ArrayList<PVector>();
    if (amt < 2) return;
    PVector ptA, ptB, ptC, ptD;
    newCurvePoints.add(curvePoints.get(0));
    for (int i = 0; i < curvePoints.size() - 1; i++) {
      if (i == 0) ptA = curvePoints.get(0);
      else ptA = curvePoints.get(i - 1);
      ptB = curvePoints.get(i);
      ptC = curvePoints.get(i + 1);
      if (i == curvePoints.size() - 2) ptD = curvePoints.get(curvePoints.size() - 1);
      else ptD = curvePoints.get(i + 2);
      if (i > 0) newCurvePoints.add(ptB.get());
      newCurvePoints.addAll(divideCurve(amt, ptA, ptB, ptC, ptD));
    }
    newCurvePoints.add(curvePoints.get(curvePoints.size() - 1).get());
    curvePoints = newCurvePoints;
  } // end multiply

  // 
  ArrayList<PVector> divideCurve(int divisions, PVector ptA, PVector ptB, PVector ptC, PVector ptD) {
    ArrayList<PVector> dividedPoints = new ArrayList<PVector>();
    if (divisions < 2) return dividedPoints;
    float ax, bx, cx, dx, ay, by, cy, dy, t, x, y;
    ax = ptA.x;
    bx = ptB.x;
    cx = ptC.x;
    dx = ptD.x;
    ay = ptA.y;
    by = ptB.y;
    cy = ptC.y;
    dy = ptD.y;
    for (float j = 2; j <= divisions; j++) {
      t = (j - 1f) / divisions;
      x = curvePoint(ax, bx, cx, dx, t);
      y = curvePoint(ay, by, cy, dy, t);
      dividedPoints.add(new PVector(x, y));
    }
    return dividedPoints;
  } // end divideCurve

  //
  void display() {
    beginShape();
    for (int i = 0; i < curvePoints.size(); i++) {
      if (i == 0) curveVertex(curvePoints.get(i).x, curvePoints.get(i).y);
      curveVertex(curvePoints.get(i).x, curvePoints.get(i).y);
      if (i == curvePoints.size() - 1) curveVertex(curvePoints.get(i).x, curvePoints.get(i).y);
    }
    endShape();
  } // end display

  //
  void displayCurvePoints() {
    float rad = 5;
    for (int i = 0; i < curvePoints.size(); i++) {
      stroke(255, 20);
      noFill();
      ellipse(curvePoints.get(i).x, curvePoints.get(i).y, rad, rad);
      //fill(0);
      //text(i, curvePoints.get(i).x, curvePoints.get(i).y);
    }
  } // end drawPoints

  //
  void displayFacetPoints() {
    float rad = 5;

    for (int i = 0; i < facetPoints.length - 1; i++) {
      line(  facetPoints[i].x, facetPoints[i].y, facetPoints[i + 1].x, facetPoints[i + 1].y);
    }

    for (int i = 0; i < facetPoints.length; i++) {
      stroke(255, 20);
      PVector up = facetUps[i].get();
      up.mult(30);
      up.add(facetPoints[i]);
      line(facetPoints[i].x, facetPoints[i].y, up.x, up.y);
    }
  } // end displayFacetPoints
} // end class Spline


//
//
//
//
//
//

