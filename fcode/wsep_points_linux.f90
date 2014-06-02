!-------------------------------------------------------------------------
!    program wsep_points
!-------------------------------------------------------------------------
!
!    find output points in windsea and swell sereration field files 
!
!    created 05/25/11 TJ Hesser
!
!-------------------------------------------------------------------------
      implicit none

character(len=2) :: mon,day,hour,min,sec,dumm
character(len=4) :: year
character*160 :: fname
character(len=14) :: time1,time2
character(len=16) :: fileout,fileout2
character(len=20) :: filename,file1,file2,file3,file4,file5
integer :: ii,jj,kk,zz
integer :: nlon,nlat
real :: lonw,lone,lats,latn,par
real, allocatable :: Hmo(:,:), Hsw1(:,:), Hsw2(:,:), Hsw(:,:),dep(:,:), &
                     Hss(:,:), Hssmax(:,:),Hsemax(:,:),Hswmax(:,:),Hssm1(:,:) &
                    ,Hssm2(:,:),Hsem1(:,:),Hsem2(:,:),Hswm1(:,:),Hswm2(:,:), &
                     U10max(:,:),U10m1(:,:),U10m2(:,:),u10(:,:),u(:,:),v(:,:)

zz = 1
kk = 0
    1 read(15,'(a20)',end=888) filename
!      print *, filename
file1 = filename
file2 = filename(1:13)//'phs_sw1'
file3 = filename(1:13)//'phs_sw2'
file4 = filename(1:13)//'hs'
file5 = filename(1:13)//'wnd'

!read(5,*,end=150) fname
!print *, fname
!150 open(02, file= fname ,status = "old")
!open(02,file = "WAM_ATL_LEVEL1.grd",status = "old")
!open(02,file="pac_i.bot",status = "old")
!open(02,file="pac_c.bot",status="old")
!open(02,file="pac_haw.dep",status = "old")
!open(02,file = fname,status = "old")

open(10,file = file1,status = "old")
open(11,file = file2,status = "old")
open(12,file = file3,status = "old")
open(13,file = file4,status = "old")
open(14,file = file5,status = "old")


read(10,100) year,mon,day,hour,min,sec,lonw,lone,nlon,lats,latn,nlat,par
!print *, year,mon,day,hour,min,sec,lonw,lone,nlon,lats,latn,nlat,par
read(11,'(a2)') dumm
read(12,'(a2)') dumm
read(13,'(a2)') dumm
read(14,'(a2)') dumm

if (zz .eq. 1) then
 allocate(Hmo(nlon,nlat),Hsw1(nlon,nlat),Hsw2(nlon,nlat),Hsw(nlon,nlat), &
           dep(nlon,nlat),Hss(nlon,nlat),Hssmax(nlon,nlat),Hsemax(nlon,nlat) &
           ,Hswmax(nlon,nlat),Hssm1(nlon,nlat),Hssm2(nlon,nlat),Hsem1(nlon,nlat), &
           Hsem2(nlon,nlat),Hswm1(nlon,nlat),Hswm2(nlon,nlat),U10max(nlon,nlat), &
           U10m1(nlon,nlat),U10m2(nlon,nlat),u10(nlon,nlat),u(nlon,nlat),v(nlon,nlat))
zz = 2

DO jj = 1,nlat
   DO ii = 1,nlon
       Hssmax(ii,jj) = 0.0
       Hsemax(ii,jj) = 0.0
       Hswmax(ii,jj) = 0.0
       U10max(ii,jj) = 0.0
  
       Hssm1(ii,jj) = 0.0
       Hsem1(ii,jj) = 0.0
       Hswm1(ii,jj) = 0.0
       U10m1(ii,jj) = 0.0
   ENDDO
ENDDO
time1 = year//mon//day//hour//min//sec
endif
DO jj = 1,nlat
      read(10,*,end=555) (Hmo(ii,jj),ii=1,nlon)
  555 read(11,*,end=556) (Hsw1(ii,jj),ii=1,nlon)
  556 read(12,*,end=557) (Hsw2(ii,jj),ii=1,nlon)
  557 read(13,*,end=558) (Hss(ii,jj),ii=1,nlon)
  558 read(05,*,end=559) (dep(ii,jj),ii=1,nlon)
  559 read(14,*) (u(ii,jj),ii=1,nlon)

ENDDO
DO jj = 1,nlat
      read(14,*,end=600) (v(ii,jj),ii=1,nlon)
ENDDO
  600 DO jj = 1,nlat
         DO ii = 1,nlon
            IF (Hsw1(ii,jj) .le. -999.000 .AND. Hsw2(ii,jj) .le. -999.000) then
               Hsw(ii,jj) = -999.000
            ELSEIF (Hsw1(ii,jj) .le. -999.000 .AND. Hsw2(ii,jj) .ge. 0.0) then
               Hsw(ii,jj) = Hsw2(ii,jj)*par
            ELSEIF (Hsw1(ii,jj) .ge. 0.0 .AND. Hsw2(ii,jj) .le. -999.000) then
               Hsw(ii,jj) = Hsw1(ii,jj)*par
            ELSE 
               Hsw(ii,jj) = 4.0e0*sqrt(((Hsw1(ii,jj)*par)/4.0e0)**2 + ((Hsw2(ii,jj)* &
                               par)/4.0e0)**2)
            ENDIF

            IF (dep(ii,jj) .gt. -1.0e0) then
               Hmo(ii,jj) = -1.0
               Hsw(ii,jj) = -1.0
            ELSEIF (Hmo(ii,jj).le.-999.000)  then
               Hmo(ii,jj) = 0.0
            ELSE 
               Hmo(ii,jj) = Hmo(ii,jj)*par
            ENDIF
            
            IF (Hsw(ii,jj) .le. -999.000) then
               Hsw(ii,jj) = 0.0
            ENDIF 
           
            IF (dep(ii,jj) .gt. -1.0e0) then
                Hss(ii,jj) = -1.0
            ELSEIF (Hss(ii,jj) .le. -999.000) then
                Hss(ii,jj) = 0.0
            ELSE 
                Hss(ii,jj) = Hss(ii,jj)*par
            ENDIF
            
            IF (dep(ii,jj) .gt. -1.0e0) then
                u10(ii,jj) = -1.0
            ELSEIF (u(ii,jj) .le. -999.000 .OR. v(ii,jj) .le. -999.000) then
                u10(ii,jj) = 0.0
            ELSE
                u10(ii,jj) = sqrt((u(ii,jj)*0.1)**2 + (v(ii,jj)*0.1)**2)
            ENDIF
 
            Hssmax(ii,jj) = max(Hssmax(ii,jj),Hss(ii,jj))
            Hsemax(ii,jj) = max(Hsemax(ii,jj),Hmo(ii,jj))
            Hswmax(ii,jj) = max(Hswmax(ii,jj),Hsw(ii,jj))
            U10max(ii,jj) = max(U10max(ii,jj),u10(ii,jj))           

            Hssm1(ii,jj) = Hssm1(ii,jj) + Hss(ii,jj)
            Hsem1(ii,jj) = Hsem1(ii,jj) + Hmo(ii,jj)
            Hswm1(ii,jj) = Hswm1(ii,jj) + Hsw(ii,jj)
            U10m1(ii,jj) = U10m1(ii,jj) + u10(ii,jj)
         ENDDO
      ENDDO
kk = kk + 1
fileout = filename(1:3)//'_'//filename(5:13)//'sep'
open(20,file = fileout,status = "unknown")
write(20,300) year,mon,day,hour,min,sec,lonw,lone,nlon,lats,latn,nlat
write(20,301) ((Hss(ii,jj),ii=1,nlon),jj=1,nlat)
write(20,301) ((Hmo(ii,jj),ii=1,nlon),jj=1,nlat)
write(20,301) ((Hsw(ii,jj),ii=1,nlon),jj=1,nlat)

close(10)
close(11)
close(12)
close(13)
close(14)
close(20)
close(02)

go to 1

  888 continue
time2 = year//mon//day//hour//min//sec
DO jj = 1,nlat
   DO ii = 1,nlon
      IF (dep(ii,jj) .eq. 0.0e0) then
         Hssmax(ii,jj) = -1.0
         Hsemax(ii,jj) = -1.0
         Hswmax(ii,jj) = -1.0
         U10max(ii,jj) = -1.0

         Hssm2(ii,jj) = -1.0
         Hsem2(ii,jj) = -1.0
         Hswm2(ii,jj) = -1.0
         U10m2(ii,jj) = -1.0
      ELSE
         Hssm2(ii,jj) = Hssm1(ii,jj)/kk
         Hsem2(ii,jj) = Hsem1(ii,jj)/kk
         Hswm2(ii,jj) = Hswm1(ii,jj)/kk
         U10m2(ii,jj) = U10m1(ii,jj)/kk
      ENDIF
   ENDDO
ENDDO
fileout2 = 'Max-mean-ww3.dat'
open(21,file = fileout2,status = "unknown")
write(21,302) time1,time2,lonw,lone,nlon,lats,latn,nlat
write(21,301) ((Hssmax(ii,jj),ii=1,nlon),jj=1,nlat)
write(21,301) ((Hssm2(ii,jj),ii=1,nlon),jj=1,nlat)
write(21,301) ((Hsemax(ii,jj),ii=1,nlon),jj=1,nlat)
write(21,301) ((Hsem2(ii,jj),ii=1,nlon),jj=1,nlat)
write(21,301) ((Hswmax(ii,jj),ii=1,nlon),jj=1,nlat)
write(21,301) ((Hswm2(ii,jj),ii=1,nlon),jj=1,nlat)
write(21,301) ((U10max(ii,jj),ii=1,nlon),jj=1,nlat)
write(21,301) ((U10m2(ii,jj),ii=1,nlon),jj=1,nlat)

  deallocate (Hmo,Hsw1,Hsw2,Hsw,Hss,dep,Hssmax,Hsemax,Hswmax,Hssm1,Hssm2, &
               Hsem1,Hsem2,Hswm1,Hswm2,U10max,U10m1,U10m2,u10,u,v)
  100 format(15x,a4,2a2,1x,3a2,2f8.2,i4,2f8.2,i4,6x,f7.4)
  200 format(1X,32f4.0)
  201 format(10f6.0)  
  300 format(a4,2a2,1x,3a2,2f8.2,i4,2f8.2,i4)
  301 format(6f8.2)
  302 format(a14,1x,a14,2f8.2,i4,2f8.2,i4)
END PROGRAM
