


//
void makeBucketDataPoints(int pointsToMake, int inputType) {
  for (int i = 0; i < bucketDataPoints.length; i++) {
    bucketDataPoints[i] = new float[pointsToMake];
    /*
    float seed = random(100);
     for (int j = 0; j < pointsToMake; j++) {
     bucketDataPoints[i][j] = (100 * noise(j * .1 + seed));
     }
     */

    

    Bucket targetBucket = bucketsAL.get(i);
    for (int j = 0; j < pointsToMake; j++) {
      if (j < targetBucket.seriesSum.length) {
        switch (inputType) {
        case INPUT_DATA_LINEAR:
          bucketDataPoints[i][j] = targetBucket.seriesSum[j];
          bucketDataPoints[i][j] += (entityMultiplier * targetBucket.seriesSumEntity[j]);
          bucketDataPoints[i][j] += (entityMultiplier * targetBucket.seriesSumPerson[j]);
          break;
        case INPUT_DATA_HALF:
          bucketDataPoints[i][j] = .5 * (targetBucket.seriesSum[j]);
          bucketDataPoints[i][j] += .5 * (entityMultiplier * targetBucket.seriesSumEntity[j]);
          bucketDataPoints[i][j] += .5 * (entityMultiplier * targetBucket.seriesSumPerson[j]);
          break;
        case INPUT_DATA_LOG:
          bucketDataPoints[i][j] = log(targetBucket.seriesSum[j]);
          bucketDataPoints[i][j] += log(entityMultiplier * targetBucket.seriesSumEntity[j]);
          bucketDataPoints[i][j] += log(entityMultiplier * targetBucket.seriesSumPerson[j]);
          break;
        case INPUT_DATA_SQUARE:
          bucketDataPoints[i][j] = (float)Math.pow(targetBucket.seriesSum[j], 2f);
          bucketDataPoints[i][j] += (float)Math.pow((entityMultiplier * targetBucket.seriesSumEntity[j]), 2f);
          bucketDataPoints[i][j] += (float)Math.pow((entityMultiplier * targetBucket.seriesSumPerson[j]), 2f);
          break;
        case INPUT_DATA_CUBE:
          bucketDataPoints[i][j] = (float)Math.pow(targetBucket.seriesSum[j], 3f);
          bucketDataPoints[i][j] += (float)Math.pow((entityMultiplier * targetBucket.seriesSumEntity[j]), 3f);
          bucketDataPoints[i][j] += (float)Math.pow((entityMultiplier * targetBucket.seriesSumPerson[j]), 3f);
          break;
        case INPUT_DATA_SQUARE_ROOT:
          bucketDataPoints[i][j] = (float)Math.pow(targetBucket.seriesSum[j], 1f/2);
          bucketDataPoints[i][j] += (float)Math.pow((entityMultiplier * targetBucket.seriesSumEntity[j]), 1f/2);
          bucketDataPoints[i][j] += (float)Math.pow((entityMultiplier * targetBucket.seriesSumPerson[j]), 1f/2);
          break;
        case INPUT_DATA_MULTIPLIED_THEN_SQUARE_ROOT:
          bucketDataPoints[i][j] = (float)Math.pow(10000 * targetBucket.seriesSum[j], 1f/2);
          bucketDataPoints[i][j] += (float)Math.pow(10000 * (entityMultiplier * targetBucket.seriesSumEntity[j]), 1f/2);
          bucketDataPoints[i][j] += (float)Math.pow(10000 * (entityMultiplier * targetBucket.seriesSumPerson[j]), 1f/2);
          break;
        case INPUT_DATA_CUBE_ROOT:
          bucketDataPoints[i][j] = (float)Math.pow(targetBucket.seriesSum[j], 1f/3);
          bucketDataPoints[i][j] += (float)Math.pow((entityMultiplier * targetBucket.seriesSumEntity[j]), 1f/3);
          bucketDataPoints[i][j] += (float)Math.pow((entityMultiplier * targetBucket.seriesSumPerson[j]), 1f/3);
          break;
        case INPUT_DATA_MULTIPLIED_THEN_CUBE_ROOT:
          bucketDataPoints[i][j] = (float)Math.pow(10000 * targetBucket.seriesSum[j], 1f/3);
          bucketDataPoints[i][j] += (float)Math.pow(10000 * (entityMultiplier * targetBucket.seriesSumEntity[j]), 1f/3);
          bucketDataPoints[i][j] += (float)Math.pow(10000 * (entityMultiplier * targetBucket.seriesSumPerson[j]), 1f/3);
          break;
        case INPUT_DATA_DOUBLE:
          bucketDataPoints[i][j] = 2 * (targetBucket.seriesSum[j]);
          bucketDataPoints[i][j] += 2 * (entityMultiplier * targetBucket.seriesSumEntity[j]);
          bucketDataPoints[i][j] += 2 * (entityMultiplier * targetBucket.seriesSumPerson[j]);
          break;
        case INPUT_DATA_TRIPLE:
          bucketDataPoints[i][j] = 3 * (targetBucket.seriesSum[j]);
          bucketDataPoints[i][j] += 3 * (entityMultiplier * targetBucket.seriesSumEntity[j]);
          bucketDataPoints[i][j] += 3 * (entityMultiplier * targetBucket.seriesSumPerson[j]);
          break;
        case INPUT_DATA_DEBUG:
          bucketDataPoints[i][j] = 13;
          break;
        case INPUT_DATA_NOISE:
          bucketDataPoints[i][j] = 100 * noise(i + j * .1);
          break;
        }
      }
      else {
        bucketDataPoints[i][j] = 0f;
      }
    }
  }
  println("generated " + bucketDataPoints.length + " new buckets of data");
  for (int i = 0; i < bucketDataPoints.length; i++) {
    for (int j = 0; j < bucketDataPoints[i].length; j++) {
      print(nf(bucketDataPoints[i][j], 0, 3) + " ");
    } 
    println("_");
  }
} // end makeBucketDataPoints




//
// this will not only order the terms by highest count to lowest, but will also order their year frequency from most to least so 
//  when placing the terms they can check the first section, then the second, etc. until either a place is found or the yearly frequency is below a given threshold
void orderBucketTerms() {
  for (Bucket b : bucketsAL) {
    b.orderTerms();
  }
} // end orderBucketTerms 



//
//
//
//
//
//
//



//
//
//
//
//
//

