PVector velocityVector;

ArrayList<PVector> linePointsVectorList;
ArrayList<PVector> twistPointsVectorList;

int LINE_LENGTH = 500;

float VELOCITY_STEP_SIZE = 0.10;
float GRAVITY_STEP_SIZE  = 0.10;

float MAX_VELOCITY_MAGNITUDE = 16;

float GRAVITY_SWITCH_PROBABILITY = 0.4;

float TWIST_DISTANCE = 15.0;

float SIDE_SEPARATION_DISTANCE = 10.0;

float movementPhase = 0.0;

boolean isGravityOn;

void setup() {
  frameRate(30);
  size(800, 800, P3D);
  smooth(8);

  linePointsVectorList  = new ArrayList<PVector>();
  twistPointsVectorList = new ArrayList<PVector>();

  PVector newPointVector = new PVector(); 
  
  // Add two points initially so velocity logic simplifies
  linePointsVectorList.add(newPointVector);
  linePointsVectorList.add(newPointVector);
  twistPointsVectorList.add(newPointVector);
  twistPointsVectorList.add(newPointVector);

  velocityVector = new PVector();

  isGravityOn = false;
}

void draw() {
  lights();
  color ambientColor = color(50);
  color backgroundColor = #36b1bf;
  color frontLightColor = #f23c50;
  color backLightColor  = #ffcb05;
 
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
  velocityVector.add(randomVelocityVector);

  if (isGravityOn) {
    PVector lastPointVector = linePointsVectorList.get(linePointsVectorList.size() - 1);
    PVector originPointVector = new PVector(0, 0, 0);

    PVector gravityAccelerationVector = 
      originPointVector.sub(lastPointVector).normalize().mult(GRAVITY_STEP_SIZE);

    velocityVector.add(gravityAccelerationVector);
  }
  velocityVector.limit(MAX_VELOCITY_MAGNITUDE);


  boolean isLineMaximumLength = linePointsVectorList.size() > LINE_LENGTH; 
  if (isLineMaximumLength) {
    linePointsVectorList.remove(0);
    twistPointsVectorList.remove(0);
  }

  PVector lastPointVector = linePointsVectorList.get(linePointsVectorList.size() - 1);
  PVector newPointVector = PVector.add(lastPointVector, velocityVector);

  PVector newTwistPointVector = new PVector();
  newTwistPointVector.x = newPointVector.x + TWIST_DISTANCE * cos(1 * log(0 + 0.3) * movementPhase);
  newTwistPointVector.y = newPointVector.y + TWIST_DISTANCE * cos(1 * log(1 + 0.3) * movementPhase);
  newTwistPointVector.z = newPointVector.z + TWIST_DISTANCE * cos(1 * log(2 + 0.3) * movementPhase);

  linePointsVectorList.add(newPointVector);
  twistPointsVectorList.add(newTwistPointVector);



  noStroke();
  for (int iPoint = 0; iPoint < linePointsVectorList.size() - 1; iPoint++) {

    PVector currentPointVector = linePointsVectorList.get(iPoint);
    PVector nextPointVector    = linePointsVectorList.get(iPoint + 1);
    
    PVector currentTwistVector = twistPointsVectorList.get(iPoint);
    PVector nextTwistVector    = twistPointsVectorList.get(iPoint + 1);

    for (int iSide = 0; iSide < 2; iSide++) {
      boolean isFrontSide = iSide == 0;
      if (isFrontSide) {
        fill(frontLightColor);
      } else {
        fill(backLightColor);
      }

      float sideSeparation = SIDE_SEPARATION_DISTANCE * iSide;

      beginShape();
      vertex(currentPointVector.x, currentPointVector.y, currentPointVector.z + sideSeparation);
      vertex(currentTwistVector.x, currentTwistVector.y, currentTwistVector.z + sideSeparation);
      vertex(nextTwistVector.x,    nextTwistVector.y,    nextTwistVector.z    + sideSeparation);
      vertex(nextPointVector.x,    nextPointVector.y,    nextPointVector.z    + sideSeparation);
      vertex(currentPointVector.x, currentPointVector.y, currentPointVector.z + sideSeparation);
      endShape();
    }


    // Draw shadow
    float yShadow = 100;
    fill(#4ad9d9);
    beginShape();
    vertex(currentPointVector.x, yShadow, currentPointVector.z);
    vertex(currentTwistVector.x, yShadow, currentTwistVector.z);
    vertex(nextTwistVector.x,    yShadow, nextTwistVector.z);
    vertex(nextPointVector.x,    yShadow, nextPointVector.z);
    vertex(currentPointVector.x, yShadow, currentPointVector.z);
    endShape();

  }

  // Draw base plane
  fill(#e9ffdf);
  beginShape();
  vertex( 100, 101, 100);
  vertex(-100, 101, 100);
  vertex(-100, 101, -100);
  vertex( 100, 101, -100);
  endShape();
}
