//
void writeHTML(float[] scales) {
  String shapeName = "poly";
  String coords = "";
  String hrefBase = "images/stories/";
  String imgExtension = ".png";
  String alt = "";
  String id = "";
  PVector cp = new PVector();


  for (float multiplier : scales) {
    println("in writeHTML for scale: " + multiplier);

    PrintWriter output = createWriter("html/" + imgName + "-" + nf((int)(multiplier * 100), 3) + ".txt");
    output.println("<map name = \"nasamap\" id = \"nasamap\">");
    for (Region r : regions) {
      coords = "";
      alt = "";
      id = "";
      for (int i = 0; i < r.pts.size (); i++) {
        cp.set(r.pts.get(i).x, r.pts.get(i).y);
        cp.mult(multiplier);
        if (i > 0) coords += ",";
        coords += (int)cp.x + "," + (int)cp.y;
      }
      //String builder = "<area shape=\"" + shapeName + "\" coords = \"" + coords + "\" id = \"" + r.fileName + "\" href = \"" + hrefBase + r.fileName + imgExtension + "\" alt = \"" + r.fileName + "\"/>";
      //String builder = "<area shape=\"" + shapeName + "\" coords = \"" + coords + "\" id = \"" + r.fileName + "\" alt = \"" + r.fileName + "\"/>";
      String builder = "<area shape=\"" + shapeName + "\" coords = \"" + coords + "\" id = \"" + r.fileName + "\" href = \"" + hrefBase + r.fileName + imgExtension + "\" alt = \"" + r.fileName + "\" data-lightbox=\"" + r.fileName + "\" data-title = \"" + "" + "\"/>";
      output.println(builder);
    }
    output.println("</map>");     

    output.flush();
    output.close();
    println("finished writing out " + regions.size() + " regions at scale: " + multiplier);
  }
} // end writeHTML

//
void makeOverayGraphic(float[] scales) {
  for (float multiplier : scales) {
    PGraphics pg = createGraphics((int)(img.width * multiplier), (int)(img.height * multiplier));
    println("making overlaygraphic for scale: " + multiplier);
    pg.beginDraw();
    for (Region r : regions) {
      pg.stroke(0, 255, 255, 250);
      pg.fill(0, 255, 255, 250);
      pg.beginShape();
      for (PVector p : r.pts) pg.vertex(p.x * multiplier, p.y * multiplier);
      pg.endShape(CLOSE);
    }
    pg.endDraw();
    pg.save("overlays/" + imgName + "-" + nf((int)(multiplier * 100), 3) + ".png");
    println("finished overlay");
  }
  
} // end makeOverlayGraphic

