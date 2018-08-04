install python SPI library
 spidev-3.2.tar.gz

===

DS18B20:
 
root@orangepizero:~/1w# python test_spi_1w_fpga_mb.py

===
usage .c example:

gcc -o spi spi.c
./spi /dev/spidev1.0


===
single wire DHT11 sensor (https://www.mouser.com/ds/2/758/DHT11-Technical-Data-Sheet-Translated-Version-1143054.pdf)

example: test_spi_sw_fpga.py

===
photo of china and original ICs:
original-left-china-right.JPG

'China' DS18B20:
no NVRAM and no possibility set ADC accuracy:

after power up:

root@orangepizero:~/1w# python test_spi_1w_fpga_mb.py
SN: 286164123388B709
CONVERT T
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 80
READ SCRATHPAD
read data
scratchpad: 6201FFFF7FFFFFFF
scratchpad CRC: 91
temperature 22.12


set 12bit ADC

root@orangepizero:~/1w# python test_spi_1w_wr_scrathpad.py
SN: 286164123388B709
WRITE SCRTCHPAD
COPY SCRATCHPAD
copy status
copy status: 80
READ SCRATHPAD
read data
scratchpad: 630105A07FFFFFFF
scratchpad CRC: 95
temperature 22.19

no changes:

root@orangepizero:~/1w# python test_spi_1w_fpga_mb.py
SN: 286164123388B709
CONVERT T
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 80
READ SCRATHPAD
read data
scratchpad: 600105A07FFFFFFF
scratchpad CRC: 50
temperature 22.00


===
Original Maxim DS18B20

after power up:

root@orangepizero:~/1w# python test_spi_1w_fpga_mb.py
SN: 28C235470A0000B5
CONVERT T
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 80
READ SCRATHPAD
read data
scratchpad: 630105A07FFF0D10
scratchpad CRC: 35
temperature 22.19


set 9 bit ADC:

root@orangepizero:~/1w# python test_spi_1w_wr_scrathpad.py
SN: 28C235470A0000B5
WRITE SCRTCHPAD
COPY SCRATCHPAD
copy status
copy status: 80
READ SCRATHPAD
read data
scratchpad: 620105A01FFF0E10
scratchpad CRC: B3
temperature 22.12


root@orangepizero:~/1w# python test_spi_1w_fpga_mb.py
SN: 28C235470A0000B5
CONVERT T
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 00
read conv.status
conv.status: 80
READ SCRATHPAD
read data
scratchpad: 680105A01FFF0810
scratchpad CRC: B5
temperature 22.50
