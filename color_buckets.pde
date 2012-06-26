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

void draw() {
  if (video.available()) {
    video.read();
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
  }
}

void keyPressed() {
}

