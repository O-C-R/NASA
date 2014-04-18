String endPoint = "http://access.alchemyapi.com/calls/text/TextGetRankedNamedEntities";
String apiKey = "6de45b31bb7f7f4a1e45926549d1ce288a8cff5b";
String filePath = "../../Data/BucketText/";
String xmlPath = "../../Data/EntityXML/";

int startYear = 1958;
int endYear = 2009;

import java.net.URLEncoder;
import java.net.URL;
import java.net.HttpURLConnection;
import java.io.DataOutputStream;
import java.io.Reader;
import java.io.InputStreamReader;

import java.util.Map;
import java.util.LinkedHashMap;

String buckets = "administrative,astronaut,mars,moon,people,politics,research_and_development,rockets,russia,satellites,space_shuttle,spacecraft,us";
String currentBucket = "rockets";

void setup() {
  size(1280, 720);

  String[] bucketList = buckets.split(",");
  for (int i = 0; i < bucketList.length; i++) {
    for (int y = startYear; y <= endYear; y++) {
      println(bucketList[i] + ":" + y);
      getSaveEntities(bucketList[i], y);
    }
  }
}

void draw() {
}

String constructQuery(String content) {
  String url = "apikey=" + apiKey + "&text=" + URLEncoder.encode(content) + "&quotations=1";
  println(url);
  return(url);
}


XML getEntitiesFromFile(String url) {
  String[] ins = loadStrings(url);

  String txt = join(ins, " ");
  println(txt.length() + " chars");
  return(getEntities(txt));
}

XML getEntities(String content) {
  String url = constructQuery(content);
  XML entityXML = null;
  entityXML = loadXML(url);

  return(entityXML);
}

void getSaveEntities(String bucket, int year) {
  String fileURL = filePath + bucket + "/uniqueBucketStories/" + year + ".txt";
  String txt = join(loadStrings(fileURL), " ");
  PrintWriter writer = createWriter(xmlPath + bucket + "/" + year + ".xml");
  try {
    URL url = new URL(endPoint);
    Map<String, Object> params = new LinkedHashMap();
    params.put("apikey", apiKey);
    params.put("text", txt);

    StringBuilder postData = new StringBuilder();
    for (Map.Entry param : params.entrySet()) {
      if (postData.length() != 0) postData.append('&');
      postData.append(URLEncoder.encode((String) param.getKey(), "UTF-8"));
      postData.append('=');
      postData.append(URLEncoder.encode(String.valueOf(param.getValue()), "UTF-8"));
    }
    byte[] postDataBytes = postData.toString().getBytes("UTF-8");

    HttpURLConnection conn = (HttpURLConnection)url.openConnection();
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
    conn.setRequestProperty("Content-Length", String.valueOf(postDataBytes.length));
    conn.setDoOutput(true);
    conn.getOutputStream().write(postDataBytes);

    Reader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
    for (int c; (c = in.read()) >= 0; writer.print((char)c));

    conn.disconnect();
  } 
  catch(Exception e) {
  }

  writer.flush();
  writer.close();
}

