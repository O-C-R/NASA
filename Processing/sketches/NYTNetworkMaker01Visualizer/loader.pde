//
void loadPhraseReferences(int[] yearRangeIn) {
  String phraseDirectory = "../../../StudyOutput/NYTNetworkMaker01/";
  nytStoriesHM = new HashMap<String, NYTStory>(); // save all stories in the hm
  String[] files = getFileNames(sketchPath("") + phraseDirectory);
  println("searching through " + files.length + " phrase month files");
  for (String file : files) {
    if (file.contains(".json")) {
      try {
        JSONObject json = loadJSONObject(file);
        JSONArray jsonArray = json.getJSONArray("phrases");
        println(jsonArray.size());
        for (int i = 0; i < jsonArray.size(); i++) {
          JSONObject phraseJSON = jsonArray.getJSONObject(i);
          PhraseReference pr = new PhraseReference(phraseJSON.getString("phrase"));
          JSONArray storiesJSON = phraseJSON.getJSONArray("stories");
          for (int j = 0; j < storiesJSON.size(); j++) {
            NYTStory nyt = new NYTStory(storiesJSON.getJSONObject(j));
            if (nytStoriesHM.containsKey(nyt.id)) nyt = (NYTStory)nytStoriesHM.get(nyt.id); // no need to make a new story if it alrady exists
            int nytYear = nyt.pubDate.get(Calendar.YEAR);
            if (nytYear >= yearRangeIn[0] && nytYear <= yearRangeIn[1]) {
              pr.addNYTStory(nyt);
              nytStoriesHM.put(nyt.id, nyt);
            }
          }
          if (pr.stories.size() > 0) {
            phraseKeeperAll.add(pr);
            phraseKeeperHM.put(pr.phrase, pr);
          }
        }
      }
      catch (Exception e) {
      }
    }
  }
  
  phraseKeeperAll = OCRUtils.sortObjectArrayListSimple(phraseKeeperAll, "storyCount");
  
  for (PhraseReference pr : phraseKeeperAll) pr.stories = OCRUtils.sortObjectArrayListSimple(pr.stories, "pubDateString");
  
  println("_");
  println("done loading stories.  hm total as: " + nytStoriesHM.size());
  println("done loading phrases.  hm total as: " + phraseKeeperHM.size());
} // end loadPhraseReferences


void loadNYTStories(int[] yearRangeIn) {
  String nytDirectory = "../../../StudyOutput/NYTArticleNASAFacetOutput/";
  nytStoriesHM = new HashMap<String, NYTStory>();
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
            nytStoriesHM.put(newStory.id, newStory);
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


  println("_");
  println("done loading stories.  hm total as: " + nytStoriesHM.size());
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

