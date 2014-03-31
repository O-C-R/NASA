class Word {

  String word;
  float size = 1;
  ArrayList<WordEdge> edges = new ArrayList();
  HashMap<Word, WordEdge> edgeMap = new HashMap();

  Word(String w) {
    word = w;
  }

  void addEdge(Word w2) {
    WordEdge we = null;
    if (edgeMap.containsKey(w2)) {
      we = edgeMap.get(w2);
    } 
    else {
      we = new WordEdge(this, w2);
      allEdges.add(we);
      edges.add(we);
      edgeMap.put(w2, we);
    }

    we.weight ++;
  }
}

class WordEdge implements Comparable {
  Word w1;
  Word w2;
  float weight = 0;

  WordEdge(Word w, Word ww) {
    w1 = w;
    w2 = ww;
    w.edges.add(this);
  }
  
  int compareTo(Object we2) {
    return(int(weight - ((WordEdge) we2).weight));
  }
  
}

