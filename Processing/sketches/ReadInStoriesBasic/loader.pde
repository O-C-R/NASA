//
void loadYears(int[] yearRangeIn) {
  for (int i = yearRangeIn[0]; i <= yearRangeIn[1]; i++) {
    try {
      JSONObject yrJSON = loadJSONObject(jsonDirectory + i + ".json");
      loadStoriesFromYear(yrJSON);
    }
    catch (Exception e) {
      println("could not load year file: " + i);
    }
  }
  for (Year yr : years) {
    println("loaded: " + yr);
  }
  println("finished loading " + years.size() + " years");
} // end loadYears

//
void loadStoriesFromYear(JSONObject yrJSON) {
  try {
    years.add(new Year(yrJSON));
  }
  catch (Exception e) {
    println("problem loading yrJSON");
  }
} // end loadStoriesFromYear

//
//
//
//
//
//

