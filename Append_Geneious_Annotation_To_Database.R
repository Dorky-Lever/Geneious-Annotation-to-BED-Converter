####################################################
#                                                  #
# Geneious Annotations.csv to BED formatted.tsv    #
# file Converter                                   #
#                                                  #
# Appends annotations to a local database          #
#                                                  #
# Created by Kyle Drover                           #
#                                                  #
####################################################

#Installs and loads the required packages
require("dplyr")
library("dplyr")


require("tidyr")
library("tidyr")


require("readr")
library("readr")


require("stringr")
library("stringr")

Convert_to_BED <- function(file_path, chromosome, key, track_name, track_description, browser_position)
{
  # Converts Annotation data exported as a csv file to a BED formatted file for UCSC Genome Browser
  
  
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
    mutate(Start = Min_with_gaps - 1) %>%
    mutate(End = Max_with_gaps - 1) %>%
    mutate(Name_ordered = Name) %>%
    select(-Name, -Min_with_gaps, -Max_with_gaps)
  
  chr_column <- rep(chromosome, length(Annotations$Name))
  
  BED_df <- data.frame(chr_column,BED_Format)
  
  
  
  
  #Crates an empty file in which all annotations will be stored
  
  name_of_BED_file = paste ("//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/Complete_Annotations_",
                            key,".tsv", sep = "")
  
  
  #need to scan the directory for any previous database was previously created.
  
  previous_files = list.files(path = "//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/", pattern = key)
  
  
  
  if (length(previous_files)>1){
    
    # if the file exists, the browser position needs to be updated to include the new annotations
    
    #To do this the current position needs to updates to keep the smallest starting position and the largest end position. 
    print("A previous database exists for this identifier, the track will be appended to this file")
    
    f <- file(name_of_BED_file, open="a")
   
    #Need the current browser position for the previous database. To do this you need to read the first line of the file. 
    old_db_files = list.files(path = "//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/", pattern = "Complete_Annotations")
  

    wanted_file = intersect(previous_files, old_db_files)
    
    
    complete_w_file = paste("//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/", wanted_file, sep = "")
    
    file(complete_w_file)
    
    database = readLines(complete_w_file[1],-1)
    
    old_browser_pos = database[1]
    
    
    
    #Then get the start and end position from that line.
    old_range = gsub("^.*?:","", old_browser_pos)
    
    old_start = as.numeric(gsub(".*?([0-9]+).*", "\\1", old_range))
    
    old_end = as.numeric(gsub(".*?([0-9]+).*$", "\\1", old_range))
    
    
    
    #obtains the user specified positon
    new_range = gsub("^.*?:","", browser_position)

    new_start = as.numeric(gsub(".*?([0-9]+).*", "\\1", new_range))
    
    new_end = as.numeric(gsub(".*?([0-9]+).*$", "\\1", new_range))
    
    
    database[1] = paste('browser position= "',noquote(chromosome), ":",min(new_start,old_start),"-",max(new_end, old_end),'"', sep = "")
    
    
    
    writeLines(database,name_of_BED_file)
  }
  
  else{

    print("No current database exists for the entered identifier, creating a new database")
    
    file.create(name_of_BED_file)
    
    f <- file(name_of_BED_file, open="a")
    
    #for new files, the default browser position for all tracks nees to be added to the top of the file
    multi_track_position = paste('browser position= "', noquote(browser_position),'" ',
                                 sep = "")
    
    #Writes the first line of the file, which is the track position
    write.table(multi_track_position, file = f, sep = " ", col.names = FALSE, row.names = FALSE, quote = FALSE)
    
  }
  

  
  parameters = paste('track name="',track_name,'" description="',
                     track_description,'" visibility=3 ',
                     'color=',sample(0:255, size = 1),",",sample(0:255, size = 1),",",sample(0:255, size = 1),",",
                     sep = "")
  
  write.table(parameters, file = f, append = TRUE, sep = " ", col.names = FALSE, row.names = FALSE, quote = FALSE)
  
  
   
  write.table(BED_df,file = f, append = TRUE, sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
  

  
  
  close(f)
  
  
  #Creates a date marked file containing the track description and the annotations. 
  #This is a way to track what annotations have been added to the database. 
  
  #Firstly, need to check if the files have been uploaded within this date otherwise data will be accidentally overwritten.
  

  key_date = paste(key, "-", as.character.Date(Sys.Date()), sep = "")
  
  
  same_day = list.files(path = "//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/", pattern = key_date)
  
  if (length(same_day) > 0){
    name_of_log_file = paste ("//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/", 
                              key_date,"(", as.character(length(same_day)),").tsv", sep = "")
  }
  
  else{
    name_of_log_file = paste ("//mhsdata.anu.edu.au/mhs/workgroups/jcsmr/ArkellLab/Bio_Informatics/Files/", 
                              key_date,".tsv", sep = "")
  }
  
  print(paste("Track added to", name_of_BED_file))
  file.create(name_of_log_file)
  
  log_f <- file(name_of_log_file, open="w")
  
  write.table(parameters, file = log_f, sep = " ", col.names = FALSE, row.names = FALSE, quote = FALSE)
  
  
  
  write.table(BED_df,file = log_f, sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
  
  close(log_f)
  
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
x6 = pasted_arguments[6]

Convert_to_BED(file_path = x1,chromosome = x2, track_name = x3,track_description = x4, browser_position =  x5, key = x6)


