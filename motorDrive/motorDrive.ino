#include <Arduino.h>
#include <Servo.h>

const int STATE_END = 0;
const int STATE_OP = 1;
const int STATE_NUM = 2;
int state = 0, op = 0, opNum;

const int R_PWM = 5; // ENA
const int R_BACK = 4; // IN1
const int R_FORWARD = 3; // IN2
const int L_PWM = 6; // ENB
const int L_FORWARD = 7; // IN3
const int L_BACK = 8; // IN4
const int servo1 = 9;
const int servo2 = 10;
const int maxSpeed = 65;

Servo myservo1;
Servo myservo2;

void setup() {
  Serial.begin(115200);
  pinMode(R_PWM, OUTPUT);
  pinMode(L_PWM, OUTPUT);
  pinMode(L_BACK, OUTPUT);
  pinMode(L_FORWARD, OUTPUT);
  pinMode(R_BACK, OUTPUT);
  pinMode(R_FORWARD, OUTPUT);

  myservo1.attach(servo1);
  myservo2.attach(servo2);
}

void loop() {
  if (Serial.available() > 0) {
    char ch = Serial.read();
    handleReceive(ch);
  }
}

void moveL(int x) {
  Serial.print("move r:");
  Serial.println(x);
  digitalWrite(L_BACK, x < 0);
  digitalWrite(L_FORWARD, x > 0);
  analogWrite(L_PWM, abs(x));
}

void moveR(int x) {
  digitalWrite(R_BACK, x < 0);
  digitalWrite(R_FORWARD, x > 0);
  analogWrite(R_PWM, abs(x));
}

void handleReceive(char x)
{
  if (x == 'M') {
    state = STATE_OP;
    op = opNum = 0;
  } else if (x == ';') {
    state = STATE_END;
    switch (op)
    {
      case 1: moveL(opNum * maxSpeed / 100); break;
      case 2: moveR(-opNum * maxSpeed / 100); break;
      case 3: moveL(-opNum * maxSpeed / 100); break;
      case 4: moveR(opNum * maxSpeed / 100); break;
      case 5: myservo1.write(opNum); break;
      case 6: myservo2.write(opNum); break;
      default:
        break;
    }
  } else if (state == STATE_OP) {
    if (x == ',') {
      state = STATE_NUM;
      return;
    }
    op *= 10;
    op += x - '0';
  } else if (state == STATE_NUM) {
    opNum *= 10;
    opNum += x - '0';
  }
}
