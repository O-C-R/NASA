float[] padding = {
  20, 20, 150, 250
};

//
void scatterPlotPageVsMonthDensity() {
  PGraphics pg = createGraphics(10000, 3500);
  pg.beginDraw();
  pg.background(255);

  int minPage = 1;
  int maxPage = 1;
  int minYearMonthCount = 1;
  int maxYearMonthCount = 1;
  int maxWordCount = 1;
  int minWordCount = 1;

  // some limiting caps so better expand things
  int wordCap = 10376;
  int pageCap = 128;
  boolean useCaps = true;

  HashMap<String, Integer> yearMonthCount = new HashMap<String, Integer>();
  HashMap<String, ArrayList<NYTStory>> yearMonthConnector = new HashMap<String, ArrayList<NYTStory>>();  

  for (int i = 0; i < nytStoriesAll.size(); i++) {
    NYTStory st = nytStoriesAll.get(i);
    if (st.printPage > -1) {    
      minPage = (minPage < st.printPage ? minPage : st.printPage);
      maxPage = (maxPage > st.printPage ? maxPage : st.printPage);
      minWordCount = (minWordCount < st.wordCount ? minWordCount : st.wordCount);
      maxWordCount = (maxWordCount > st.wordCount ? maxWordCount : st.wordCount);
      String yearMonth = st.pubDateString.substring(0, 6);
      if (!yearMonthCount.containsKey(yearMonth)) {
        yearMonthCount.put(yearMonth, 0);
        yearMonthConnector.put(yearMonth, new ArrayList<NYTStory>());
      }
      int oldCount = (Integer)yearMonthCount.get(yearMonth);
      yearMonthCount.put(yearMonth, oldCount + 1);
      maxYearMonthCount = (maxYearMonthCount > oldCount + 1 ? maxYearMonthCount : oldCount + 1);
      ArrayList<NYTStory> thisList = (ArrayList<NYTStory>)yearMonthConnector.get(yearMonth);
      thisList.add(st);
      yearMonthConnector.put(yearMonth, thisList);
    }
  }

  if (useCaps) {
    maxWordCount = wordCap;
    maxPage = pageCap;
    minPage = 1;
  }

  pg.stroke(0, 20);

  for (NYTStory st : nytStoriesAll) {
    if (st.printPage > -1) {
      String yearMonth = st.pubDateString.substring(0, 6);
      int groupCount = (Integer)yearMonthCount.get(yearMonth);
      int page = st.printPage;
      float rad = map(sqrt(sqrt(groupCount)), 1, sqrt(sqrt(maxYearMonthCount)), 2, 30); 
      //float x = constrain(map(sqrt(st.printPage), sqrt(minPage), sqrt(maxPage), padding[3], pg.width - padding[1]), padding[3], pg.width - padding[1]);
      //float y = constrain(map(sqrt(sqrt(st.wordCount)), sqrt(sqrt(minWordCount)), sqrt(sqrt(maxWordCount)), pg.height - padding[2], padding[0]), padding[0], pg.height - padding[2]);
      float x = map(sqrt(st.printPage), sqrt(minPage), sqrt(maxPage), padding[3], pg.width - padding[1]);
      float y = map(sqrt(sqrt(st.wordCount)), sqrt(sqrt(minWordCount)), sqrt(sqrt(maxWordCount)), pg.height - padding[2], padding[0]);;
      float xVariation = random(-2.5 * rad, 2.5 * rad);
      pg.fill(0, 100);
      pg.ellipse(x + xVariation, y, rad, rad);
      if (xVariation > rad/2) pg.line(x, y, x + (xVariation - rad/2), y);
      else if (abs(xVariation) > rad/2) pg.line(x, y, x - (abs(xVariation) - rad/2), y);
      st.tempPosition.set(x + xVariation, y);
    }
  }

  // connections

  for (Map.Entry me : yearMonthConnector.entrySet()) {
    ArrayList<NYTStory> connections = (ArrayList<NYTStory>)me.getValue();
    
  pg.stroke(0, map(sqrt((Integer)yearMonthCount.get((String)me.getKey())), 0, sqrt(maxYearMonthCount), 10, 40));
  pg.noFill();
    if (connections.size() > 1) {
      pg.beginShape();
      for (NYTStory st : connections) {
        pg.vertex(st.tempPosition.x, st.tempPosition.y);
      }
      pg.endShape();
    }
  } 

  // axis labels
  // x
  float lastX = -100f;
  float xSpacing = 30f;
  pg.fill(0);
  pg.textAlign(CENTER, CENTER);
  pg.text("page number", pg.width / 2, pg.height - 10);

  for (int i = minPage; i <= maxPage; i++) {
    //float x = constrain(map(sqrt(i), sqrt(minPage), sqrt(maxPage), padding[3], pg.width - padding[1]), padding[3], pg.width - padding[1]);
    float x = map(sqrt(i), sqrt(minPage), sqrt(maxPage), padding[3], pg.width - padding[1]);
    if (x - lastX > xSpacing) {
      pg.text(i, x, pg.height - 25);
      lastX = x;
      pg.line(x, 0, x, pg.height);
    }
  }
  float lastY = pg.height + 100;
  float ySpacing = 15f;
  pg.pushMatrix();
  pg.translate(pg.width - padding[1], pg.height / 2);
  pg.rotate(-PI/2);
  pg.text("word count", 0, 0);
  pg.popMatrix();
  pg.textAlign(RIGHT, CENTER);
  for (int i = minWordCount; i <= maxWordCount; i++) {
    //float y = constrain(map(sqrt(sqrt(i)), sqrt(sqrt(minWordCount)), sqrt(sqrt(maxWordCount)), pg.height - padding[2], padding[0]), padding[0], pg.height - padding[2]);
    float y = map(sqrt(sqrt(i)), sqrt(sqrt(minWordCount)), sqrt(sqrt(maxWordCount)), pg.height - padding[2], padding[0]);
    if (lastY - y > ySpacing) {
      pg.text(i, pg.width - padding[2], y);
      lastY = y;
      pg.line(0, y, pg.width, y);
    }
  }

  println(yearMonthCount);
  println("minPage: " + minPage + " maxPage: " + maxPage + " maxYearMonthCount: " + maxYearMonthCount);
  println("minWordCount: " + minWordCount + " maxWordCount: " + maxWordCount);

  pg.textAlign(LEFT, TOP);
  pg.text("size of dot shows that story was in a month with a lot of stories", 20, 20);
  pg.text("note: dots were given a little wiggle room in the x to help reduce overlap and illustrate all dots", 20, 40);
  //pg.text("note: dots on the far edge may have exceeded the bounds.. and so were constrained to the borders", 20, 40);
  

  pg.endDraw();
  pg.save("output/" + timeStamp + "scatterPlotPageVsMonthDensity.png");
} // end scatterPlotPageVsMonthDensity

//
//
//
//
//
//
//

