//
void populatePhrases() {
  int minGramCount = 0;
  int maxGramCount = 0;
  for (int i = 0; i < phrasesAll.size(); i++) {
    int sz = split(phrasesAll.get(i).phrase, " ").length;
    if (i == 0) minGramCount = maxGramCount = sz;
    minGramCount = (minGramCount < sz ? minGramCount : sz);
    maxGramCount = (maxGramCount > sz ? maxGramCount : sz);
  }
  println("min/maxGramCount: " + minGramCount + ", " + maxGramCount);


  for (HistoryStory hs : historyStoriesAll) {
    HashMap<Integer, IntDict> gramDict = new HashMap<Integer, IntDict>();
    String[] sentences = RiTa.splitSentences(hs.story);
    // develop all grams for this story
    for (int i = minGramCount; i <= maxGramCount; i++) {
      IntDict countGrams = countGrams(i, sentences);
      if (!gramDict.containsKey(i)) gramDict.put(i, new IntDict());
      IntDict oldDict = (IntDict)gramDict.get(i);
      if (oldDict.size() > 0) oldDict = addIntDicts(oldDict, countGrams);
      else oldDict = countGrams;
      gramDict.put(i, oldDict);
    } 

    // go through all phrases and add as appropriate
    for (Phrase p : phrasesAll) {
      int thisPhraseWordCount = p.phraseWordCount;
      IntDict thisIntDict = (IntDict)gramDict.get(thisPhraseWordCount);
      if (thisIntDict.hasKey(p.phrase)) {
        //println("MATCH: " + p.phrase + "   count: " + thisIntDict.get(p.phrase));
        int count = thisIntDict.get(p.phrase);
        p.addHistoryStory(hs, count);
        hs.addPhrase(p, count);
      }
    }
  }
} // end populatePhrases


//
IntDict countGrams(int n, String[] sentences) {
  IntDict counter = new IntDict();
  for (String s:sentences) {
    String[] words = RiTa.tokenize(RiTa.stripPunctuation(s.toLowerCase()));
    for (int i = 0; i <= words.length - n; i++) {
      String ngram = "";
      for (int j = 0; j < n; j++) {
        ngram += words[i + j];
        if (j != n) ngram += " ";
      }
      counter.increment(ngram.trim());
    }
  }
  counter.sortValuesReverse();
  return(counter);
} // end countGrams

//
IntDict addIntDicts(IntDict a, IntDict b) {
  IntDict c = a.copy();
  for (String k : b.keys()) {
    if (!c.hasKey(k)) c.set(k, b.get(k));
    else c.add(k, b.get(k));
  }
  return c;
} // end addIntDicts

//
//
//
//

