//
void exportSer(String name, Object o) {
  String fileName = sketchPath("") + "ser/" + name + ".ser"; // folder path must exist!
  try {
    FileOutputStream fileOut = new FileOutputStream(fileName);
    ObjectOutputStream out = new ObjectOutputStream(fileOut);
    out.writeObject(o);
    out.close();
    println("wrote object \"" + name + "\" out successfully");
  } 
  catch (IOException i) {
    println("problem exporting ser");
  }
} // end exportCol


//
public Object readSer(String name) {
  Object newData = null;
  String fileName = sketchPath("") + "ser/" + name + ".ser"; // folder path must exist!
  try {
    FileInputStream fileIn = new FileInputStream(fileName);
    ObjectInputStream in = new ObjectInputStream(fileIn);
    try {
      newData = in.readObject();
    }
    catch (ClassNotFoundException e) {
      println("class not found exception");
    }
    in.close();
    fileIn.close();
    //println("read in file successfully");
  }
  catch(IOException i)
  {
    println("problem importing ser for " + fileName);
    newData = null;
  }
  return newData;
} // end readSer

//
//
//
//
//
//
//

