import processing.video.*;
import toxi.color.*;
import toxi.math.*;

PImage workImg;

float tolerance=0.2;

Capture video;

void setup() {
  size(640, 480, P2D);
  video = new Capture(this, width, height, 24);
  workImg = new PImage(video.width, video.height, ARGB);
}

boolean doHistogram = false;
boolean showBars = false;

void draw() {
  if (video.available()) {
    video.read();
    if (doHistogram) {
      video.loadPixels();
      Histogram hist=Histogram.newFromARGBArray(video.pixels, video.pixels.length/10, tolerance, true);

      TColor col=TColor.BLACK.copy();
      for (int i=0; i<video.pixels.length; i++) {
        col.setARGB(video.pixels[i]);
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
}

