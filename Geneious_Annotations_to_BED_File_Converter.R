####################################################
#                                                  #
# Geneious Annotations.csv to BED formatted.tsv    #
# file Converter                                   #
#                                                  #
# Created by Kyle Drover                           #
#                                                  #
####################################################

#Installs and loads the required packages

#packages = c("dplyr","tidyr","readr")
require("dplyr")


#install.packages("dplyr", repos = "http://cran.us.r-project.org")

library("dplyr")


#install.packages("tidyr", repos = "http://cran.us.r-project.org")
require("tidyr")

library("tidyr")

#install.packages("readr", repos = "http://cran.us.r-project.org")

require("readr")

library("readr")




Convert_to_BED <- function(file_path, chromosome, track_name, track_description, browser_position)
{
  # Converts Annotation data exported as a csv file to a BED formatted file for UCSC Genome Browser
  
  
  # prompt user for the file path (needs to be one long line as it interferes with the code otherwise)
   
  directory = "//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/"
  
  complete_path = paste(directory, file_path, sep = "")
  
  #Read annotations from specificied csv file
  Annotations <- read_csv(complete_path, 
                          col_types = cols(End = col_integer(), 
                                           Start = col_number()))
  names(Annotations)<-str_replace_all(names(Annotations), c(" " = "_" , "\\)" = "", "\\(" = ""))
  
  #Converts annotations into BED format
  
  BED_Format <- Annotations %>% 
    select(-Length, -Sequence_Name) %>%
    mutate(Start = Min_with_gaps + 1) %>%
    mutate(End = Max_with_gaps + 1) %>%
    mutate(Name_ordered = Name) %>%
    select(-Name, -Min_with_gaps, -Max_with_gaps)
  
  
  chr_column <- rep(chromosome, length(Annotations$Name))
  
  BED_df <- data.frame(chr_column,BED_Format)
  
  
  #Writes the paramaters required for the UCSC genome browser to the user specified file
  
  parameters = paste('track name="',track_name,'" description="',
                     track_description,'" visibility=3 itemRgb="On"',
                     '\n','browser position= "', noquote(browser_position),'" ',
                     sep = "")
  
  name_of_BED_file = paste("//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/","Hg38","-",as.character.Date(Sys.Date()),".tsv", sep = "")
  print(name_of_BED_file)
  
  
  file.create(name_of_BED_file)
  
  f <- file(name_of_BED_file, open="w")
  
  write.table(parameters, file = f, sep = " ", col.names = FALSE, row.names = FALSE, quote = FALSE)
  
  #Writes the BED formatted data to the user inputed file. 
  write.table(BED_df,"//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/Data.tsv", sep = "\t", 
              col.names = FALSE, row.names = FALSE, quote = FALSE) 
  file.append(name_of_BED_file, "Data.tsv")
  
  file.remove("//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/Data.tsv")
  
  
  
  #Creates a new file if the f
  Final_file = "//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/Complete_Annotations_ZIC2_Hg38.tsv"
  file.create(Final_file)
  
  
  complete_annotations <- file(Final_file, open="w")
  
  file.append(Final_file, name_of_BED_file)
}

user_parameters = commandArgs(trailingOnly = TRUE)

#paste the arguments together as windows batch seperates arguments by spaces, identifies and removes tag.
start_counter = 1 
end_counter = 1
pasted_arguments = c()

for (word in as.character(user_parameters)) {
  
  if (grepl("\\*",word)){
    
    
    tagged_arg = paste(user_parameters[c(start_counter:end_counter)], collapse = " ")
  
    argument = gsub("[*].*$","",tagged_arg)
    
    pasted_arguments = c(pasted_arguments, argument)
    
    start_counter = end_counter + 1
    end_counter = start_counter
  
  }
  
  else {
    
    end_counter = end_counter + 1
  }
  
}
  
x1 = pasted_arguments[1]
x2 = pasted_arguments[2]
x3 = pasted_arguments[3]
x4 = pasted_arguments[4]
x5 = pasted_arguments[5]

Convert_to_BED(file_path = x1,chromosome = x2, track_name = x3,track_description = x4, browser_position =  x5)
