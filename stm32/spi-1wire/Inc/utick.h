#if !defined __UTICK_H__
#define __UTICK_H__
#include "stm32f1xx_hal.h"


void     reset_utick(void);
uint32_t get_utick(void);
void     inc_utick(void);
void     usleep(__IO uint32_t t);
void usleep_spin(__IO uint32_t t);

#endif /*__UTICK_H__*/
