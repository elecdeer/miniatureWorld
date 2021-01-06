
float x = 0;
float z = 0;

int len = 35;
int size = 20;

int altitudeSeed = 0;
int rainSeed = 1;
int temperatureSeed = 2;

float[][] altitudeMap;
float[][] rainMap;
float[][] temperatureMap;
Biome[][] biomeMap;

int memoX = -9999;
int memoZ = -9999;


int initializeTick = 0;
final int INIT_TICK = 180;
int timeTick = 0;


void settings(){
  smooth(8);
  size(1600, 900, P3D);
  
}



void setup(){
  frameRate(60);
  
  int baseSeed = floor(random(0, 99999));
  
  
  altitudeSeed = baseSeed;
  rainSeed = baseSeed + 1;
  temperatureSeed = baseSeed + 2;
  
  
  
  ortho();
  strokeWeight(1);
  
  //colorMode(HSB, 100);
  
  altitudeMap = new float[len][len];
  rainMap = new float[len][len];
  temperatureMap = new float[len][len];
  biomeMap = new Biome[len][len];
  
  for(int i = 0; i < len; i++){
    for(int j = 0; j < len; j++){
      biomeMap[i][j] = nil;
    }
  }
  
}

void setDebugAltitudeMap(){
  for(int i = 0; i < len; i++){
    for(int j = 0; j < len; j++){
      altitudeMap[i][j] = map(i, 0, len, 500, -500);
    }
  }
}


float fade(float t){
  return t*t*(3-2*t);
}

float sigmoid(float t){
  float a = 2.5;
  return (1 - exp(-a*t))/(1 + exp(-a*t)) * (1 + exp(-a))/(1 - exp(-a));
}


float max = sigmoid(len/2);
float fadeX(float x){
  float xx = -(abs(x - len/2) - len/2);
  float fade = sigmoid(xx) / max;
  if(fade > 0.999) return 1;
  
  return fade;
}

void draw(){
  
  pushMatrix();
  
  //int cx = 600;
  //int cy = 450;
  //int cz = 600;
  //ortho();
  //camera(cx, cy, cz, cx-800, cy-800, cz-800, 0, -1, 0);
  
  int cx = 500;
  int cy = 300;
  int cz = 500;
  camera(cx, cy, cz, 0, cy-400, 0, 0, -1, 0);
  translate(0, 100, 0);
  
  if(0 < initializeTick && initializeTick < INIT_TICK){
    initializeTick++;
    println(initializeTick);
  }
  if(INIT_TICK <= initializeTick){
    timeTick++;
  }
  
  
  //ortho();
  float f = map(initializeTick, 0, INIT_TICK, 0.0, 1.0);
  float interpolated = f*(2-f);
  translate(0, -3000*(1-interpolated), 0);
  
  
  int xi = (int)x;
  int zi = (int)z;
  
  boolean clearMemo = xi != memoX || zi != memoZ;
  
  if(clearMemo){
    remapWorld();
    //setDebugAltitudeMap();
  }
  
  
  
  drawWorld();
  
  
  popMatrix();
  
  pushMatrix();
  if(INIT_TICK <= initializeTick){
    drawSubInfo();
    control();
  }
  popMatrix();
  
}



double altitudeDistributionFunc(double d){
  //return 58.6247157216436 * d*d*d*d*d*d
  //     - 151.4085655728657 * d*d*d*d*d
  //     + 143.4549615984169 * d*d*d*d
  //     - 58.7707587413954 * d*d*d
  //     + 8.4756352600414 * d*d
  //     + 0.6240117341592 * d;
       
  return -33.7707143061444 * d*d*d*d*d*d
  + 86.4959091935013 * d*d*d*d*d
  - 79.036456342492 * d*d*d*d
  + 33.2921293740206 * d*d*d
  - 7.3809617634773 * d*d
  + 1.4000938445919 * d;
}

void remapWorld(){
  int xi = (int)x;
  int zi = (int)z;
  
  noiseSeed(altitudeSeed);
  noiseDetail(4, 0.5);
  
  memoX = xi;
  memoZ = zi;
  
  for(int i = 0; i < len; i++){
    for(int j = 0; j < len; j++){
      int indexX = (int)x - i;
      int indexZ = (int)z - j;
      
      double d = noise(indexX/25.0, indexZ/25.0);
      //println(d);
      float inter = (float)altitudeDistributionFunc((d-0.5)*1.8+0.5);
      //float inter = (float)d;
     
      float hei = map(inter, 0, 1, -500, 2500);
      
      //println(hei);
      altitudeMap[i][j] = hei;
    }
  }
  
  noiseSeed(temperatureSeed);
  noiseDetail(8, 0.4);
  for(int i = 0; i < len; i++){
    for(int j = 0; j < len; j++){
      int indexX = (int)x - i;
      int indexZ = (int)z - j;
      
      temperatureMap[i][j] = altitudeMap[i][j] + (noise(indexX/25.0, indexZ/25.0)-0.5)*400;
    }
  }
  
  
  
  float biomeCycle = 80;
  
  noiseSeed(rainSeed);
  noiseDetail(6, 0.3);
  for(int i = 0; i < len; i++){
    for(int j = 0; j < len; j++){
      int indexX = (int)x - i;
      int indexZ = (int)z - j;
      
      //println(noise(((float)indexX)/biomeCycle, ((float)indexZ)/biomeCycle));
      
      float rain = map(noise(indexX/biomeCycle, indexZ/biomeCycle), 0, 1, 0, 4500);
      rainMap[i][j] = rain;
    }
  }
  
  
  for(int i = 0; i < len; i++){
    for(int j = 0; j < len; j++){
      biomeMap[i][j] = getBiome(altitudeMap[i][j], rainMap[i][j], temperatureMap[i][j]);//, temperatureMap[i][j])
    }
  }
}



Biome getBiome(float altitude, float rainfall, float temperature){
  //alti: -500~2000
  //rain: 0~4500
  
  if(altitude < 0){
    return ocean;
  }else if(1500 < temperature){
    return tundra;
  }else{
    if(rainfall < 500){
      if(temperature < 750){
        return desert;
      }else{
        return tundra;
      }
    }else if(rainfall < 1500){
      if(temperature < 750){
        return savanna;
      }else{
        return steppe;
      }
    }else if(rainfall < 3500){
      if(temperature < 500){
        return conifer;
      }else if(temperature < 1000){
        return broadleaf;
      }else{
        return laurel;
      }
    }else{
      return tropical;
    }
  }
}




void drawWorld(){
  
  float lightDir = radians(timeTick/5);
  
  //fill(cos(lightDir)*128+128);
  
  //background(0, 0, 100);
  background(cos(lightDir)*64+192, cos(lightDir)*64+192, cos(lightDir)*48+208);
  
  //stroke(0);
  //line(0, -10000, 0, 0, 10000, 0);
  
  pushMatrix();
  //translate(0, -1000, -len*size);
  
  noLights();
  ambientLight(128, 128, 128);
  
  //println((frameCount/5)%360);
  directionalLight(255, 255, 255, 0, -cos(lightDir), sin(lightDir));
  popMatrix();
  
  translate(-len*size/2, -300, -len*size/2);
  
  //println(rainMap[0][0]);
  for(int i = 0; i < len; i++){
    for(int j = 0; j < len; j++){
      float xLocal = x - (int)x + i;
      float zLocal = z - (int)z + j;
      
      Biome biome = biomeMap[i][j];
      //Biome biome = ocean;
      //Biome biome = nil;
      
      biome.draw(altitudeMap[i][j], xLocal, zLocal, size);
    }
    
  }
}


void drawSubInfo(){
  float lightDir = radians(timeTick/5);
  
  
  textSize(30);
  
  //color textColor = #b0b0b0;
  color textColor = color(sin(lightDir)*64+192);
  
  color highlightColor = #ff9524;
  
  fill(textColor);

  String seedText = String.format("seed: %5d", altitudeSeed);
  textAlign(RIGHT);
  text(seedText, width -10, height - 10);

  
  pushMatrix();
  textAlign(CENTER);
  
  translate(15, height - 35);
  
  rotate(radians(45));
  
  fill(wPressing ? highlightColor : textColor);
  text("W", 20, -30);
  fill(aPressing ? highlightColor : textColor);
  text("A", 0, 0);
  fill(sPressing ? highlightColor : textColor);
  text("S", 20, 0);
  fill(dPressing ? highlightColor : textColor);
  text("D", 40, 0);
  
  popMatrix();
  
  fill(highlightColor);
  if(autoMode){
    text("Auto", 140, height -10);
  }

 
}


void control(){
  vx *= 0.98;
  vz *= 0.98;
  
  x += vx;
  z += vz;
  
  float speed = shiftPressing ? 0.01 : 0.005;
  
  if(autoMode){
    vx += 0.008;
    vz += 0.003;
  }else{
    if(aPressing){
      vz += speed;
    }
    if(dPressing){
      vz -= speed;  
    }
    if(wPressing){
      vx += speed;  
    }
    if(sPressing){
      vx -= speed;
    }
  }
}



float vx = 0;
float vz = 0;

boolean aPressing = false;
boolean dPressing = false;
boolean wPressing = false;
boolean sPressing = false;
boolean shiftPressing = false;

boolean autoMode = false;

void keyPressed(){
  if(key == 'a'){
    aPressing = true;
  }
  if(key == 'd'){
    dPressing = true;
  }
  if(key == 'w'){
    wPressing = true;
  }
  if(key == 's'){
    sPressing = true;
  }
  if(key == ' '){
    if(initializeTick == 0){
       initializeTick = 1;
    }
    
    if(INIT_TICK <= initializeTick){
      autoMode = !autoMode;
      println("autoMode: " + autoMode);
    }
    
  }
  if(key == CODED && keyCode == SHIFT){
    shiftPressing = true;
  }
}

void keyReleased(){
  if(key == 'a'){
    aPressing = false;
  }
  if(key == 'd'){
    dPressing = false;
  }
  if(key == 'w'){
    wPressing = false;
  }
  if(key == 's'){
    sPressing = false;
  }
  if(key == CODED && keyCode == SHIFT){
    shiftPressing = false;
  }
}
