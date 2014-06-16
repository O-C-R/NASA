import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;

import simpleTween.*;
import java.io.*;

// global scale and offset
FSTween sc;
PVSTween offset;
PVector currentWorldLoc = new PVector();

//
float[] htmlScales = {
  1, .5
};



// image stuff
String imageDir = "../../Graphics/";
 
String imgName = "Graphic8kFull"; //
PImage img;

// regions
ArrayList<Region> regions = new ArrayList();
Region currentRegion = null;

// controls
boolean showText = true;


void setup() {
  size(900, 900, P3D);
  SimpleTween.begin(this);
  sc = new FSTween(10, 0, 1, 1);
  offset = new PVSTween(10, 0, new PVector(), new PVector());

  //load the image
  img = loadImage(imageDir + imgName + ".jpg");
  

  // load the regions if any
  importRegions(imgName);

} // end setup

void draw() {
  background(0);
  pushMatrix();
  translate(offset.value().x, offset.value().y);
  scale(sc.value());

  currentWorldLoc = getWorldCoordFromMouseLocation(new PVector(mouseX, mouseY));

  
  image(img, 0, 0);
  
  for (Region r : regions) drawRegion(r, showText);

  popMatrix();

  // draw the details
  fill(255);
  noStroke();
  textAlign(LEFT, TOP);
  text("Mouse Location: " + currentWorldLoc, 20, 20);
  text("Current scale:  " + nf(sc.value(), 0, 3), 20, 40);
  text("Region count:   " + regions.size(), 20, 60);
} // end draw

//
void keyPressed() {
  if ( keyCode == ESC) {
    key = '%';
    if (currentRegion != null && currentRegion.isActive && currentRegion.oldFileName.length() == 0) {
      regions.remove(currentRegion);
      currentRegion = null;
    } else if (currentRegion != null && currentRegion.isActive && !currentRegion.isAddingPoints && currentRegion.oldFileName.length() > 0) {
      currentRegion.fileName = currentRegion.oldFileName;
      currentRegion.deselectRegion();
      currentRegion = null;
    }
  }
} // end keyPressed


//
void keyReleased() {
  if (keyCode == RIGHT) moveWorld(MOVE_RIGHT);
  if (keyCode == LEFT) moveWorld(MOVE_LEFT);
  if (keyCode == UP) moveWorld(MOVE_UP);
  if (keyCode == DOWN) moveWorld(MOVE_DOWN);


  if (currentRegion != null && !currentRegion.isAddingPoints && currentRegion.isActive) {
    // switch spaces to _
    if (key == ' ') {
      key = '_';
    }

    if (keyCode == ENTER) {
      println("pressed enter, locking in region " + currentRegion.fileName);
      currentRegion.deselectRegion();
      currentRegion = null;
    } else if (key == '~') {
      println("deleteing region " + currentRegion.fileName);
      regions.remove(currentRegion);
      currentRegion = null;
    } else if (keyCode == BACKSPACE || keyCode == DELETE) {
      currentRegion.backspace();
    } else if (key == '+') {
      currentRegion.isAddingPoints = true;
    } else {
      int charInt = Character.valueOf(key);
      if (charInt >= 33 && charInt <= 122) {
        currentRegion.dealWithKey(key + "");
      }
    }
    return;
  }

  if (key == 'a' && currentRegion == null) {
    println(frameCount + " adding new region");
    currentRegion = new Region((int)random(10000));
    regions.add(currentRegion);
  } 

  if (key == 'z' && currentRegion != null && currentRegion.isAddingPoints) {
    println(frameCount + " oops");
    currentRegion.removeLastPt();
  }
  if (key == 'c' && currentRegion != null && currentRegion.isAddingPoints) {  
    if (currentRegion != null) {
      currentRegion.closeRegion();
      println(frameCount + " closing shape");
    }
  }
  if (key == 'q' && currentRegion != null && currentRegion.isAddingPoints) {
    println(frameCount + " canceling new region add");
    if (currentRegion != null) regions.remove(currentRegion);
    currentRegion = null;
  }
  if (key == 't' && currentRegion == null) showText = !showText;
  if (key == 'x') exportRegions(imgName);
  if (key == 'w') {
    exportRegions(imgName);
    writeHTML(htmlScales);
    makeOverayGraphic(htmlScales);
  }

  if (key == '1') {
    int amtToMake = 150;
    println("making " + amtToMake + " random spots");
    PVector center = new PVector();
    float x = img.width - 30;
    float y = img.height - 30;
    for (int i = 0; i < amtToMake; i++) {
      x -= 70;
      if (x < img.width / 2) {
        x = img.width - 30;
        y -= 70;
      }
      center.set(x, y);
      PVector a = center.get();
      makeRandom(a);
    }
  }
} // end keyReleased

//
void mouseDragged() {
  if (mouseButton == RIGHT) offset.playLive(new PVector(offset.getEnd().x - (pmouseX - mouseX), offset.getEnd().y - (pmouseY - mouseY)));
} // end mouseDragged

//
void mouseWheel(MouseEvent event) {
  float e = event.getAmount();
  if (e < 0) moveWorld(ZOOM_IN);
  else moveWorld(ZOOM_OUT);
} // end mouseWheel

//
void mousePressed() {
  if (mouseButton == LEFT && currentRegion != null && currentRegion.isAddingPoints) {
    currentRegion.addPoint(currentWorldLoc);
  }
} // end mousePressed

//
void mouseReleased() {
  // check if the mouse was released over an existing region
  if (currentRegion == null && mouseButton == LEFT) {
    PVector[] ptsVector;
    for (Region r : regions) {
      ptsVector = new PVector[r.pts.size()];
      for (int i = 0; i < r.pts.size (); i++) ptsVector[i] = r.pts.get(i);
      if (OCRMath.isInsidePolygon(currentWorldLoc, ptsVector)) {
        currentRegion = r;
        currentRegion.isActive = true;
        currentRegion.oldFileName = currentRegion.fileName;
        break;
      }
    }
  }
} // end mouseReleased

//
//
//
//
//
//
//

