class HistoryStory {  
  String month = "";
  int monthNumber = 0;
  int day = 0;
  String story = "";
  Calendar cal = null;
  int year = 0;

  int id = 0;

  color c = color(random(255), random(255), random(255));

  HashMap<Phrase, Integer> phraseAndCount = new HashMap<Phrase, Integer>(); // phrases belonging to this story along with count

  // keep track of the phrase bands
  ArrayList<HistoryBandPosition> bandPositions = new ArrayList<HistoryBandPosition>();

  //
  HistoryStory(String month, int day, int monthNumber, String story) {
    this.month = month;
    this.day = day;
    this.monthNumber = monthNumber;
    this.story = story;
  } // end constructor

  //
  HistoryStory(JSONObject json, int year) {
    this.month = json.getString("month");
    this.day = json.getInt("day");
    this.monthNumber = json.getInt("monthNumber");
    this.year = year;
    this.story = json.getString("story").trim();
    cal = getCalFromDataTime(year + nf(monthNumber, 2) + nf(day, 2));
  } // end constructor

  //
  void addPhrase(Phrase phrase, int count) {
    phraseAndCount.put(phrase, count);
  } // end addPhrase

  //
  void addBandPosition(PVector[] pts) {
    HistoryBandPosition hbp = new HistoryBandPosition();
    hbp.pts = pts;
    bandPositions.add(hbp);
  } // end addBandPosition

  //
  boolean drawBandPositions(PGraphics pg, PVector center) {
    boolean drewBand = false;
    float outsideStrength = .65;
    float insideStrength = .63;

    float multFactor = 1f; // changes with distance from eachother

    if (bandPositions.size() > 1) {
      drewBand = true;
      for (int i = 0; i < bandPositions.size(); i++) {
        //if (i == 1) break; // manual debug

        HistoryBandPosition first = bandPositions.get(i);
        HistoryBandPosition second = null;

        // skip this if there are only two bands
        if (bandPositions.size() == 2 && i == bandPositions.size() - 1) return true;

        if (i < bandPositions.size() - 1) {
          second = bandPositions.get(i + 1);
        }
        else {
          second = bandPositions.get(0);
        }


        // determin the mult factor based on distance from center and distance from each other
        float diam = 2 * first.pts[0].dist(center);
        float dist = first.pts[0].dist(second.pts[second.pts.length - 1]);
        multFactor = map(dist, 0, diam, .1, 1);


        /*
        pg.stroke(0);
         pg.line(first.start.x, first.start.y, second.start.x, second.start.y);
         */
        PVector firstD1 = PVector.sub(center, first.pts[0]);
        firstD1.mult(insideStrength * multFactor);
        PVector firstCP1 = PVector.add(first.pts[0], firstD1);
        PVector firstD2 = PVector.sub(center, first.pts[first.pts.length - 1]);
        firstD2.mult(outsideStrength * multFactor);
        PVector firstCP2 = PVector.add(first.pts[first.pts.length - 1], firstD2);
        /*
        pg.stroke(0);
         pg.ellipse(firstCP1.x, firstCP1.y, 23, 23);
         pg.line(firstCP1.x, firstCP1.y, first.pts[0].x, first.pts[0].y);
         pg.stroke(122, 0, 122);
         pg.ellipse(firstCP2.x, firstCP2.y, 3, 3);
         pg.line(firstCP2.x, firstCP2.y, first.pts[first.pts.length - 1].x, first.pts[first.pts.length - 1].y);
         */

        PVector secondD1 = PVector.sub(center, second.pts[second.pts.length - 1]);
        secondD1.mult(insideStrength * multFactor);
        PVector secondCP1 = PVector.add(second.pts[second.pts.length - 1], secondD1);
        PVector secondD2 = PVector.sub(center, second.pts[0]);
        secondD2.mult(outsideStrength * multFactor);
        PVector secondCP2 = PVector.add(second.pts[0], secondD2);

        /*
        pg.stroke(0);
         pg.ellipse(secondCP1.x, secondCP1.y, 13, 13);
         pg.line(secondCP1.x, secondCP1.y, second.pts[second.pts.length - 1].x, second.pts[second.pts.length - 1].y);
         pg.stroke(122, 0, 122);
         pg.ellipse(secondCP2.x, secondCP2.y, 3, 3);
         pg.line(secondCP2.x, secondCP2.y, second.pts[0].x, second.pts[0].y);
         
         pg.ellipse(first.pts[0].x, first.pts[0].y, 10, 10);
         pg.ellipse(second.pts[second.pts.length - 1].x, second.pts[second.pts.length - 1].y, 20, 20);
         */

        //pg.stroke(0, 255, 0);
        pg.noStroke();
        //pg.strokeWeight(5);
        //pg.noFill();
        pg.fill(c, constrain(map(bandPositions.size(), 2, 14, 10, 150), 40, 150));
        pg.beginShape();
        pg.vertex(first.pts[0].x, first.pts[0].y);
        pg.bezierVertex(firstCP1.x, firstCP1.y, secondCP1.x, secondCP1.y, second.pts[second.pts.length - 1].x, second.pts[second.pts.length - 1].y);
        for (int k = second.pts.length - 1; k >= 0; k--) pg.vertex(second.pts[k].x, second.pts[k].y);
        pg.bezierVertex(secondCP2.x, secondCP2.y, firstCP2.x, firstCP2.y, first.pts[first.pts.length - 1].x, first.pts[first.pts.length - 1].y);
        for (int k = first.pts.length - 1; k >= 0; k--) pg.vertex(first.pts[k].x, first.pts[k].y);
        pg.endShape(CLOSE);
      }
    }
    return drewBand;
  } // end drawBandPositions

  //
  void drawLabels(PGraphics pg, PVector center, float radiusAddition) {
    for (HistoryBandPosition hb : bandPositions) {
      PVector pt = hb.getMedian();
      PVector direction = PVector.sub(pt, center);
      float dist = pt.dist(center);
      direction.normalize();
      direction.mult(dist + 5 + radiusAddition);
      direction.add(center);
      pg.pushMatrix();
      pg.translate(direction.x, direction.y);
      float thisAngle = atan((pt.y - center.y) / (pt.x - center.x));
      boolean reversed = false;
      if (pt.x > center.x) reversed = true;
      pg.rotate(thisAngle);
      if (reversed) pg.textAlign(LEFT, CENTER);
      else pg.textAlign(RIGHT, CENTER);
      pg.text(story, 0, 0);
      pg.popMatrix();
    }
  } //e nd drawLabels


  //
  String toString() {
    String builder = month + " " + day + ", " + year + "\n";
    builder += story + "\n";
    return builder;
  } // end toString

  //

  //
  JSONObject getJSON() {
    JSONObject output = new JSONObject();
    output.setString("month", month);
    output.setInt("day", day);
    output.setInt("monthNumber", monthNumber);
    output.setString("story", story);
    return output;
  } // end getJSON
} // end class HistoryStory



//
class HistoryBandPosition {
  PVector[] pts = new PVector[0];

  //
  PVector getMedian() {
    return pts[floor((float)pts.length / 2)];
  } // end getMedian
} /// end class HistoryBandPosition

//
//
//
//
//
//
//
//

