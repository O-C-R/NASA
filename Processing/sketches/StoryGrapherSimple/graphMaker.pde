float[] padding = {
  40f, 40f, 60f, 80f
};
int xCount = 14;
int yCount = 10;

// graph types
final int TYPE_BAR = 0;
final int TYPE_LINE = 1;
final int TYPE_SCATTER = 2;


//
void setupGraphEnvironment(PGraphics pg) {
  pg.background(255);
  pg.strokeWeight(1);
} // end setupGraphEnvironment

//
void drawGraph(String name, String xLabel, String[] xLabels, float[] xs, float[] rangeX, int xSkip, String yLabel, String[] yLabels, float[] ys, float[] rangeY, int ySkip, PGraphics pg, int graphType) {
  boolean drawX, drawY;
  drawX = drawY = false;
  // to draw the y values, don't include y labels
  // to draw the x values, don't include the x labels
  // to draw a scatter plot don't include x or y labels 
  if (xLabels.length == 0) {
    xLabels = makeLabels(rangeX, "x");
    drawX = true;
  }
  if (yLabels.length == 0) {
    yLabels = makeLabels(rangeY, "y");
    drawY = true;
  }

  pg.beginDraw();
  setupGraphEnvironment(pg);
  drawGridAndLabels(xLabel, xLabels, xs, rangeX, xSkip, yLabel, yLabels, ys, rangeY, ySkip, pg);

  // assume drawY, otherwise switch to x
  float[] values = ys;
  float[] range = rangeY;
  if (drawX) {
    values = xs;
    range = rangeX;
  }

  switch(graphType) {
  case TYPE_BAR:
    drawValuesBar(pg, drawY, values, range);
    break;
  case TYPE_LINE:
    drawValuesLine(pg, drawY, values, range);
    break;
  case TYPE_SCATTER:
    drawValuesScatter(pg, xs, rangeX, ys, rangeY);
    break;
  }
  pg.endDraw();
  output(pg, name);
} // end drawGraph

//
float[] getRange (float[] values) {
  float[] range = new float[2];
  if (values.length > 0) {
    range[0] = range[1] = values[0];
    for (float f : values) {
      range[0] = (range[0] < f ? range[0] : f);
      range[1] = (range[1] > f ? range[1] : f);
    }
  }
  return range;
} // end getRange


// 
String[] makeLabels(float[] rangeIn, String axis) {
  String[] labels = new String[0];
  if (axis.equals("x")) {
    for (int i = 0; i < xCount; i++) {
      labels = (String[])append(labels, nf(map(i, 0, xCount - 1, rangeIn[0], rangeIn[1]), 0, 2));
    }
  }
  else {
    for (int i = 0; i < yCount; i++) {
      labels = (String[])append(labels, nf(map(i, 0, yCount - 1, rangeIn[0], rangeIn[1]), 0, 2));
    }
  }
  return labels;
} // end makeLabels

//
void drawGridAndLabels(String xLabel, String[] xLabels, float[] xs, float[] rangeX, int xSkip, String yLabel, String[] yLabels, float[] ys, float[] rangeY, int ySkip, PGraphics pg) {

  // axis
  pg.textSize(12);
  pg.stroke(0, 77);
  pg.strokeWeight(2);
  pg.line(padding[3], pg.height - padding[2], pg.width - padding[1], pg.height - padding[2]);
  pg.line(padding[3], pg.height - padding[2], padding[3], padding[0]);

  // grid + labels
  pg.stroke(0, 36);
  pg.strokeWeight(1);
  for (int x = 0; x < xLabels.length; x+=xSkip) {
    float xPos = map(x, 0, xLabels.length - 1, padding[3], pg.width - padding[1]);
    pg.line(xPos, pg.height - padding[2], xPos, padding[0]);
    pg.textAlign(RIGHT, CENTER);
    pg.pushMatrix();
    pg.translate(xPos, pg.height - padding[2]);
    pg.translate(0, 10);
    pg.rotate(-PI/4);
    pg.fill(127);
    pg.text(xLabels[x], 0, 0);
    pg.popMatrix();
  }
  for (int y = 0; y < yLabels.length; y+=ySkip) {
    float yPos = map(y, 0, yLabels.length - 1, pg.height - padding[2], padding[0]);
    pg.line(padding[3], yPos, pg.width - padding[1], yPos);
    pg.textAlign(RIGHT, CENTER);
    pg.pushMatrix();
    pg.translate(padding[3], yPos);
    pg.translate(-10, 0);
    pg.fill(127);
    pg.text(yLabels[y], 0, 0);
    pg.popMatrix();
  }

  // axis and title labeling
  pg.textAlign(CENTER, BOTTOM);
  pg.text(xLabel, (pg.width - padding[1] - padding[3]) / 2 + padding[3], pg.height - 4);
  pg.pushMatrix();
  pg.textAlign(CENTER, TOP);
  pg.translate(4, (pg.height - padding[0] - padding[2]) / 2 + padding[0]);
  pg.rotate(-PI/2);
  pg.text(yLabel, 0, 0);
  pg.popMatrix();

  pg.textAlign(CENTER, BOTTOM);
  pg.textSize(20);
  pg.text(xLabel + " vs. " + yLabel + "", pg.width / 2, padding[0] - 4);
} // end drawGridAndLabels

//
void drawValuesBar(PGraphics pg, boolean drawY, float[] values, float[] range) {
  pg.noStroke();
  pg.fill(90);
  float barWidth = 0f;
  float barHeight = 0f;
  if (drawY) {
    barWidth = (float)((pg.width - padding[1] - padding[3])) / values.length;
    barWidth *= .75;
    for (int i = 0; i < values.length; i++) {
      float x = map(i, 0, values.length - 1, padding[3], pg.width - padding[1]);
      float y = pg.height - padding[2];
      barHeight = map(values[i], range[0], range[1], 0, pg.height - padding[0] - padding[2]);
      pg.rect(x - barWidth / 2, y, barWidth, -barHeight);
    }
  }
  else {
    barHeight = (float)((pg.height - padding[0] - padding[2])) / values.length;
    barHeight *= .75;
    for (int i = 0; i < values.length; i++) {
      float x = padding[3];
      float y = map(i, 0, values.length - 1, padding[0], pg.height - padding[2]);
      barWidth = map(values[i], range[0], range[1], 0, pg.width - padding[1] - padding[3]);
      pg.rect(x, y - barHeight / 2, barWidth, barHeight);
    }
  }
} // end drawValuesBar

//
void drawValuesLine(PGraphics pg, boolean drawY, float[] values, float[] range) {
  ArrayList<PVector> pts = new ArrayList<PVector>();
  if (drawY) {
    for (int i = 0; i < values.length; i++) {
      float x = map(i, 0, values.length - 1, padding[3], pg.width - padding[1]);
      float y = pg.height - padding[2];
      y -= map(values[i], range[0], range[1], 0, pg.height - padding[0] - padding[2]);
      pts.add(new PVector(x, y));
    }
  }
  else {
    for (int i = 0; i < values.length; i++) {
      float x = padding[3];
      x += map(values[i], range[0], range[1], 0, pg.width - padding[1] - padding[3]);
      float y = map(i, 0, values.length - 1, padding[0], pg.height - padding[2]);
      pts.add(new PVector(x, y));
    }
  }

  pg.stroke(90);
  pg.noFill();
  pg.beginShape();
  for (PVector pt : pts) {
    pg.vertex(pt.x, pt.y);
  }
  pg.endShape();

  pg.noStroke();
  pg.fill(90);
  for (PVector pt: pts) {
    pg.ellipse(pt.x, pt.y, 5, 5);
  }
} // end drawValuesLine

//
void drawValuesScatter(PGraphics pg, float[] xs, float[] rangeX, float[] ys, float[] rangeY) {
  for (int i = 0; i < xs.length; i++) {
    pg.stroke(0, 127);
    pg.strokeWeight(3);
    float x = map(xs[i], rangeX[0], rangeX[1], padding[3], pg.width - padding[1]);
    float y = map(ys[i], rangeY[0], rangeY[1], padding[0], pg.height - padding[2]);
    pg.point(x, y);
  }
} // end drawValuesScatter

//
//
//
//

