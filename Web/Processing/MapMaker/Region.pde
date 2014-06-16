//
public static class Region implements Serializable {
  public int id = 0;
  public ArrayList<PVector> pts = new ArrayList();
  public boolean isAddingPoints = true;
  public boolean isActive = true;
  public String fileName = "";
  public String oldFileName = "";
  public PVector center = new PVector();
  public float closeTolerance = 2f; // when clicking inside this distance it will close the region

  //public String name

  //
  public Region(int id) {
    this.id = id;
  } // end constructor

  //
  public void addPoint(PVector point) {
    boolean autoClose = false;
    if (pts.size() > 2) {
      if (point.dist(pts.get(0)) < closeTolerance) {
        //println("closing shape");
        closeRegion();
        autoClose = true;
      }
    }

    if (!autoClose) {
      pts.add(point.get());
      makeCenter();
    }
  } // end addPoint

  //
  public void removeLastPt() {
    if (pts.size() > 0) pts.remove(pts.size() - 1);
    makeCenter();
  } // end removeLastPt

  //
  public void makeCenter() {
    center.set(0, 0);
    for (PVector p : pts) center.add(p);
    if (pts.size() > 0) center.div(pts.size());
  } // end makeCenter

  //
  public void clearPoints() {
    pts.clear();
  } // end clearPoints

  //
  public void backspace() {
    //println("BACKSPACING");
    if (fileName.length() > 0) fileName = fileName.substring(0, fileName.length() - 1);
  } // end backspace

  //
  public void dealWithKey(String k) {
    fileName += "" + k;
  } // end dealWithKey

  //
  public void closeRegion() {
    isAddingPoints = false;
  } // end closeRegion

  //
  public void deselectRegion() {
    isActive = false;
  } // end deselectRegion
} // end class Region



//
void drawRegion(Region r, boolean showText) {
  color c = color(35, 255, 0);
  if (r.fileName.length() == 0) {
    c = color(255, 0, 0);
  }
  if (r.isAddingPoints && r.isActive) {
    c = color(0, 130, 255);
  } else if (!r.isAddingPoints && r.isActive) {
    c = color(255, 127, 0);
  } 


  noStroke();
  fill(c, 30);
  beginShape();
  for (PVector p : r.pts) vertex(p.x, p.y);
  endShape(CLOSE);

  noFill();

  if (!r.isActive) stroke(c, 150);
  else stroke(c);
  for (int i = 1; i < r.pts.size (); i++) {
    line(r.pts.get(i - 1).x, r.pts.get(i - 1).y, r.pts.get(i).x, r.pts.get(i).y);
  }
  if (!r.isAddingPoints && r.pts.size() > 1) {
    line(r.pts.get(0).x, r.pts.get(0).y, r.pts.get(r.pts.size() - 1).x, r.pts.get(r.pts.size() - 1).y);
    if (r.isActive) fill(0, 127, 255);
    else fill(255, 200);
    textAlign(CENTER, CENTER);
    if (showText || r.isActive) text(r.fileName, r.center.x, r.center.y + (r.isActive ? 20 : 0));
  }
} // end drawRegion


//
void exportRegions(String name) {
  try {
    exportSer(name, regions);
  } 
  catch(Exception e) {
    
  }
} // end exportRegions

//
void importRegions(String name) {
      regions = new ArrayList<Region>();
  try {
    regions = (ArrayList<Region>)readSer(name);
    if (regions == null) regions = new ArrayList();
  }
  catch (Exception e) {
    println("problem loading ser of name: " + name);
  } 
  println("end of load regions for " + name + ".  loaded " + regions.size() + " regions");
} // end importRegions

