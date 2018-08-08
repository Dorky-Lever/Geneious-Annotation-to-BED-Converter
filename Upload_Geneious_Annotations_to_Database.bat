@echo off
REM any line with REM is a comment 


echo Geneious Annotation File Converter

cd C:\Program Files\R\R-3.4.3\bin

echo We are about to start the program

pause




REM input user data:

echo ^

echo Please enter the name of the csv file (include the file extension)

echo include the directory starting from the Arkell lab folder

set /p  "filepath=e.g. Lab Members/Kyle/Honours/ZIC2_Annotation/RNA_BPs.csv: --> "

set "filepath=%filepath%*"

echo  ^

echo Enter the chromosome that the annotations are on

echo This code will only work if annotations are on a single chromosome

set /p "chromosome=e.g.chr13: -->"

set "chromosome=%chromosome%*"


echo  ^

echo Please give the track a name

set /p "track_name=e.g. ZIC2 3UTR SNVs: --> "

set "track_name=%track_name%*"



echo  ^

echo Please provide a short description of the track

set /p "track_description=e.g. Predicted poly(A) sites within the ZIC2 3'UTR:--> "

set "track_description=%track_description%*"


echo  ^

echo Please provide the default position for viewing the track in UCSC genome browser

set /p "browser_position=e.g. chr13:99985683-99986781: --> "
set "browser_position=%browser_position%*"


echo  ^

echo Please provide the keyword or identifier to upload the track to the database

echo It is recommended to use a combination of the reference genome and locus of interest

set /p "identifier=e.g. Hg38_ZIC2 --> "
set "identifier=%identifier%*"


Rscript \\mhsdata.anu.edu.au\mhs\workgroups\jcsmr\ArkellLab\Bio_Informatics\Kyle_R_codes\Append_Geneious_Annotation_To_Database.R %filepath% %chromosome% %track_name% %track_description% %browser_position% %identifier%

echo program has run

pause