#!/usr/bin/python
#
import spidev
import time
 
class SPI_TEST:
        def __init__(self, spi_channel=0):
                self.spi_channel = spi_channel
                self.conn = spidev.SpiDev(1, spi_channel)
                self.conn.max_speed_hz = 10000 # 10KHz
 
        def __del__( self ):
                self.close
 
        def close(self):
                if self.conn != None:
                        self.conn.close
                        self.conn = None
 
        def bitstring(self, n):
                s = bin(n)[2:]
                return '0'*(8-len(s)) + s

        def read8(self, cmd = 0x11):
                reply_bytes = self.conn.xfer2([cmd])
                print "rb:=%d" % (reply_bytes[0])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:7]
                return int(reply_bitstring, 2)

        def read64(self, cmd = 0x00, arg = [0,0,0,0,0,0,0]):

                reply_bytes = self.conn.xfer2([cmd] + arg)
                print "rb:=%d" % (reply_bytes[0])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:7]
                return int(reply_bitstring, 2)
 
        def read(self, cmd = 0x11, arg = 0):

                reply_bytes = self.conn.xfer2([cmd, arg])
                print "rb:=%X %X" % (reply_bytes[0], reply_bytes[1])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:15]
                return int(reply, 2)
 
import time
from time import sleep
if __name__ == '__main__':
        from sys import exit

        spi = SPI_TEST(0)

        a0 = spi.read(0x01, 0x00) #reset
#        time.sleep(2)
        a0 = spi.read(0x02, 0x33) #write cmd
        sleep(0.002)

        a0 = spi.read(0x03, 0x00) #read cmd
        sleep(0.002)
        a0 = spi.read(0x03, 0x00) #read cmd
        sleep(0.002)
        a0 = spi.read(0x03, 0x00) #read cmd
        sleep(0.002)
        a0 = spi.read(0x03, 0x00) #read cmd
        sleep(0.002)
        a0 = spi.read(0x03, 0x00) #read cmd
        sleep(0.002)
        a0 = spi.read(0x03, 0x00) #read cmd
        sleep(0.002)
        a0 = spi.read(0x04, 0x00) #read cmd

#        a0 = spi.read64(0x00)
#        print "b0=%8X" % (a0)

        print ""
        exit(0)
 
