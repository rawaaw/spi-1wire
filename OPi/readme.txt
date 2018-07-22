install python SPI library
 spidev-3.2.tar.gz

root@orangepizero:~/1w# python test_spi_1w_fpga.py
rb:=BD 0
rbs:=1011110100000000
rb:=BD 0
rbs:=1011110100000000
rb:=BD 0
rbs:=1011110100000000
rb:=28 0                -- S/N->
rbs:=0010100000000000
rb:=61 0
rbs:=0110000100000000
rb:=64 0
rbs:=0110010000000000
rb:=12 0
rbs:=0001001000000000
rb:=33 0
rbs:=0011001100000000
rb:=BD 0                -- S/N<-
rbs:=1011110100000000

===
usage .c example:

gcc -o spi spi.c
./spi /dev/spidev1.0
