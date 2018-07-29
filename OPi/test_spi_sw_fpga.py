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

        def read40(self, arg = [0,0,0,0], cmd = 0x00):  # 6 bytes
                reply_bytes = self.conn.xfer2(arg + [cmd])
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
#  4 - read DHT
#

import time
from time import sleep
if __name__ == '__main__':
      from sys import exit

      spi = SPI_TEST(0)

      a0 = spi.read8((0x04 << 4) | 0x01) #write get temp. from DHT11
      sleep(0.04)

      a0 = spi.read40([0,0,0,0], (0x03 << 4)) #read buffer : read 5 bytes
      sleep(0.002)
      print "DHT11: %40X" % (a0)
      print "DHT11: HUM: %.2f" % ((a0 >> 32) + (((a0 >> 24) & 0xFF) / 100.0))
      print "DHT11: TEMP: %.2f" % (((a0 >> 16) & 0xFF) + (((a0 >> 8) & 0xFF) / 100.0))

      csum = ((a0 >> 32) + ((a0 >> 24) & 0xFF) + ((a0 >> 16) & 0xFF) + (((a0 >> 8) & 0xFF)) & 0xFF)
      psum = (a0 & 0xFF);

      print "calculated sum: %2X received sum: %2X" % (csum, psum)
      exit(0)
 
