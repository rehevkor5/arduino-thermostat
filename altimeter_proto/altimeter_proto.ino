#include <Wire.h>
#include "IntersemaBaro.h"

/*
"This module’s default communication setup is I²C. Use of SPI communication is configured by pulling the
PS pin low. See the datasheet for SPI configuration and use."


For info about datatypes such as uint32_t, see http://en.wikipedia.org/wiki/C_data_types#stdint.h
*/

// boolean parameter is i2c address select
Intersema::BaroPressure_MS5607B baro(true);

void setup() { 
    Serial.begin(9600);
    baro.init();
    baro.testTemperatureRange();
}

void loop() {
//  int alt = baro.getHeightCentiMeters();
//  Serial.print("Centimeters: ");
//  Serial.print((float)(alt));
//  Serial.print(", Feet: ");
//  Serial.println((float)(alt) / 30.48);
  
//  int pascals = baro.getPressurePascals();
//  Serial.print("Pascals: ");
//  Serial.println(pascals);
//  
//  int temp = baro.getTemperature(); 
//  Serial.print("Temperature in cents of C: "); 
//  Serial.println(temp);
//  delay(400);


  int pascals = baro.getPressurePascals();
  int temp = baro.getTemperature();
  Serial.print(pascals);
  Serial.print(",");
  Serial.println(temp);
  delay(1000);
}
