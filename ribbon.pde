import java.lang.Math;

ArrayList<Float> velocityVector;

ArrayList<ArrayList<Float>> linePointsVectorList;
ArrayList<ArrayList<Float>> twistPointsVectorList;

int LINE_LENGTH = 500;

float VELOCITY_STEP_SIZE = 0.30;
float GRAVITY_STEP_SIZE  = 1.00;

float MAX_VELOCITY = 8;

float GRAVITY_SWITCH_PROBABILITY = 0.40;

float TWIST_DISTANCE = 5.0;

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

  velocityVector = new ArrayList();
  velocityVector.add(0.0);
  velocityVector.add(0.0);
  velocityVector.add(0.0);

  isGravityOn = false;
}

void draw() {
  lights();
  color ambientColor = color(50);
  color backgroundColor = #36b1bf;
  color frontLightColor = #f23c50;
  color backLightColor  = #ffcb05;
  color fillColor = color(150);
 
  directionalLight(red(frontLightColor), green(frontLightColor), blue(frontLightColor), 0, 0, -2);
  directionalLight(red(backLightColor), green(backLightColor), blue(backLightColor), 0, 0,  2);
  
  // Top light
  directionalLight(130, 130, 130, 0, 5, 0);

  
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

  for (int iDimension = 0; iDimension < 3; iDimension++) {
    float oldVelocity = velocityVector.get(iDimension);
    float newVelocity = oldVelocity + random(-VELOCITY_STEP_SIZE, VELOCITY_STEP_SIZE);
    
    if (isGravityOn) {
      ArrayList<Float> lastPointVector = linePointsVectorList.get(linePointsVectorList.size() - 1);
      float lastPoint = lastPointVector.get(iDimension);
      newVelocity -= Math.copySign(GRAVITY_STEP_SIZE, lastPoint);
    }
    
    // Set terminal velocity
    newVelocity = min(newVelocity,  MAX_VELOCITY);
    newVelocity = max(newVelocity, -MAX_VELOCITY);

    velocityVector.set(iDimension, newVelocity);
  }
  
  println("Velocity: " + velocityVector.get(0) + ", " + velocityVector.get(1) + ", " + velocityVector.get(2) + ", ");

  velocityVector.set(0, velocityVector.get(0) + random(-VELOCITY_STEP_SIZE, VELOCITY_STEP_SIZE));
  velocityVector.set(1, velocityVector.get(1) + random(-VELOCITY_STEP_SIZE, VELOCITY_STEP_SIZE));
  velocityVector.set(2, velocityVector.get(2) + random(-VELOCITY_STEP_SIZE, VELOCITY_STEP_SIZE));

  boolean isLineMaximumLength = linePointsVectorList.size() > LINE_LENGTH; 
  if (isLineMaximumLength) {
    linePointsVectorList.remove(0);
    twistPointsVectorList.remove(0);
  }
    
  ArrayList<Float> lastPointsVector = linePointsVectorList.get(linePointsVectorList.size() - 1);
  
  ArrayList<Float> newPointsVector = new ArrayList();
  ArrayList<Float> newTwistVector  = new ArrayList();
  
  for (int iDimension = 0; iDimension < 3; iDimension++) {
    float oldPoint = lastPointsVector.get(iDimension);
    float newPoint = oldPoint + velocityVector.get(iDimension);
    
    float twistPoint = newPoint + TWIST_DISTANCE * cos(30 * log(iDimension + 0.3) * movementPhase);
    
    newPointsVector.add(newPoint);
    newTwistVector.add(twistPoint);
  }
  linePointsVectorList.add(newPointsVector);
  twistPointsVectorList.add(newTwistVector);


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
    
    fill(fillColor);
    beginShape();
    vertex(xCurr,      yCurr,      zCurr);
    vertex(xCurrTwist, yCurrTwist, zCurrTwist);
    vertex(xNextTwist, yNextTwist, zNextTwist);
    vertex(xNext,      yNext,      zNext);
    vertex(xCurr,      yCurr,      zCurr);
    endShape();
    
    
    // Draw shadow
    float yShadow = 100;
    fill(100);
    beginShape();
    vertex(xCurr,      yShadow, zCurr);
    vertex(xCurrTwist, yShadow, zCurrTwist);
    vertex(xNextTwist, yShadow, zNextTwist);
    vertex(xNext,      yShadow, zNext);
    vertex(xCurr,      yShadow, zCurr);
    endShape();

  }
  
  fill(180);
  beginShape();
  vertex( 100, 101, 100);
  vertex(-100, 101, 100);
  vertex(-100, 101, -100);
  vertex( 100, 101, -100);
  endShape();
}
