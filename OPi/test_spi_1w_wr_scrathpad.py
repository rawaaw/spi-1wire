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
                return reply_bytes[0]

        def read48(self, arg = [0,0,0,0,0], cmd = 0x00):  # 6 bytes
                reply_bytes = self.conn.xfer2(arg + [cmd])
#                print "rb:=%d" % (len(reply_bytes))
                return ((reply_bytes[5]<<40) | (reply_bytes[4]<<32) | 
                        (reply_bytes[3]<<24) | (reply_bytes[2]<<16) | (reply_bytes[1]<<8) | (reply_bytes[0]))

        def read64(self, arg = [0,0,0,0,0,0,0], cmd = 0x00):

                reply_bytes = self.conn.xfer2(arg + [cmd])
#                print "rb:=%d" % (len(reply_bytes))
                return ((reply_bytes[7]<<56) | (reply_bytes[6]<<48) | (reply_bytes[5]<<40) | (reply_bytes[4]<<32) | 
                        (reply_bytes[3]<<24) | (reply_bytes[2]<<16) | (reply_bytes[1]<<8) | (reply_bytes[0]))
 
        def read(self, arg = 0, cmd = 0x00):

                reply_bytes = self.conn.xfer2([arg, cmd])
#                print "rb:=%X %X" % (reply_bytes[0], reply_bytes[1])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
#                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:15]
                return int(reply, 2)
 
        def dallas_crc8(self, data=0, size=1):
          crc = 0
          for i in range (0, (size)):
#            print "i:%d shift:%d" % (i, ((size - i - 1) << 3))
            inbyte = data >> ((size - i - 1) << 3)
            for j in range (0, 8):
              mix = (crc ^ inbyte) & 0x01
              crc = crc >> 1
              if (mix):
                crc = crc ^ 0x8C
              inbyte = inbyte >> 1
          return int(crc)

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

      a0 = spi.read(0x33, (0x01 << 4) | 0x01) #write cmd READ ROM (1 byte)
      sleep(0.002)
      a0 = spi.read8((0x02 << 4) | 0x08) #read cmd : read 8 bytes from 1wire device
      sleep(0.008) # >= 8ms 
      a0 = spi.read64([0,0,0,0,0,0,0], (0x03 << 4) | 0x08) #read buffer : read 8 bytes
      sleep(0.002)
      print "SN: %.16X" % (a0)
      print "calculated CRC: %.2X" % (spi.dallas_crc8((a0 >> 8), 7))
      print "WRITE SCRTCHPAD"
      a0 = spi.read(0x4E, (0x01 << 4) | 0x01) #write cmd WRITE SCRATHPAD
      sleep(0.002)
      a0 = spi.read(0x05, (0x01 << 4) | 0x01) #write Th
      sleep(0.002)
      a0 = spi.read(0xA0, (0x01 << 4) | 0x01) #write Tl
      sleep(0.002)
      a0 = spi.read((0x3 << 5) | 0x1F, (0x01 << 4) | 0x01) #write CONF REG (12 bit ADC)
#      a0 = spi.read((0x2 << 5) | 0x1F, (0x01 << 4) | 0x01) #write CONF REG (11 bit ADC)
#      a0 = spi.read((0x1 << 5) | 0x1F, (0x01 << 4) | 0x01) #write CONF REG (10 bit ADC)
#      a0 = spi.read((0x0 << 5) | 0x1F, (0x01 << 4) | 0x01) #write CONF REG (9 bit ADC)
      sleep(0.002)

      print ""
      a0 = spi.read8(0x00) #reset
      time.sleep(0.002)

      a0 = spi.read(0x33, (0x01 << 4) | 0x01) #write cmd READ ROM (1 byte)
      sleep(0.002)
      a0 = spi.read8((0x02 << 4) | 0x08) #read cmd : read 8 bytes from 1wire device
      sleep(0.008) # >= 8ms 
      a0 = spi.read64([0,0,0,0,0,0,0], (0x03 << 4) | 0x08) #read buffer : read 8 bytes
      sleep(0.002)
      print "SN: %.16X" % (a0)
      print "calculated CRC: %.2X" % (spi.dallas_crc8((a0 >> 8), 7))

      print "READ SCRATHPAD"
      a0 = spi.read(0xBE, (0x01 << 4) | 0x01) #write cmd READ SCRATHPAD
      sleep(0.002)

      print "read data"
      a0 = spi.read(0x00, (0x02 << 4) | 0x08) #read cmd (scratchpad data)
      sleep(0.008) # >= 8ms
      scrp = spi.read64([0,0,0,0,0,0,0], (0x03 << 4) | 0x08) #read buffer : read 8 bytes
      print "scratchpad: %.16X" % (scrp)
      sleep(0.002)

      a0 = spi.read8((0x02 << 4) | 0x01) #read cmd (scratchpad data CRC)
      sleep(0.002) # >= 2ms
      a0 = spi.read8((0x03 << 4) | 0x01) #read buffer (scratchpad data CRC)
      print "scratchpad CRC: %.2X" % ((a0) & 0xFF)  #http://crccalc.com/ (CRC-8/MAXIM)
      print "calculated CRC: %.2X" % (spi.dallas_crc8(scrp, 8))

      print ""
      a0 = spi.read8(0x00) #reset
      time.sleep(0.002)

      a0 = spi.read(0x33, (0x01 << 4) | 0x01) #write cmd READ ROM (1 byte)
      sleep(0.002)
      a0 = spi.read8((0x02 << 4) | 0x08) #read cmd : read 8 bytes from 1wire device
      sleep(0.008) # >= 8ms 
      a0 = spi.read64([0,0,0,0,0,0,0], (0x03 << 4) | 0x08) #read buffer : read 8 bytes
      sleep(0.002)
      print "SN: %.16X" % (a0)
      print "calculated CRC: %.2X" % (spi.dallas_crc8((a0 >> 8), 7))

      print "COPY SCRATCHPAD"
      a0 = spi.read(0x48, (0x01 << 4) | 0x01) #write cmd COPY SCRATHPAD


      sleep(0.002)
      print "copy status"
      a0 = spi.read8((0x02 << 4) | 0x00) #read conv.status (1bit)
      sleep(0.002)
      a0 = spi.read8((0x03 << 4) | 0x00) #read conv.status buffer
      print "copy status: %.2X" % (a0)
      sleep(0.002)
      while (a0 != 0x80):
        print "copy status"
        a0 = spi.read8((0x02 << 4) | 0x00) #read conv.status
        sleep(0.002)
        a0 = spi.read8((0x03 << 4) | 0x00) #read conv.status buffer
        print "copy status: %.2X" % (a0)
        sleep(0.002)

      print ""
      a0 = spi.read8(0x00) #reset
      time.sleep(0.002)

      a0 = spi.read(0x33, (0x01 << 4) | 0x01) #write cmd READ ROM (1 byte)
      sleep(0.002)
      a0 = spi.read8((0x02 << 4) | 0x08) #read cmd : read 8 bytes from 1wire device
      sleep(0.008) # >= 8ms 
      a0 = spi.read64([0,0,0,0,0,0,0], (0x03 << 4) | 0x08) #read buffer : read 8 bytes
      sleep(0.002)
      print "SN: %.16X" % (a0)
      print "calculated CRC: %.2X" % (spi.dallas_crc8((a0 >> 8), 7))

      print "READ SCRATHPAD"
      a0 = spi.read(0xBE, (0x01 << 4) | 0x01) #write cmd READ SCRATHPAD
      sleep(0.002)

      print "read data"
      a0 = spi.read(0x00, (0x02 << 4) | 0x08) #read cmd (scratchpad data)
      sleep(0.008) # >= 8ms
      scrp = spi.read64([0,0,0,0,0,0,0], (0x03 << 4) | 0x08) #read buffer : read 8 bytes
      print "scratchpad: %.16X" % (scrp)
      sleep(0.002)

      a0 = spi.read8((0x02 << 4) | 0x01) #read cmd (scratchpad data CRC)
      sleep(0.002) # >= 2ms
      a0 = spi.read8((0x03 << 4) | 0x01) #read buffer (scratchpad data CRC)
      print "scratchpad CRC: %.2X" % ((a0) & 0xFF)  #http://crccalc.com/ (CRC-8/MAXIM)
      print "calculated CRC: %.2X" % (spi.dallas_crc8(scrp, 8))

      print ""
      exit(0)
 
