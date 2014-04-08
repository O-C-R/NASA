class Word {
 
  PVector pos = new PVector();
  String w;
  float a;
  float count =0 ;
  float wsize = 10;
  float wwidth = 100;
  color col;
  float lineY;
  
  float[] counts;
  
  void update() {
    
  }
  
  void renderCurve() {
    
    beginShape();
    stroke(col,50);
    noFill();
   for(int i = 0; i < counts.length; i++) {
    float x = map(i, 0, counts.length, 50, width  - 50);
    float y = lineY - map(counts[i], 0, 0.01, 0, 250);
    //ellipse(x,y,3,3);
    vertex(x,y);
   } 
   endShape();
  }
  
  void render() {
    pushMatrix();
      textAlign(RIGHT);
      translate(pos.x,pos.y);
      //rotate(map(pos.y, 0, height, PI/5, -PI/5));
      textSize(wsize);
      fill(col,a);
      textAlign(CENTER,CENTER);
      text(w, 0, 0);
    popMatrix();
  }
  
}
