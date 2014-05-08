
//
void makeEdgeFlares() {
  long startTime = millis();
  println("in makeEdgeFlares");

  flares = new ArrayList<Flare>();
  flares.clear();

  Flare topFlare = new Flare("topFlare", splabels.get(0).topSpline, true, true, true); // Flare(boolean isTopFlare, boolean goUp, boolean goLeft) {
  Flare bottomFlare = new Flare("bottomFlare", splabels.get(splabels.size() - 1).bottomSpline, false, false, true);

  // top first

  ArrayList<Spline> splines = makeFlares(topFlare.baseSpline, true, true);
  for (Spline s : splines) {
    s.reverseDirection();
    //s.useUpHeight = false; // reverse it
    topFlare.makeFlareSpline(s);
  }
  println("done making topFlare with new flaresplines.size() as: " + topFlare.flareSplines.size());
  flares.add(topFlare);

  // bottom second
  splines = makeFlares(bottomFlare.baseSpline, false, true);
  for (Spline s : splines) {
    //s.useUpHeight = false; // reverse it
    s.reverseDirection();
    bottomFlare.makeFlareSpline(s);
  }
  println("done making bottomFlare with new flaresplines.size() as: " + bottomFlare.flareSplines.size());
  flares.add(bottomFlare);
  println("done making edge flares.  took " + nf(((float)millis() - startTime) / 1000, 0, 2) + " seconds");
} // end makeEdgeFlares

//
ArrayList<Spline> makeFlares(Spline base, boolean toUp, boolean goLeft) {
  // note: assume that the base goes from left to right

    println("in makeFlares toUp: " + toUp + " goLeft: " + goLeft);
  ArrayList<Spline> flares = new ArrayList<Spline>();

  ArrayList<PVector> departurePoints = new ArrayList<PVector>();
  ArrayList<PVector> departureDirections = new ArrayList<PVector>();
  ArrayList<PVector> targetPoints = new ArrayList<PVector>();

  float approxDivisionDistance = 10f; // how far to divide
  float divisionVariation = .25; // above and below

  float targetXPercent = 1.45; // this will be a multiplication factor of the distance between the current point y pos and the target y
  float targetXVariation = .31; // left and right

  float targetY = -20;
  if (!toUp) targetY = height - targetY;


  float wiggleAngleThresh = PI/15; // when the angle goes within this range of the pt/target angle, then it breaks free
  float wiggleDistance = 20f; 
  float freeAngleAdjust = PI / 8; // when broken free, then can go up and down by this much
  float regularAngleVariation = PI/64; // for the non free angles, should vary a bit

  float lastDistance = 0f;
  if (goLeft) lastDistance = base.totalDistance;
  ArrayList<PVector> distancePoint = null;
  while (true) {
    float distanceAddition = approxDivisionDistance * (random(1 - divisionVariation, 1 + divisionVariation));
    if (goLeft) distanceAddition *= -1;
    float newDistance = lastDistance + distanceAddition;

    if (newDistance < 0 || newDistance > base.totalDistance) break;

    distancePoint = base.getPointByDistance(newDistance);
    if (distancePoint != null) {
      PVector newDeparturePoint = distancePoint.get(0).get();
      PVector newDepartureDirection = distancePoint.get(2).get();
      if (goLeft) newDepartureDirection.mult(-1);
      departurePoints.add(newDeparturePoint);
      departureDirections.add(newDepartureDirection);

      float yDiff = abs(newDeparturePoint.y - targetY);
      PVector targetSpot = newDepartureDirection.get();
      targetSpot.mult(yDiff * targetXPercent * random(1 - targetXVariation, 1 + targetXVariation));
      targetSpot.add(newDeparturePoint);

      targetPoints.add(new PVector(targetSpot.x, targetY));

      flares.add(new Spline());

      distancePoint = null;
    }
    else {
      break;
    }
    lastDistance = newDistance;
  } 



  for (int i = 0; i < departurePoints.size(); i++) {
    boolean iWantToBreakFree = false; // when this is true it will just wiggle free at it's own discretion after getting close enough to the pt/target angle
    //if (i > 0) break; // manual break;
    //if (i != 2) continue;

    PVector pt = departurePoints.get(i);
    stroke(255, 0, 0);
    noFill();
    //ellipse(pt.x, pt.y, 40, 40);
    stroke(0, 255, 0);
    PVector dir = departureDirections.get(i).get();
    dir.mult(200);
    dir.add(pt);
    //line(pt.x, pt.y, dir.x, dir.y);

    stroke(0, 0, 255);
    PVector target = targetPoints.get(i); 
    //ellipse(target.x, target.y, 4, 4);
    //line(target.x, target.y, pt.x, pt.y);

    // do the wiggle
    int ptsToMake = ceil(target.dist(pt) / wiggleDistance);
    //println("making " + ptsToMake + " pts");

    PVector lastPt = pt.get();
    PVector lastAngle = departureDirections.get(i).get();
    for (int k = 0; k < ptsToMake; k++) {
      float dist = lastPt.dist(target);
      float newDist = dist * (((float)k * k) / ((ptsToMake - 1) * (ptsToMake - 1)));
      float currentAngle = OCR3D.getAdjustedRotation(lastAngle);
      //println(currentAngle);


      PVector angleToTarget = PVector.sub(target, lastPt);
      float angleDifference = OCR3D.findSignedAngle2D(lastAngle, angleToTarget);
      float angleAdjust = 0f; 
      //if (!iWantToBreakFree) angleAdjust = angleDifference * ((((float)k * k) / ((ptsToMake - 1) * (ptsToMake - 1))));
      if (!iWantToBreakFree) {
        angleAdjust = angleDifference * ((((float)k) / ((ptsToMake - 1))));
        angleAdjust += random(-regularAngleVariation, regularAngleVariation);
      }
      else {
        // ******** //
        angleAdjust = random(-freeAngleAdjust, freeAngleAdjust); // use this to make it vary quite a bit
        //angleAdjust += random(-regularAngleVariation, regularAngleVariation); // use this to make it vary a little
        //angleAdjust += (toUp ? 1 : -1) * regularAngleVariation / 2; // do this to make it goe more or less straight
        // ******** //
      }

      lastAngle.normalize();
      PVector rotatedAngle = lastAngle.get(); 
      rotatedAngle = OCR3D.rotateUnitVector2D(lastAngle, angleAdjust);
      // check that the angle isnt too far out
      if (iWantToBreakFree) {
        if (PVector.angleBetween(rotatedAngle, PVector.sub(target, pt)) > 2 * freeAngleAdjust) {
          rotatedAngle = OCR3D.rotateUnitVector2D(lastAngle, -angleAdjust); // go the other way
        }
      }

      lastAngle = rotatedAngle.get();
      rotatedAngle.mult(newDist);
      rotatedAngle.add(lastPt);

      stroke(255, map(k, 0, ptsToMake - 1, 255, 50));
      //ellipse(rotatedAngle.x, rotatedAngle.y, 8, 8);

      // add to flare
      flares.get(i).addCurvePoint(rotatedAngle.get());

      // break if too far outside the bounds
      if (toUp) {
        if (rotatedAngle.y < targetY) break;
      }
      else {
        if (rotatedAngle.y > targetY) break;
      }


      lastPt = rotatedAngle.get();


      float signedAngleBetween = OCR3D.findSignedAngle2D(lastAngle, PVector.sub(target, pt));

      if (signedAngleBetween < wiggleAngleThresh && k > (float)ptsToMake / 2) iWantToBreakFree = true;
    }
  }

  for (Spline s : flares) s.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, !splineFlipUp); // note the reverse flipUp here... tricky tricky

  for (int i = flares.size() - 1; i >= 0; i--) if (flares.get(i).totalDistance == 0) flares.remove(i); // mal formed spline

  makeFlareHeights(flares, toUp, goLeft);

  return flares;
} // end makeFlares

//
void makeFlareHeights(ArrayList<Spline> splines, boolean toUp, boolean goLeft) {
  int addition = 0;
  float targetHeight = random(minimumFlareHeight, maximumFlareHeight);
  for (Spline s : splines) {
    addition++;
    s.facetHeights = new float[0]; // reset just in case it was already in
    for (int i = 0; i < s.facetPoints.length; i++) {
      float runningDist = s.runningDistances[i];
      float runningPercent = runningDist / s.totalDistance; 

      //float noiseMultiplier = map(runningPercent * runningPercent, 0, 1, 1, 0);

      //float newHeight = constrain(defaultFontSize + noiseMultiplier * (noise(.018 * runningPercent * 100 + addition) - .5) * defaultFontSize * 6, defaultFontSize, 6 * defaultFontSize);
      float newHeight = constrain(map(runningPercent, 0, 1, defaultFontSize, targetHeight), minimumFlareHeight, maximumFlareHeight);

      s.facetHeights = (float[])append(s.facetHeights, newHeight);
    }
    if (goLeft) s.useUpHeight = false;
  }
} // end makeFlareHeights


//
//
//
//

