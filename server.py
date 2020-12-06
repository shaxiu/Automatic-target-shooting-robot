'''
Author: OldConcept
Date: 2020-12-04 07:37:29
LastEditors: OldConcept
LastEditTime: 2020-12-06 06:48:58
FilePath: \py\rm_server\server.py
'''
from flask import Flask, request, jsonify
import comm
import shoot
import threading
import multiprocessing

# 后端程序启动
app = Flask(__name__)

success_message = {
    "success": 1
}

value = [0, 0, 0, 0]
shoot_order = [0, 0, 0]

shootOrderQueue = multiprocessing.Queue(maxsize = 1)
tagNumQueue = multiprocessing.Queue(maxsize = 1)
fireFlagQueue = multiprocessing.Queue(maxsize = 1)
shootOrderQueue.put(shoot_order, False)
fireFlagQueue.put(0, False)
processDetect = multiprocessing.Process(target=shoot.shoot_byorder, args=(shootOrderQueue, tagNumQueue, fireFlagQueue))
processDetect.start()
print('TagDetectProcess start...')

continousFireFlagQueue = multiprocessing.Queue(maxsize = 1)
continousFireFlagQueue.put(0, False)
continousFireProcess = multiprocessing.Process(target=shoot.continousFire, args=(continousFireFlagQueue,))
continousFireProcess.start()
print('ContinousFireSystem start...')

# servoYQueue = multiprocessing.Queue(maxsize = 1)
# servoXQueue = multiprocessing.Queue(maxsize = 1)
# setServoFlagQueue = multiprocessing.Queue(maxsize = 1)
# setServoFlagQueue.put(0, False)

@app.route('/test', methods=['GET'])
def test():
    if request.method == "GET":
        return jsonify(success_message)

@app.route('/setSpeed', methods=['GET'])
def setSpeed():
    if request.method == "GET":
        motor_1 = request.args.get("motor1")
        motor_2 = request.args.get("motor2")
        value[0] = int(motor_1)
        value[1] = int(motor_2)
        # 调用串口发送函数给下位机发送速度数据
        comm.transferParam(0, value)
        return jsonify(success_message)

@app.route('/fire', methods=['GET'])
def fire():
    if request.method == "GET":
        first_tag = request.args.get("tag1")
        second_tag = request.args.get("tag2")
        third_tag = request.args.get("tag3")
        shoot_order[0] = int(first_tag)
        shoot_order[1] = int(second_tag)
        shoot_order[2] = int(third_tag)
        # TODO
        # 调用射击函数
        try:
            shootOrderQueue.put(shoot_order, False)
            fireFlagQueue.put(1, False)
        except:
            shootOrderQueue.get()
            shootOrderQueue.put(shoot_order, False)
            fireFlagQueue.get()
            fireFlagQueue.put(1, False)
        return jsonify(success_message)

@app.route('/ceasefire', methods=['GET'])
def ceasefire():
    if request.method == "GET":
        # TODO
        # 设置全局标志，放在while处理每一帧图像之前处理，标志位为真再进行图像处理
        try:
            fireFlagQueue.put(0, False)
        except:
            fireFlagQueue.get()
            fireFlagQueue.put(0, False)
        return jsonify(success_message)

@app.route('/checkTagNum', methods=['GET'])
def checkTagNum():
    if request.method == "GET":
        # TODO
        # 调用api返回当前时刻摄像头中的tag数量
        if not tagNumQueue.empty():
            tagNum = tagNumQueue.get()
            return jsonify({
                "tagNum": tagNum
            })
        else:
            return jsonify({
                "failed": 1
            })

@app.route('/servo', methods=['GET'])
def setServo():
    if request.method == "GET":
        servo1 = request.args.get("servo1")
        servo2 = request.args.get("servo2")
        up_pwm = 260 - int(servo1)
        dowm_pwm = int(510 - int(servo2)*1.2)
        setServoProcess = multiprocessing.Process(target=shoot.setServo, args=(up_pwm, dowm_pwm))
        setServoProcess.start()
        return jsonify(success_message)

@app.route('/shooting', methods=['GET'])
def shooting():
    if request.method == "GET":
        flag = request.args.get("flag")
        flag = int(flag)
        if flag == 0:
            try:
                continousFireFlagQueue.put(0, False)
            except:
                continousFireFlagQueue.get()
                continousFireFlagQueue.put(0, False)
        else:
            try:
                continousFireFlagQueue.put(1, False)
            except:
                continousFireFlagQueue.get()
                continousFireFlagQueue.put(1, False)
        return jsonify(success_message)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=9600)
    print("server down")