from dibujo_ui import *
import time
from PyQt5 import QtWidgets
from PyQt5.QtGui import QPainter, QPen, QPixmap, QColor
import serial
import threading
#import puerto_serial as ps
import sys
coso = 0



class dibujo (QtWidgets.QMainWindow, Ui_MainWindow):
    
    def __init__ (self):
        super().__init__()
        self.setupUi(self)  
        
        self.pushButton_1.clicked.connect(self.apachado1)
        self.pushButton_2.clicked.connect(self.apachado2)
        self.pushButton_3.clicked.connect(self.apachado3)
        self.pushButton_4.clicked.connect(self.apachado4)
        enviarr = threading.Thread(daemon=True, target=secuencias)
        enviarr.start()

    def apachado1(self):
        try:
            global coso
            coso = 1
        except:
            print('no sirve')

    def apachado2(self):
        try:
            global coso
            coso = 2
        except:
            print('no sirve')
        
    def apachado3(self):
        try:
            global coso
            coso = 3
        except:
            print('no sirve')

    def apachado4(self):
        try:
            global coso
            coso = 4
        except:
            print('no sirve')
    def mensajes(self, serv1, serv2):
        if (serv2 >= 7):
            if (serv1 <= 3):
                self.label.setText('Feliz Navidad!!')
            else:
                pass
        elif (serv2 <= 3):
            if (serv1 >= 7):
                self.label.setText(':(')
            else:
                pass
        else:
            self.label.setText(':)')

    def yaa(self):
        self.update()

def secuencias():
    global coso, ventamain
    ser = serial.Serial(port="COM3",baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
    while(1):
        ser.flushOutput()
        
        ser.write(bytes.fromhex(hex(ord(str(coso)))[2:]))
        #print(ser.read())
        ser.flushInput()
        time.sleep(.3)
        ser.readline()
        try:
            servo = str(ser.readline()).split(',')
            servo1 = int(servo[0][2])
            servo2 = int(servo[1][0])
            ventanamain.mensajes(servo1, servo2)
            print(servo1, '\t', servo2)
        except:
            pass
        ventanamain.yaa()
        
aplication = QtWidgets.QApplication([])
ventanamain=dibujo()
ventanamain.show()
aplication.exec_()
