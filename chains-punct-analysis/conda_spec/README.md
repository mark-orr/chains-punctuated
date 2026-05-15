PUT NAME OF CONDA ENV HERE:
#FIND ENV BY 
% conda env list #lists environments
conda create --name chains-punct python=3.11 numpy pandas scipy
conda install -c conda-forge matplotlib


IF DESIRED, ALSO GEN A SPEC FILE FROM CONDA FOR THIS ENV USING:
conda list --explicity > spec-file.txt 
#DO THIS IN CONDA ENVIROMENT THAT IS ACTIVATED>

EOF 