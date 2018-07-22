SPI <> 1wire interface for Orange Pi Zero.

===

accessing SPI in linux examples

python:
http://codelectron.com/how-to-get-analog-input-for-orange-pi-zero-using-mcp3208/
c:
https://www.emcraft.com/som/stm32f7-212/accessing-spi-devices-in-linux

===
OPi zero configuration.

enable spi
https://docs.armbian.com/Hardware_Allwinner_overlays/

less /boot/dtb/overlay/README.sun8i-h3-overlays
/boot/armbianEnv.txt

tar -zxf spidev-3.2.tar.gz
cd spidev-3.2/
python setup.py build
python setup.py install

===
OPi Zero pins

SPI 1 pins (MOSI, MISO, SCK, CS): PA15, PA16, PA14, PA13
                    pin
MOSI  PA15  green   19
MISO  PA16  yellow  21
SCK   PA14  orange  23
CS    PA13  red     24
GND         blue    25
5V          brown   2

===

ENC28J60

5V      -   brown   2
GND     -   black   25
INT
CLK
SO      -   yellow  21 MISO PA16
WOL
SCK     -   orange  23 SCK  PA14
ST(SI)  -   green   19 MOSI PA15
RST
CS      -   red     24 CS   PA13
Q3
GND

===
MAXII

+5      -   brown   2
GND     -   black   25

MISO    -   yellow  57 MISO PA16
SCK     -   orange  55 SCK  PA14
MOSI    -   green   58 MOSI PA15
CS      -   red     56 CS   PA13

===
CIV

GND       CON26A 3    GND         blue    25
HSYNC     CON26A 8    SCK   PA14  orange  23
VSYNC     CON26A 7    CS    PA13  red     24
PS2_DAT   CON26A 5    MOSI  PA15  green   19
PS2_CLK   CON26A 6    MISO  PA16  yellow  21
VB0       CON26A 10   wire_out
VB2       CON26A 9    wire_in    (connected to wire_out)

===
STM32

GND     -   black   G

MISO    -   yellow  PA6 MISO PA16
SCK     -   orange  PA5 SCK  PA14
MOSI    -   green   PA7 MOSI PA15
CS      -   red     PA4 CS   PA13
1WIRE   -   white   PA0
