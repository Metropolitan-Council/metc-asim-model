RUN PGM = MATRIX MSG='Prepare non-motorized/all-period skims'
FILEI MATI[1] = "%SCENARIO_DIR%\nonmotorized\NM_SKIM.SKM"
FILEO MATO[1] = "%SCENARIO_DIR%\nonmotorized\nmskims.mat", MO = 1, 2, NAME = DISTWALK, DISTBIKE

; Use midday (uncongested) skim for distance, bike and walk are set to this also
MW[1] = MI.1.BIKEDIST
MW[2] = MI.1.WALKDIST
ENDRUN
CONVERTMAT FROM="%SCENARIO_DIR%\nonmotorized\nmskims.mat" TO="%SCENARIO_DIR%\OMX\nmskims.omx" COMPRESSION=4