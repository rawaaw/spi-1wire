#!/usr/bin/python
#
import spidev
import time
 
class SPI_TEST:
        def __init__(self, spi_channel=0):
                self.spi_channel = spi_channel
                self.conn = spidev.SpiDev(1, spi_channel)
                self.conn.max_speed_hz = 500000 # 500KHz
 
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
#                print "rb:=%d" % (reply_bytes[0])
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
#                print "rbs:=%s" % (reply_bitstring)
                reply = reply_bitstring[0:7]
                return int(reply_bitstring, 2)
 
        def read(self, cmd = 0x11, arg = 0):
                # build command
 
                # send & receive data
                reply_bytes = self.conn.xfer2([cmd, arg])
 
                #
                reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
                # print reply_bitstring
 
                # see also... http://akizukidenshi.com/download/MCP3204.pdf (page.20)
                reply = reply_bitstring[7:19]
                return int(reply, 2)
 
if __name__ == '__main__':
        from sys import exit

        spi = SPI_TEST(0)

        try:
          i = 0;
#          while(i < 256):
          while(1):
            a0 = spi.read8( i & 0xFF)
            time.sleep(1)
#            a0 = spi.read8(0x23)
  #          a0 = spi.read8(0x7E)
            if (a0 != 0xA5):
              print "error %X %X" % (a0, i)
  #          print "b0=%8X" % (a0)
            i = i+1;
        except:
          pass
        print ""
        exit(0)
