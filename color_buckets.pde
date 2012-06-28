import processing.video.*;
import toxi.color.*;
import toxi.math.*;


PImage workImg;

float tolerance=0.2;
int threshhold = 93;

Capture video;
int[] backgroundPixels;
int[] workPixels;
int numPixels;

PDS150e ps;
ColorBlast []cb;
final int NUM_LIGHTS = 1;

void setup() {
    ps = new PDS150e();
    cb = new ColorBlast[NUM_LIGHTS];
    for (int i = 0; i < NUM_LIGHTS; i++){
	cb[i] = new ColorBlast(1 + 3 * i);
	ps.addFixture(cb[i]);
    }
    /*
      size(640, 480, P2D);
      video = new Capture(this, width, height, 24);
      workImg = new PImage(video.width, video.height, ARGB);
      numPixels = video.width * video.height;
      backgroundPixels = new int[numPixels];
      workPixels = new int[numPixels];
      
      threshholdSlider = new Slider("threshhold", 100, (float)threshhold/100, 20, 20, width/2-20, 30);
      sliders = new ArrayList();
      sliders.add(threshholdSlider);
    */
}

boolean doHistogram = false;
boolean showBars = false;

int currentLight = 0;
int lastLight = millis();


void draw() {
    if (millis() - lastLight > 2000){
	ps.clear();
	cb[currentLight].setColor(255,255,255, true);
	currentLight++;
        currentLight = currentLight % NUM_LIGHTS;
    }
    
    /*
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
        if (tmp < threshholdSlider.val()) {
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
  for (int i = 0; i < sliders.size(); i++)
    drawSlider((Slider)sliders.get(i));

  if (activeSlider != null) {
    text(activeSlider.name + "\n" + activeSlider.val(), width/2, 20);
  }
    */
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

class Slider {
  String name;
  float minX, minY, maxX, maxY;
  float val;
  float range;
  Slider(String n, float r, float d, float x1, float y1, float x2, float y2) {
    name = n;
    val = d;
    range = r;
    minX = min(x1, x2);
    maxX = max(x1, x2);
    minY = min(y1, y2);
    maxY = max(y1, y2);
  }

  boolean contains(int mouseX, int mouseY) {
    return (mouseX > minX && mouseX < maxX && mouseY > minY && mouseY < maxY);
  } 
  void update(float v) {
    val = max(0.0, min(1.0, (v-minX)/(maxX-minX)));
    println(name + ": " + val);
  }
  float val() {
    return val * range;
  }
}

ArrayList sliders;
Slider activeSlider;
Slider threshholdSlider;
void mousePressed() {
  if (activeSlider == null) {
    for (int i = 0; i < sliders.size(); i++) {
      if (((Slider)(sliders.get(i))).contains(mouseX, mouseY))
        activeSlider = (Slider)sliders.get(i);
    }
  }
}

void mouseDragged() {
  if (activeSlider != null) {
    activeSlider.update(mouseX);
  }
}

void mouseReleased() {
  if (activeSlider != null) {
    activeSlider.update(mouseX);
    activeSlider = null;
  }
}

void drawSlider(Slider s) {
  noStroke();
  strokeWeight(1);
  fill(0, 255, 0);
  rect(s.minX, s.minY, s.maxX-s.minX, s.maxY-s.minY); 
  float valX = s.minX + (s.maxX - s.minX) * s.val;
  fill(200, 200, 200);
  rect(valX-2, s.minY, 4, s.maxY-s.minY);
}
