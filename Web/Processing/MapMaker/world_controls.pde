final static int MOVE_RIGHT = 0;
final static int MOVE_LEFT = 1;
final static int MOVE_UP = 2;
final static int MOVE_DOWN = 3;
final static int ZOOM_OUT = 4;
final static int ZOOM_IN = 5;

void moveWorld(int whereTo) {
  float offsetAmt = 50f * sc.getEnd();
  float scaleAmt = .1;
  switch(whereTo) {
  case MOVE_RIGHT:
    offset.playLive(new PVector(offset.getEnd().x - offsetAmt, offset.getEnd().y));
    break;
  case MOVE_LEFT:
    offset.playLive(new PVector(offset.getEnd().x + offsetAmt, offset.getEnd().y));
    break;
  case MOVE_UP:
    offset.playLive(new PVector(offset.getEnd().x, offset.getEnd().y + offsetAmt));
    break;
  case MOVE_DOWN:
    offset.playLive(new PVector(offset.getEnd().x, offset.getEnd().y - offsetAmt));
    break;
  case ZOOM_IN:
    sc.playLive(sc.getEnd() * (1 + scaleAmt));
    //offset.playLive(new PVector(offset.getEnd().x + (offset.getEnd().x - width / 2) * scaleAmt, offset.getEnd().y + (offset.getEnd().y - height / 2) * scaleAmt));
    offset.playLive(new PVector(offset.getEnd().x + (offset.getEnd().x - mouseX) * scaleAmt, offset.getEnd().y + (offset.getEnd().y - mouseY) * scaleAmt));
    break;
  case ZOOM_OUT:
    sc.playLive(sc.getEnd() * (1 - scaleAmt));
    //offset.playLive(new PVector(offset.getEnd().x - (offset.getEnd().x - width / 2) * scaleAmt, offset.getEnd().y - (offset.getEnd().y - height / 2) * scaleAmt));
    offset.playLive(new PVector(offset.getEnd().x - (offset.getEnd().x - mouseX) * scaleAmt, offset.getEnd().y - (offset.getEnd().y - mouseY) * scaleAmt));
    break;
  } // end switch
} // end moveWorld

//
PVector getWorldCoordFromMouseLocation(PVector mouseLoc) {
  PVector worldCoord = new PVector();
  worldCoord.set(mouseLoc.x, mouseLoc.y);
  worldCoord.sub(offset.value());
  worldCoord.div(sc.value());
  return worldCoord;
} // end getWorldCoord


//
//
//
//
//
//
//

