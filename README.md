# Geneious-Annotation-to-BED-Converter
Converts mapped Geneious annotations saved as a .csv file into a .BED formatted tsv file for submission to the UCSC Human Genome Browser. Source code can be run within R or from a Windows batch file. 

Requirements:
* Windows XP or later
* Access to the ArkellLab Network (directories to the network are written within the source code).
* R 3.4.3 (https://cran.r-project.org/bin/windows/base/)
* R studio (Available at: https://www.rstudio.com/).
* csv file containing Geneious annotations that have been mapped to the corresponding chromosome with the following columns selected: 
    * Sequence Name 
    * Name
    * Min (with gaps)
    * Max (with gaps)

