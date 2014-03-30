//
float[] padding = {
  50, 100, 50, 100
};
//
void outputPhrases() {
  println("in outputPhrases");
  PGraphics pg = createGraphics(1000, 600);
  pg.beginDraw();
  pg.background(255);

  float verticalSpacing = 6f;

  int tempCount = 0;

  // year markings
  for (int i = yearRange[0]; i <= yearRange[1]; i++ ) {
    float x = map(i, yearRange[0], yearRange[1] + 1, padding[3], pg.width - padding[1]);
    if (i % 5 == 0) pg.stroke(0, 100);
    else pg.stroke(0, 50);
    pg.line(x, 0, x, pg.height);
    if (i % 5 == 0) {
     pg.fill(0, 150);
    pg.textAlign(CENTER, CENTER);
   pg.text(i, x, pg.height - 20); 
    }
  }

  // assign positions to the stories
  HashMap<String, ArrayList<NYTStory>> quarterTracker = new HashMap<String, ArrayList<NYTStory>>(); // 195001 to see how many are in each quarter of a year
  for (PhraseReference pr : phraseKeeperAll) {
    for (int i = 0; i < pr.stories.size(); i++) {
      String storyQuarter = pr.stories.get(i).pubDateString.substring(0, 4);
      int quarter = floor((Float.parseFloat(pr.stories.get(i).pubDateString.substring(4, 6)) - 1) / 3);
      storyQuarter += "" + nf(quarter, 2); 
      if (!quarterTracker.containsKey(storyQuarter)) quarterTracker.put(storyQuarter, new ArrayList<NYTStory>());
      ArrayList<NYTStory> thisQuarter = (ArrayList<NYTStory>)quarterTracker.get(storyQuarter);
      if (!thisQuarter.contains(pr.stories.get(i))) {
        float x = map(quarter + pr.stories.get(i).pubDate.get(Calendar.YEAR) * 4, yearRange[0] * 4, 4 * (yearRange[1]), padding[3], pg.width - padding[1]);
        float y = pg.height - padding[2] - (thisQuarter.size() + 1) * verticalSpacing;
        PVector newPos = new PVector(x, y);
        pr.stories.get(i).pos = newPos;
        thisQuarter.add(pr.stories.get(i));
        quarterTracker.put(storyQuarter, thisQuarter);
        tempCount++;
        //println("adding story: " + tempCount);
      }
      else {
        // positions already assigned
      }
    }
  }

  // run through each pr and story to connect the lines
  for (PhraseReference pr : phraseKeeperAll) {
    pg.beginShape();
    pg.stroke(0, 40);
    pg.noFill();
    for (NYTStory nyt : pr.stories) {
      pg.vertex(nyt.pos.x, nyt.pos.y);
    }
    pg.endShape();
    for (NYTStory nyt : pr.stories) {
      pg.fill(0, 100);
      pg.noStroke();
      pg.ellipse(nyt.pos.x, nyt.pos.y, 4, 4);
    }
  }


  pg.endDraw();
  pg.save("output/" + yearRange[0] + "-" + yearRange[1] + "_" + phraseKeeperAll.size() + "_" + nytStoriesHM.size() + ".png");
  println("end of outputPhrases");
} // end ouptutPhrases

//
//
//
//

