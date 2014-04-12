class Entity implements Comparable {
  String term;
  int[] counts;
  int count = 0;
 
 
  Entity init() {
   counts = new int[(endYear - startYear) + 1];
   return(this);
  } 
  
  int compareTo(Object o) {
    return(count - ((Entity) o).count);
  }
  
}
