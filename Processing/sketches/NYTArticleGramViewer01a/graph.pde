float[] padding = {
  20, 20, 40, 40
};

//
void makeGraphPoints(PGraphics pg) {

  for (Gram g : grams) {
    ArrayList<PVector> pts = new ArrayList<PVector>();
    for (int year = lowYear; year <= highYear; year++) {
      float x = map(year, lowYear, highYear, padding[3], pg.width - padding[1]); 
      float y = pg.height - padding[2];
      if (g.yearsCounts.containsKey(year)) {
        y = map((Integer)g.yearsCounts.get(year), minCount, maxCount, pg.height - padding[2], padding[0]);
      }
      pts.add(new PVector(x, y));
    }
    g.graphPoints = pts;
  }
} // end makeGraphPoints

//
void graphGrams(PGraphics pg, PVector mouseLoc) {
  for (Gram g : grams) g.label.mouseOver(mouseLoc);
  drawGridAndAxis(pg);
  for (Gram g : grams) g.graph(pg);
  // draw the selected one again
  for (Gram g : grams) if (g.selected) g.graph(pg);
  for (Gram g : grams) g.label.display(pg);
} // end graphGrams

// 
void drawGridAndAxis(PGraphics pg) {
  // x axis -- horizontals
  int yAdd = 250;
  pg.textAlign(RIGHT, CENTER);
  pg.fill(0, 100);
  for (int y = minCount; y <= maxCount; y+= yAdd) {
    if (y == minCount) pg.stroke(0, 100);
    else pg.stroke(0, 50);
    float yloc = map(y, minCount, maxCount, pg.height - padding[2], padding[0]);
    pg.line(padding[3], yloc, pg.width - padding[1], yloc);
    pg.text(y, padding[3] - 3, yloc);
  }
  //y axis -- verticals
  int xAdd = 5;
  pg.textAlign(RIGHT, TOP);
  for (int x = lowYear; x <= highYear; x+= xAdd) {
    if (x == lowYear) pg.stroke(0, 100);
    else pg.stroke(0, 50);
    float xloc = map(x, lowYear, highYear, padding[3], pg.width - padding[1]);
    pg.line(xloc, padding[0], xloc, pg.height - padding[2]);
    pg.pushMatrix();
    pg.translate(xloc, pg.height - padding[2] + 3);
    pg.rotate(-PI/8);
    pg.text(x, 0, 0);
    pg.popMatrix();
  }
} // end drawGridAndAxis 


//
void applyLabels(PGraphics pg) {
  // somehow sort the grams by something ??
  grams = OCRUtils.sortObjectArrayListSimple(grams, "totalHits");
  grams = OCRUtils.reverseArrayList(grams);
  PVector startingPos = new PVector(padding[3] + 20, padding[0] + 20);
  int count = 0;
  for (int i = 0; i < grams.size(); i++) {
    if (count != 0) startingPos.y += 18; // label set to height of 15
    if (startingPos.y > height - padding[2] - 40) {
      startingPos.y = padding[0] + 20;
      startingPos.x += 125;
      count = 0;
    }
    count++;
    grams.get(i).label = new Label(grams.get(i), startingPos.get());
  }
} // end applyLabels

//
//
//
//

