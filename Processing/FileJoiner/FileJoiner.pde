String buckets = "administrative,astronaut,mars,moon,people,politics,research_and_development,rockets,russia,satellites,space_shuttle,spacecraft,us";



for (String s:buckets.split(",")) {
  try {
    //Runtime.getRuntime().exec("cat  ~/code/NASA/Data/BucketText/" + s + "/allBucketStories/* > ~/code/NASA/Data/BucketText/" + s + "/allBucketStories/allYears.txt");
    print("cat  ~/code/NASA/Data/BucketText/" + s + "/uniqueBucketStories/* > ~/code/NASA/Data/BucketText/" + s + "/uniqueBucketStories/allYears.txt;");
  } 
  catch (Exception e) {
    println("error");
    println(e);
  }
}

