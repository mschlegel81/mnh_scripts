chcp 65001
rem robocopy "N:\Martin\TmForever\Tracks\Challenges\My Challenges" "C:\users\schlegel\Documents\TmForever\Tracks\Challenges\My Challenges" /FFT /S

rem robocopy D:\dokumente\Sylwia N:\Sylwia /FFT /S
rem robocopy D:\dokumente\Martin N:\Martin /FFT /S
rem robocopy D:\dokumente\Oskar N:\Oskar /FFT /S

rem robocopy N:\Sylwia D:\dokumente\Sylwia /FFT /S
rem robocopy N:\Martin D:\dokumente\Martin /FFT /S
rem robocopy N:\Oskar D:\dokumente\Oskar /FFT /S

D:
cd \dev 
mnh -v1 incrementalBackup.mnh restore
robocopy D:\dev\ib D:\backup\dev\ib *.ib /MIR /NP /LEV:1 /FFT /MIR /COPY:DT
robocopy D:\dev D:\backup\dev *.mnh /MIR /NP /LEV:1 /FFT /MIR /COPY:DT 