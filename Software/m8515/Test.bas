$regfile = "m8515.dat"
$crystal = 1000000
$hwstack = 40
$swstack=16
Config Adc = Single , Prescaler = Auto , Reference = Avcc
Dim Schwelle As Word
Schwelle = Getadc(0)





