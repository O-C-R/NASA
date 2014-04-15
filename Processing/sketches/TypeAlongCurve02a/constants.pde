// the different status codes used after trying to place a term
final String POPULATE_STATUS_EMPTY = "emtpy";
final String POPULATE_STATUS_SUCCESS = "success";
final String POPULATE_STATUS_FAIL = "fail";

// the ways in which the bucket data is read in and/or reduced
final int INPUT_DATA_LINEAR = 0; // will take the full bucket value
final int INPUT_DATA_LOG = 1; // log of the bucket value
final int INPUT_DATA_HALF = 2; // half of the bucket value
final int INPUT_DATA_DOUBLE = 3; // double of the bucket value
final int INPUT_DATA_TRIPLE = 4; // triple of the bucket value
final int INPUT_DATA_CUBE = 5; // cube the bucket value
final int INPUT_DATA_SQUARE = 6; // square the data
final int INPUT_DATA_SQUARE_ROOT = 7; // squareroot the data
final int INPUT_DATA_MULTIPLIED_THEN_SQUARE_ROOT = 111; // 10000 * the value, then squareroot the data
final int INPUT_DATA_CUBE_ROOT = 8; // cuberoot the data
final int INPUT_DATA_MULTIPLIED_THEN_CUBE_ROOT = 9; // 10000 * the value, then cuberoot the data
final int INPUT_DATA_DEBUG = 10; // assign an static number
final int INPUT_DATA_NOISE = 11; // just noise, not data

// the different types of label alignments
final int LABEL_ALIGN_LEFT = 0;
final int LABEL_ALIGN_CENTER = 1;
final int LABEL_ALIGN_RIGHT = 2;

// color stuff
final int dateColor = #4D489F;
final int bgColor = #0B0A19;


//
//
//
//

