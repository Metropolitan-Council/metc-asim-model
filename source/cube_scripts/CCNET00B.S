;;<<Process Template>><<NETWORK>><<Network>><<Highway>><<Compare>>;;
;%Title,note,12,"Compare 2 Highway Networks"%>>>
;%note1,note,10,"Compare 2 highway networks and flags the links that are different"%>>> 
;%note2,note,10,"Input / Output Specification"%>>> 
;Input  Highway Network File 1: %neti1,filename,"Enter Input Highway Network File 1 Name",x,"","Network File (*.net)|*.net"%
;Input  Highway Network File 2: %neti2,filename,"Enter Input Highway Network File 2 Name",x,"","Network File (*.net)|*.net"%
;Output Highway Network File:   %neto,filename,"Enter Output Highway Network File Name",x,"","Network File (*.net)|*.net"%
;;<<End Parameters>>;;

RUN PGM=NETWORK

; Compare 2 highway networks and flags the links that are different

FILEI NETI[1]=%neti1.q%
FILEI NETI[2]=%neti2.q%

FILEO NETO=%neto.q%

  MERGE RECORD=T 

  PHASE=LINKMERGE

    COMPARE RECORD=1-2, LIST=20  ; compare link record 1 with 2

    CMPFLAG=_COMPARE             ; save comparison flag

                                 ; -2 = link in NET1, not in NET2 

                                 ; -1 = link in NET2, not in NET1    

                                 ;  0 = links identical

                                 ; +n = number of attributes that are different

ENDRUN


