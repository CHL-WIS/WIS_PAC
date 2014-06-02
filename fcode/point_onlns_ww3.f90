program point_onlns_ww3
!
implicit none
! -------------------------------------------------------------------
! -------------------------------------------------------------------
!  Convert tab32, tab33, and tab34 into a onlns file
!
!  Created 06/03/11 by TJ Hesser
!
! -------------------------------------------------------------------

character(2) :: mon,day,hour,min,sec,dumm
character(4) :: year
character(14) :: time
character(31) :: fileout
integer :: ii, jj, kk, zz, qq, npoint, npp, pp, ppp
real, dimension(500) :: lon,lat,dep,uc,cdir,u10,udir,hs,wl,tmm,wdir,wspr, &
                         fpp,ppdir,ppspr,ustar,cd,tpp,xlon,xlat
character(5), dimension(500) :: stac 

      OPEN(11,FILE = "tab32.ww3",status="old")
      OPEN(12,FILE = "tab33.ww3",status="old")
      OPEN(13,FILE = "tab34.ww3",status="old")
      OPEN(14,FILE = "Output_Locs.txt",status="old")

      read(14,*)
      read(14,*)
      read(14,*)
      DO qq = 1,500
          read(14,151,end=91) xlon(qq),xlat(qq),stac(qq)
          npp = qq
      ENDDO
   91 continue
      DO zz = 1,999999
        read(11,101) year,mon,day,hour,min,sec
        time = year//mon//day//hour//min//sec
        IF (zz .eq. 1) then
          fileout="WW3-PACIFIC-Basin-"//year//"-"//mon//".onlns"
          OPEN(21,FILE = fileout,status="unknown")
        ENDIF
!        print *, time
        ppp = 0
        read(11,*)
        read(11,*)
        read(11,*)
        read(11,*)
        DO jj = 1,500
          read(11,102,end=99)lon(jj),lat(jj),dep(jj),uc(jj),cdir(jj),u10(jj),udir(jj)
          if (lon(jj) .eq. 0.0) then 
              npoint = jj-1
              go to 98
          endif
        ENDDO
    98  read(11,*)
        ppp = 1
!    99    print *, lon(1), lat(1)

    99  read(12,*)
        read(12,*)
        read(12,*)
        read(12,*)
        read(12,*)
        DO jj = 1,npoint
          read(12,103) hs(jj),wl(jj),tmm(jj),wdir(jj),wspr(jj),fpp(jj),ppdir(jj),ppspr(jj)
        ENDDO
        IF (ppp .eq. 1) then
          read(12,*)
          read(12,*)    
        ENDIF
 
        read(13,*)
        read(13,*)
        read(13,*)
        read(13,*)
        read(13,*)
        DO jj = 1,npoint
          read(13,104) ustar(jj),cd(jj)
        ENDDO
        IF (ppp .eq. 1) then
          read(13,*)
          read(13,*)     
        ENDIF

        pp = 0
        DO jj = 1,npp
!          pp = pp + 1
          DO pp = 1, npoint
!          print *, lon(pp), xlon(jj), lat(pp), xlat(jj)
          if (lon(pp) .eq. xlon(jj) .AND. lat(pp) .eq. xlat(jj)) then
             tpp(pp) = 1/(fpp(pp))
             if (fpp(pp) .eq. 0.0) tpp(pp) = 1.0
             wdir(pp) = 180.0 + wdir(pp)
             if (wdir(pp) .ge. 360.0) wdir(pp) = wdir(pp) - 360.0
             write(21,201)zz,jj,time,stac(jj),lat(pp),lon(pp),u10(pp),udir(pp),ustar(pp),cd(pp), &
                        -999.99,hs(pp),tpp(pp),-999.99,tmm(pp),-999.99,-999.99,wdir(pp),wspr(pp)
             go to 40
          elseif (pp .eq. npoint) then
!          if (lon(pp) .ne. xlon(jj) .OR. lat(pp) .ne. xlat(jj)) then
             write(21,201)zz,jj,time,stac(jj),xlat(jj),xlon(jj),-999.9,-999.,-999.99,-999.99, &
                       -999.99,-999.99,-999.99,-999.99,-999.99,-999.99,-999.99,-999.,-999.
!          pp = pp - 1
!          else 
!          tpp(pp) = 1/(fpp(pp))
!          if (fpp(pp) .eq. 0.0) tpp(pp) = 1.0
!          write(21,201)zz,jj,time,stac(jj),lat(pp),lon(pp),u10(pp),udir(pp),ustar(pp),cd(pp), &
!                        -999.99,hs(pp),tpp(pp),-999.99,tmm(pp),-999.99,-999.99,wdir(pp),wspr(pp)
          ENDIF
        ENDDO
!   40 continue
   40 ENDDO
      IF (ppp .eq. 0) go to 96
      ENDDO
   96 continue
       
      close(11)
      close(12)
      close(13)
      close(14)
      close(21)


  101 format(8x,a4,5(1x,a2))
  102 format(2x,2f8.3,f10.1,2(f6.2,f7.1))
  103 format(19x,f8.3,2(f7.1,f7.2),f8.4,f7.1,f7.2)
  104 format(21x,f7.4,23x,f6.3)
  151 format(1x,f8.2,1x,f6.2,3x,a5)
  201 format(2i5,1x,a14,1x,a5,1x,2f8.3,f7.1,f6.0,9f8.2,2f6.0)
     end program
