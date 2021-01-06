
Biome nil = new MonoBiome();
Biome ocean = new OceanBiome();
Biome tundra = new TundraBiome();
Biome desert = new DesertBiome();
Biome steppe = new DirtRockBiome(#cdf0b6);
Biome savanna = new DirtRockBiome(#abab6d);
Biome conifer = new DirtRockBiome(#609660);
Biome broadleaf = new DirtRockBiome(#6eba6e);
Biome laurel = new DirtRockBiome(#377d37);
Biome tropical = new DirtRockBiome(#2c572c);


public abstract class Biome{
  
  public abstract void draw(float altitude, float xLocal, float zLocal, int size);
  
  
  private final float altiToPosY(float alti){
    return map(alti, -500, 2000, 0, 400);
  }
  
  public void drawColumn(float altiLow, float altiHigh, float xLocal, float zLocal, int size){
    pushMatrix();
    //float heightFrom 
    
    float yLow = altiToPosY(altiLow);
    float yHigh = altiToPosY(altiHigh);
    
    
    float thretholdDiv = size/2;
    float yLowThre = floor(yLow/thretholdDiv)*thretholdDiv;
    float yHighThre = floor(yHigh/thretholdDiv)*thretholdDiv;
    
    float fade = 500 * (fadeX(xLocal) * fadeX(zLocal) - 1);
    
    translate(size*xLocal, fade, size*zLocal);
    //translate(size*xLocal, 0, size*zLocal);

      
    column(size, yLowThre, yHighThre);
    //translate(-size/2, dispHeight/2, -size/2);
    //box(size, dispHeight, size);
    
    popMatrix();
  }
  
  float max = sigmoid(len/2);
  float fadeX(float x){
    float xx = -(abs(x - len/2) - len/2);
    float fade = sigmoid(xx) / max;
    if(fade > 0.999) return 1;
    
    return fade;
  }
  
  public void column(float planeSize, float yLow, float yHigh){
    pushMatrix();
    float ySize = yHigh - yLow;
    translate(-planeSize/2, (ySize/2+ yLow), -planeSize/2);
    box(planeSize, ySize, planeSize);
    popMatrix();
  }
}





public class MonoBiome extends Biome{
  public void draw(float altitude, float xLocal, float zLocal, int size){
    float col = map(altitude, -500, 4000, 50, 255);
    fill(col);
    
    //if(altitude > 0 ){
    //  drawColumn(-10000, altitude, xLocal, zLocal, size);
    //}
    
    drawColumn(-10000, altitude, xLocal, zLocal, size);
    
  }
}


color rockColor = #828282;
color dirtColor = #916b17;

public class OceanBiome extends Biome{
  public void draw(float altitude, float xLocal, float zLocal, int size){
    if(0 < altitude){
      return;
    }
    
    //float col = map(altitude, -500, 4000, 50, 255);
    fill(#3282c8);
    //println("alti:" + altitude);
    drawColumn(altitude, 0, xLocal, zLocal, size);
    
    fill(rockColor);
    drawColumn(-10000, altitude, xLocal, zLocal, size);
  }
}

public class TundraBiome extends Biome{
  public void draw(float altitude, float xLocal, float zLocal, int size){
    fill(#f0f7f7);
    drawColumn(altitude-800, altitude, xLocal, zLocal, size);
    fill(rockColor);
    drawColumn(-10000, altitude-800, xLocal, zLocal, size);
  }
}


public class DesertBiome extends Biome{
  public void draw(float altitude, float xLocal, float zLocal, int size){
    fill(#e6e69c);
    drawColumn(altitude-300, altitude, xLocal, zLocal, size);
    fill(rockColor);
    drawColumn(-10000, altitude-300, xLocal, zLocal, size);
  }
}


//public class SteppeBiome extends Biome{
//  public void draw(float altitude, float xLocal, float zLocal, int size){
//    fill(#cdf0b6);
//    drawColumn(-10000, altitude, xLocal, zLocal, size);
//  }
//}


//public class SavannaBiome extends Biome{
//  public void draw(float altitude, float xLocal, float zLocal, int size){
//    fill(#abab6d);
//    drawColumn(-10000, altitude, xLocal, zLocal, size);
//  }
//}

public class DirtRockBiome extends Biome{
  color surfaceColor;
  public DirtRockBiome(color col){
    surfaceColor = col;
  }
  
  public void draw(float altitude, float xLocal, float zLocal, int size){
    fill(surfaceColor);
    drawColumn(altitude-600, altitude, xLocal, zLocal, size);
    //fill(dirtColor);
    //drawColumn(altitude-600, altitude-200, xLocal, zLocal, size);
    fill(rockColor);
    drawColumn(-10000, altitude-600, xLocal, zLocal, size);
  }
}

////針葉樹
//public class ConiferBiome extends Biome{
//  public void draw(float altitude, float xLocal, float zLocal, int size){
//    fill(#609660);
//    drawColumn(-10000, altitude, xLocal, zLocal, size);
//  }
//}
////広葉樹
//public class BroadleafBiome extends Biome{
//  public void draw(float altitude, float xLocal, float zLocal, int size){
//    fill(#6eba6e);
//    drawColumn(-10000, altitude, xLocal, zLocal, size);
//  }
//}
////照葉樹林
//public class LaurelBiome extends Biome{
//  public void draw(float altitude, float xLocal, float zLocal, int size){
//    fill(#377d37);
//    drawColumn(-10000, altitude, xLocal, zLocal, size);
//  }
//}
////熱帯雨林
//public class TropicalBiome extends Biome{
//  public void draw(float altitude, float xLocal, float zLocal, int size){
//    fill(#2c572c);
//    drawColumn(-10000, altitude, xLocal, zLocal, size);
//  }
//}
