// This is for final project


#include <Wire.h>
#include <Servo.h>
Servo servo0;
Servo servo1;
Servo servo2;

// device address
#define MPU 0x68
#define VCL 0x13
// device sub address
#define ACCLX 0x3B
#define ACCLY 0x3D
#define ACCLZ 0x3F
#define GYROX 0x43
#define GYROY 0x45
#define LIDA 0x07
// config constants
#define gyro 131.0
#define accel 16384.0
// config address
#define GyroCon 0x1B
#define AcceCon 0x1C
#define fifo 0x23


float AcX,AcY,AcZ,GyX,GyY;
int16_t LaR;
long prevT = 0;
int Pitch = 0;
int Roll = 0;
float heave = 0;
float angleP = 0;
float angleR = 0;
float alpha = 0.97;

void setup() {
  Serial.begin(9600);
  Serial.print("Red");
  //setConfig(MPU,GyroCon,0x00);
  //setConfig(MPU,AcceCon,0x00);
  //setConfig(MPU,fifo,0x00);
  //setConfig(MPU,0x6B,0x08);
  servo0.attach(9,500,2500);
  servo1.attach(10,500,2500);
  servo2.attach(11,500,2500);





}

void loop() {
// read input then read sensor values with comp filter.
// calculate pitch, roll and heave
// pitch is s1 then negative s2 and s3
// roll is s3 then negative s2
// heave is s1 s2 s3

  long currT = micros();
  float deltaT = ((float) (currT - prevT))/( 1.0e6 );
  prevT = currT;
  AcX = dataRead(MPU,ACCLX)/accel;
  AcY = dataRead(MPU,ACCLY)/accel;
  AcZ = dataRead(MPU,ACCLZ)/accel;
  GyX = dataRead(MPU,GYROX)/gyro;
  GyY = dataRead(MPU,GYROY)/gyro;
  LaR = dataRead(VCL,LIDA);

  float accP = atan2(AcX,AcZ) *180/PI; // acceleration of angle 
  float accR = atan2(AcY,AcZ) *180/PI;
  // complementray filter for angle
  angleP = alpha * angleP + (1.0 - alpha)*accP;
  angleR = alpha * angleR + (1.0 - alpha)*accR;







}


uint16_t dataRead(int device,int REG){     // this function is used for reading 2 byte data from mpu, plug hex value of high
  Wire.beginTransmission(device);
  Wire.write(REG);
  Wire.endTransmission(false);
  Wire.requestFrom(device,2,true);
  uint16_t tempValue = Wire.read()<<8|Wire.read();
  return tempValue;
}
void setConfig(int dev, int address, int Value){    // this fnction is used for writing 1 byte data to mpu, use hex, binary or value
  Wire.beginTransmission(dev);
  Wire.write(address);
  Wire.write(Value);
  Wire.endTransmission(true);
}
