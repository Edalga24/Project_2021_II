MODULE INITIALIZE
IMPLICIT NONE
CONTAINS


SUBROUTINE INITIAL(Natoms,RO,TEMP,taskid,POSI,VEL,L)
! Given a total number of particles Natoms, a density RO and a temperature TEMP, this subroutine returns the initial position POSI(3,Natoms) of those particles in a 3D sc lattice and it's initial velocities VEL(3,Natoms). The velocities are set in a MB distribution
IMPLICIT NONE
DOUBLE PRECISION RO,TEMP,POSI(3,Natoms),VEL(3,Natoms),A,L
DOUBLE PRECISION AVER(3),AVER2,X1,X2,u1,u2,PHI,PI
INTEGER Natoms,N3,II,JJ,KK,ATOM,SEED
! Parallel variables 
integer taskid

! El càlcul només el fa el primer processador.
if (taskid==0) then

N3=Natoms**(1./3.)+1



L=N3/(RO**(1./3.))              ! Length of the cell
A=L/DBLE(N3)                    ! Distance between fist-neighbour atoms



ATOM=0
! We will place the atoms in a square lattice until we run out of atoms
DO II=1,N3
	DO JJ=1,N3
		DO KK=1,N3
			ATOM=ATOM+1


			IF (ATOM.GT.Natoms) goto 10        ! When the atoms placed are bigger that the total atoms, we stop

			POSI(1,ATOM)=A*DBLE(II)-L/2.D0     ! x coordinate
			POSI(2,ATOM)=A*DBLE(JJ)-L/2.D0     ! y coordinate
			POSI(3,ATOM)=A*DBLE(KK)-L/2.D0     ! z coordinate

		ENDDO
	ENDDO
10 ENDDO



! The velocities are initialized in a MB distribution
SEED=31415926
CALL SRAND(SEED)
PI=4.D0*DATAN(1.D0)

AVER=0.D0
DO II=1,Natoms
	DO KK=1,3
		call random_number(u1)
		call random_number(u2)
		X1=1.D0-u1
		X2=1.D0-u2
		PHI=2.D0*PI*X2
		VEL(KK,II)=DSQRT(-2.D0*TEMP*DLOG(X1))*DSIN(PHI)
		AVER(KK)=AVER(KK)+VEL(KK,II)
	ENDDO
ENDDO

! Rescaling (total momentum equal to zero)
DO KK=1,3
	VEL(KK,:)=VEL(KK,:)-AVER(KK)/Natoms
ENDDO

! Rescaling (total kinetic energy acording to a MB distribution, ergo SUM(1/2*v²) = 3/2*N*T)
AVER2=0.d0
DO II=1,Natoms
	DO KK=1,3
		AVER2=AVER2+VEL(KK,II)**2.D0
	ENDDO
ENDDO
VEL=VEL*DSQRT(3.D0*Natoms*TEMP/AVER2)

endif 

RETURN
END SUBROUTINE INITIAL


END MODULE INITIALIZE

