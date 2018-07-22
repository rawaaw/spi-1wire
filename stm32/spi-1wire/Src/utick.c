/* usecond time */
#include "stm32f1xx_hal.h"
#include "utick.h"

__IO uint32_t s_utick_counter;

void reset_utick(void){
  s_utick_counter = 0;
  return;
}


uint32_t get_utick(void){
  return s_utick_counter;
}
void inc_utick(void){
  s_utick_counter ++;
  return;
}

void usleep(__IO uint32_t t){
  uint32_t tickstart = get_utick();
  uint32_t wait = t;
  
  /* Add a period to guarantee minimum wait */
  if (wait < HAL_MAX_DELAY){
     wait++;
  }
  while((get_utick() - tickstart) < wait){
  }
  return;
}

void usleep_spin(__IO uint32_t t){
  __IO uint32_t i;
  for (i = 0; i < t; i++){
  }
  return;
}
