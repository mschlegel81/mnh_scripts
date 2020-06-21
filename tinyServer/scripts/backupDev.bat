chcp 65001
D:
cd dev
pushtoUsb.mnh zip
robocopy D:\dev D:\backup\dev *.7z /MIR /NP /LEV:1 /FFT /COPY:DT
mnh -cmd "folders('*.*').pMap({print($x,' ',$x.allFiles('*.*').sort.fileStats.serialize.sha256)})"