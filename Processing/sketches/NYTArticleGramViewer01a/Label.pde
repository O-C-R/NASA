class Label {
  PVector[] bounds = new PVector[2];
  PVector pos = new PVector();
  Gram gram;
  boolean mouseOver = false;

  //
  Label(Gram gram, PVector pos) {
    this.pos = pos;
    this.gram = gram;
    makeBounds();
  } // end constructor

  //
  void makeBounds() {
    float w = textWidth(gram.searchTerm);
    bounds[0] = pos.get();
    bounds[1] = new PVector(pos.x + w, pos.y + 15);
  } // end makeBounds

  //
  void display(PGraphics pg) {
    if (mouseOver) pg.fill(0);
    else pg.fill(gram.c);
    pg.textAlign(LEFT, TOP);
    pg.text(gram.searchTerm, pos.x, pos.y);
  } // end display

  //
  boolean mouseOver(PVector mouseLoc) {
    mouseOver = false;
    gram.selected = false;
    if (mouseLoc.x >= bounds[0].x && mouseLoc.x <= bounds[1].x) {
      if (mouseLoc.y >= bounds[0].y && mouseLoc.y <= bounds[1].y) {
        mouseOver = true;
        gram.selected = true;
        return true;
      }
    }
    return false;
  } // end mouseOver
} // end class Label

//
//
//
//

