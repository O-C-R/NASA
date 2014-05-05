PImage letterImage;
PGraphics letterPG;
PVector[] getEdges(Letter l, boolean leftSide, float angle) {
  textSize(l.size);
  float w = max(textWidth(l.letter), 1);
  float h = max(g.textDescent() + g.textAscent(), 1);
  letterPG = createGraphics((int)w, (int)h);
  letterPG.beginDraw();
  letterPG.background(0);
  letterPG.fill(255);
  letterPG.textAlign(LEFT, TOP);
  letterPG.textFont(font, l.size);
  letterPG.text(l.letter, 0, 0);
  letterPG.endDraw();
  letterImage = letterPG;


  pushMatrix();
  translate(l.pos.x, l.pos.y);

  letterImage.loadPixels();
  int ht = letterImage.height;
  int wi = letterImage.width;
  PVector[] edgePoints = new PVector[0];

  float xMultiplier = 1f;
  if (leftSide) xMultiplier = -1f;

  PVector startPoint = new PVector();
  PVector direction = new PVector(cos(angle), -sin(angle));
  direction.x *= xMultiplier;
  for (int y = 0; y < ht; y++) {
    boolean foundSpot = false;
    startPoint.set((leftSide ? 0 : wi), y);
    stroke(255, 0, 250);
    for (int x = 0; x < wi; x++) {
      int xToUse = (leftSide ? x : wi - x);

      int yToUse = y;
      if (direction.x != 0) yToUse += (int)(direction.y * x / abs(direction.x));
      if (xToUse >= 0 && xToUse <= letterImage.width && yToUse >= 0 && yToUse <= letterImage.height && brightness(letterImage.get(xToUse, yToUse)) == 255) {
        edgePoints = (PVector[])append(edgePoints, new PVector(xToUse, yToUse));
        stroke(0, 50);
        foundSpot = true;
        break;
      }
    }
  }

  // if baseline verticalAlign
  if (l.letterVerticalAlign == BASELINE) {
    for (PVector p : edgePoints) {
      p.y -= (g.textAscent());
    }
  }

  if (l.letterAlign == LEFT) {
    // nothing
  }
  else if (l.letterAlign == RIGHT) {
    textSize(l.size);
    float letterW = textWidth(l.letter);
    for (PVector p : edgePoints) {
      p.x -= letterW;
    }
  }

  popMatrix();
  return edgePoints;
} // end getEdge


//
float getDistanceToNeighbor(PVector[] edges, PVector direction, Letter l, Letter neighbor) {
  float neighborDistance = -1f;
  float anglesToTry = 5;
  float angleVariation = PI/3.4;
  float[] rotationAngles = new float[0];
  float directionF = OCR3D.getAdjustedRotation(direction);
  for (float i = -anglesToTry; i <= anglesToTry; i++) {
    rotationAngles = (float[])append(rotationAngles, map(i, -anglesToTry, anglesToTry, -angleVariation, angleVariation));
  }

  PVector dims = new PVector(abs(l.pos.x - neighbor.pos.x), abs(l.pos.y - neighbor.pos.y));

  float largerSize = (l.size > neighbor.size ? l.size : neighbor.size);
  textFont(font, largerSize);
  float padding = 2 * textWidth("w");
  
  if (l.letter.equals(" ") || neighbor.letter.equals(" ")) {
    return (l.pos.dist(neighbor.pos) + textWidth(" "));
  }

  // large enough work area for whereever the neighbor should want to go
  float dimsX = 2 * (dims.x + padding);
  float dimsY = 2 * (dims.y + padding);



  PVector center = new PVector(dimsX / 2, dimsY / 2); // l will be drawn from here
  PVector centerSubtraction = PVector.sub(l.pos, center); // difference
  PVector neighborPosMod = PVector.sub(neighbor.pos, centerSubtraction); // position used to draw the neighbor

  letterPG = createGraphics(ceil(dimsX), ceil(dimsY)); // arbitrary size

  letterPG.beginDraw();
  letterPG.pushMatrix();
  letterPG.background(0);
  letterPG.fill(0, 0, 255);
  letterPG.textAlign(l.letterAlign, l.letterVerticalAlign);
  letterPG.textFont(font, l.size);
  letterPG.pushMatrix();
  letterPG.translate(center.x, center.y);
  letterPG.rotate(l.rotationF);
  letterPG.text(l.letter, 0, 0);
  letterPG.popMatrix();
  letterPG.pushMatrix();
  letterPG.textAlign(neighbor.letterAlign, neighbor.letterVerticalAlign);
  letterPG.textFont(font, neighbor.size);
  letterPG.translate(neighborPosMod.x, neighborPosMod.y);
  letterPG.rotate(neighbor.rotationF);
  letterPG.fill(255);
  letterPG.text(neighbor.letter, 0, 0);
  letterPG.popMatrix();
  letterPG.popMatrix();
  letterPG.endDraw();
  letterImage = letterPG;

  image(letterImage, 0, 0);
  //letterImage.save("save/" + l.letter + "-" + neighbor.letter + ".png");

  PVector ptMod = new PVector();
  pushMatrix();
  translate(center.x, center.y);
  rotate(l.rotationF);

  int wi = letterImage.width;
  int hi = letterImage.height; 

  PVector sumPt = new PVector();
  for (PVector pt : edges) {
    for (float angle : rotationAngles) {
      PVector dir = direction.get();
      dir = OCR3D.rotateUnitVector2D(dir, angle);
      for (int i = 1; i < 100; i+=3) {
        dir.normalize();
        dir.mult(i);
        sumPt.set(pt.x + dir.x, pt.y + dir.y);

        PVector untransformedPoint = new PVector();
        untransformedPoint.set(screenX(sumPt.x, sumPt.y), screenY(sumPt.x, sumPt.y)); // lazy/ cheating...

        color imgColor =  letterPG.get((int)untransformedPoint.x, (int)untransformedPoint.y);

        stroke(255, 0, 0);
        if (imgColor == color(255)) {
          stroke(255, 0, 0);

          float thisDist = sumPt.dist(pt);
          if (neighborDistance == -1 || thisDist < neighborDistance) {
            neighborDistance = thisDist;
            //println(thisDist);
          }
          break;
        }
        point(sumPt.x, sumPt.y);
      }
    }
  }

  

  popMatrix();
  
  
  return neighborDistance;
} // end getDistanceToNeighbor


//
//
//
//
//
//
//
//
//

