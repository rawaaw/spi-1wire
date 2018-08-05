#!/usr/bin/python
#
#
# test for stm32 interconnect
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

  def read64(self, arg = [0,0,0,0,0,0,0], cmd = 0x00):
    reply_bytes = self.conn.xfer2(arg + [cmd])
    return ((reply_bytes[0]<<56) | (reply_bytes[1]<<48) | (reply_bytes[2]<<40) | (reply_bytes[3]<<32) | 
            (reply_bytes[4]<<24) | (reply_bytes[5]<<16) | (reply_bytes[6]<<8) | (reply_bytes[7]))

  def read(self, cmd = 0x11, arg = 0):
    reply_bytes = self.conn.xfer2([cmd, arg])
    reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
    reply = reply_bitstring[0:15]
    return int(reply, 2)

  # https://stackoverflow.com/questions/29214301/ios-how-to-calculate-crc-8-dallas-maxim-of-nsdata
  def dallas_crc8(self, data=0, size=1):
    crc = 0
    for i in range (0, (size)):
      inbyte = data >> ((size - i - 1) << 3)
      for j in range (0, 8):
        mix = (crc ^ inbyte) & 0x01
        crc = crc >> 1
        if (mix):
          crc = crc ^ 0x8C
        inbyte = inbyte >> 1
    return int(crc)

 
import time
if __name__ == '__main__':
  from sys import exit

  spi = SPI_TEST(0)

  a0 = spi.read8(0x00)
  time.sleep(2)
  scrp = spi.read64()
  crc = spi.read8(0x00)
  print "scratchpad: %.16X" % (scrp)
  print "scratchpad CRC: %.2X" % (crc)
  print "calculated CRC: %.2X" % (spi.dallas_crc8(scrp, 8))

  msb = (scrp >> 48) & 0xFF;
  lsb = (scrp >> 56) & 0xFF;
  print "temperature %.2f" % (((msb << 8) | lsb) * 0.0625)

  print ""
  exit(0)
