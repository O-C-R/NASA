class Word {
 
  PVector pos = new PVector();
  String w;
  float a;
  float count =0 ;
  float wsize = 10;
  float wwidth = 100;
  
  void update() {
    
  }
  
  void render() {
    pushMatrix();
      textAlign(RIGHT);
      translate(pos.x,pos.y);
      rotate(map(pos.y, 0, height, PI/5, -PI/5));
      textSize(wsize);
      fill(255,a);
      textAlign(CENTER,CENTER);
      text(w, 0, 0);
    popMatrix();
  }
  
}
