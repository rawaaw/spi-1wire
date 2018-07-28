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

        def read8(self, cmd = 0x00):
                reply_bytes = self.conn.xfer2([cmd])
                print "rb:=%d" % (reply_bytes[0])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:7]
                return int(reply_bitstring, 2)

        def read48(self, arg = [0,0,0,0,0], cmd = 0x00):  # 6 bytes
                reply_bytes = self.conn.xfer2(arg + [cmd])
                print "rb:=%d" % (reply_bytes[0])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:7]
                return int(reply_bitstring, 2)

        def read64(self, arg = [0,0,0,0,0,0,0], cmd = 0x00):

                reply_bytes = self.conn.xfer2(arg + [cmd])
                print "rb:=%d" % (reply_bytes[0])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:7]
                return int(reply_bitstring, 2)
 
        def read(self, arg = 0, cmd = 0x00):

                reply_bytes = self.conn.xfer2([arg, cmd])
                print "rb:=%X %X" % (reply_bytes[0], reply_bytes[1])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:15]
                return int(reply, 2)
 

#
#  SPI: [MS byte] ...[MS byte] [LS byte]
#          args      1wire cmd  (cmd << 4) | (width & 0Fh)
#
#  CMD:
#  0 - reset
#  1 - write
#  2 - read (read previous value of the buffer and send command to 1wire device)
#  3 - read buf (read previous value of the buffer w/o intechange with 1wire device)
#  4 - reset read buffer
#
#  width:
#  0,1,2,3,4,5,6,7,8 - 0 - 1bit or 1-8 bytes per cycle

import time
from time import sleep
if __name__ == '__main__':
      from sys import exit

      spi = SPI_TEST(0)

      a0 = spi.read8(0x00) #reset
      time.sleep(0.002)

      a0 = spi.read(0xCC, (0x01 << 4) | 0x01) #write cmd SKIP ROM (1 byte)
      sleep(0.002)


      if (1):
        print "CONVERT T"
        a0 = spi.read(0x44, (0x01 << 4) | 0x01) #write cmd CONVERT T

#        sleep(0.002)
#        print "read conv.status"
#        a0 = spi.read8((0x02 << 4) | 0x00) #read conv.status
#        sleep(0.002)
#        a0 = spi.read8((0x03 << 4) | 0x00) #read conv.status buffer
#        print "conv.status: %8X" % (a0)
#        sleep(0.002)

        sleep(0.4)

#        print "read conv.status"
#        a0 = spi.read8((0x02 << 4) | 0x01) #read conv.status
#        sleep(0.002)

#        a0 = spi.read8((0x03 << 4) | 0x01) #read buffer cmd
#        print "read conv.status %.1X" % (a0)
#        sleep(0.002)

      print "READ SCRATHPAD"
      a0 = spi.read(0xBE, (0x01 << 4) | 0x01) #write cmd READ SCRATHPAD
      sleep(0.002)

      print "read data"
      a0 = spi.read(0x00, (0x02 << 4) | 0x08) #read cmd (scratchpad data)
      sleep(0.008) # >= 8ms
      a0 = spi.read64([0,0,0,0,0,0,0], (0x03 << 4) | 0x08) #read buffer : read 8 bytes
      sleep(0.002)
      print "scratchpad: %64X" % (a0)

      print ""
      exit(0)
 
