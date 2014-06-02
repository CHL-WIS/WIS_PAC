      PROGRAM spec_onlns_WW3
      IMPLICIT NONE
!
!
!  Convert spectral files from WW3 to WAM onlns file format
!
!  TJH 5/4/11
!
!-----------------------------------------------------------------------
!
! Format for WW3 spectral files
      CHARACTER(1)  :: stac1
      CHARACTER(2)  :: stac2
      CHARACTER(5)  :: stac
      CHARACTER(6)  :: time2
      CHARACTER(16) :: FILE01
      CHARACTER(18) :: fileout1
!      CHARACTER(17) :: fileout
      CHARACTER(13) :: fileout
      INTEGER :: ii,jj,mm,kk,zz,nn,rr,ll,pp,fpar,time1,bb,qq
      INTEGER :: i,j,k,nsta,idate,nang,nfrq,idateo,nsta1,npoint
      REAL :: xlon,xlat,dep,hscale,hsig,avan,tss,wsnow,wdout,fma
      REAL :: FV,Drag,norm,Hmo,mo,co,delth,fm,tp,tm,TM1,TM2,co1,tpp
      REAL :: THQ,SPREAD,dirt,sprt,sis,THK,CM,wdoutr
      REAL :: mosea,Hmosea,tpsea,tmsea,TM1sea,TM2sea,dirtsea,sprtsea,tpps
      REAL :: moswe,Hmoswe,tpswe,tmswe,TM1swe,TM2swe,dirtswe,sprtswe,tppw
      REAL :: PI,ZPI,G,ROAIR
      REAL :: coef1,coef2,cdrag,ustsq,ustar, col
      REAL, ALLOCATABLE :: e(:,:),freq(:),DFIM(:),DFFR(:),DFFR2(:),C(:), &
                           TH(:),e1(:,:),col1(:),angl(:)
      INTEGER, DIMENSION(500) :: staf, stap
      REAL, PARAMETER :: FRIC = 28.



      PARAMETER(co = 1.1)
!------------------------------------------------------------------------
      read(2,'(a16)') FILE01
!      FILE01="ww3.99010101.spc"
      nn = 0
      rr = 0
      idateo = 0
      open(01,file = FILE01,status = 'old')
!      open(01,file = "ww3.99010101.spc",status = 'old')
      read(1,100) nfrq, nang, npoint
      allocate(e(nang,nfrq),freq(nfrq),DFIM(nfrq),DFFR(nfrq),DFFR2(nfrq), &
               C(nfrq),TH(nang),e1(nang,nfrq),col1(nfrq-1),angl(nang))
      read(1,*) (freq(ii), ii=1,nfrq)
      read(1,*) (angl(jj), jj=1,nang)
      bb = 0
      DO zz = 1,999999
!      DO zz = 1,10
      bb = bb + 1
      IF (zz .eq. 1 .OR. bb .gt. npoint) then
      	read(1,101,END=211) time1, time2
        bb = 1
        qq = qq + 1
        rr = 1
      ENDIF
      read(1,102) nsta,xlat,xlon,dep,wsnow,wdout
!      print *, time1, time2 
     
      IF (zz .gt. 1) then
      DO ll = 1,pp 
         IF (nsta .eq. stap(ll)) then
            fpar = staf(ll)
            go to 25
         ELSEIF (ll .eq. pp .AND. nsta .ne. stap(ll)) then
            staf(ll+1) = staf(ll) + 1
            stap(ll+1) = nsta
            fpar = staf(ll+1)
            pp = pp + 1
            go to 25
         ENDIF
      ENDDO     
      ELSE
        pp = 1
        staf(1) = 1000
        fpar = staf(1)
        stap(1) = nsta
      ENDIF

   25 continue
      
      read(1,103)((e(ii,jj),jj=1,nfrq),ii=1,nang)

!      if (nsta .lt. 10) then
!          write(stac1,'(i1)') nsta
!          stac = '00'//stac1
!      elseif (nsta .lt. 100) then
!          write(stac2,'(i2)') nsta
!          stac = '0'//stac2
!      else
          write(stac,'(i5)') nsta
!      endif
      
!      read(time2,'(a6)') idate
      rr = rr + 1
!      if (idate .ne. idateo) then
!         qq = qq + 1
!         rr = 1
!         idateo = idate
!      endif

!      xlon = 360 + xlon
      
      ZPI = 8.0E0*ATAN(1.0e0)
      PI = 0.5*ZPI
      G = 9.81
      ROAIR = 1.225


!      FV = -999.99
!      Drag = -999.99
      norm = -999.99
   
!      freq = (/ 0.03333,0.04000,0.05000,0.05500,0.06000,0.06666,0.07000, &
!            0.08000, 0.09000, 0.10000,0.11000,0.12000,0.13000,0.14000, &
!            0.15000, 0.16000, 0.18000, 0.20000, 0.25000, 0.30000 /)

      delth = ZPI/nang
!      co1 = 0.1*delth
!      col = 0.5*(freq(2)-freq(1))
!      col1(1:nfrq-1) = 0.5*(freq(2:nfrq) - freq(1:nfrq-1))
!      DFIM(1) = col + col1(1)
!      DFIM(2:nfrq-1) = col1(1:nfrq-2) + col1(2:nfrq-1)
!      DFIM(nfrq) = 2.0*col1(nfrq-1)
!      DFIM(1:nfrq-1) = 0.5*(freq(2:nfrq-1) - freq(1:nfrq-2))
!      DFIM(nfrq) = 0.5*(freq(nfrq)-freq(nfrq-1))
      col1(1:nfrq-1) = 0.5*((freq(2:nfrq)/freq(1:nfrq-1))-1.0)*delth
      DFIM(1) = col1(1)*freq(1)
      DFIM(2:nfrq-1) = col1(2:nfrq-1)*(freq(2:nfrq-1) + freq(1:nfrq-2))
      DFIM(nfrq) = col1(nfrq-1)*freq(nfrq-1)
      
!      print *, freq
      DFFR = DFIM*freq
      DFFR2= DFIM*freq**2
      
      CALL TOTAL_ENERGY (1,nang,nfrq,e,freq,DFIM,delth,hscale,mo)
      Hmo = 4.0e0*sqrt(mo)

      CALL PEAK_PERIOD (nang,nfrq,delth,e,freq,tp,tpp)

      CALL FEMEAN (1,nang,nfrq,delth,e,freq,mo,DFIM,fm)
      tm = 1/fm

      CALL TM1_TM2_PERIODS (nang,nfrq,delth,e,freq,mo,DFIM,DFFR,DFFR2,TM1,TM2)

      CALL MEAN_DIRECTION (nang,nfrq,delth,e,DFIM,angl,THQ,SPREAD)
      dirt = THQ * 180/3.14
      dirt = dirt + 180.0
      if (dirt .ge. 360.0) dirt = dirt - 360.0
      sprt = SPREAD * 180/3.14   

!--------------------------------------------------------------------------
!   Seperate Wind-Sea and Swell

!   Calcuate ustar
      coef1 = 1.1
      coef2 = 0.035
      cdrag = (coef1 + coef2*wsnow)*0.001
      ustsq = cdrag*wsnow**2
      ustar = sqrt(ustsq)


      C = G/(ZPI*freq)
      DO kk = 1,nang
         TH(kk) = angl(kk)
      ENDDO
      
      wdoutr = (wdout-180)
      if (wdoutr .lt. 0) wdoutr = wdoutr + 360
      wdoutr = wdoutr * pi/180.0e0 

      e1 = 0.
      DO mm = 1,nfrq
         CM = FRIC/C(mm)
         DO kk=1,nang
           THK=TH(kk)
           SIS = 1.2*ustar*COS(THK-wdoutr)
           if (cm*sis<1.0) e1(kk,mm) = e(kk,mm)
        END DO
     END DO
!--------------------------------------------------------------------------
!  Wind Sea Calculations
      CALL TOTAL_ENERGY (1,nang,nfrq,e-e1,freq,DFIM,delth,hscale,mosea)
      Hmosea = 4.0e0*sqrt(mosea)

      CALL PEAK_PERIOD (nang,nfrq,delth,e-e1,freq,tpsea,tpps)

      CALL FEMEAN (1,nang,nfrq,delth,e-e1,freq,mosea,DFIM,fm)
      tmsea = 1/fm

      CALL TM1_TM2_PERIODS (nang,nfrq,delth,e-e1,freq,mosea,DFIM,DFFR,DFFR2,TM1sea,TM2sea)

      CALL MEAN_DIRECTION (nang,nfrq,delth,e-e1,DFIM,angl,THQ,SPREAD)
      dirtsea = THQ * 180/pi
      dirtsea = dirtsea + 180.0
      if (dirtsea .ge. 360.0) dirtsea = dirtsea - 360.0
      sprtsea = SPREAD * 180/pi

!---------------------------------------------------------------------------
!  Swell Calculations
      CALL TOTAL_ENERGY (1,nang,nfrq,e1,freq,DFIM,delth,hscale,moswe)
      Hmoswe = 4.0e0*sqrt(moswe)

      CALL PEAK_PERIOD (nang,nfrq,delth,e1,freq,tpswe,tppw)

      CALL FEMEAN (1,nang,nfrq,delth,e1,freq,moswe,DFIM,fm)
      tmswe = 1/fm

      CALL TM1_TM2_PERIODS (nang,nfrq,delth,e1,freq,moswe,DFIM,DFFR,DFFR2,TM1swe,TM2swe)

      CALL MEAN_DIRECTION (nang,nfrq,delth,e1,DFIM,angl,THQ,SPREAD)
      dirtswe = THQ * 180/pi
      dirtswe = dirtswe + 180.0
      if (dirtswe .ge. 360.0) dirtswe = dirtswe - 360.0
      sprtswe = SPREAD * 180/pi

      IF (zz .eq. 1) THEN
        qq = 1
        rr = 1
        idateo = idate
!        nsta1 = nsta-1
        fileout1 = 'WW3-Pac-'//FILE01(5:8)//'.onlns'
        OPEN (9, FILE = fileout1, STATUS = "UNKNOWN")
      ENDIF
      IF (pp .gt. nn) THEN
        nn = pp
        fileout = 'ST'//stac//'.onlns'
        OPEN (fpar, FILE = fileout, STATUS = "UNKNOWN")
      ENDIF
      write(9,250)qq,rr,time1,time2,nsta,xlat,xlon,wsnow,wdout,ustar,cdrag*1000, &
                 norm,Hmo,tp,tpp,tm,TM1,TM2,dirt,sprt,Hmosea,tpsea,tpps,   &
                 tmsea,TM1sea,TM2sea,dirtsea,sprtsea,Hmoswe,tpswe,tppw,      &
                 tmswe,TM1swe,TM2swe,dirtswe,sprtswe

      write(fpar,201)time1,time2,nsta,xlat,xlon,wsnow,wdout,ustar,cdrag*1000, &
                 norm,Hmo,tp,tpp,tm,TM1,TM2,dirt,sprt,Hmosea,tpsea,tpps,   &
                 tmsea,TM1sea,TM2sea,dirtsea,sprtsea,Hmoswe,tpswe,tppw,      &
                 tmswe,TM1swe,TM2swe,dirtswe,sprtswe


      ENDDO

  211 deallocate(e,freq,DFIM,DFFR,DFFR2,C,TH,e1,col1,angl)

    
      CLOSE(01)
      CLOSE(10)
      CLOSE(11)
      CLOSE(09)
      STOP 
  100 format(27x,i3,3x,i3,3x,i3)
  101 format(i8,1x,a6)
  102 format(1x,i5,6x,2f7.2,f10.1,f7.2,f6.1)
  103 format(7(f11.3))
!  101 format(1x,i4,2i4,2f10.5,f7.1,i11,2i4,f13.7,5f7.1,f7.4)   
!  102 format(10(e12.4))
  201 format(i8,a6,1x,i6,1x,2f10.3,f7.1,f6.0,3f8.2,3(6f8.2,2f6.0))
  202 format(16(e12.4))
  250 format(2i5,1x,i8,a6,1x,i6,1x,2f10.3,f7.1,f6.0,3f8.2,3(6f8.2,2f6.0))
!FORMAT(i5,I5,1X,A14,1X,A6,1X,2F8.3,F7.1,F6.0,F8.2,F8.2,F8.2,3(5F8.2,2F6.0)

      END PROGRAM

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
SUBROUTINE TOTAL_ENERGY (qq,nang, nfrq, F3, FR, DFIM2, delth, hscale, EMEAN)

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
     PPP = 1./(PPF + -1.0E-10)

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
SUBROUTINE MEAN_DIRECTION (nang, nfrq, delth, F3, DFIM, angl,THQ, SPREAD)

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

!-----------------------------------------------------------------------------
!-----------------------------------------------------------------------------
!-----------------------------------------------------------------------------
!SUBROUTINE SWELL_SEPARATION (nang,nfrq,FL3, FL1)

! ---------------------------------------------------------------------------- !
!                                                                              !
!   SWELL_SEPARATION - COMPUTES THE SWELL SPECTRUM AND INTEGRATED PARAMETER    !
!                      OF SWELL AND WINDSEA.                                   !
!                                                                              !
!     P.LIONELLO     FEBRUARY 87                                               !
!                                                                              !
!     L.ZAMBRESKY    NOVEMBER 87   GKSS/ECMWF   OPTIMIZED SUB.                 !
!     H. GUENTHER    FEBRUARY 2002   GKSS       FT90 AND INTEGRATED PARAMETERS !
!     A. Behrens     December 2003 MSC/GKSS     Message passing                !
!     E. Myklebust   February 2005              MPI parallelization
!                                                                              !
!     PURPOSE.                                                                 !
!     --------                                                                 !
!                                                                              !
!       TO SEPARATE THE SWELL FROM THE WIND INTERACTING SEA AND COMPUTE        !
!       INTEGRATED PARAMETER FOR BOTH SYSTEMS.                                 !
!                                                                              !
!     METHOD.                                                                  !
!     -------                                                                  !
!                                                                              !
!       THE WAVES WHICH DO NOT INTERACT WITH THE WIND ARE CONSIDERED SWELL.    !
!                                                                              !
! ---------------------------------------------------------------------------- !
!                                                                              !
!     INTERFACE VARIABLES.                                                     !
!     --------------------                                                     !

!dimension FL3(nang,nfrq), FL1(nang,nfrq)!! BLOCK OF SPECTRA.

! ---------------------------------------------------------------------------- !
!                                                                              !
!     LOCAL VARIABLES.                                                         !
!     ----------------                                                         !

!REAL, PARAMETER :: FRIC = 28.

!INTEGER  :: K, M, ij
!REAL     :: CM
!REAL     :: SIS, THK
!INTEGER :: IJS, IJL

! ---------------------------------------------------------------------------- !
!                                                                              !
!     1. THE SWELL DISTRIBUTION IS COMPUTED.                                   !
!        -----------------------------------                                   !
!
!FL1 = 0.
!DO M = 1,ML
!   CM = FRIC/C(M)
!   DO K=1,KL
!      THK=TH(K)
!      do ij=ijs, ijl
!         SIS = 1.2*USTAR(ij)*COS(THK-UDIR(ij))
!         if (cm*sis<1.0) fl1(ij,k,m) = fl3(ij,k,m)
!      END DO
!   END DO
!enddo
!! ---------------------------------------------------------------------------- !
!!                                                                              !
!!     2. COMPUTATION INTEGRATED PARAMETER FOR WINDSEA.                         !
!!        ---------------------------------------------                         !
!
!IF (CFLAG_P(17).OR.ANY(CFLAG_P(19:21))) THEN
!   CALL TOTAL_ENERGY (FL3-FL1, BLOCK(IJS:IJL,17))
!   IF (CFLAG_P(19)) THEN
!      CALL FEMEAN (FL3-FL1, BLOCK(IJS:IJL,17), FM=BLOCK(IJS:IJL,19))
!      BLOCK(:,19) = 1./BLOCK(:,19)
!   END IF
!   IF (CFLAG_P(20).AND.CFLAG_P(21)) THEN
!      CALL TM1_TM2_PERIODS (FL3-FL1, BLOCK(IJS:IJL,17), TM1=BLOCK(IJS:IJL,20), &
!&                                                       TM2=BLOCK(IJS:IJL,21))
!   ELSE IF (CFLAG_P(20)) THEN
!      CALL TM1_TM2_PERIODS (FL3-FL1, BLOCK(IJS:IJL,17), TM1=BLOCK(IJS:IJL,20))
!   ELSE IF (CFLAG_P(21)) THEN
!      CALL TM1_TM2_PERIODS (FL3-FL1, BLOCK(IJS:IJL,17), TM2=BLOCK(IJS:IJL,21))
!   END IF
!   IF (CFLAG_P(17)) BLOCK(IJS:IJL,17) = 4.*SQRT(BLOCK(IJS:IJL,17))
!END IF
!
!IF (CFLAG_P(18)) CALL PEAK_PERIOD (FL3-FL1,BLOCK(IJS:IJL,18))
!
!IF (CFLAG_P(22).AND.CFLAG_P(23)) THEN
!   CALL MEAN_DIRECTION (FL3-FL1, THQ=BLOCK(IJS:IJL,22),                        &
!&                                SPREAD=BLOCK(IJS:IJL,23))
!ELSE IF (CFLAG_P(22)) THEN
!   CALL MEAN_DIRECTION (FL3-FL1, THQ=BLOCK(IJS:IJL,22))
!ELSE IF (CFLAG_P(23)) THEN
!   CALL MEAN_DIRECTION (FL3-FL1, SPREAD=BLOCK(IJS:IJL,23))
!END IF
!IF (CFLAG_P(22)) BLOCK(IJS:IJL,22) = BLOCK(IJS:IJL,22)*DEG
!IF (CFLAG_P(23)) BLOCK(IJS:IJL,23) = BLOCK(IJS:IJL,23)*DEG
!
!! ---------------------------------------------------------------------------- !
!!                                                                              !
!!     3. COMPUTATION INTEGRATED PARAMETER FOR SWELL.                           !
!!        -------------------------------------------                           !
!
!IF (CFLAG_P(25).OR.ANY(CFLAG_P(27:29))) THEN
!   CALL TOTAL_ENERGY (FL1, BLOCK(IJS:IJL,25))
!   IF (CFLAG_P(27)) THEN
!      CALL FEMEAN (FL1,  BLOCK(IJS:IJL,25), FM=BLOCK(IJS:IJL,27))
!      BLOCK(IJS:IJL,27) = 1./BLOCK(IJS:IJL,27)
!   END IF
!   IF (CFLAG_P(28).AND.CFLAG_P(29)) THEN
!      CALL TM1_TM2_PERIODS (FL1, BLOCK(IJS:IJL,25), TM1=BLOCK(IJS:IJL,28),     &
!&                                                   TM2=BLOCK(IJS:IJL,29))
!   ELSE IF (CFLAG_P(28)) THEN
!      CALL TM1_TM2_PERIODS (FL1, BLOCK(IJS:IJL,25), TM1=BLOCK(IJS:IJL,28))
!   ELSE IF (CFLAG_P(29)) THEN
!      CALL TM1_TM2_PERIODS (FL1, BLOCK(IJS:IJL,25), TM2=BLOCK(IJS:IJL,29))
!   END IF
!   IF (CFLAG_P(25)) BLOCK(IJS:IJL,25) = 4.*SQRT( BLOCK(IJS:IJL,25))
!END IF
!
!IF (CFLAG_P(26)) CALL PEAK_PERIOD (FL1, BLOCK(IJS:IJL,26))
!
!IF (CFLAG_P(30).AND.CFLAG_P(31)) THEN
!   CALL MEAN_DIRECTION (FL1, THQ=BLOCK(IJS:IJL,30), SPREAD=BLOCK(IJS:IJL,31))
!ELSE IF (CFLAG_P(30)) THEN
!   CALL MEAN_DIRECTION (FL1, THQ=BLOCK(IJS:IJL,30))
!ELSE IF (CFLAG_P(31)) THEN
!   CALL MEAN_DIRECTION (FL1, SPREAD=BLOCK(IJS:IJL,31))
!END IF
!IF (CFLAG_P(30)) BLOCK(IJS:IJL,30) = BLOCK(IJS:IJL,30)*DEG
!IF (CFLAG_P(31)) BLOCK(IJS:IJL,31) = BLOCK(IJS:IJL,31)*DEG
!END SUBROUTINE SWELL_SEPARATIO
