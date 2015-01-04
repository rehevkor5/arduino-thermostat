#include <Wire.h>
#include "IntersemaBaro.h"

/*
Currently using I2C to communicate with the temperature & barometer chip.
"This module’s default communication setup is I²C. Use of SPI communication is configured by pulling the
PS pin low. See the datasheet for SPI configuration and use."

Wire.h by default uses pin A4 as SDA and pin A5 as SCL.
*/


/*
temperature: divide by 100 to get degrees C
*/
float relativeHumidity(int32_t temperature) {
  // Read voltage coming from sensor (adcValue will be between 0-1023)
  float adcValue = analogRead(A0);
  float unadjustedRh = adcValue / (.0062 * 1023.0) - (.16 / .0062);
  
  // RH adjusted for temperature
  return unadjustedRh / (1.0546 - .00216 / 100.0 * temperature);
}

// boolean parameter is i2c address select
Intersema::BaroPressure_MS5607B baro(true);

void setup() {
  // Analog pin zero reads temperature as compared to 5V.
  analogReference(DEFAULT);
  pinMode(A0, INPUT);
  
  Serial.begin(9600);
  
  baro.init();
}

void loop() {
  int32_t temperature = baro.getTemperature();
  
  float rh = relativeHumidity(temperature);
  
  Serial.print(temperature);
  Serial.print(",");
  Serial.println(rh, DEC);
  
  // Delay for one second
  delay(1000);
}
