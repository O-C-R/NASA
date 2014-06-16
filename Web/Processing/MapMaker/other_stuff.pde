void makeRandom(PVector center) {
  int pts = (int)random(10, 15);
  float angle = 0f;
  PVector newPt = new PVector();
  currentRegion = new Region((int)random(10000));
    regions.add(currentRegion);
  for (int i = 0; i < pts; i++) {
    angle = map(i, 0, pts, 0, TWO_PI);
    newPt.set(cos(angle), sin(angle));
    newPt.mult(random(10, 15));
    newPt.add(center);
    
    currentWorldLoc = getWorldCoordFromMouseLocation(newPt);
    currentRegion.addPoint(currentWorldLoc);
    if (i == pts - 1) currentRegion.closeRegion();
  }
  
  currentRegion.fileName = nf(regions.size(), 3);
  currentRegion.deselectRegion();
  currentRegion = null;
  println("added.  " + regions.size());
} // end makeRandom


//
//
//
//

