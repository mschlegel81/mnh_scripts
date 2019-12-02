chcp 65001
rem robocopy N:\server D:\server /LEV:1 /MIR /NP /FFT /COPY:DT -XF *.log
rem robocopy N:\server\scripts D:\server\scripts /MIR /NP /FFT /COPY:DT -XF *.log
rem robocopy N:\server\server D:\server\server /MIR /NP /FFT /COPY:DT -XF *.log

rem robocopy "N:\Martin\TmForever\Tracks\Challenges\My Challenges" "C:\users\schlegel\Documents\TmForever\Tracks\Challenges\My Challenges" /FFT /S

robocopy N:\dev D:\dev *.7z /MIR /NP /LEV:1 /FFT /COPY:DT
robocopy N:\dev\art.bin D:\dev\art.bin /MIR /COPY:DT
robocopy N:\dev\mnh5 D:\dev\mnh5 /MIR /NP /FFT /COPY:DT 

robocopy D:\dev D:\backup\dev *.7z /NP /LEV:1 /FFT /COPY:DT
robocopy D:\dev\art.bin D:\backup\dev\art.bin /MIR /COPY:DT

rem robocopy D:\dokumente\Sylwia N:\Sylwia /FFT /S
rem robocopy N:\Sylwia D:\dokumente\Sylwia /FFT /S
rem robocopy D:\dokumente\Martin N:\Martin /FFT /S
rem robocopy N:\Martin D:\dokumente\Martin /FFT /S
rem robocopy D:\dokumente\Oskar N:\Oskar /FFT /S
rem robocopy N:\Oskar D:\dokumente\Oskar /FFT /S
D:
cd dev 
rem rmdir /S /Q 3rd_party
rem "c:\Program Files\7-Zip\7z.exe" x -y 3rd_party.7z
rem rmdir /S /Q art.source
rem "c:\Program Files\7-Zip\7z.exe" x -y art.source.7z
rem del /Q checkstyle*
rem "c:\Program Files\7-Zip\7z.exe" x -y dev.7z
rem "c:\Program Files\7-Zip\7z.exe" x -y mnh5.7z
rem rmdir /S /Q mnh_scripts
rem "c:\Program Files\7-Zip\7z.exe" x -y mnh_scripts.7z
rem rmdir /S /Q retrospective
rem "c:\Program Files\7-Zip\7z.exe" x -y retrospective.7z
rem rmdir /S /Q git
rem "c:\Program Files\7-Zip\7z.exe" x -y git.7z
rem rmdir /S /Q graveyard
rem "c:\Program Files\7-Zip\7z.exe" x -y graveyard.7z
rem rmdir /S /Q Sudoku3
rem "c:\Program Files\7-Zip\7z.exe" x -y Sudoku3.7z
rem rmdir /S /Q web
rem "c:\Program Files\7-Zip\7z.exe" x -y web.7z
demos\inputs\inputs.mnh
cd mnh5
make.mnh status
