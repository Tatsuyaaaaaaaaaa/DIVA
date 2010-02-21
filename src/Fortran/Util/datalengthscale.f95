!C
             INTEGER, PARAMETER :: IW = 5000000
             REAL(KIND=4) ::  C(IW),RL(IW),RN(IW)
             REAL(KIND=8) ::  C8,RRR
             REAL(KIND=4) ::  X(IW),Y(IW)
!C Read data (just coordinates, not value)
          
             NDATA=0
 5           continue
             read(40,*,END=99,ERR=99) XX,YY
             NDATA=NDATA+1
             X(NDATA)=XX
             Y(NDATA)=YY
             goto 5
!C
 99          continue
             write(6,*) ' Data read:',NDATA
!C Read grid from a dummy diva run (with L*10 and no error)
!C            call ureadc(C,NX,NY)
             call UREADC(10,c8,C,valex,IPR,NX,NY,NZ,NW)
!C The length scale of a box containing one data point is on average
             
      READ(11,*) x1
      READ(11,*) y1
      READ(11,*) dx
      READ(11,*) dy
      READ(11,*) NXN
      READ(11,*) NYN
      if(NX.NE.NXN.OR.NY.NE.NYN) THEN
      write(6,*) 'Incorrect grid definition??',NX,NXN,NY,NYN
      stop
      endif
      READ(5,*) RATIO
      call RLBIN(C,RN,RL,X,Y,NDATA,X1,Y1,DX,DY,NX,NY,RATIO,VALEX)
      stop
      end
      
      
      
!C From here make a subroutine call to be able to use n(NX,NY) and RL(NX,NY)
             subroutine RLBIN(C,RN,RL,X,Y,NDATA,X1,Y1,DX,DY,NX,NY,RATIO,VALEX)
             REAL(KIND=4) ::  RL(NX,NY)
             REAL(KIND=4) ::  RN(NX,NY)
             REAL(KIND=4) ::  C(NX,NY)
             REAL(KIND=4) ::  X(*),Y(*)
             REAL(KIND=8) ::  RNDATA,RWET,RVAR,C8,RLM
!C Now do binning n(i,j): number of data points in box of size DELTAxDELTA
!C n(NX,NY)
             do i=1,NX
              do j=1,NY
              RN(i,j)=0
              RL(i,j)=1.
              enddo
             enddo
             do ii=1,NDATA
             i=(X(ii)-X1)/DX+1
             if(i.ge.1.and.i.le.NX) then
             j=(Y(ii)-Y1)/DY+1
             if(j.ge.1.and.j.le.NY) then
             RN(i,j)=RN(i,j)+1.
!C             write(6,*) RN(i,j),i,j,X(ii),Y(ii)
             endif
             endif
             enddo
             
!C Save data coverage
            do i=1,NX
             do j=1,NY
             if(C(i,j).EQ.VALEX) RN(i,j)=VALEX
             enddo
            enddo
!C            write(6,*) '??',RN(36,36)
            call UWRITC(21,c8,RN,valex,4,NX,NY,1,NX*NY)
!C            write(6,*) '??',RN(36,36)
            do i=1,NX
             do j=1,NY
             if(C(i,j).EQ.VALEX) RN(i,j)=0
             enddo
            enddo
!C Now calculate the number of data on wet points, the average number
!C per wet point and their variance
             RNDATA=0
             RWET=0
             RVAR=0
             do i=1,NX
              do j=1,NY
              if(C(i,j).NE.VALEX) then
!C Wet point
              RNDATA=RNDATA+RN(i,j)
              RWET=RWET+1
              RVAR=RVAR+RN(i,j)*RN(i,j)
              endif
              enddo
             enddo  
             IF(RWET.LE.0) THEN
!C No data???
             write(6,*) ' No data on the grid? Originally: ',NDATA
             GOTO 100
             ENDIF
             RNDATA=RNDATA/RWET
             RVAR=RVAR/RWET-RNDATA*RNDATA
             RVAR=sqrt(max(RVAR,0.D0))
             RLM=sqrt(DX*DY/RNDATA)
             write(6,*) ' Data on output grid', RNDATA*RWET
             write(6,*) 'Associated mean length', RLM
             write(33,*) ' Mean length scale'
             write(33,*) RLM
             if(RVAR.EQ.0) then
             write(6,*) '???',RVAR
             RVAR=RNDATA
             endif
!C After binning decide which relative length. The minimun and maximum relative length
!C scale have a ratio of RATIO
!C for n(i,j) close to RNDATA: use 1
!C for n(i,j) much smaller than RNDATA: use sqrt(RATIO)
!C for n(i,i) much larger than RNDATA: use 1/sqrt(RATIO)
!C
             RA=1/sqrt(RATIO)
             RB=1/RA
             RDEL=(1-RB)/(RA-1)
             write(6,*) 'RDEL',RDEL,RA,RB,RVAR,RNDATA
             do i=1,NX
                do j=1,NY
                IF(C(i,j).NE.VALEX) then
                XI=(RN(i,j)-RNDATA)/RVAR
                xi=max(xi,-5.)
                xi=min(xi,5.)
                RL(i,j)= (RB*exp(-xi)+RA*RDEL*exp(xi))/(exp(-xi)+RDEL*exp(xi))
                RL(I,J)=sqrt(RATIO)
                if(RN(I,J).gt.0) then
                RL(i,j)=sqrt(RNDATA/RN(I,J))
                endif
                RL(i,j)=max(RL(i,j),RA)
                RL(i,j)=min(RL(i,j),RB)
                endif
                enddo
             enddo
             
!C After this, smooth the RL field by an application of a Laplacian filter at least
!C sqrt(sqrt(NX*NY)) times
!C Take into account exclusion values and boundaries
!C by filling first the grid.
             call ufill(RL,VALEX,NX,NY,1)

             NTIMES=sqrt(sqrt(NX*NY*1.)+1.)/3.+1.
!C             NTIMES=0
             do nn=1,NTIMES
             
             
              do i=2,NX-1
               do j=2,NY-1
               RN(i,j)=(RL(I+1,j)+RL(I-1,j)+RL(i,j+1)+RL(i,j-1))/4.
               enddo
              enddo
!C zero gradient
             do i=1,NX
             RN(i,1)=RL(i,2)
             RN(i,NY)=RL(i,NY-1)
             enddo
             do j=1,NY
             RN(1,j)=RN(2,j)
             RN(NX,j)=RN(NX-1,j)
             enddo

             do i=1,NX
              do j=1,NY
              RL(i,j)=RN(i,j)
              enddo
             enddo
!C Make sure average is 1. Possibly average on 1/RL^2.
!C use only wet point for this average.
             RRR=0
             do i=1,NX
              do j=1,NY
              if(C(i,j).NE.VALEX) then
              RRR=RRR+1./RL(i,j)/RL(i,j)
              endif
              enddo
             enddo
             RRR=RRR/RWET
             write(6,*) 'RRR',RRR
             do i=1,NX
              do j=1,NY
              if(C(i,j).NE.VALEX) then
              RL(i,j)=RL(i,j)*sqrt(RRR)
              endif
              enddo
             enddo
             
             enddo
!C
!C finally put out the RL field and RLinfo.dat
 100        continue
            call UWRITC(20,c8,RL,valex,4,NX,NY,1,NX*NY)
!C Close
      return
      end

      subroutine UFILL(c,valexc,imax,jmax,kmax)
!c                =====
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!c
!c Fills in the standart field C by interpolating the field into the
!c points where there was a exclusion value valexc.
!c The interpolation is continued until the complete field contains
!c regular values
!c
!c JMB 3/4/91
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
       REAL(KIND=4) ::  C(imax,jmax,kmax),valexc
       parameter(iwork=1000000)
       REAL(KIND=4) ::  work(iwork),work2(iwork)
       integer*2 ic(iwork)
       integer*2 ic2(iwork)
       if( (imax+2)*(jmax+2)*(kmax+2).gt.iwork) then
         write(6,*) ' Sorry, UFILL needs more working space'
         return
       endif
!c
       call JM0000(c,valexc,imax,jmax,kmax,work,work2,ic,ic2)
       return
       end
!c
       subroutine JM0000(c,valexc,imax,jmax,kmax,work,work2,ic,ic2)
!c      parameter(A1=5,A2=2,A3=4)
       parameter(A1=5,A2=0,A3=0)
       REAL(KIND=4) ::  C(imax,jmax,kmax),valexc
       REAL(KIND=4) ::  work(0:imax+1,0:jmax+1,0:kmax+1)
       REAL(KIND=4) ::  work2(0:imax+1,0:jmax+1,0:kmax+1)
       integer*2 ic(0:imax+1,0:jmax+1,0:kmax+1)
       integer*2 ic2(0:imax+1,0:jmax+1,0:kmax+1)
!c fill the borders...
       write(6,*) ' Filling in',valexc,imax,jmax,kmax
       do 11 j=0,jmax+1
        do 11 i=0,imax+1
        work(i,j,0)=valexc
        ic(i,j,0)=0
        work(i,j,kmax+1)=valexc
        ic(i,j,kmax+1)=0
 11     continue
       do 12 k=0,kmax+1
        do 12 i=0,imax+1
        work(i,0,k)=valexc
        ic(i,0,k)=0
        work(i,jmax+1,k)=valexc
        ic(i,jmax+1,k)=0
 12     continue
       do 13 k=0,kmax+1
        do 13 j=0,jmax+1
        work(0,j,k)=valexc
        ic(0,j,k)=0
        work(imax+1,j,k)=valexc
        ic(imax+1,j,k)=0
 13     continue
!c
!c copy interior field
        do 100 k=1,kmax
         do 100 j=1,jmax
          do 100 i=1,imax
          work(i,j,k)=c(i,j,k)
          ic(i,j,k)=1
          if(work(i,j,k).eq.valexc) ic(i,j,k)=0
 100    continue
!c
 1000  continue 
       icount=0
       do 500 k=1,kmax
        do 500 j=1,jmax
         do 500 i=1,imax
         work2(i,j,k)=work(i,j,k)
         ic2(i,j,k)=ic(i,j,k)
         if(ic(i,j,k).eq.0 ) then
         work2(i,j,k)=valexc
          icount=icount+1
          isom1=                         &
!c    &      ic(i,j,k+1)+ic(i,j,k-1)
           0.                            &
           +ic(i+1,j,k)+ic(i-1,j,k)      &
           +ic(i,j+1,k)+ic(i,j-1,k)
          isom2=                               &
           ic(i+1,j+1,k+1)+ic(i+1,j+1,k-1)     &
           +ic(i+1,j-1,k+1)+ic(i+1,j-1,k-1)    &
           +ic(i-1,j+1,k+1)+ic(i-1,j+1,k-1)    &
           +ic(i-1,j-1,k+1)+ic(i-1,j-1,k-1)
          isom3=                               &
            ic(i,j+1,k+1)+ic(i,j+1,k-1)        &
          + ic(i,j-1,k+1)+ic(i,j-1,k-1)        &
          + ic(i+1,j,k+1)+ic(i+1,j,k-1)        &
          + ic(i-1,j,k+1)+ic(i-1,j,k-1)        &
          + ic(i+1,j+1,k)+ic(i+1,j-1,k)        &
          + ic(i-1,j+1,k)+ic(i-1,j-1,k)
           isom=isom1*a1+isom2*a2+isom3*a3
           if(isom.ne.0) then
!c interpolate
           rsom1=                             &
!!c    &      ic(i,j,k+1)*work(i,j,k+1)
!c    &     +ic(i,j,k-1)*work(i,j,k-1)
           0.                                 &
          +ic(i+1,j,k)*work(i+1,j,k)          &
          +ic(i-1,j,k)*work(i-1,j,k)          &
          +ic(i,j+1,k)*work(i,j+1,k)          &
          +ic(i,j-1,k)*work(i,j-1,k)
          rsom2=                               &
           ic(i+1,j+1,k+1)*work(i+1,j+1,k+1)   &
          +ic(i+1,j+1,k-1)*work(i+1,j+1,k-1)   &
          +ic(i+1,j-1,k+1)*work(i+1,j-1,k+1)   &
          +ic(i+1,j-1,k-1)*work(i+1,j-1,k-1)   &
          +ic(i-1,j+1,k+1)*work(i-1,j+1,k+1)   &
          +ic(i-1,j+1,k-1)*work(i-1,j+1,k-1)   &
          +ic(i-1,j-1,k+1)*work(i-1,j-1,k+1)   &
          +ic(i-1,j-1,k-1)*work(i-1,j-1,k-1)
          rsom3=                               &
           ic(i,j+1,k+1)*work(i,j+1,k+1)       &
          +ic(i,j+1,k-1)*work(i,j+1,k-1)       &
          +ic(i,j-1,k+1)*work(i,j-1,k+1)       &
          +ic(i,j-1,k-1)*work(i,j-1,k-1)       &
          +ic(i+1,j,k+1)*work(i+1,j,k+1)       &
          +ic(i+1,j,k-1)*work(i+1,j,k-1)       &
          +ic(i-1,j,k+1)*work(i-1,j,k+1)       &
          +ic(i-1,j,k-1)*work(i-1,j,k-1)       &
          +ic(i+1,j+1,k)*work(i+1,j+1,k)       &
          +ic(i+1,j-1,k)*work(i+1,j-1,k)       &
          +ic(i-1,j+1,k)*work(i-1,j+1,k)       &
          +ic(i-1,j-1,k)*work(i-1,j-1,k)
          work2(i,j,k)=(a1*rsom1+a2*rsom2+a3*rsom3)/float(isom)
          ic2(i,j,k)=1
           endif
         endif
 500   continue
       do 501 k=1,kmax
        do 501 j=1,jmax
         do 501 i=1,imax
          work(i,j,k)=work2(i,j,k)
          ic(i,j,k)=ic2(i,j,k)
 501   continue
       if(icount.gt.0) goto 1000
!c
!c fini
       do 99 k=1,kmax
        do 99 j=1,jmax
         do 99 i=1,imax
         c(i,j,k)=work(i,j,k)
 99    continue

       return
       end
