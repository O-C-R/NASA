int circumferencePoints = 33000; // how many poitns along the circumference
int storyCutoff = 170; // a phrase must have at least this many stories to be counted
int pictureSize = 8000;
float overallOuterRadius = 1800;
boolean saveImage = true;



//
void makeCircularDiagram() {
  // sort everything out
  ArrayList<Phrase> ppAL = new ArrayList<Phrase>();
  HashMap<HistoryStory, Integer> hsHM = new HashMap<HistoryStory, Integer>();
  int totalStories = 0; // how many stories there are.. can be duplicated
  int totalMentions = 0; // how many total phrase mentiones there are.. eg: n mentions per story.. summed up

  for (Phrase p : phrasesAll) {
    if (p.historyStories.size() >= storyCutoff) { // minimum number of history stories here
      ppAL.add(p);
      p.totalMentions = p.getMentions(); // set the total mentions
      totalStories += p.historyStories.size();
      for (Map.Entry me : p.historyStories.entrySet()) {
        HistoryStory hs = (HistoryStory)me.getKey();
        int count = (Integer)me.getValue();
        if (!hsHM.containsKey(hs)) hsHM.put(hs, 0);
        hsHM.put(hs, ((Integer)hsHM.get(hs)) + count);
        totalMentions += count;
      }
    }
  }

  println("makeCircularDiagram");
  println("total phrases: " + ppAL.size());
  println("unique stories: " + hsHM.size());
  println("total stories: " + totalStories);
  println("total mentions: " + totalMentions);

  ppAL = OCRUtils.sortObjectArrayListSimple(ppAL, "totalMentions");
  ppAL = OCRUtils.reverseArrayList(ppAL);  

  // draw the diagram
  
  float padding = 10f; // pulled back from the edge
  float totalCircumference = 2 * PI * (pictureSize - 2 * padding) / 2;
  float spacingArcLength = 15f; // arc length spacing between groups
  float spacingRotation = getRadiansForArc(spacingArcLength, totalCircumference);
  float workableArcLength = totalCircumference - (ppAL.size() * spacingArcLength);
  float startingRotation = -PI/2f + getRadiansForArc(spacingArcLength / 2f, totalCircumference);

  println("startingRotation: " + startingRotation);
  println("workableArcLength: " + workableArcLength);
  println("spacingArcLength: " + spacingArcLength);
  println("totalCircumference: " + totalCircumference);



  PGraphics pg = createGraphics(pictureSize, pictureSize);
  pg.beginDraw();
  pg.background(0);

  //float overallOuterRadius = pg.width / 2 - 100;
  
  float overallInnerRadius = overallOuterRadius - 50;
  float storyOuterRadius = overallOuterRadius - 10;
  float storyInnerRadius = overallInnerRadius;

  for (Phrase p : ppAL) {
    float pArcLength = workableArcLength * ((float)p.totalMentions / totalMentions);
    float pRadians = getRadiansForArc(pArcLength, totalCircumference);
    float endingRotation = startingRotation + pRadians;
    //println("pArcLength: " + pArcLength);
    //println("pRadians: " + pRadians);

    pg.stroke(0);
    pg.fill(255, 0, 0, 50);
    PVector[] phraseStartEnd = drawBand(pg, pg.width/2, pg.height/2, overallInnerRadius, overallOuterRadius, startingRotation, endingRotation, circumferencePoints);
    //println("start: " + startingRotation + " end: " + endingRotation);

    // do the inner stories
    float hsStartRotation = startingRotation;
    ArrayList<HistoryStory> phraseHistoryStories = p.getOrderedHistoryStories();
    for (HistoryStory hs : phraseHistoryStories) {
      int mentions = (Integer)p.historyStories.get(hs);
      float hsArcLength = pArcLength * (float)mentions / p.totalMentions;
      float hsRadians = getRadiansForArc(hsArcLength, totalCircumference);
      float hsEndingRotation = hsStartRotation + hsRadians;
      //pg.stroke(0);
      pg.noStroke();
      pg.fill(hs.c, 150);
      PVector[] startEnd = drawBand(pg, pg.width/2, pg.height/2, storyInnerRadius, storyOuterRadius, hsStartRotation, hsEndingRotation, circumferencePoints);

      hs.addBandPosition(startEnd);

      hsStartRotation = hsEndingRotation;
    }

    endingRotation += spacingRotation;
    startingRotation = endingRotation;

    PVector phraseTextLoc = phraseStartEnd[floor((float)phraseStartEnd.length / 2)];
    p.centerLoc = phraseTextLoc;
  }

  // draw connections
  for (Map.Entry me : hsHM.entrySet()) {
    //if (((HistoryStory)me.getKey()).bandPositions.size() != 2) continue;
    boolean drewBand = ((HistoryStory)me.getKey()).drawBandPositions(pg, new PVector(pg.width/2, pg.height/2));
    //if (drewBand) break;
  }

  // draw phrase labels on top
  pg.fill(255);
  pg.textSize(14);
  PVector center = new PVector(pg.width / 2, pg.height/2);
  for (Phrase p : ppAL) {
    pg.pushMatrix();
    PVector direction = PVector.sub(p.centerLoc, center);
    float dist = p.centerLoc.dist(center);
    direction.normalize();
    direction.mult(dist - 5);
    direction.add(center);
    pg.translate(direction.x, direction.y);

    float thisAngle = atan((p.centerLoc.y - center.y) / (p.centerLoc.x - center.x));
    boolean reversed = false;
    if (p.centerLoc.x > pg.width / 2) reversed = true;
    pg.rotate(thisAngle);
    if (!reversed) pg.textAlign(LEFT, CENTER);
    else pg.textAlign(RIGHT, CENTER);
    pg.text(p.phrase, 0, 0);
    pg.popMatrix();
  }

  // draw story labels
  pg.textSize(12);
  pg.fill(255);
  for (Map.Entry me : hsHM.entrySet()) {
    ((HistoryStory)me.getKey()).drawLabels(pg, center, (overallOuterRadius - overallInnerRadius));
  }

  pg.endDraw();

  if (saveImage) pg.save("output/" + timeStamp + ".png");

  image(pg, 0, 0, width, height);
} // end makeCircularDiagram

//
float getRadiansForArc(float arcLengthIn, float circumferenceIn) {
  return (TWO_PI * arcLengthIn / circumferenceIn);
} // end getRadiansForArc

//
PVector[] drawBand(PGraphics pg, float x, float y, float innerRad, float outerRad, float startAngle, float endAngle, int divisions) {
  PVector[] startEnd = new PVector[0]; 
  // divisions are for the entire circle, so this portion will just ceil up to the required divisions
  // assume it always goes clockwise
  // adjust the end angle if it is before the startAngle

  startAngle %= 2 * (float)Math.PI;
  endAngle %= 2 * (float)Math.PI;
  if (endAngle < startAngle) {
    endAngle += 2 * (float)Math.PI;
  }

  float totalCircumference = outerRad * (float)Math.PI * 2;
  float outerArcLength = totalCircumference * (endAngle - startAngle) / (2 * (float)Math.PI);
  int divisionsToUse = ceil(divisions * outerArcLength / totalCircumference);

  float ptx, pty, thisAngle;  
  pg.beginShape();
  //outerband
  for (int i = 0; i < divisionsToUse; i++) {
    thisAngle = map(i, 0, divisionsToUse - 1, startAngle, endAngle);
    ptx = x + outerRad * (float)Math.cos(thisAngle);
    pty = y + outerRad * (float)Math.sin(thisAngle);
    pg.vertex(ptx, pty);
  }
  //innerband
  for (int i = divisionsToUse - 1; i >= 0; i--) {
    thisAngle = map(i, 0, divisionsToUse - 1, startAngle, endAngle);
    ptx = x + innerRad * (float)Math.cos(thisAngle);
    pty = y + innerRad * (float)Math.sin(thisAngle);
    pg.vertex(ptx, pty);
    startEnd = (PVector[])append(startEnd, new PVector(ptx, pty));
  }
  pg.endShape(CLOSE);
  return startEnd;
} // end drawBand

//
//
//
//
//
//

