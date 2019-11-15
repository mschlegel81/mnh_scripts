@rem robocopy N:\server D:\server /LEV:1 /MIR /NP /FFT /COPY:DT -XF *.log
@rem robocopy D:\server\scripts N:\server\scripts /FFT -XF sync.bat
@rem robocopy N:\server\scripts D:\server\scripts /FFT
@rem robocopy D:\server\logs N:\server\logs 

@rem robocopy "N:\Martin\TmForever\Tracks\Challenges\My Challenges" "C:\users\schlegel\Documents\TmForever\Tracks\Challenges\My Challenges" /FFT
@rem robocopy N:\roms D:\spiele\gens\roms /MIR /NP /LEV:1 /FFT /COPY:DT

robocopy N:\dev D:\dev *.7z /MIR /NP /LEV:1 /FFT /COPY:DT
robocopy N:\dev\art.bin D:\dev\art.bin /MIR /NP /FFT /COPY:DT -XF *.log
robocopy N:\dev\mnh5 D:\dev\mnh5 /MIR /NP /FFT /COPY:DT 
@rem robocopy D:\dokumente\Sylwia N:\Sylwia  /FFT
@rem robocopy N:\Sylwia D:\dokumente\Sylwia /FFT
@rem robocopy D:\dokumente\Martin N:\Martin /FFT 
@rem robocopy N:\Martin D:\dokumente\Martin /FFT 
@rem robocopy D:\dokumente\Oskar N:\Oskar /FFT
@rem robocopy N:\Oskar D:\dokumente\Oskar /FFT 
D:
cd dev 
@rem "c:\Program Files\7-Zip\7z.exe" x -y 3rd_party.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y art.source.7z
"c:\Program Files\7-Zip\7z.exe" x -y dev.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y mnh5.7z
"c:\Program Files\7-Zip\7z.exe" x -y mnh_scripts.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y retrospective.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y git.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y graveyard.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y Sudoku3.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y web.7z
cd mnh5
make status