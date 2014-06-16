


String imageDirectory = "../../Graphics/";
//String imageName = "GraphicLarge"; // 12k wide image
String imageName = "Graphic8kFull"; // 8k wide image
String imageExtension = ".jpg";

int tileSize = 1000;

// location settings
// <img src="GraphicLargeCROP.jpg" style="display:block; z-index:2000; color:#3ff; position:absolute; left:323px; top: 0px; opacity:.3">
String html1 = "<img src = \"images/tiles";
String html2 = "\" style=\"display:block; z-index:2000; position:absolute; left:";
String html3 = "px; top:";
String html4 = "px\">";

//
float[] htmlScales = {
  1, .5
};

//
void setup() {

  for (float multiplier : htmlScales) {
    println("in writeHTML for scale: " + multiplier);
    String outputDirectory = "output/" + imageName + "/" + tileSize + "-scale-" + nf((int)(multiplier * 100), 3) + "/";
    PrintWriter htmlTileOutput = createWriter(outputDirectory + "html/html.txt");
    PImage img = loadImage(imageDirectory + imageName + imageExtension);
    img.resize(0, (int)(multiplier * img.height));

    PGraphics pg;
    for (int y = 1; y < img.height - 1; y += tileSize) {
      for (int x = 1; x < img.width - 1; x += tileSize) {
        int tileWidth = tileSize;
        int tileHeight = tileSize;
        if (img.width - x - 1 < tileSize) tileWidth = img.width - x - 1;
        if (img.height - y - 1 < tileSize) tileHeight = img.height - y - 1;
        println(x + " - " + y + " -- " + tileWidth + " x " + tileHeight);
        pg = createGraphics(tileWidth, tileHeight);
        pg.beginDraw();
        for (int yy = 0; yy <= tileHeight; yy++) {
          for (int xx = 0; xx <= tileWidth; xx++) {
            pg.set(xx, yy, img.get(xx + x, yy + y));
          }
        }
        pg.endDraw();
        String tileName = nf(x, 4) + "-" + nf(y, 4) + ".jpg";
        pg.save(outputDirectory + "tiles" + nf((int)(multiplier * 100), 3) + "/" + tileName);
        htmlTileOutput.println(html1 + nf((int)(multiplier * 100), 3) + "/" + tileName + html2 + x + html3 + y + html4);
      }
    } 

    htmlTileOutput.flush();
    htmlTileOutput.close();
    //println(img.width + ", " + img.height);
  }
  println("done");
  exit();
} // end setup

