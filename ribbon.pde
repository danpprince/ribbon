import java.lang.Math;

PVector velocityVector;

ArrayList<ArrayList<Float>> linePointsVectorList;
ArrayList<ArrayList<Float>> twistPointsVectorList;

int LINE_LENGTH = 500;

float VELOCITY_STEP_SIZE = 0.10;
float GRAVITY_STEP_SIZE  = 0.010;

float MAX_VELOCITY_MAGNITUDE = 16;

float GRAVITY_SWITCH_PROBABILITY = 0.40;

float TWIST_DISTANCE = 15.0;

float movementPhase = 0.0;

boolean isGravityOn;

void setup() {
  frameRate(30);
  size(800, 800, P3D);
  smooth(8);

  linePointsVectorList  = new ArrayList<ArrayList<Float>>();
  twistPointsVectorList = new ArrayList<ArrayList<Float>>();

  ArrayList<Float> newPointsVector = new ArrayList(); 
  newPointsVector.add(0.0);
  newPointsVector.add(0.0);
  newPointsVector.add(0.0);
  
  // Add two points initially so velocity logic simplifies
  linePointsVectorList.add(newPointsVector);
  linePointsVectorList.add(newPointsVector);
  twistPointsVectorList.add(newPointsVector);
  twistPointsVectorList.add(newPointsVector);

  velocityVector = new PVector();

  isGravityOn = false;
}

void draw() {
  lights();
  color ambientColor = color(50);
  color backgroundColor = #36b1bf;
  color frontLightColor = #f23c50;
  color backLightColor  = #ffcb05;
  color fillColor = color(150);
 
  color directionalLightColor = color(80);
  directionalLight(red(directionalLightColor), green(directionalLightColor), green(directionalLightColor), 0, 0, -2);
  directionalLight(red(directionalLightColor), green(directionalLightColor), green(directionalLightColor), 0, 0,  2);
  
  // Top light
  color topLightColor = color(80);
  directionalLight(red(topLightColor), blue(topLightColor), green(topLightColor), 0, 5, 0);

  
  ambientLight(red(ambientColor), green(ambientColor), blue(ambientColor));  
  background(backgroundColor);

  float eyeZ = 300 * sin(movementPhase);
  float eyeX = 300 * cos(movementPhase);
  movementPhase += 0.02;

  camera(eyeX, 10.0, eyeZ, // eyeX, eyeY, eyeZ
         0.0, 0.0, 0.0, // centerX, centerY, centerZ
         0.0, 1.0, 0.0); // upX, upY, upZ

  boolean isGravitySwitching = GRAVITY_SWITCH_PROBABILITY > random(0.0, 1.0);
  if (isGravitySwitching) {
    isGravityOn = !isGravityOn;
  }

  // Update velocity
  PVector randomVelocityVector = PVector.random3D().mult(VELOCITY_STEP_SIZE);
  velocityVector = velocityVector.add(randomVelocityVector);

  if (isGravityOn) {
    ArrayList<Float> lastPointList = linePointsVectorList.get(linePointsVectorList.size() - 1);
    PVector lastPointVector = new PVector();
    PVector originVector = new PVector(0, 0, 0);

    lastPointVector.x = lastPointList.get(0);
    lastPointVector.y = lastPointList.get(1);
    lastPointVector.z = lastPointList.get(2);
    
    PVector gravityAccelerationVector = originVector.sub(lastPointVector).mult(GRAVITY_STEP_SIZE);

    velocityVector = velocityVector.add(gravityAccelerationVector);
  }
  
  // Set terminal velocity
  velocityVector = velocityVector.limit(MAX_VELOCITY_MAGNITUDE);
  
  println("Velocity: " + velocityVector);

  boolean isLineMaximumLength = linePointsVectorList.size() > LINE_LENGTH; 
  if (isLineMaximumLength) {
    linePointsVectorList.remove(0);
    twistPointsVectorList.remove(0);
  }

  ArrayList<Float> lastPointList = linePointsVectorList.get(linePointsVectorList.size() - 1);
  
  ArrayList<Float> newPointList = new ArrayList();
  ArrayList<Float> newTwistPointList  = new ArrayList();

  PVector lastPointVector = new PVector();
  lastPointVector.x = lastPointList.get(0);
  lastPointVector.y = lastPointList.get(1);
  lastPointVector.z = lastPointList.get(2);

  PVector newPointVector = lastPointVector.add(velocityVector);
  
  PVector newTwistVector = new PVector(); 
  
  if (true) {
    newTwistVector.x = newPointVector.x + TWIST_DISTANCE * cos(1 * log(0 + 0.3) * movementPhase);
    newTwistVector.y = newPointVector.y + TWIST_DISTANCE * cos(1 * log(1 + 0.3) * movementPhase);
    newTwistVector.z = newPointVector.z + TWIST_DISTANCE * cos(1 * log(2 + 0.3) * movementPhase);
  
    newPointList.add(newPointVector.x);
    newPointList.add(newPointVector.y);
    newPointList.add(newPointVector.z);
  
    newTwistPointList.add(newTwistVector.x);
    newTwistPointList.add(newTwistVector.y);
    newTwistPointList.add(newTwistVector.z);
  
    linePointsVectorList.add(newPointList);
    twistPointsVectorList.add(newTwistPointList);
  }


  noStroke();
  for (int iPoint = 0; iPoint < linePointsVectorList.size() - 1; iPoint++) {

    ArrayList<Float> currentPointVector = linePointsVectorList.get(iPoint);
    ArrayList<Float> nextPointVector    = linePointsVectorList.get(iPoint + 1);
    
    ArrayList<Float> currentTwistVector = twistPointsVectorList.get(iPoint);
    ArrayList<Float> nextTwistVector    = twistPointsVectorList.get(iPoint + 1);
    
    float xCurr = currentPointVector.get(0);
    float yCurr = currentPointVector.get(1);
    float zCurr = currentPointVector.get(2);
    float xNext = nextPointVector.get(0);
    float yNext = nextPointVector.get(1);
    float zNext = nextPointVector.get(2);
    
    float xCurrTwist = currentTwistVector.get(0);
    float yCurrTwist = currentTwistVector.get(1);
    float zCurrTwist = currentTwistVector.get(2);    
    float xNextTwist = nextTwistVector.get(0);
    float yNextTwist = nextTwistVector.get(1);
    float zNextTwist = nextTwistVector.get(2);
    
    for (int iSide = 0; iSide < 2; iSide++) {
      boolean isFrontSide = iSide == 0;
      if (isFrontSide) {
        fill(frontLightColor);
      } else {
        fill(backLightColor);
      }

      beginShape();
      float sideSeparation = 2;
      vertex(xCurr,      yCurr,      zCurr      + sideSeparation * iSide);
      vertex(xCurrTwist, yCurrTwist, zCurrTwist + sideSeparation * iSide);
      vertex(xNextTwist, yNextTwist, zNextTwist + sideSeparation * iSide);
      vertex(xNext,      yNext,      zNext      + sideSeparation * iSide);
      vertex(xCurr,      yCurr,      zCurr      + sideSeparation * iSide);
      endShape();
    }
    
    
    // Draw shadow
    float yShadow = 100;
    fill(#4ad9d9);
    beginShape();
    vertex(xCurr,      yShadow, zCurr);
    vertex(xCurrTwist, yShadow, zCurrTwist);
    vertex(xNextTwist, yShadow, zNextTwist);
    vertex(xNext,      yShadow, zNext);
    vertex(xCurr,      yShadow, zCurr);
    endShape();

  }
  
  fill(#e9ffdf);
  beginShape();
  vertex( 100, 101, 100);
  vertex(-100, 101, 100);
  vertex(-100, 101, -100);
  vertex( 100, 101, -100);
  endShape();
}
