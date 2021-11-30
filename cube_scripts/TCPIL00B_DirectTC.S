FILEO PRINTO[1] = "%SCENARIO_DIR%\TourCastStatus.prn"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ONRUNERRORGOTO = 'TCError'

;* echo cmd /C ..\TourCast\bin\ModelEngine.exe VehicleAvailabilityModel1.py  > TourCastRun.bat
;* echo IF ERRORLEVEL 2 ECHO "TourCast Error - Continue?" >> TourCastRun.bat 
;* echo pause >> TourCastRun.bat 
;* echo exit /B 2 >> TourCastRun.bat
;* echo pause >> TourCastRun.bat
;* echo exit >> TourCastRun.bat
;** start /wait TourCastRun.bat
;  IF (ReturnCode <> 0) 
;    PRINT LIST='TourCast Vehicle Availability Error - see log files for more information'
;    abort
;  ENDIF

;
; Vehicle Availability Sequence
;
IF (%TC_vehavail% == 1)

  * "..\TourCast\bin\ModelEngine.exe" "VehicleAvailabilityModel.py" 
  * "..\TourCast\bin\ModelEngine.exe" "VehicleAvailabilityModelPostProcessor.py" 

  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Vehicle Availability Error - see log files for more information'
    abort
  ENDIF
ENDIF

;
; School Location
;
IF (%TC_schLocation% == 1)

  * "..\TourCast\bin\ModelEngine.exe" "SchoolLocationConstrChoice.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast School Location Error - see log files for more information'
    abort
  ENDIF
ENDIF

;
; Usual Work Location
;
IF (%TC_workLocation% == 1)

  * "..\TourCast\bin\ModelEngine.exe" "WorkplaceLocationChoiceModelPreProcessor.py" 
  * "..\TourCast\bin\ModelEngine.exe" "UsualWorkplaceLocationChoiceModel.py" "UsualWorkplaceLocationTourModeChoiceLogsumModel.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Usual Work Location Error - see log files for more information'
    abort
  ENDIF
ENDIF

;
; Pass Models
;
IF (%TC_pass% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "PassModels.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Pass Models Error - see log files for more information'
    abort
  ENDIF  
ENDIF

;
; DAP
;
IF (%TC_DAP% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "DailyActivityPatternModelPreProcessor.py" 
  * "..\TourCast\bin\ModelEngine.exe" "DailyActivityPatternModel.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Daily Activity Pattern Error - see log files for more information'
    abort
  ENDIF    
ENDIF

;
; Mandatory Tour Destination Choice (Work and University)
;
IF (%TC_mandTourDest% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "TourDestinationChoiceUniversity.py" "TourModeChoiceLogsum_SchoolLocation.py" 
  * "..\TourCast\bin\ModelEngine.exe" "TourDestinationChoiceWork.py" "TourModeChoiceLogsum_Work.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast School Location Error - see log files for more information'
    abort
  ENDIF      
ENDIF

;
; Mandatory Tour TOD
;
IF (%TC_mandTourTOD% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "MandatoryTourTimeOfDayChoiceModelPreProcessor.py" 
  * "..\TourCast\bin\ModelEngine.exe" "TourTimeOfDayDAPFirstTours.py" 
  * "..\TourCast\bin\ModelEngine.exe" "TourTimeOfDayDAPSecondTours.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Mandatory Tour TOD Error - see log files for more information'
    abort
  ENDIF     
ENDIF

;
; School Escorting
;
IF (%TC_schEscort% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "SchoolEscortModel.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast School Escort Error - see log files for more information'
    abort
  ENDIF     
ENDIF

;
; Fully Joint Tours
;
IF (%TC_FJ% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "FullyJointTourPreProcessor.py" 
  * "..\TourCast\bin\ModelEngine.exe" "FullyJointTour.py" 
  * "..\TourCast\bin\ModelEngine.exe" "FullyJointTourDestinationChoice.py" "TourModeChoiceLogsum_FullyJoint.py" 
  * "..\TourCast\bin\ModelEngine.exe" "FullyJointTourTimeOfDay.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Fully Joint Error - see log files for more information'
    abort
  ENDIF     
ENDIF
  
;
; INM Tours
;
IF (%TC_INM% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "IndividualNonMandatoryPreProcessor.py" 
  * "..\TourCast\bin\ModelEngine.exe" "IndividualNonMandatory.py" 
  * "..\TourCast\bin\ModelEngine.exe" "IndividualNonMandatoryEscortTourDestinationChoice.py" "TourModeChoiceLogsum_IndividualNonMandatory_Escort.py" 
  * "..\TourCast\bin\ModelEngine.exe" "IndividualNonMandatoryTourDestinationChoice.py" "TourModeChoiceLogsum_IndividualNonMandatory_Escort.py" 
  * "..\TourCast\bin\ModelEngine.exe" "TourTimeOfDayIndNonMandNonEscort.py" 
  * "..\TourCast\bin\ModelEngine.exe" "TourTimeOfDayIndNonMandEscort.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Individual Non-Mandatory Error - see log files for more information'
    abort
  ENDIF     
ENDIF

;
; Stop Generation
;
IF (%TC_stopGen% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "StopGeneration.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Stop Generation Error - see log files for more information'
    abort
  ENDIF    
ENDIF

;
; Home-Based Tour Mode Choice
;
IF (%TC_tourMC% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "TourModeChoiceHomeBased.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Tour Mode Choice Error - see log files for more information'
    abort
  ENDIF    
ENDIF

;
; Work-Based Tours
;
IF (%TC_WB% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "WorkBasedSubTourPreProcessor.py" 
  * "..\TourCast\bin\ModelEngine.exe" "WorkBasedSubTour.py" 
  * "..\TourCast\bin\ModelEngine.exe" "WorkBasedTourDestinationChoice.py" "TourModeChoiceLogsum_WorkBased.py" 
  * "..\TourCast\bin\ModelEngine.exe" "WorkBasedTourTimeOfDay.py" 
  * "..\TourCast\bin\ModelEngine.exe" "WorkBasedStopGeneration.py" 
  * "..\TourCast\bin\ModelEngine.exe" "WorkBasedTourModeChoice.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Work Based Subtour Error - see log files for more information'
    abort
  ENDIF    
ENDIF

;
; Stop-Level Models
;
IF (%TC_stopDestTOD% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "StopDestination.py" 
  * "..\TourCast\bin\ModelEngine.exe" "StopTimeOfDay.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Stop-Level Model Error - see log files for more information'
    abort
  ENDIF    
ENDIF

;
; Trip Mode Choice
;
IF (%TC_tripMC% == 1)
  * "..\TourCast\bin\ModelEngine.exe" "TripModeChoice.py" 
  IF (ReturnCode <> 0) 
    PRINT LIST='TourCast Trip Mode Choice Error - see log files for more information'
    abort
  ENDIF    
ENDIF

:TCError
PRINT LIST='TourCast Error - see log files for more information'
