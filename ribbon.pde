// Global constants

// Defines the maximum number of points in a ribbon
int RIBBON_LENGTH = 1000;

// Defines the amount of acceleration of new points in a random direction
float RANDOM_ACCELERATION = 0.1;

// Defines the amount of acceleration of new points towards the center of the space
float GRAVITY_ACCELERATION = 0.9;

// Defines the amount of acceleration of new points away from old points
float REPELLANCE_ACCELERATION = 0.9;

// Defines the maximum distance at which old points repel new points 
float REPELLANCE_DISTANCE_THRESHOLD = 60;

// Defines a limit on the maximum velocity magnitude to control speed
float MAX_VELOCITY_MAGNITUDE = 2;

// Defines the probability at each frame that gravity will turn on if it is off (and vice versa)
float GRAVITY_SWITCH_ON_PROBABILITY  = 0.013;
float GRAVITY_SWITCH_OFF_PROBABILITY = 0.00;

// Defines the width of each ribbon
float RIBBON_WIDTH = 5.0;

// Defines the distance between each ribbon
float RIBBON_SEPARATION_DISTANCE = 5.0;

// Defines the limits on the cubic space where points can be generated
float X_CUBE_LIMIT = 80;
float Y_CUBE_LIMIT = 80;
float Z_CUBE_LIMIT = 80;

// Defines the amount of bounce that the sides of the cubic space (higher values create more bounce)
float CUBE_BOUNCE_COEFFICIENT = 0.02;

// Defines whether a sphere should be drawn in the center when gravity is on
boolean IS_VISUALIZING_GRAVITY = false;

// Defines whether each frame should be saved to disk for generating a movie
boolean IS_IMAGE_SAVING_ON = true;



// Global state variables
float movementPhase = 0.0;
boolean isGravityOn = true;
PVector velocityVector;
ArrayList<PVector> linePointsVectorList;
ArrayList<PVector> twistPointsVectorList;


void setup() {
  frameRate(30);
  size(800, 800, P3D);
  smooth(8);

  linePointsVectorList  = new ArrayList<PVector>();
  twistPointsVectorList = new ArrayList<PVector>();

  PVector newPointVector = PVector.random3D().mult(X_CUBE_LIMIT); 
  
  // Add two points initially so velocity logic simplifies
  linePointsVectorList.add(newPointVector);
  linePointsVectorList.add(newPointVector);
  twistPointsVectorList.add(newPointVector);
  twistPointsVectorList.add(newPointVector);

  velocityVector = new PVector();
}

void draw() {
  color ambientColor = color(160);
  color backgroundColor = #36b1bf;

  color ribbon1Color = #f23c50;
  color ribbon2Color = #4ad9d9;
  color ribbon3Color = #ffcb05;

 
  color directionalLightColor = color(200);
  directionalLight(red(directionalLightColor), green(directionalLightColor), green(directionalLightColor), 0, 0, -2);
  directionalLight(red(directionalLightColor), green(directionalLightColor), green(directionalLightColor), 0, 0,  2);
  
  // Top light
  color topLightColor = color(90);
  directionalLight(red(topLightColor), blue(topLightColor), green(topLightColor), 0, 5, 0);

  
  ambientLight(red(ambientColor), green(ambientColor), blue(ambientColor));  
  background(backgroundColor);

  float eyeZ = 300 * sin(movementPhase);
  float eyeX = 300 * cos(movementPhase);
  movementPhase += 0.01;

  camera(eyeX, 10.0, eyeZ, // eyeX, eyeY, eyeZ
         0.0, 0.0, 0.0, // centerX, centerY, centerZ
         0.0, 1.0, 0.0); // upX, upY, upZ

  // Update velocity
  PVector randomVelocityVector = PVector.random3D().mult(RANDOM_ACCELERATION);
  velocityVector.add(randomVelocityVector);

  if (isGravityOn) {
    boolean isGravitySwitchingOff = GRAVITY_SWITCH_OFF_PROBABILITY > random(0.0, 1.0);
    if (isGravitySwitchingOff) {
      isGravityOn = false;
    }

    if (IS_VISUALIZING_GRAVITY) {
      fill(#e9ffdf);
      sphere(10.0);
    }
    
    PVector lastPointVector = linePointsVectorList.get(linePointsVectorList.size() - 1);
    PVector originPointVector = new PVector(0, 0, 0);

    PVector gravityAccelerationVector = PVector.sub(originPointVector, lastPointVector);
    gravityAccelerationVector.normalize().mult(GRAVITY_ACCELERATION);

    velocityVector.add(gravityAccelerationVector);
  } else {
    boolean isGravitySwitchingOn = GRAVITY_SWITCH_ON_PROBABILITY > random(0.0, 1.0);
    if (isGravitySwitchingOn) {
      isGravityOn = true;
    }
  }


  boolean isLineMaximumLength = linePointsVectorList.size() > RIBBON_LENGTH; 
  if (isLineMaximumLength) {
    linePointsVectorList.remove(0);
    twistPointsVectorList.remove(0);
  }

  PVector lastPointVector = linePointsVectorList.get(linePointsVectorList.size() - 1);
  PVector newPointVector = PVector.add(lastPointVector, velocityVector);
  
  // Avoid previously generated points. Skip the first several points in this calculation
  // so the ribbon doesn't tend to move in a straight line.
  for (int iPoint = 50; iPoint < linePointsVectorList.size() - 1; iPoint++) {
    PVector currentPoint = linePointsVectorList.get(iPoint);
    float newPointDistance = PVector.dist(newPointVector, currentPoint);

    boolean isPointWithinDistanceThreshold = newPointDistance < REPELLANCE_DISTANCE_THRESHOLD;
    if (isPointWithinDistanceThreshold) {
      PVector velocityUpdate = PVector.sub(newPointVector, currentPoint);
      velocityUpdate.mult(REPELLANCE_ACCELERATION / sq(newPointDistance));
      velocityVector.add(velocityUpdate);
    }
  }
  
  
  PVector newTwistPointVector = new PVector();
  newTwistPointVector.x = newPointVector.x + RIBBON_WIDTH * cos(1 * log(0 + 0.3) * movementPhase);
  newTwistPointVector.y = newPointVector.y + RIBBON_WIDTH * cos(1 * log(1 + 0.3) * movementPhase);
  newTwistPointVector.z = newPointVector.z + RIBBON_WIDTH * cos(1 * log(2 + 0.3) * movementPhase);

  // Limit to a cube
  boolean isNewPointXOutsideCube = newPointVector.x > X_CUBE_LIMIT || newPointVector.x < -X_CUBE_LIMIT;
  if (isNewPointXOutsideCube) {
    newPointVector.x = max(-X_CUBE_LIMIT, min(X_CUBE_LIMIT, newPointVector.x));
    velocityVector.x *= -CUBE_BOUNCE_COEFFICIENT;
  }

  boolean isNewPointYOutsideCube = newPointVector.y > Y_CUBE_LIMIT || newPointVector.y < -Y_CUBE_LIMIT;
  if (isNewPointYOutsideCube) {
    newPointVector.y = max(-Y_CUBE_LIMIT, min(Y_CUBE_LIMIT, newPointVector.y));
    velocityVector.y *= -CUBE_BOUNCE_COEFFICIENT;
  }

  boolean isNewPointZOutsideCube = newPointVector.z > Z_CUBE_LIMIT || newPointVector.z < -Z_CUBE_LIMIT;
  if (isNewPointZOutsideCube) {
    newPointVector.z = max(-Z_CUBE_LIMIT, min(Z_CUBE_LIMIT, newPointVector.z));
    velocityVector.z *= -CUBE_BOUNCE_COEFFICIENT;
  }

  velocityVector.limit(MAX_VELOCITY_MAGNITUDE);


  linePointsVectorList.add(newPointVector);
  twistPointsVectorList.add(newTwistPointVector);



  noStroke();
  for (int iPoint = 0; iPoint < linePointsVectorList.size() - 1; iPoint++) {

    PVector currentPointVector = linePointsVectorList.get(iPoint);
    PVector nextPointVector    = linePointsVectorList.get(iPoint + 1);
    
    PVector currentTwistVector = twistPointsVectorList.get(iPoint);
    PVector nextTwistVector    = twistPointsVectorList.get(iPoint + 1);

    for (int iRibbon = 0; iRibbon < 3; iRibbon++) {
      switch (iRibbon) {
        case 0:
          fill(ribbon1Color);
          break;
        case 1:
          fill(ribbon2Color);
          break;
        case 2:
          fill(ribbon3Color);
          break;
      }

      float ribbonSeparation = RIBBON_SEPARATION_DISTANCE * iRibbon;

      beginShape();
      vertex(currentPointVector.x, currentPointVector.y, currentPointVector.z + ribbonSeparation);
      vertex(currentTwistVector.x, currentTwistVector.y, currentTwistVector.z + ribbonSeparation);
      vertex(nextTwistVector.x,    nextTwistVector.y,    nextTwistVector.z    + ribbonSeparation);
      vertex(nextPointVector.x,    nextPointVector.y,    nextPointVector.z    + ribbonSeparation);
      vertex(currentPointVector.x, currentPointVector.y, currentPointVector.z + ribbonSeparation);
      endShape();
  
      // Draw shadow
      float yShadow = 100;
      fill(#4ad9d9);
      beginShape();
      vertex(currentPointVector.x, yShadow, currentPointVector.z + ribbonSeparation);
      vertex(currentTwistVector.x, yShadow, currentTwistVector.z + ribbonSeparation);
      vertex(nextTwistVector.x,    yShadow, nextTwistVector.z    + ribbonSeparation);
      vertex(nextPointVector.x,    yShadow, nextPointVector.z    + ribbonSeparation);
      vertex(currentPointVector.x, yShadow, currentPointVector.z + ribbonSeparation);
      endShape();
    }

  }

  // Draw base plane
  fill(#e9ffdf);
  beginShape();
  vertex( 120, 101,  120);
  vertex(-120, 101,  120);
  vertex(-120, 101, -120);
  vertex( 120, 101, -120);
  endShape();
  
  
  if (IS_IMAGE_SAVING_ON) {
    saveFrame("saved-frames/out-####.png");
    
    boolean is1MinuteSaved = frameCount >= 1800;
    if (is1MinuteSaved) {
      exit();
    }
  }
}
