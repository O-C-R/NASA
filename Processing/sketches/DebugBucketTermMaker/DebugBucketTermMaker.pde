String outputDirectory = "../../../Data/BucketGramsAll/debug/";

int[] yearRange = {
  1961, 
  2009
};

//
void setup() {
  PrintWriter output = createWriter(outputDirectory + "series.txt");
  int toMake = 1000;
  for (int i = 0; i < toMake; i++) {
    String ln = "";
    int numToMake = (int)random(4, 10);
    for (int j = 0; j < numToMake; j++) {
      ln += i + (j < numToMake - 2 ? "-" : "");
      //if (random(1) > .85 && j < numToMake + 1) ln += " ";
      //if (ln.length() > 10) {
      //ln = ln.substring(0, 10) ;
      //break;
    }
    ln += ",";
    ln += (toMake - i) + ",";
    for (int j = 0; j < yearRange[1] - yearRange[0]; j++) {
      float value = .01;
      /*
      if (j == 10) value = (yearRange[1] - yearRange[0] - j) * value * 3;
       else if (j == 5) value = (yearRange[1] - yearRange[0] - j) * value * 2;
       else if (j == 15) value = (yearRange[1] - yearRange[0] - j) * value * 1;
       else if (j == 8) value = (yearRange[1] - yearRange[0] - j) * value * .5;
       else if (j == 12) value = (yearRange[1] - yearRange[0] - j) * value * .35;
       else value = 0f;
       */
      value *= noise(j * .1 + 3);
      ln += nf(value, 0, 6) + (j < yearRange[1] - yearRange[0] - 1 ? "," : "");
    }

    output.println(ln);
  }
  output.flush();
  output.close();
  println("done");
  exit();
} // end setup

//
//
//
//

