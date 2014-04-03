//
void makeStoryNGrams() {
  int maxGramLength = 0;
  for (Bucket b : bucketsAll) {
    for (String s : b.phrases) maxGramLength = (maxGramLength > split(s, " ").length ? maxGramLength : split(s, " ").length);
  } 
  println("maxGramLength: " + maxGramLength);
  for (HistoryStory hs : historyStoriesAll) {
    String[] sentences = RiTa.splitSentences(hs.story);
    for (int i = 1; i <= maxGramLength; i++) {
      hs.ngrams = addIntDicts(hs.ngrams, countGrams(i, sentences));
    }
  }
  println("finished making story ngrams");
} // end makeStoryNGrams


//
void assignStoriesToBuckets() {
  for (HistoryStory hs : historyStoriesAll) { 
    for (Bucket b : bucketsAll) {
      for (String phrase : b.phrases) {
        if (hs.ngrams.hasKey(phrase)) {
          b.addHistoryStory(phrase, hs);
          hs.addBucket(b);
        }
      }
    }
  }
  // make unique stories
  for (Bucket b : bucketsAll) b.uniqueStories = b.makeUniqueStories();
  // make unique unique stories
  for (Bucket b : bucketsAll) {
    ArrayList<HistoryStory> uniques = (ArrayList<HistoryStory>)b.uniqueStories.clone();
    for (int i = uniques.size() - 1; i >= 0; i--) {
      boolean removedStory = false;
      for (Bucket bb : bucketsAll) {
        if (bb != b) {
          for (HistoryStory other : bb.uniqueStories) {
            if (other == uniques.get(i)) {
              uniques.remove(i);
              removedStory = true;
              break;
            }
          }
          if (removedStory) break;
        }
      }
      b.uniqueToThisBucket = uniques;
    }
  }   

  println("finished assignStoriesToBuckets");
  for (Bucket b : bucketsAll) println(b);
} // end assignStoriesToBuckets


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
  if (a.size() == 0) return b;
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
//

