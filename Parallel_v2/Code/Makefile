# Author: Jaume Garcia
# Start of the makefile
# Defining variables

objects = forces.o main.o Initialize.o Integration.o boundary.o statistics.o radial_distribution.o reader.o parallel.o
f90comp = mpif90

OPT= -O3
# Makefile
programa.exe: $(objects)
	$(f90comp) -o programa.exe $(OPT) $(objects)
reader.o: reader.f90
	$(f90comp) -c $(OPT) reader.f90
parallel.o: parallel.f90
	$(f90comp) -c $(OPT) parallel.f90
boundary.o: boundary.f90
	$(f90comp) -c $(OPT) boundary.f90
Initialize.o: Initialize.f90
	$(f90comp) -c $(OPT) Initialize.f90
forces.o: boundary.o Initialize.o forces.f90
	$(f90comp) -c $(OPT) forces.f90	
statistics.o: statistics.f90
	$(f90comp) -c $(OPT) statistics.f90	
Integration.o: boundary.o forces.o statistics.o radial_distribution.o Integration.f90
	$(f90comp) -c $(OPT) Integration.f90
radial_distribution.o: boundary.o radial_distribution.f90
	$(f90comp) -c $(OPT) radial_distribution.f90	
main.o: Initialize.o Integration.o reader.o parallel.o  main.f90
	$(f90comp) -c $(OPT) main.f90
  
## clean: Remove *.o , *.mod and *.exe files
.PHONY: clean
clean:
	rm -f programa.exe
	rm -f $(objects)
	rm -f *.mod

## plots: Generate gnuplots
.PHONY: plots
plots:
	gnuplot grafics.gnu
	
#Help
.PHONY: help
help:
	@sed -n 's/^##//p' Makefile
# End of the makefile
