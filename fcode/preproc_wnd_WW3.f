c Program to read winds from Oceanweather and convert to WAM format

      Dimension u(1000,1000), v(1000,1000),
     .          uin(1000,1000), vin(1000,1000)
      Character *8 forma
      Integer*8 idate, kdate, kstart, kend, kstart2, kend2, kdate2,
     .              idate2
c
c
c  Flags for the WAM Wind Field
c       Header Record for WAM generated from the Wind Field Header
c       This code should be generic NOW.
c
c  HARD WIRED FOR WIND AND WAVE MODEL GRIDS TO BE CONSISTENT
c  =========================================================
c    
      icoord = 1
      iper = 1
      icode = 3
      forma = '(12f6.2)'
      nwinds = 0
c
c  Formats
c
  200 format(2i6,4f10.3,3i4)
  205 format(a8)
c
  120 format (5x,i4,6x,i4,3x,f6.4,3x,f6.4,6x,f8.3,6x,f8.3,3x,i8,i4)
c i12 changed to i8 TJH 
  130 format(8f10.4)

  210 format(i14)
  220 format(12f6.2)
  230 format (1x,i14,2x,i14)
  235 format (2x,i10,2x,i10)

  300 format (2x,'Date Processed = ',i14)
  305 format (2x,'Date Processed = ',i14,'  WS < 2.5 = ',i8)
  310 format (2x,'Date Processed = ',i14, '  No. Bad Winds = ',i5,
     .            '  NS Bad Winds = ',i5, '  EW Bad Winds = ',i5)
   13 format(12f6.2)
  400 format (1x,'Original  w = ', i14, 6f10.3)
  410 format (1x,'Corrected w = ', i14, 4f10.3)
c
      read(02,*)
	
   50 read(02,120,end=99) nrread,ncread,dely,delx,swlat,swlon,kdate,
     &                   kdate2
!      idate = 100*kdate
       idate = kdate
       idate2 = kdate2*100
      read(02,130) ((uin(i,j), i=1,ncread), j=1,nrread)
      read(02,130) ((vin(i,j), i=1,ncread), j=1,nrread)
c

      nwinds = nwinds + 1
      if (nwinds .eq. 1)  then
	  kstart1 = idate
          kstart2 = idate2
	  rlats = swlat
	  rlatn = swlat + dely*float(nrread-1)
	  rllonl = swlon
	  rllonr = swlon + delx*float(ncread-1)
!          Write (12,200)ncread,nrread,rlats,rlatn,rllonl,rllonr,
!     &                  icoord,iper,icode
!          Write (12,205) forma
      endif
c
      write(12,'(i10.8,i7.6)') idate, idate2
	Print 210, idate
      kend1 = idate
      kend2 = idate2
c
c
c  Set the output winds to to the input winds
c
      do 22 j=1,nrread
        do 2 i=1,ncread
         u(i,j) = uin(i,j)
         v(i,j) = vin(i,j)
    2   continue
   22 continue
c
c  Check on zero wind speed for water points.
c
      kbad_wnd   = 0
      do 33 j=1,nrread
	  xlat = rlats + dely*(j-1)
        do 3 i=1,ncread
 	    xlong = rllonl + delx*(i-1)
          w= sqrt(uin(i,j)*uin(i,j) + vin(i,j)*vin(i,j))

c          if (w .le. 2.5 ) then
c	      kbad_wnd = kbad_wnd + 1
c	      ang = atan2(vin(i,j),uin(i,j))
c	      u(i,j) = 2.5 * cos(ang)
c	      v(i,j) = 2.5 * sin(ang)
c	    endif
    3   continue
   33 continue
c
c     Print 305, idate, kbad_wnd 
      do j = 1,nrread
         Write (12,'(12f8.3)') (u(i,j), i=1,ncread)
      enddo
      do j = 1,nrread
      	Write (12,'(12f8.3)') (v(i,j), i=1,ncread)
      enddo

      go to 50
   99 continue
c
c  Write out TWO FILES 
c     1.  FOR WAM_User [start and end dates]
c     2.  FOR POST PROCESSING HEADER RECORD
c
      Write (20,'(2(i10.8,i7.6))')  kstart1,kstart2,kend1,kend2
c      kstart2 = kstart / 10000
c      kend2   = kend / 10000
c      Write (21,235)  kstart2, kend2
c
c 
      stop
      end

