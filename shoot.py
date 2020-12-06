'''
Author: OldConcept
Date: 2020-12-04 22:58:11
LastEditors: OldConcept
LastEditTime: 2020-12-06 11:24:07
FilePath: \py\rm_server\shoot.py
'''
import apriltag
import cv2 as cv
import numpy as np
import threading
import sys
import Adafruit_PCA9685
import time
import RPi.GPIO as GPIO
import multiprocessing

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(18, GPIO.OUT)

pwm = Adafruit_PCA9685.PCA9685()
pwm.set_pwm_freq(50)
at_detector =  apriltag.Detector(apriltag.DetectorOptions(families='tag36h11'))

pwm_x_flag = 0
pwm_y_flag = 0
lastError_x = 0
lastError_y = 0
w_center = 320
h_center = 240
x_dutyCircle = 450
y_dutyCircle = 230
para_x = [lastError_x, x_dutyCircle]
para_y = [lastError_y, y_dutyCircle]

def position_init():
    pwm.set_pwm(9, 0, 450)
    time.sleep(0.005)
    pwm.set_pwm(8, 0, 230)

def set_pwm_x(center_param):
    err = w_center - center_param
    pwm_x = err * 0.02 + 0.008 * (err - para_x[0])
    para_x[0] = err
    para_x[1] += pwm_x

def set_pwm_y(center_param):
    err = h_center - center_param
    pwm_y = err * 0.02 + 0.008 * (err - para_y[0])
    para_y[0] = err
    para_y[1] += pwm_y

def fire(num):
    for i in range(num):
        GPIO.output(18, GPIO.HIGH)
        time.sleep(0.3)
        GPIO.output(18, GPIO.LOW)

def setServo(servoX, servoY):
    pwm.set_pwm(8, 0, servoX)
    time.sleep(0.01)
    pwm.set_pwm(9, 0, servoY)

def continousFire(continousFireFlagQueue):
    continousFireFlag = 0
    while True:
        if not continousFireFlagQueue.empty():
            continousFireFlag = continousFireFlagQueue.get()
        if continousFireFlag == 0:
            continue
        else:
            fire(1)
    
def shoot_byorder(shootOrderQueue, tagNumQueue, fireFlagQueue):
    cap = cv.VideoCapture(0)
    cap.set(3, 640)
    cap.set(4, 480)
    fireFlag = 0

    position_init()
    
    global pwm_x_flag
    global pwm_y_flag

    if cap.isOpened():
        print('Camera Feature normal')
    else:
        print('Camera Feature abnormal')

    while cap.isOpened():
        ret, frame = cap.read()
        gray = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)
        tags = at_detector.detect(gray)

        key = cv.waitKey(45)
        if key & 0x00FF == 27:
            break

        # 获取是否进行击靶标志位
        if not fireFlagQueue.empty():
            fireFlag = fireFlagQueue.get()

        # 获取击靶顺序
        if not shootOrderQueue.empty():
            shoot_order = shootOrderQueue.get()

        if fireFlag == 1:
            for tag in tags:
                if len(shoot_order) == 0:
                    break
                else:
                    if(tag.tag_id == shoot_order[0]):
                        if(pwm_x_flag != 2 or pwm_y_flag != 2):
                            threads = []
                            if abs(w_center - tag.center[0].astype(int)) < 6:
                                pwm_x_flag = 2
                                # print('x limited')
                            else:
                                pwm_x_flag = 1
                                t1 = threading.Thread(target=set_pwm_x, args=(tag.center[0],))
                                threads.append(t1)

                            if abs(h_center - tag.center[1].astype(int)) < 6:
                                pwm_y_flag = 2
                                # print('y limited')
                            else:
                                pwm_y_flag = 1
                                t2 = threading.Thread(target=set_pwm_y, args=(tag.center[1],))
                                threads.append(t2)
                            
                            for t in threads:
                                t.setDaemon(True)
                                t.start()
                                t.join()

                            if pwm_y_flag == 1:
                                pwm.set_pwm(8, 0, para_y[1].astype(int))
                                time.sleep(0.005)
                            if pwm_x_flag == 1:
                                pwm.set_pwm(9, 0, para_x[1].astype(int))
                                time.sleep(0.005)

                        elif(pwm_x_flag == 2 and pwm_y_flag == 2):
                            fire(5)
                            del shoot_order[0]
                            pwm_x_flag = 0
                            pwm_y_flag = 0
    
        # cv.imshow('capture', frame)
        # 写入当前画面apriltag数量
        try:
            tagNumQueue.put(len(tags), False)
        except:
            continue

    cap.release()
    cv.destroyAllWindows()
