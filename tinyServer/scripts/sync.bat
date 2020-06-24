chcp 65001
rem robocopy "N:\Martin\TmForever\Tracks\Challenges\My Challenges" "C:\users\schlegel\Documents\TmForever\Tracks\Challenges\My Challenges" /FFT /S

rem robocopy N:\dev D:\dev *.7z /MIR /NP /LEV:1 /FFT /COPY:DT
rem robocopy N:\dev\art.bin D:\dev\art.bin /MIR /COPY:DT
rem robocopy N:\dev\mnh5 D:\dev\mnh5 /S /NP /FFT /COPY:DT /XO
rem robocopy N:\dev\retrospective D:\dev\retrospective /S /NP /FFT /COPY:DT /XO
rem robocopy N:\dev\retrospective D:\dev\retrospective /MIR /COPY:DT
robocopy N:\dev\ib D:\dev\ib *.ib /LEV:1 /MIR /COPY:DT 
robocopy N:\dev\ D:\dev\ *.mnh /LEV:1 /MIR /COPY:DT 

rem robocopy D:\dokumente\Sylwia N:\Sylwia /FFT /S
rem robocopy D:\dokumente\Martin N:\Martin /FFT /S
rem robocopy D:\dokumente\Oskar N:\Oskar /FFT /S

robocopy N:\Sylwia D:\dokumente\Sylwia /FFT /S
robocopy N:\Martin D:\dokumente\Martin /FFT /S
robocopy N:\Oskar D:\dokumente\Oskar /FFT /S

D:
cd dev 
incrementalBackup.mnh