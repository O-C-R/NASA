void loadNYTStories(int[] yearRangeIn) {
  String nytDirectory = "../../../StudyOutput/NYTArticleNASAFacetOutput/";
  HashMap<String, NYTStory> storiesHM = new HashMap<String, NYTStory>();
  String[] storyNames = {
  }; // blank means load all

  String[] files = getFileNames(sketchPath("") + nytDirectory);
  println("searching through " + files.length + " nyt month files");

  int breakCounter = 0;
  int storyCounter = 0; // right now the total story count is 36168
  for (String file : files) {
    if (file.contains(".json")) {
      try {

        // make sure it is part of the target years
        String[] tmp = split(file, "/");
        String yearString = tmp[tmp.length - 1].substring(0, 4);
        boolean withinYearRange = false;
        //for (int yr : yearRangeIn) {
        for (int yr = yearRangeIn[0]; yr <= yearRangeIn[1]; yr++) {
          if (yearString.equals(yr + "")) {
            withinYearRange = true;
            break;
          }
        }
        if (!withinYearRange) continue; // skip if not in range

          JSONObject json = loadJSONObject(file);
        JSONArray jsonArray = json.getJSONArray("results");
        //println("jsonArray.size(): " + jsonArray.size());
        for (int i = 0; i < jsonArray.size(); i++) {
          NYTStory newStory = new NYTStory(jsonArray.getJSONObject(i));
          if (newStory.isValid) {
            storiesHM.put(newStory.id, newStory);
            storyCounter++;
            if (storyCounter % 100 == 0) print(".");
          }
        }

        // manual break;
        //if (storyCounter > 1000) break;
      }
      catch (Exception e) {
        // problem loading json
      }
    }
  }

  // do the initial sorts
  for (Map.Entry me : storiesHM.entrySet()) {
    NYTStory nyt = (NYTStory)me.getValue();
    nytStoriesAll.add(nyt);
    // pub date
    if (nyt.pubDateString.length() > 0) nytStoriesByDate.add(nyt);
    // page
    if (nyt.printPage > -1) nytStoriesByPage.add(nyt);
    // add story to year
    int year = -1;
    int month = -1;
    if (nyt.pubDate != null) {
      year = nyt.pubDate.get(Calendar.YEAR);
      month = nyt.pubDate.get(Calendar.MONTH);
    }
    if (month >= 0 && month <= 11) {
      for (int i = 0; i < years.size(); i++) {
        if (years.get(i).year == year) {
          years.get(i).addNYTStory(nyt);
          nyt.year = years.get(i);
          break;
        }
      }
    }
  }

  println("_");
  nytStoriesByDate = OCRUtils.sortObjectArrayListSimple(nytStoriesByDate, "pubDateString");
  nytStoriesByPage = OCRUtils.sortObjectArrayListSimple(nytStoriesByPage, "printPage");


  println("done loading stories.  hm total as: " + storiesHM.size());
  println("done loading stories.  all stories total as: " + nytStoriesAll.size());
  println("done loading stories.  date stories total as: " + nytStoriesByDate.size());
  println("done loading stories.  page stories total as: " + nytStoriesByPage.size());
} // end loadNYTStories



//
// this function will get the file names for things that arent directories
String[] getFileNames (String fileDirectory) {
  String[] validFiles = new String[0];
  try {
    // list all of the files and read in the top n files -- starting from the most recent
    File file = new File(fileDirectory);
    if (file.isDirectory()) {  
      String allFiles[] = file.list();
      for (String thisFile : allFiles) {
        if (thisFile.length() > 0 && thisFile.toLowerCase().charAt(0) != '.') {
          File child = new File(fileDirectory + thisFile);
          if (!child.isDirectory()) validFiles = (String[])append(validFiles, fileDirectory + thisFile);
          else {
            String[] childFiles = getFileNames(fileDirectory + thisFile + "/");
            for (String s : childFiles) validFiles = (String[])append(validFiles, s);
          }
        }
      }
    }
  }
  catch (Exception e) {
    println("error getting file names for directory: " + fileDirectory);
  }
  return validFiles;
} // end getFileNames





//
void loadYears(int[] yearRangeIn) {
  // note that it will load 1 previous year so that when checking backwards from the nyt stories it can
  //   check stories that happened in the previous n months
  for (int i = yearRangeIn[0] - 1; i <= yearRangeIn[1]; i++) {
    try {
      JSONObject yrJSON = loadJSONObject(jsonDirectory + i + ".json");
      loadStoriesFromYear(yrJSON);
    }
    catch (Exception e) {
      println("could not load year file: " + i);
    }
  }
  for (Year yr : years) {
    //println("loaded: " + yr);
  }
  println("finished loading " + years.size() + " years");
} // end loadYears

//
void loadStoriesFromYear(JSONObject yrJSON) {
  try {
    Year newYear = new Year(yrJSON);
    years.add(newYear);
    yearsHM.put(newYear.year, newYear);
  }
  catch (Exception e) {
    println("problem loading yrJSON");
  }
} // end loadStoriesFromYear





//
void loadCommonWords() {
  String commonWordsFile = "commonWords.csv";
  String[] commonWordsStringArray = loadStrings(commonWordsFile);
  for (String s : commonWordsStringArray) commonWords.add(split(s, ",")[0].toLowerCase().trim());
} // end loadCommonWords

//
//
//
//
//
//
//
//
//
//
//

