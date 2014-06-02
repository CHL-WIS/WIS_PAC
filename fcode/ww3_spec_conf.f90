program ww3_spec_conv

implicit none

character(len=5)  :: stat
character(len=6)  :: time2
character(len=8)  :: time1
character(len=25) :: FILE01
character(len=13) :: fileout

integer :: ii, jj, ll, zz, nn, pp, qq, id
integer :: fpar,nsta,ddi
integer :: nfrq, ndir, numst
integer, dimension(1) :: temp1
real :: lat, lon, dep, wspd, wdir, cspd, cdir,deldir,ZPI,ustar,dird1
real :: delth,mo,Hmo,tp,tpp,fm,tm,TM1,TM2,THQ,SPREAD,dirt,sprt
real, allocatable :: freq(:), dir(:), e(:,:),col1(:),DFIM(:), &
                     DFFR(:),DFFR2(:),dird(:),eout(:,:),dird2(:)
integer, dimension(72) :: idd
integer, dimension(500) :: staf,stap

ZPI = 8.0e0*atan(1.0e0)

!FILE01 = "ww3.99010101.spc"
read(2,*) FILE01
OPEN(10,file = FILE01,status = "OLD")
      read(10,101) nfrq, ndir, numst
      allocate (freq(nfrq),dir(ndir),e(ndir,nfrq),col1(nfrq), &
                 DFIM(nfrq),DFFR(nfrq),DFFR2(nfrq),dird(ndir), &
                 eout(ndir,nfrq),dird2(ndir))
      read(10,*) (freq(ii),ii=1,nfrq)
      read(10,*) (dir(ii),ii=1,ndir)
      dird = dir*180/3.14 
!      dird2 = dird + 180
!      do ii = 1,ndir
!         if (dird(ii) .ge. 360) dird2(ii) = dird(ii) - 360
!      enddo
      deldir = dird(1)-dird(2)
      dird1 = minval(dird)
      temp1= minloc(dird)
      idd(1) = sum(temp1)
      do id = 2,ndir
        idd(id) = idd(id-1) - 1
        if (idd(id) .eq. 0) then
             idd(id) = ndir
        endif
      enddo
                
   do zz = 1,9999999
      read(10,*,end=90) time1, time2
     do qq = 1,numst
      read(10,102) stat, lat, lon, dep, wspd, wdir, cspd, cdir
      read(10,*) ((e(jj,ii),ii=1,nfrq),jj=1,ndir)
      eout(1:72,:) = e(idd,:)
      read(stat,'(i5)') nsta
      if (zz .eq. 1 .AND. qq .eq. 1) then
         pp = 1
         nn = 0
         staf(1) = 1000
         fpar = staf(1)
         stap(1) = nsta
      else
         do ll = 1, pp 
           if (nsta .eq. stap(ll)) then
              fpar = staf(ll)
              go to 95
           elseif (ll .eq. pp .AND. nsta .ne. stap(ll)) then
              staf(ll+1) = staf(ll) + 1
              stap(ll+1) = nsta
              fpar = staf(ll+1)
              pp = pp + 1
              go to 95
           endif
         enddo
      endif
   95 continue

      delth = ZPI/ndir
      col1(1:nfrq-1) = 0.5*((freq(2:nfrq)/freq(1:nfrq-1))-1.0)*delth
      DFIM(1) = col1(1)*freq(1)
      DFIM(2:nfrq-1) = col1(2:nfrq-1)*(freq(2:nfrq-1) + freq(1:nfrq-2))
      DFIM(nfrq) = col1(nfrq-1)*freq(nfrq-1)
      DFFR = DFIM*freq
      DFFR2= DFIM*freq**2

      CALL TOTAL_ENERGY (1,ndir,nfrq,e,freq,DFIM,delth,mo)
      Hmo = 4.0e0*sqrt(mo)

      CALL PEAK_PERIOD (ndir,nfrq,delth,e,freq,tp,tpp)

      CALL FEMEAN (1,ndir,nfrq,delth,e,freq,mo,DFIM,fm)
      tm = 1/fm

      CALL TM1_TM2_PERIODS (ndir,nfrq,delth,e,freq,mo,DFIM,DFFR,DFFR2,TM1,TM2)

      CALL MEAN_DIRECTION (ndir,nfrq,delth,e,DFIM,dir,THQ,SPREAD)
      dirt = THQ * 180/3.14
!      dirt = dirt + 180.0
      if (dirt .ge. 360.0) dirt = dirt - 360.0
      sprt = SPREAD * 180/3.14


      if (pp .gt. nn) then
         nn = pp
         fileout = 'ST'//stat//'.spe2d'
         open(fpar,file = fileout, status = "unknown")
      endif
      ustar = -99.99
      write(fpar,201) 1,time1,time2,lon,lat,nfrq,ndir,freq(1),dird1,deldir
      write(fpar,202) wspd, wdir, ustar
      write(fpar,203) Hmo,tpp,tm,TM1,TM2,dirt,sprt
      do ii = 1,nfrq
        write(fpar,204) freq(ii), (eout(jj,ii),jj=1,ndir)
      enddo
     enddo
   enddo
   90 deallocate(freq,dir,e,eout)
      
      close(10)
  101 format(27x,i3,3x,i3,3x,i3)
  102 format(1x,a5,6x,2f7.2,f10.1,2(f7.2,f6.1))
  103 format(7f11.3)
  201 format(i1,1x,a8,a6,f8.2,f6.2,2i5,3f8.4)
  202 format(f6.2,f6.0,f7.2)
  203 format(5f6.2,2f6.0)
  204 format(f8.4,f10.3,72f8.3)

      end program

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
SUBROUTINE TOTAL_ENERGY (qq,nang, nfrq, F3, FR, DFIM2, delth, EMEAN)

! ---------------------------------------------------------------------------- !
!                                                                              !
!   TOTAL_ENERGY_B - COMPUTES TOTAL ENERGY (VECTOR VERSION).                   !
!                                                                              !
!     S.D. HASSELMANN.                                                         !
!     OPTIMIZED BY: L. ZAMBRESKY AND H. GUENTHER                               !
!     H. GUENTHER     GKSS   DECEMBER 2001  FT90                               !
!                                                                              !
!     PURPOSE.                                                                 !
!     --------                                                                 !
!                                                                              !
!       TO COMPUTE TOTAL ENERGY AT EACH GRID POINT.                            !
!                                                                              !
!     METHOD.                                                                  !
!     -------                                                                  !
!                                                                              !
!       INTEGRATION OVER DIRECTION AND FREQUENCY. A TAIL CORRECTION IS ADDED.  !
!                                                                              !
!     REFERENCE.                                                               !
!     ----------                                                               !
!                                                                              !
!       NONE.                                                                  !
!                                                                              !
! ---------------------------------------------------------------------------- !
!                                                                              !
!     INTERFACE VARIABLES.                                                     !
!     --------------------                                                     !
dimension F3(nang,nfrq), FR(nfrq), DFIM2(nfrq)
REAL,INTENT(OUT)            :: EMEAN(1)     !! TOTAL ENERGY.

! ---------------------------------------------------------------------------- !
!                                                                              !
!     LOCAL VARIABLES.                                                         !
!     ----------------                                                         !
INTEGER  :: qq,ii
REAL     :: DELT25,EMIN
REAL     :: TEMP(SIZE(F3,2))
PARAMETER(EMIN = 1.0e-12)

! ---------------------------------------------------------------------------- !
!                                                                              !
!     1. INTEGRATE OVER FREQUENCIES AND DIRECTION.                             !
!        -----------------------------------------
!TEMP = SUM(F3, DIM=1)*delth
!EMEAN = 0.
!DO ii = 1,nfrq
!  EMEAN = EMEAN + TEMP(ii)*DFIM2(ii)
!ENDDO

TEMP = SUM(F3, DIM=1)
EMEAN = DOT_PRODUCT(TEMP,DFIM2)
! ---------------------------------------------------------------------------- !
!                                                                              !
!     2. ADD TAIL ENERGY.                                                      !
!        ----------------                                                      !
!
!EMEAN = EMEAN + qq*hscale
DEL25 = 0.25*FR(nfrq)*delth
EMEAN = EMEAN + qq*DEL25*TEMP(nfrq)
EMEAN = MAX(EMEAN, EMIN)

END SUBROUTINE TOTAL_ENERGY

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE PEAK_PERIOD (nang, nfrq, delth, F, FR, PEAKP, PPP)

! ---------------------------------------------------------------------------- !
!                                                                              !
!    PEAK_PERIOD_1 - COMPUTATES PEAK PERIOD (SCALAR VERSION).                  !
!                                                                              !
!     H. GUNTHER      ECMWF            DECEMBER 1989                           !
!     (CODE REMOVED FROM SUB. FEMEAN)                                          !
!     H. GUNTHER      GKSS            FEBRUARY 2002  CHANGED TO PERIOD.        !
!                                                                              !
!     PURPOSE.                                                                 !
!     --------                                                                 !
!                                                                              !
!       COMPUTE PEAK PERIOD.                                                   !
!                                                                              !
!     METHOD.                                                                  !
!     -------                                                                  !
!                                                                              !
!       THE FREQUENCY INDEX OF THE 1-D SPECTRUM IS COMPUTED AND                !
!       CONVERTED TO PERIOD.                                                   !
!                                                                              !
!     REFERENCE.                                                               !
!     ----------                                                               !
!                                                                              !
!       NONE.                                                                  !
!                                                                              !
! ---------------------------------------------------------------------------- !
!                                                                              !
!     INTERFACE VARIABLES.                                                     !
!     --------------------                                                     !

dimension F(nang,nfrq), FR(nfrq)     !! SPECTRUM.
REAL,    INTENT(OUT)           :: PEAKP, PPP      !! PEAK PERIOD.

! ---------------------------------------------------------------------------- !
!                                                                              !
!     LOCAL VARIABLES.                                                         !
!     ----------------                                                         !

INTEGER  :: IPEAK(1:1)
REAL     :: EED1D(SIZE(F,2)), ED(SIZE(F,2))
REAL     :: PPF, eneck, v1, v2, a, b

! ---------------------------------------------------------------------------- !
!                                                                              !
!     1. COMPUTE 1-D SPECTRUM (WITHOUT DELTA THETA).                           !
!        -------------------------------------------                           !

IPEAK(1:1) = nfrq

EED1D = SUM(F, DIM=1)
ED = EED1D*delth
! ---------------------------------------------------------------------------- !
!                                                                              !
!     2. DEFINE PEAK INDEX.                                                    !
!        ------------------                                                    !

IPEAK(1:1) = MAXLOC(EED1D)
!IPEAK(1:1) = MAXLOC(ED)
! ---------------------------------------------------------------------------- !
!                                                                              !
!     3. CALCULATE PEAK PERIOD FROM PEAK INDEX.                                !
!        --------------------------------------                                !
PEAKP = 1./FR(IPEAK(1))
IF (IPEAK(1).EQ.1) THEN
 PEAKP = 1.
 IPEAK(1) = nfrq
ENDIF

! ---------------------------------------------------------------------------- !
!
!     4. CALCULATE PEAK PERIOD OF THE PARABOLIC FIT.
!        -------------------------------------------

    PPF = FR(IPEAK(1))
    IPK = IPEAK(1)
    IPKp1 = IPK + 1
    IPKm1 = IPK - 1

    if (IPK .ne. nfrq) then
       PPF = FR(IPK)
       eneck = ED(IPKp1) + ED(IPK) + ED(IPKm1)

       if (eneck .gt. 1.0E-10) then
          v1 = (FR(IPK) - FR(IPKp1))*(FR(IPKm1) - FR(IPK))
          v2 = (ED(IPKm1) - ED(IPKp1))*(FR(IPKm1) - FR(IPK))/  &
                 (FR(IPKm1) - FR(ipkp1))

          if (v2 .ne. 0) then
             a = (ED(IPKm1) - ED(IPK) - v2)/v1
             b = (ED(IPKm1) - ED(IPKp1))/(FR(IPKm1) - FR(IPKp1)) &
                  - a*(FR(IPKm1) + FR(IPKp1))

             IF (a .ne. 0.) PPF = -0.5*b/a
          endif
       endif
     endif
     PPP = 1./(PPF + (-1.0E-10))

END SUBROUTINE PEAK_PERIOD

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE FEMEAN (qq, nang, nfrq, delth, F, FR, EMEAN, DFIM, FMM)

! ---------------------------------------------------------------------------- !
!                                                                              !
!   FEMEAN - COMPUTATION OF MEAN FREQUENCY.                                    !
!                                                                              !
!     S.D. HASSELMANN                                                          !
!     MODIFIED : P.JANSSEN (INTEGRATION OF F**-4 TAIL)                         !
!     OPTIMIZED BY : L. ZAMBRESKY AND H. GUENTHER                              !
!     H. GUNTHER     GKSS         DECEMBER 2001    FT90                        !
!                                                                              !
!                                                                              !
!     PURPOSE.                                                                 !
!     --------                                                                 !
!                                                                              !
!       COMPUTE MEAN FREQUENCY AT EACH GRID POINT.                             !
!                                                                              !
!     METHOD.                                                                  !
!     -------                                                                  !
!                                                                              !
!       NONE.                                                                  !
!                                                                              !
!     REFERENCE.                                                               !
!     ----------                                                               !
!                                                                              !
!       NONE.                                                                  !
!                                                                              !
! ---------------------------------------------------------------------------- !
!                                                                              !
!     INTERFACE VARIABLES.                                                     !
!     --------------------                                                     !
dimension F(nang,nfrq),FR(nfrq),DFIM(nfrq)
REAL,    INTENT(OUT)           :: FMM       !! MEAN FREQUENCY.

! ---------------------------------------------------------------------------- !
!                                                                              !
!     LOCAL VARIABLES.                                                         !
!     ----------------                                                         !
INTEGER :: qq
REAL     :: DELT25,EMIN,FM1
REAL     :: TEMP2(SIZE(F,2)), DFIMOFR(nfrq)
PARAMETER(EMIN = 1.0e-12)
! ---------------------------------------------------------------------------- !
!                                                                              !
!     1. INTEGRATE OVER DIRECTIONS.                                            !
!        ---------------------------                                           !
!TEMP2 = SUM(F,DIM=1)*delth
TEMP2 = SUM(F,DIM=1)
DFIMOFR = DFIM/FR
! ---------------------------------------------------------------------------- !
!                                                                              !
!     2. COMPUTE MEAN FREQUENCY.                                               !
!        -----------------------                                               !
FMM = DOT_PRODUCT(TEMP2,DFIMOFR)       !! INTEGRATE OVER FREQUENCIES.
!FM1 = DOT_PRODUCT(TEMP2,DFIM)
DEL25 = 0.20*delth
FMM = FMM + DEL25*TEMP2(nfrq)
!FMM = MAX(FMM,EMIN)
!FMM = MAX(FM1,EMIN)/MAX(FMM,EMIN)          !! NORMALIZE WITH TOTAL ENERGY.
FMM = EMEAN/MAX(FMM,EMIN)

END SUBROUTINE FEMEAN

!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE TM1_TM2_PERIODS (nang, nfrq, delth, F, FR, EMEAN, DFIM, DFFR, DFFR2, TM1, TM2)

! ---------------------------------------------------------------------------- !
!                                                                              !
!   TM1_TM2_PERIODS_1 - COMPUTES TM1 AND/OR TM2 PERIODS (SCALAR VESION).       !
!                                                                              !
!     C.SCHNEGGENBURGER 08/97.                                                 !
!                                                                              !
!     PURPOSE.                                                                 !
!     --------                                                                 !
!                                                                              !
!       COMPUTE TM1 AND TM2 PERIODS.                                           !
!                                                                              !
!     METHOD.                                                                  !
!     -------                                                                  !
!                                                                              !
!       INTEGARATION OF SPECTRA AND ADDING OF TAIL FACTORS.                    !
!                                                                              !
!     REFERENCE.                                                               !
!     ----------                                                               !
!                                                                              !
!       NONE.                                                                  !
!                                                                              !
! ---------------------------------------------------------------------------- !
!                                                                              !
!     INTERFACE VARIABLES.                                                     !
!     --------------------                                                     !

dimension F(nang,nfrq), DFFR(nfrq), DFFR2(nfrq), FR(nfrq),DFIM(nfrq)    !! BLOCK OF SPECTRA.
REAL,    INTENT(IN )           :: EMEAN     !! TOTAL ENERGY [M*M].
REAL,    INTENT(OUT), OPTIONAL :: TM1       !! TM1 PERIOD [S].
REAL,    INTENT(OUT), OPTIONAL :: TM2       !! TM2 PERIOD [S].

! ---------------------------------------------------------------------------- !
!                                                                              !
!     LOCAL VARIABLES.                                                         !
!     ----------------                                                         !

REAL    :: TLFR
REAL    :: TEMP(SIZE(F,2))
PARAMETER(EMIN = 1.0e-12)

! ---------------------------------------------------------------------------- !
!                                                                              !
!     1. INTEGRATE OVER DIRECTIONS .                                           !
!        ------------------------------------------                            !

!TEMP = SUM(F, DIM=1)*delth
TEMP = SUM(F, DIM=1)
! ---------------------------------------------------------------------------- !
!                                                                              !
!     2. TM1 PERIOD.                                                           !
!        -----------                                                           !

TM1 = DOT_PRODUCT(TEMP, DFFR)              !! FREQUENCY INTEGRATION.
!TMM = DOT_PRODUCT(TEMP, DFIM)
TLFR = 1./3.*(FR(SIZE(F,2)))**2*delth    !! ADD TAIL CORRECTION.
TM1    = TM1 + TLFR * TEMP(SIZE(F,2))
TM1    = MAX(TM1, EMIN)
!TMM = MAX(TMM,EMIN)
IF (EMEAN.GT.EMIN) THEN                    !! NORMALIZE WITH TOTAL ENERGY.
   TM1 = EMEAN/TM1
!   TM1 = TMM/TM1
ELSE
   TM1 = 1.
END IF

! ---------------------------------------------------------------------------- !
!                                                                              !
!     3. TM2 PERIOD.                                                           !
!        -----------                                                           !

TM2 = DOT_PRODUCT(TEMP, DFFR2)              !! FREQUENCY INTEGRATION.

TLFR = 0.5*(FR(SIZE(F,2)))**3*delth     !! ADD TAIL CORRECTION.
TM2    = TM2 + TLFR * TEMP(SIZE(F,2))
TM2    = MAX(TM2, EMIN)

IF (EMEAN.GT.EMIN) THEN                     !! NORMALIZE WITH TOTAL ENERGY.
   TM2 = SQRT(EMEAN/TM2)
!   TM2 = SQRT(TMM/TM2)
ELSE
   TM2 = 1.
END IF
!
END SUBROUTINE TM1_TM2_PERIODS

!---------------------------------------------------------------------------
!---------------------------------------------------------------------------
SUBROUTINE MEAN_DIRECTION (nang, nfrq, delth, F3, DFIM,angl, THQ, SPREAD)

! ---------------------------------------------------------------------------- !
!                                                                              !
!   MEAN_DIRECTION_1 - COMPUTATION OF MEAN WAVE DIRECTION ONE SPECTRUM.        !
!                                                                              !
!     S.D. HASSELMANN                                                          !
!     OPTIMIZED BY L. ZAMBRESKY                                                !
!     MODIFIED FOR K-MODEL BY C.SCHNEGGENBURGER                                !
!                                                                              !
!     PURPOSE.                                                                 !
!     --------                                                                 !
!                                                                              !
!       TO COMPUTE MEAN WAVE DIRECTION FROM ONE SPECTRUM.                      !
!                                                                              !
!     METHOD.                                                                  !
!     -------                                                                  !
!                                                                              !
!       INTEGRATION OF SPECTRUM TIMES SIN AND COS OVER DIRECTION.              !
!                                                                              !
!     EXTERNALS.                                                               !
!     ----------                                                               !
!                                                                              !
!       NONE.                                                                  !
!                                                                              !
!     REFERENCE.                                                               !
!     ----------                                                               !
!                                                                              !
!       NONE.                                                                  !
!                                                                              !
! ---------------------------------------------------------------------------- !
!                                                                              !
!     INTERFACE VARIABLE                                                       !

dimension F3(nang,nfrq), DFIM(nfrq), angl(nang)  !! DENSITY SPECTRUM.
REAL, INTENT(OUT), OPTIONAL :: THQ      !! MEAN DIRECTION [RAD].
REAL, INTENT(OUT), OPTIONAL :: SPREAD   !! MEAN SPREAD [RAD].

! ---------------------------------------------------------------------------- !
!                                                                              !
!     LOCAL VARIABLE                                                           !
INTEGER  :: kk
REAL     :: SI, CI
REAL     :: TEMP(1:SIZE(F3,1)), TH(nang), SINTH(nang), COSTH(nang)
REAL, PARAMETER :: ZPI=2.*3.14
! ---------------------------------------------------------------------------- !
!                                                                              !
!     1. INTEGRATE OVER FREQUENCIES AND DIRECTIONS.                            !
!        ------------------------------------------                            !

DO kk = 1,nang
   TH(kk) = angl(kk)
ENDDO
SINTH = SIN(TH)
COSTH = COS(TH)

TEMP = MATMUL(F3, DFIM)
SI = DOT_PRODUCT(TEMP,SINTH)
CI = DOT_PRODUCT(TEMP,COSTH)
! ---------------------------------------------------------------------------- !
!                                                                              !
!     2. COMPUTE MEAN DIRECTION.                                               !
!        -----------------------                                               !

IF (CI.EQ.0.) CI = 0.1E-30
THQ = ATAN2(SI,CI)
IF (THQ.LT.0.) THQ = THQ + ZPI
! ---------------------------------------------------------------------------- !
!                                                                              !
!     3. COMPUTE MEAN SPREAD.                                                  !
!        --------------------                                                  !

SPREAD = SUM(TEMP)
IF (ABS(CI) .LT. 0.1E-15) CI = SIGN(0.1E-15,CI)
IF (ABS(SI) .LT. 0.1E-15) SI = SIGN(0.1E-15,SI)
IF (ABS(SPREAD) .LT. 0.1E-15) SPREAD = SIGN(0.1E-15,SPREAD)
SPREAD = 2.*(1.-SQRT(SI**2 + CI**2)/SPREAD)
IF (SPREAD.LE.0) THEN
   SPREAD = TINY(1.)
ELSE
   SPREAD = SQRT(SPREAD)
END IF

END SUBROUTINE MEAN_DIRECTION


