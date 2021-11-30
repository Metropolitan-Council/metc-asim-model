FILEO PRINTO[1] = "%SCENARIO_DIR%\TourCastStatus.prn"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

; 
; Build a batchfile to drive TourCast and show outputs (calling direct from Cube hides status)
;

* echo %echo on > TourCastRun.bat
* echo %cd ..\TourCast\bin >> TourCastRun.bat
* echo %echo TourCast Aborted ^> ..\..\Cube\TC_error.txt >> TourCastRun.bat
;
; Vehicle Availability Sequence
;
IF (%TC_vehavail% == 1)

  * echo ModelEngine.exe VehicleAvailabilityModel.py >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe VehicleAvailabilityModelPostProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat

ENDIF

;
; School Location
;
IF (%TC_schLocation% == 1)

  * echo ModelEngine.exe SchoolLocationConstrChoice.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  
ENDIF

;
; Usual Work Location
;
IF (%TC_workLocation% == 1)

  * echo ModelEngine.exe WorkplaceLocationChoiceModelPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat    
  * echo ModelEngine.exe UsualWorkplaceLocationChoiceModel.py UsualWorkplaceLocationTourModeChoiceLogsumModel.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat    
  
ENDIF

;
; Pass Models
;
IF (%TC_pass% == 1)
  * echo ModelEngine.exe PassModels.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
    
ENDIF

;
; DAP
;
IF (%TC_DAP% == 1)
  * echo ModelEngine.exe DailyActivityPatternModelPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe DailyActivityPatternModel.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat      
ENDIF

;
; Mandatory Tour Destination Choice (Work and University)
;
IF (%TC_mandTourDest% == 1)
  * echo ModelEngine.exe TourDestinationChoiceUniversity.py  TourModeChoiceLogsum_SchoolLocation.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourDestinationChoiceWork.py TourModeChoiceLogsum_Work.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Mandatory Tour TOD
;
IF (%TC_mandTourTOD% == 1)
  * echo ModelEngine.exe MandatoryTourTimeOfDayChoiceModelPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourTimeOfDayDAPFirstTours.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourTimeOfDayDAPSecondTours.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  
ENDIF

;
; School Escorting
;
IF (%TC_schEscort% == 1)
  * echo ModelEngine.exe SchoolEscortModel.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Fully Joint Tours
;
IF (%TC_FJ% == 1)
  * echo ModelEngine.exe FullyJointTourPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe FullyJointTour.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe FullyJointTourDestinationChoice.py TourModeChoiceLogsum_FullyJoint.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe FullyJointTourTimeOfDay.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF
  
;
; INM Tours
;
IF (%TC_INM% == 1)
  * echo ModelEngine.exe IndividualNonMandatoryPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe IndividualNonMandatory.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe IndividualNonMandatoryEscortTourDestinationChoice.py TourModeChoiceLogsum_IndividualNonMandatory_Escort.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe IndividualNonMandatoryTourDestinationChoice.py TourModeChoiceLogsum_IndividualNonMandatory.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourTimeOfDayIndNonMandNonEscort.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourTimeOfDayIndNonMandEscort.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Stop Generation
;
IF (%TC_stopGen% == 1)
  * echo ModelEngine.exe StopGeneration.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Home-Based Tour Mode Choice
;
IF (%TC_tourMC% == 1)
  * echo ModelEngine.exe TourModeChoiceHomeBased.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Work-Based Tours
;
IF (%TC_WB% == 1)
  * echo ModelEngine.exe WorkBasedSubTourPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedSubTour.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedTourDestinationChoice.py TourModeChoiceLogsum_WorkBased.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedTourTimeOfDay.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedStopGeneration.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedTourModeChoice.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Stop-Level Models
;
IF (%TC_stopDestTOD% == 1)
  * echo ModelEngine.exe StopDestination.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe StopTimeOfDay.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Trip Mode Choice
;
IF (%TC_tripMC% == 1)
  * echo ModelEngine.exe TripModeChoice.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Write error checking to TourCastRun.bat
;
* echo %del ..\..\Cube\TC_error.txt >> TourCastRun.bat
* echo exit >> TourCastRun.bat
* echo :TCERROR >> TourCastRun.bat
* echo %echo TourCast Component Failed
* echo %echo TourCast Error ^> ..\..\Cube\TC_error.txt >> TourCastRun.bat
* echo %pause >> TourCastRun.bat
* echo exit >> TourCastRun.bat

* start /wait TourCastRun.bat
* dir TC_error.txt
  IF (ReturnCode == 0) 
    PRINT LIST='TourCast Model Error - see log files for more information'
    * type TC_error.txt
    abort
  ENDIF 
