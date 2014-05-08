// this sketch will just look at the output for the typeAlongCurve sketch and see which words are super similar .. but different because of UPPERCASE or lowercase

import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;
import java.util.Map;
import java.util.Collections;

HashMap<String, Term> terms = new HashMap<String, Term>();
ArrayList<String> allTerms = new ArrayList<String>();
int totalCount = 0;

void setup() {
  OCRUtils.begin(this);
  String[] files = OCRUtils.getFileNames(sketchPath("") + "../../sketches/TypeAlongCurve06a/bucketTextUsed/20140505135105", false);
  for (int i = 0; i < files.length; i++) {
    if (!files[i].contains("byPos.txt")) continue;
    String bucketName = splitTokens(files[i], "/")[splitTokens(files[i], "/").length - 1];
    bucketName = split(bucketName, "-")[0];
    String[] allLines = loadStrings(files[i]);
    for (int k = 0; k < allLines.length; k++) {
      String term = split(allLines[k], ",")[1];
      term = term.replace("|", ".").replace("}", " ").replace("{", " ");
      allTerms.add(term + "+" + bucketName);
      totalCount++;

      if (isVerb(term)) continue;

      if (!terms.containsKey(term.toLowerCase())) {
        terms.put(term.toLowerCase(), new Term(term.toLowerCase()));
      }

      Term oldTerm = (Term)terms.get(term.toLowerCase());
      oldTerm.addBucket(bucketName);
      oldTerm.addTerm(term);
      terms.put(term.toLowerCase(), oldTerm);
    }
  }

  ArrayList<Term> termsAL = new ArrayList<Term>();
  for (Map.Entry me : terms.entrySet()) {
    termsAL.add((Term)me.getValue());
  }

  //termsAL = OCRUtils.sortObjectArrayListSimple(termsAL, "bucketCount");
  termsAL = OCRUtils.sortObjectArrayListSimple(termsAL, "termCount");
  termsAL = OCRUtils.reverseArrayList(termsAL);

  PrintWriter output = createWriter("output/output.txt");
  for (Term t : termsAL) output.println(t);
  output.flush();
  output.close();

  // then do the other stuff
  println("total count of terms: " + totalCount);
  println("size of allTerms: " + allTerms.size());
  int termWordCount = 0;
  for (String s : allTerms) termWordCount += split(s.replace("|", ".").replace("}", " ").replace("{", " "), " ").length;
  println("termWordCount: " + termWordCount);

  println("done");
  exit();
} // end setup


//
boolean isVerb(String s) {
  if (split(s, " ").length == 1) {
    if (s.length() > 2) {
      if ((s.substring(s.length() - 3)).equals("ing")) return true;
    }
  }

  if (s.trim().equals("term")) return true;
  return false;
} // end isVerb


//
class Term {
  HashMap<String, Integer> buckets = new HashMap<String, Integer>();
  int bucketCount = 0;
  String term = "";
  ArrayList<String> terms = new ArrayList<String>();
  int termCount = 0;

  //
  Term (String term) {
    this.term = term;
  } // end constructor

  //
  void addBucket(String b) {
    if (!buckets.containsKey(b)) {
      buckets.put(b, 0);
      bucketCount++;
    }
  } // end addBucket

  //
  void addTerm(String t) {
    terms.add(t);
    termCount++;
  } // end addTerm

  //
  String toString() {
    String builder = formattedTerm() + "--bucketCount: " + nf(bucketCount, 2) + " - ";
    for (Map.Entry me : buckets.entrySet()) builder += (String)me.getKey() + " - ";
    builder += "\n";
    for (int i = 0; i < terms.size(); i++) builder += "X";
    builder += "   ";
    for (String s : terms) builder += s + " - ";  
    return builder;
  } // end toString

  //
  String formattedTerm() {
    int targetLength = 38;
    String spaces = "";
    for (int i = 0; i < targetLength - term.length(); i++) spaces += " ";
    return term.replace("|", ".").replace("}", " ") + spaces;
  } // end formattedTerm
} // end class Term

//
//
//
//

