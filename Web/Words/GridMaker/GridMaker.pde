void setup() {
  size(4267, 3200);
  fill(127);
  strokeWeight(3);
  stroke(255);
  rect(0, 0, width, height);
  textFont(createFont("Helvetica", 9));
  int thick = 3;
  int thin = 1;
  for (int i = 0; i < width; i += 100) {
    if (i % 500 == 0) {
      strokeWeight(thick);
      stroke(255, 100, 100);
    } else {
      strokeWeight(thin);
      stroke(255);
    }
    line(i, 0, i, height);
    for (int j = 0; j < height; j += 100) {
      if (i == 0) {
        if (j % 500 == 0) {
          strokeWeight(thick);
          stroke(255, 100, 100);
        } else {
          strokeWeight(thin);
          stroke(255);
        }
        line(0, j, width, j);
      }
      fill(0);
      textAlign(RIGHT, BOTTOM);
      text("(" + i + ", " + j + ")", i - 2, j - 2);
    }
  }
  saveFrame("grids/" + width + "-" + height + ".png");
  exit();
} // end setup

