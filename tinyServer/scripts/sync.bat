@robocopy "N:\Martin\TmForever\Tracks\Challenges\My Challenges" "C:\users\schlegel\Documents\TmForever\Tracks\Challenges\My Challenges"
@robocopy N:\dev D:\dev *.7z /MIR /NP /LEV:1 /FFT /COPY:DT
@robocopy D:\dev\art.bin D:\dev\art.bin /MIR /NP /FFT /DCOPY:D /COPY:DT -XF *.log
@robocopy D:\dokumente\Sylwia N:\Sylwia 
@rem @robocopy N:\Sylwia D:\dokumente\Sylwia 
@robocopy D:\dokumente\Martin N:\Martin 
@rem @robocopy N:\Martin D:\dokumente\Martin 
@robocopy D:\dokumente\Oskar N:\Oskar 
@rem @robocopy N:\Oskar D:\dokumente\Oskar 
D:
cd dev 
"c:\Program Files\7-Zip\7z.exe" x -y 3rd_party.7z
"c:\Program Files\7-Zip\7z.exe" x -y art.source.7z
"c:\Program Files\7-Zip\7z.exe" x -y dev.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y git.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y graveyard.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y lazarus.7z
"c:\Program Files\7-Zip\7z.exe" x -y mnh5.7z
"c:\Program Files\7-Zip\7z.exe" x -y mnh_scripts.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y Sudoku3.7z
@rem "c:\Program Files\7-Zip\7z.exe" x -y web.7z
cd dev\mnh5
make status