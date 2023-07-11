FILEO PRINTO[1] = "%SCENARIO_DIR%\TourCastStatus.prn"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;
; Vehicle Availability Sequence
;
IF (%TC_vehavail% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\VehicleAvailabilityModel.py" 
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\VehicleAvailabilityModelPostProcessor.py" 
ENDIF

;
; School Location
;
IF (%TC_schLocation% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\SchoolLocationConstrChoice.py" 
ENDIF

;
; Usual Work Location
;
IF (%TC_workLocation% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\WorkplaceLocationChoiceModelPreProcessor.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\UsualWorkplaceLocationChoiceModel.py" "%CATALOG_DIR%\TourCast\Script\UsualWorkplaceLocationTourModeChoiceLogsumModel.py" 
ENDIF

;
; Pass Models
;
IF (%TC_pass% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\PassModels.py" 
ENDIF

;
; DAP
;
IF (%TC_DAP% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\DailyActivityPatternModelPreProcessor.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\DailyActivityPatternModel.py" 
ENDIF

;
; Mandatory Tour Destination Choice (Work and University)
;
IF (%TC_mandTourDest% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\TourDestinationChoiceUniversity.py" "%CATALOG_DIR%\TourCast\Script\TourModeChoiceLogsum_SchoolLocation.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\TourDestinationChoiceWork.py" "%CATALOG_DIR%\TourCast\Script\TourModeChoiceLogsum_Work.py" 
ENDIF

;
; Mandatory Tour TOD
;
IF (%TC_mandTourTOD% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\MandatoryTourTimeOfDayChoiceModelPreProcessor.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\TourTimeOfDayDAPFirstTours.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\TourTimeOfDayDAPSecondTours.py" 
ENDIF

;
; School Escorting
;
IF (%TC_schEscort% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\SchoolEscortModel.py" 
ENDIF

;
; Fully Joint Tours
;
IF (%TC_FJ% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\FullyJointTourPreProcessor.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\FullyJointTour.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\FullyJointTourDestinationChoice.py" "%CATALOG_DIR%\TourCast\Script\TourModeChoiceLogsum_FullyJoint.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\FullyJointTourTimeOfDay.py" 
ENDIF
  
;
; INM Tours
;
IF (%TC_INM% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\IndividualNonMandatoryPreProcessor.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\IndividualNonMandatory.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\IndividualNonMandatoryEscortTourDestinationChoice.py" "%CATALOG_DIR%\TourCast\Script\TourModeChoiceLogsum_IndividualNonMandatory_Escort.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\IndividualNonMandatoryTourDestinationChoice.py" "%CATALOG_DIR%\TourCast\Script\TourModeChoiceLogsum_IndividualNonMandatory_Escort.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\TourTimeOfDayIndNonMandNonEscort.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\TourTimeOfDayIndNonMandEscort.py" 
ENDIF

;
; Stop Generation
;
IF (%TC_stopGen% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\StopGeneration.py" 
ENDIF

;
; Home-Based Tour Mode Choice
;
IF (%TC_tourMC% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\TourModeChoiceHomeBased.py" 
ENDIF

;
; Work-Based Tours
;
IF (%TC_WB% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\WorkBasedSubTourPreProcessor.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\WorkBasedSubTour.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\WorkBasedTourDestinationChoice.py" "%CATALOG_DIR%\TourCast\Script\TourModeChoiceLogsum_WorkBased.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\WorkBasedTourTimeOfDay.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\WorkBasedStopGeneration.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\WorkBasedTourModeChoice.py" 
ENDIF

;
; Stop-Level Models
;
IF (%TC_stopDestTOD% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\StopDestination.py" 

  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\StopTimeOfDay.py" 
ENDIF

;
; Trip Mode Choice
;
IF (%TC_tripMC% == 1)
  * "%CATALOG_DIR%\TourCast\bin\ModelEngine.exe" "%CATALOG_DIR%\TourCast\Script\TripModeChoice.py" 
ENDIF

