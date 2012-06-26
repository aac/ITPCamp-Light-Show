import processing.video.*;
import toxi.color.*;
import toxi.math.*;

PImage workImg;

float tolerance=0.2;

Capture video;
int[] backgroundPixels;
int[] workPixels;
int numPixels;

void setup() {
  size(640, 480, P2D);
  video = new Capture(this, width, height, 24);
  workImg = new PImage(video.width, video.height, ARGB);
  numPixels = video.width * video.height;
  backgroundPixels = new int[numPixels];
  workPixels = new int[numPixels];
}

boolean doHistogram = false;
boolean showBars = false;

void draw() {
  if (video.available()) {
    video.read();
    if (doHistogram) {
      video.loadPixels();

      // Difference between the current frame and the stored background
      int presenceSum = 0;
      for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
        // Fetch the current color in that location, and also the color
        // of the background in that spot
        color currColor = video.pixels[i];
        color bkgdColor = backgroundPixels[i];
        // Extract the red, green, and blue components of the current pixel’s color
        int currR = (currColor >> 16) & 0xFF;
        int currG = (currColor >> 8) & 0xFF;
        int currB = currColor & 0xFF;
        // Extract the red, green, and blue components of the background pixel’s color
        int bkgdR = (bkgdColor >> 16) & 0xFF;
        int bkgdG = (bkgdColor >> 8) & 0xFF;
        int bkgdB = bkgdColor & 0xFF;
        // Compute the difference of the red, green, and blue values
        int diffR = abs(currR - bkgdR);
        int diffG = abs(currG - bkgdG);
        int diffB = abs(currB - bkgdB);
        // Add these differences to the running tally
        int tmp = diffR + diffG + diffB;
        presenceSum += tmp;
        // Render the difference image to the screen
        //pixels[i] = color(diffR, diffG, diffB);
        if (tmp < threshhold){
          diffR = 0;
          diffG = 0;
          diffB = 0; 
        }
        else {
          diffR = currR;
          diffG = currG;
          diffB = currB; 
        }
        // The following line does the same thing much faster, but is more technical
        workPixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
      }
      Histogram hist=Histogram.newFromARGBArray(workPixels, workPixels.length/10, tolerance, true);

      TColor col=TColor.BLACK.copy();
      for (int i=0; i<video.pixels.length; i++) {
        col.setARGB(workPixels[i]);
        TColor closest=col;
        float minD=1;
        for (HistEntry e : hist) {
          float d=col.distanceToRGB(e.getColor());
          if (d<minD) {
            minD=d;
            closest=e.getColor();
          }
        }
        workImg.pixels[i]=closest.toARGB();
      }
      image(workImg, 0, 0);
      if (showBars) {
        float x=0;
        int w=width/hist.getEntries().size();
        for (Iterator<HistEntry> i=hist.iterator(); i.hasNext() && x<width;) {
          HistEntry e=i.next();
          println(e.getColor().toHex()+": "+e.getFrequency());
          fill(e.getColor().toARGB());
          float h=e.getFrequency()*height;
          rect(x, height-h, w, h);
          x+=w;
        }
      }
    }
    else
      image(video, 0, 0);
  }
}

void keyPressed() {
  if (key == 'h')
    doHistogram = !doHistogram;
  if (key == 'b')
    showBars = !showBars;
  if (key == ' ') {
    video.loadPixels();
    arraycopy(video.pixels, backgroundPixels);
  }
}

