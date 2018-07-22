/* 
* Sample application that makes use of the SPIDEV interface
* to access an SPI slave device. Specifically, this sample
* reads a Device ID of a JEDEC-compliant SPI Flash device.
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

int main(int argc, char **argv){

  char *name;
  int fd;
  struct spi_ioc_transfer xfer[2];
  unsigned char tx_buf[32], *bp;
  unsigned char rx_buf[32];
  int len, status;
  int i = 0;

  name = argv[1];
  fd = open(name, O_RDWR);
  if (fd < 0) {
    perror("open");
    return 1;
  }

  memset(xfer, 0, sizeof xfer);
  memset(tx_buf, 0, sizeof tx_buf);
  memset(rx_buf, 0, sizeof rx_buf);
  len = 0;

  /*
  * Send a GetID command
  */
  i = 0;
  while (1){
    tx_buf[0] = 0x1f;
    len = 1;
    xfer[0].tx_buf = (unsigned long)tx_buf;
    xfer[0].rx_buf = (unsigned long)rx_buf;
    xfer[0].len = 1;

  //  xfer[1].rx_buf = (unsigned long)rx_buf;
  //  xfer[1].len = 1;

    status = ioctl(fd, SPI_IOC_MESSAGE(1), xfer);
    if (status < 0) {
      perror("SPI_IOC_MESSAGE");
      return -1;
    }
    if (((unsigned char*)(xfer[0].rx_buf))[0] != 0x7e){
      printf ("%x %d\n", ((unsigned char*)(xfer[0].rx_buf))[0], i);
    }


#if 0
    printf("response(%d): ", status);
    for (bp = (unsigned char*)(xfer[0].rx_buf); len; len--){
      printf("%02x ", *bp++);
    }
    printf("\n");
#endif
    i++;
  }

  return 0;
}

