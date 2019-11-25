D:
cd \dev\mnh5
make.mnh status
mnh -out curr_hashes.txt make_config.mnh
demos\diff.mnh expected_hashes.txt curr_hashes.txt 