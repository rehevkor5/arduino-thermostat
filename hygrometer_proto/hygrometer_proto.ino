void setup() {
  analogReference(DEFAULT);
  pinMode(A0, INPUT);
  
  Serial.begin(9600);
}

void loop() {
  // We'll get an acutal temperature from a chip
  float temperature = 22.0;
  
  // Read voltage coming from sensor (adcValue will be between 0-1023)
  float adcValue = analogRead(A0);
  
  //float voltage = (adcValue / 1023.0) * 5.0;
  float percentRH1 = adcValue / (.0062 * 1023.0) - (.16 / .0062);
  
  float percentRH2 = percentRH1 / (1.0546 - .00216 * temperature);
  
  // Print value
  Serial.print("%RH1 = ");
  Serial.println(percentRH1, DEC);
  Serial.print("%RH2 = ");
  Serial.println(percentRH2, DEC);
  
  // Delay for one second
  delay(1000);
}
