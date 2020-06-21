chcp 65001
rem robocopy "N:\Martin\TmForever\Tracks\Challenges\My Challenges" "C:\users\schlegel\Documents\TmForever\Tracks\Challenges\My Challenges" /FFT /S

rem robocopy N:\dev D:\dev *.7z /MIR /NP /LEV:1 /FFT /COPY:DT
robocopy N:\dev\art.bin D:\dev\art.bin /MIR /COPY:DT
rem robocopy N:\dev\mnh5 D:\dev\mnh5 /S /NP /FFT /COPY:DT /XO
rem robocopy N:\dev\retrospective D:\dev\retrospective /S /NP /FFT /COPY:DT /XO
rem robocopy N:\dev\retrospective D:\dev\retrospective /MIR /COPY:DT
robocopy N:\dev\ib D:\dev\ib *.ib /LEV:1 /MIR /COPY:DT 
robocopy N:\dev\ D:\dev\ *.mnh /LEV:1 /MIR /COPY:DT 

rem robocopy D:\dokumente\Sylwia N:\Sylwia /FFT /S
rem robocopy D:\dokumente\Martin N:\Martin /FFT /S
rem robocopy D:\dokumente\Oskar N:\Oskar /FFT /S

rem robocopy N:\Sylwia D:\dokumente\Sylwia /FFT /S
rem robocopy N:\Martin D:\dokumente\Martin /FFT /S
rem robocopy N:\Oskar D:\dokumente\Oskar /FFT /S

D:
cd dev 
incrementalBackup.mnh
cd mnh5
make.mnh status
demos\inputs\inputs.mnh
mnh -v1io -cmd "httpGet('http://192.168.1.100:80/addTask?scriptName=backupDev%2Ebat&cmdLineParameters=')"
mnh -v1io -cmd "httpGet('http://192.168.1.100/addTask?scriptName=buildMnh%2Ebat&cmdLineParameters=status%20build%20status%20test%20status')"
