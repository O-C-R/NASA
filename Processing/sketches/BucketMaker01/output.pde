//
void outputBuckets() {
  String outputDirectory = "output/";
  // first output the overall map
  PrintWriter output = createWriter(outputDirectory + "map.txt");
  for (Bucket b : bucketsAll) output.println(b);
  output.flush();
  output.close();
  for (Bucket b : bucketsAll) {
    String thisOutputDirectory = outputDirectory + b.phrase.replace(" ", "_") + "/";
    // then the unique stories as flat text
    for (int year = yearRange[0]; year <= yearRange[1]; year++) {
      output = createWriter(thisOutputDirectory + "/allBucketStories/" + year + ".txt");
      ArrayList<HistoryStory> yearStories = getStoriesByYear(b.uniqueStories, year);
      for (HistoryStory hs : yearStories) output.println(hs.story);
      output.flush();
      output.close();
    }
    // then the stories unique to the bucket as flat text
    for (int year = yearRange[0]; year <= yearRange[1]; year++) {
      output = createWriter(thisOutputDirectory + "/uniqueBucketStories/" + year + ".txt");
      ArrayList<HistoryStory> yearStories = getStoriesByYear(b.uniqueToThisBucket, year);
      for (HistoryStory hs : yearStories) output.println(hs.story);
      output.flush();
      output.close();
    }
  }
} // end outputBuckets

//
ArrayList<HistoryStory> getStoriesByYear(ArrayList<HistoryStory> listIn, int yearIn) {
  ArrayList<HistoryStory> culled = new ArrayList<HistoryStory>();
  for (HistoryStory hs : listIn) if (hs.year == yearIn) culled.add(hs);
  return culled;
} // end getStoriesByYear

//
//
//
//
//
//

