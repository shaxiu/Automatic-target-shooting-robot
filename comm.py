'''
Author: OldConcept
Date: 2020-12-04 09:26:20
LastEditors: OldConcept
LastEditTime: 2020-12-06 00:45:10
FilePath: \py\rm_server\comm.py
'''
import serial
import serial.tools.list_ports
import time
import threading

portx_1 = "/dev/ttyUSB0"
portx_2 = "/dev/ttyUSB1"
bps = 115200
timex = None
try:
    ser = serial.Serial(portx_1, bps, timeout = timex)
except:
    ser = serial.Serial(portx_2, bps, timeout = timex)

# type = {0, 1}
# value = [0, 0, 0, 0]
# 0表示给下位机传递电机速度控制小车，传入的值为一个数组

def sendData(str):
    ser.write(str.encode())

def transferParam(type, value):
    threads = []
    if type == 0:
        if value[0] > 0:
            t1 = threading.Thread(target=sendData, args=('M01,'+'{:0>3d}'.format(value[0])+';',))
        else:
            value[0] = abs(value[0])
            t1 = threading.Thread(target=sendData, args=('M03,'+'{:0>3d}'.format(value[0])+';',))
        if value[1] > 0:
            t2 = threading.Thread(target=sendData, args=('M02,'+'{:0>3d}'.format(value[1])+';',))
        else:
            value[1] = abs(value[1])
            t2 = threading.Thread(target=sendData, args=('M04,'+'{:0>3d}'.format(value[1])+';',))
        threads.append(t1)
        threads.append(t2)
    if type == 1:
        t1 = threading.Thread(target=sendData, args=('M09,'+'{:0>3d}'.format(value[0])+';',))
        t2 = threading.Thread(target=sendData, args=('M10,'+'{:0>3d}'.format(value[1])+';',))
        threads.append(t1)
        threads.append(t2)
    for t in threads:
        t.setDaemon(True)
        t.start()
        t.join()

def test(value):
    for v in value:
        print(v)
