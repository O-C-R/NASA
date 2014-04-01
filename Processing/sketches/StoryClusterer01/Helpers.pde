class PhraseDropOff {
  Phrase p;
  Phrase topPhrase = null;
  
  ArrayList<HistoryStory> commonStories = new ArrayList<HistoryStory>();
  int storyCount = 0;

  int level = 0;
  ArrayList<PhraseDropOff> children = new ArrayList<PhraseDropOff>();
  PhraseDropOff parent = null;

  //
  PhraseDropOff(Phrase p) {
    this.p = p;
  } // end constructor

  //
  void addSimilarStory(HistoryStory hs) {
    if (!commonStories.contains(hs)) {
      commonStories.add(hs);
      storyCount++;
    }
  } // end addSImilarStory

  //
  ArrayList<Phrase> getPhraseLineage() {
    ArrayList<Phrase> lineage = new ArrayList<Phrase>();
    if (!lineage.contains(p)) lineage.add(p);
    if (parent != null) {
      ArrayList<Phrase> parentsLineage = parent.getPhraseLineage();
      for (Phrase pp : parentsLineage) if (!lineage.contains(pp)) lineage.add(pp);
    }
    else {
     if (topPhrase != null) if (!lineage.contains(topPhrase)) lineage.add(topPhrase);
    }
    return lineage;
  } // end getPhraseLineage

    //
  void makeChildren(int maxLevel) {
    if (level < maxLevel) {
      ArrayList<Phrase> lineage = getPhraseLineage();
      children = getTopRelativeStories(lineage, commonStories, phrasesAll, level);
      for (PhraseDropOff pd : children) {
        pd.level = level + 1;
        pd.parent = this;
        pd.makeChildren(maxLevel);
      }
    }
  } // end makeChildren

  //
  String toString() {
    String spacer = "";
    for (int i = 0; i < level + 1; i++) spacer += "  ";
    String builder = "  ";
    if (level != 0) builder += "\n";
    builder += spacer + "SIMILAR: " + p.phrase + "----" + storyCount;
    for (PhraseDropOff child : children) builder += child.toString();
    return builder;
  } // end toString
} // end class PhraseDropOff

