import processing.video.*;

boolean displayBucketedPixels = false;

int numPixels;
int[] normalizedPixels;
int[] pixelBuckets;
Capture video;
PImage normalizedImage;
int numBuckets = 20;
float bucketWidth = 1.0/numBuckets;

Bucket buckets[];

void setup() {
  size(640, 480, P2D);
  video = new Capture(this, width, height, 24);
  numPixels = video.width * video.height;
  loadPixels();
  pixelBuckets = new int[numPixels];

  buckets = new Bucket[numBuckets * numBuckets * numBuckets];
  for (int i = 0; i < buckets.length; i++)
    buckets[i] = new Bucket();
}

void bucketPixel(int index, color pixel)
{
  int r = (pixel >> 16) & 0xFF;
  int g = (pixel >> 8) & 0xFF;
  int b = pixel & 0xFF;
  int sum = r+g+b;

  float nR = ((float)r/255);//sum);
  float nG = ((float)g/255);//sum);
  float nB = ((float)b/255);//sum);

  int bR = floor(nR * (numBuckets-1));
  int bG = floor(nG * (numBuckets-1));
  int bB = floor(nB * (numBuckets-1));

  int bucketIndex = (bR * numBuckets * numBuckets) + (bG * numBuckets) + bB;

  if (bucketIndex >= buckets.length) {
    println("(bR,bG,bB) => ("+bR+", "+bG+", " + bB +")");
  }

  int rR = bR * 255/10;
  int rG = bG * 255/10;
  int rB = bB * 255/10;

  buckets[bucketIndex].addColor(0xFF000000 | (rR<< 16) | (rG << 8) | rB);
  pixelBuckets[index] = bucketIndex;
}

void resetBuckets() {
  for (int i = 0; i < buckets.length; i++)
    buckets[i].clear();
}

class Bucket {
  ArrayList colors;
  int sumR;
  int sumG;
  int sumB;

  Bucket() {
    colors = new ArrayList();
    sumR = 0;
    sumG = 0;
    sumB = 0;
  }

  void clear() {
    colors.clear();
    sumR = 0;
    sumG = 0;
    sumB = 0;
  }

  void addColor(int c) {
    colors.add(Integer.valueOf(c));
    sumR += (c >> 16) & 0xFF;
    sumG += (c >> 8) & 0xFF;
    sumB += c & 0xFF;
  }

  int getColor() {
    if (colors.size() > 0) {
      sumR /= colors.size();
      sumG /= colors.size();
      sumB /= colors.size();
      //println("(r,g,b) => ("+sumR+", " + sumG +", " + sumB + ")");
      return 0xFF000000 | (sumR << 16) | (sumG << 8) | sumB;
    }
    return 0xFF000000;
  }
}


void draw() {
  if (video.available()) {
    video.read();
    video.loadPixels();
    resetBuckets();

    for (int i = 0; i < numPixels; i++) {
      bucketPixel(i, video.pixels[i]);
    }

    if (displayBucketedPixels) {
      //println("Getting pixel colors");
      for (int i = 0; i < numPixels; i++) {
        int r = pixelBuckets[i] / (numBuckets * numBuckets);
        int g = (pixelBuckets[i] - (r * (numBuckets * numBuckets))) / numBuckets;
        int b = (pixelBuckets[i] - (r * (numBuckets * numBuckets)) - (g * numBuckets));
        pixels[i] = 0xFF000000 | ( (r * 255/10) << 16) | ((g * 255/10) << 8) | (b * 255/10);//buckets[pixelBuckets[i]].getColor();
      }
      //println("Updating pixels");
      updatePixels();
      //println("Pixels updated");
    }
    else {
      image(video, 0, 0);
    }
  }
}
/*      
 color c = video.pixels[i];
 int r = (c >> 16) & 0xFF;
 int g = (c >> 8) & 0xFF;
 int b = c & 0xFF;
 
 int sum = r + g + b;
 if (sum > 0) {
 int nR = (float)r/sum;
 int nG = (float)g/sum;
 int nB = (float)b/sum;
 normalizedPixels[i] = 0xFF000000 | (nR << 16) | (nG << 8) | nB;
 }
 else {
 normalizedPixels[i] = c;
 }
 }    
 
 if (displayNormalizedPixels) {
 for (int i = 0; i < numPixels; i++)
 normalizedImage.pixels[i] = normalizedPixels[i];
 normalizedImage.;
 image(normalizedImage, 0, 0);
 }
 else {
 image(video, 0, 0);
 }
 }
 }
 */
void keyPressed() {  
  if (key == 'n')
    displayBucketedPixels = !displayBucketedPixels;
}

