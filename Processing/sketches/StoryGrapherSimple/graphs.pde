//
void graphStoriesPerYear(PGraphics pg) {
  String name = "storiesPerYear"; // saved out
  String xLabel = "year";
  String yLabel = "storyCount";
  float[] xs, ys;
  String[] xLabels, yLabels;
  xs = ys = new float[0];
  xLabels = yLabels = new String[0];

  for (Year yr : years) {
    xs = (float[])append(xs, yr.year);
    xLabels = (String[])append(xLabels, yr.year + "");
    ys = (float[])append(ys, yr.stories.size());
  }

  float[] rangeX, rangeY;
  rangeX = rangeY = new float[2];
  rangeY = getRange(ys);
  rangeY[0] = 0; // start at o

  drawGraph(name + "-bar", xLabel, xLabels, xs, rangeX, 1, yLabel, yLabels, ys, rangeY, 1, pg, TYPE_BAR);
  drawGraph(name + "-line", xLabel, xLabels, xs, rangeX, 1, yLabel, yLabels, ys, rangeY, 1, pg, TYPE_LINE);
} // end graphStoriesPerYear

//
void storiesPerMonthTotal(PGraphics pg) {
  String name = "storiesPerMonthTotal"; // saved out
  String xLabel = "time";
  String yLabel = "storyCount per month";
  float[] xs, ys;
  String[] xLabels, yLabels;
  xs = ys = new float[0];
  xLabels = yLabels = new String[0];

  boolean started = false;
  for (Year yr : years) {
    for (int i = 0; i < yr.storiesByMonth.size(); i++) {
      ys = (float[])append(ys, yr.storiesByMonth.get(i).size());
      xLabels = (String[])append(xLabels, "" + yr.year);
    }
  }

  float[] rangeX, rangeY;
  rangeX = rangeY = new float[2];
  rangeY = getRange(ys);
  rangeY[0] = 0; // start at o

  drawGraph(name + "-bar", xLabel, xLabels, xs, rangeX, 12, yLabel, yLabels, ys, rangeY, 1, pg, TYPE_BAR);
  drawGraph(name + "-line", xLabel, xLabels, xs, rangeX, 12, yLabel, yLabels, ys, rangeY, 1, pg, TYPE_LINE);
} // end graphStoriesPerYear


//
void storiesPerMonthWordAverage(PGraphics pg) {
  String name = "storiesPerMonthWordAverage"; // saved out
  String xLabel = "time";
  String yLabel = "avg words per story per month";
  float[] xs, ys;
  String[] xLabels, yLabels;
  xs = ys = new float[0];
  xLabels = yLabels = new String[0];

  boolean started = false;
  for (Year yr : years) {
    for (int i = 0; i < yr.storiesByMonth.size(); i++) {
      float totalWordCount = 0;
      for (Story st : yr.storiesByMonth.get(i)) {
        totalWordCount += (splitTokens(st.story, " ,.-()[]")).length;
      }
      ys = (float[])append(ys, totalWordCount / yr.storiesByMonth.get(i).size());
      xLabels = (String[])append(xLabels, "" + yr.year);
    }
  }

  float[] rangeX, rangeY;
  rangeX = rangeY = new float[2];
  rangeY = getRange(ys);
  rangeY[0] = 0; // start at o

  drawGraph(name + "-bar", xLabel, xLabels, xs, rangeX, 12, yLabel, yLabels, ys, rangeY, 1, pg, TYPE_BAR);
  drawGraph(name + "-line", xLabel, xLabels, xs, rangeX, 12, yLabel, yLabels, ys, rangeY, 1, pg, TYPE_LINE);
} // end storiesPerMonthWordAverage




//
void storiesByWordCountVSReadingLevel(PGraphics pg) {
  // essentially the x will be the word count
  // the y will be reading level
  String name = "sotiresByWordCountVSReadingLevel"; // saved out
  String xLabel = "word count";
  String yLabel = "rough flesch kincaid reading score";
  float[] xs, ys;
  String[] xLabels, yLabels;
  xs = ys = new float[0];
  xLabels = yLabels = new String[0];

  int count = 0;
  boolean started = false;
  for (Year yr : years) {
    for (int i = 0; i < yr.storiesByMonth.size(); i++) {
      for (Story st : yr.storiesByMonth.get(i)) {
        try {
          float fleschTestScore = fleschTest(st.story);
          if (fleschTestScore < 0) {
            println("skip: " + fleschTestScore);
            continue; // skip the ones that are a wacky negative value
          }
          ys = (float[])append(ys, fleschTestScore);
          xs = (float[])append(xs, (splitTokens(st.story, " ,.-()[]")).length);
        }
        catch(Exception e) {
          println("problem getting flesch score from: " + st.year.year + " -- " + st.month + "/" + st.day);
        }
      }
    }
  }

  float[] rangeX, rangeY;
  rangeX = rangeY = new float[2];
  rangeY = getRange(ys);
  rangeX = getRange(xs);
  rangeY[0] = 0;
rangeX[0] = 0;  

  drawGraph(name + "-scatter", xLabel, xLabels, xs, rangeX, 1, yLabel, yLabels, ys, rangeY, 1, pg, TYPE_SCATTER);
} // end storiesByWordCountVSReadingLevel
//
//
//
//
//

