class Bucket {
  String name = "";
  HashMap<String, Pos> posesHM = new HashMap<String, Pos>();
  ArrayList<Pos> posesAL = new ArrayList<Pos>();

  float highCount = 0f;
  float totalSeriesSum = 0; // total from all of the terms within all of the poses
  int totalTermCount = 0; // total terms from all of the poses
  float highestSeriesCount = 0; // max count for a term
  String highestSeriesTermString = "";
  Term highestSeriesTerm;
  
  float maxPosSeriesNumber = 0f; // go through and find the max posSeries number
  

  float[] seriesSum = null;

  //
  Bucket(String name) {
    this.name = name;
  } // end constructor

  //
  void addPos(Pos pos) {
    posesHM.put(pos.pos, pos);
    posesAL.add(pos);
  } // end addPos

    //
  void tallyThings() {
    for (Map.Entry me : posesHM.entrySet()) {
      Pos p = (Pos)me.getValue();
      p.tallyThings();

      if (p.seriesSum != null && p.seriesSum.length > 0) {
        if (seriesSum == null) seriesSum = p.seriesSum;
        else {
          for (int i = 0; i < seriesSum.length; i++) seriesSum[i] += p.seriesSum[i];
        }
      }

      totalSeriesSum += p.totalSeriesSum;
      totalTermCount += p.totalTermCount;
      if (p.totalSeriesSum > highestSeriesCount) {
        highestSeriesCount = p.totalSeriesSum;
        highestSeriesTermString = p.highestSeriesTermString;
        highestSeriesTerm = p.highestSeriesTerm;
      }
    }
    
    for (float f : seriesSum) maxPosSeriesNumber = (maxPosSeriesNumber > f ? maxPosSeriesNumber : f); 
  } // end tallyThings

  //
  String toString() {
    String builder = "BUCKET: " + name + " with " + posesHM.size() + " poses.";
    builder += "\n  totalSeriesSum: " + totalSeriesSum + "  totalTermCount: " + totalTermCount + "  highestSeriesCount: " + highestSeriesCount + "  highestSeriesTermString: " + highestSeriesTermString;
    for (Map.Entry me : posesHM.entrySet()) {
      builder += "\n" + ((Pos)me.getValue()).getString();
    }
    return builder;
  } // end toString
} // end class Bucket

//
//
//
//
//
//
//
//

