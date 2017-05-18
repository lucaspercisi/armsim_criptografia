arm-none-eabi-as.exe -o test.o test.s
arm-none-eabi-ld -T mapa.lds -o test test.o
java -jar armsim.jar -c -l test -d devices.txt