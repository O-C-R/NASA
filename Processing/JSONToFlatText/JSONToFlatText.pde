String jsonPath = "../../Data/PDFsAsJSON/";
String flatPath = "../../Data/PDFsAsJSON/";

void setup() {
  size(1280,720);
  processYears(1986,2009);
  
}

void draw () {
  
}

void processYears(int sy, int ey) {
  for(int i = sy; i <= ey; i++) {
    println("Processing year " + i);
    JSONObject jo = loadJSONObject(jsonPath + i + ".json");
    PrintWriter w = createWriter(flatPath + i + ".txt");
    JSONArray stories = jo.getJSONArray("stories");
    for (int j =0 ; j < stories.size(); j++) {
      JSONObject story = stories.getJSONObject(j);
      w.println(story.getString("story")); 
    }
    w.flush();
    w.close();
    
  }
}
