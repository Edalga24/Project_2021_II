module statistics
! Module with functions and subroutines to calculate averages.
implicit none
contains

! ------------------------------------------------------------------ !
!                           KINETIC ENERGY                           !
! ------------------------------------------------------------------ !
subroutine kinetic(Natoms,vel,numproc,index_particles,taskid,kin)
implicit none
! Input
integer:: Natoms
double precision:: vel(3,Natoms)
! - Parallel
integer:: numproc,taskid
integer:: index_part(numproc,2)
! Output
double precision kin
! Other variables
integer II,JJ,KK
! ****************************************************************** !
! This subroutine takes as an input the number of atoms and their 
! velocities and calculates the global kinetic energy.
! ****************************************************************** !
! ------------------------------------------------------------------ !

kin = 0.d0
do II = index_part(taskid+1,1),index_part(taskid+1,2)
    do JJ = 1,3

        kin = kin + vel(JJ,II)**2.d0

    enddo
enddo
kin = kin*0.5d0

! Adding contributions.
call MPI_REDUCE(kin,kin,1,MPI_DOUBLE_PRECISION,MPI_SUM,0,MPI_COMM_WORLD,ierror)

return
end subroutine kinetic

! ------------------------------------------------------------------ !
!                       INSTANT TEMPERATURE                          !
! ------------------------------------------------------------------ !

subroutine function insttemp(Natoms,kine,temp)
implicit none
! Input
integer Natoms
double precision kine
! Other variables
integer Nf
! ****************************************************************** !
! This subroutine takes as an input the number of atoms and the 
! kinetic energy of the system and computes the instant temperature.
! ****************************************************************** !
! ------------------------------------------------------------------ !

Nf = 3*Natoms - 3
temp = 2.d0*kine/dble(Nf)

end function insttemp

! ------------------------------------------------------------------ !
!                           TOTAL ENERGY                             !
! ------------------------------------------------------------------ !

double precision function totalenergy(potene,kinene)
implicit none
! Input
double precision potene,kinene
! ****************************************************************** !
! This subroutine takes as an input the kinetic and the potential
! energy and computes the total energy.
! ****************************************************************** !
! ------------------------------------------------------------------ !

totalenergy = potene + kinene

end function totalenergy


! ------------------------------------------------------------------ !
!                              PRESSURE                              !
! ------------------------------------------------------------------ !

subroutine pressure(Natoms,L,rho,posis,force,temp,numproc,index_particles,taskid,pres)
implicit none
! Input
integer Natoms
double precision L,rho,posis(3,Natoms),force(3,Natoms),temp
! Output
double precision pres
! Other variables
integer i,j
! Parallel variables
integer :: index_particles(numproc,2)
! ****************************************************************** !
! This subroutine takes as an input the knumber of atoms, the den-
! sity, the positions of the particles, the force applied to them,
! and the temperature to calculate the instantaneous pressure.
! ****************************************************************** !
! ------------------------------------------------------------------ !

pres = 0.d0

do i = index_particles(taskid+1,1), index_particles(taskid+1,2)
    do j = 1, 3

        pres = pres + posis(j,i)*force(j,i)

    enddo
enddo

pres = rho*temp + pres/(3.d0*(L**3)*Natoms)
! Sumem totes les contribucions de la pressió de tots els processadors 
call MPI_REDUCE(pres,pres,1,MPI_DOUBLE_PRECISION,MPI_SUM,0,MPI_COMM_WORLD,ierror)
return
end subroutine pressure

end module statistics
