#include <Wire.h>
#include <Servo.h>

const int STATE_R = 1;
const int STATE_L = 2;
const int STATE_r = 3;
const int STATE_l = 4;
const int STATE_U = 5;
const int STATE_D = 6;

const int L_PWM = 5; // ENA
const int R_BACK = 4; // IN1
const int R_FORWARD = 3; // IN2
const int R_PWM = 6; // ENB
const int L_FORWARD = 7; // IN3
const int L_BACK = 8; // IN4
const int servo1 = 9;
const int servo2 = 10;

Servo myservo1;
Servo myservo2;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Wire.begin(4);                // join i2c bus with address #4
  Wire.onReceive(receiveEvent); // register event
  pinMode(R_PWM, OUTPUT);
  pinMode(L_PWM, OUTPUT);
  pinMode(L_BACK, OUTPUT);
  pinMode(L_FORWARD, OUTPUT);
  pinMode(R_BACK, OUTPUT);
  pinMode(R_FORWARD, OUTPUT);

  myservo1.attach(servo1);
  myservo2.attach(servo2);
    myservo1.writeMicroseconds(1000);
 myservo2.writeMicroseconds(2400);
}

void loop() {
//  for(int i = 0; i < 3000; i++ ) {
//     myservo2.writeMicroseconds(i);
//     Serial.println(i);
//     delay(1);
//  }
//    for(int i = 2400; i > 600; i--) {
//     myservo2.writeMicroseconds(i);
//     Serial.println(i);
//     delay(3);
//  }
//  for(int i = 30; i < 150; i ++ ) {
//     myservo1.write(i);
//     delay(20);
//  }
//    for(int i = 150; i > 30; i -- ) {
//     myservo1.write(i);
//     delay(20);
//  }
  delay(100);
}

void receiveEvent(int howMany)
{
  while (0 < Wire.available())
  {
    int x = Wire.read();
    handleReceive(x);
  }
}

void moveR(int x) {
  Serial.print("move r:");
  Serial.println(x);
  if ( x == 0) {
    digitalWrite(L_BACK, 0);
    digitalWrite(L_FORWARD, 0);
  } else if (x < 0) {
    digitalWrite(L_BACK, 1);
    digitalWrite(L_FORWARD, 0);
  } else {
    digitalWrite(L_BACK, 0);
    digitalWrite(L_FORWARD, 1);
  }

  analogWrite(R_PWM, abs(x));
}

void moveL(int x) {
  Serial.print("move l:");
  Serial.println(x);
  if ( x == 0) {
    digitalWrite(R_BACK, 0);
    digitalWrite(R_FORWARD, 0);
  } else if (x < 0) {
    digitalWrite(R_BACK, 1);
    digitalWrite(R_FORWARD, 0);
  } else {
    digitalWrite(R_BACK, 0);
    digitalWrite(R_FORWARD, 1);
  }

  analogWrite(L_PWM, abs(x));
}

void handleReceive(int x)
{
  static int state = 0;

  if (state == 0) {
    switch (x) {
      case 'R': state = STATE_R; break;
      case 'r': state = STATE_r; break;
      case 'L': state = STATE_L; break;
      case 'l': state = STATE_l; break;
      case 'U': state = STATE_U; break;
      case 'D': state = STATE_D; break;
      case 'O': state = 0;
    }
  } else {
    switch (state) {
      case STATE_L: moveL(x); break;
      case STATE_l: moveL(-x); break;
      case STATE_R: moveR(x); break;
      case STATE_r: moveR(-x);
      case STATE_U: myservo1.write(x);
      case STATE_D: myservo2.write(x);
    }
    state = 0;
  }
}
