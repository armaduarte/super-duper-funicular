#!/bin/bash

#============================================================================#
#                                                                            #
#           FILE: logger.sh                                                  #
#                                                                            #
#          USAGE: ./logger.sh                                                #
#                                                                            #
#      DESCRIPTION: Script that reads all the .log files inside /var/log and #
#                   creates a report at /root/counts.log containing the      #
#                   datetime, filename and number of lines.                  #
#                                                                            #
#        OPTIONS: ---                                                        #
#   REQUIREMENTS: ---							     #
#           BUGS: ---                                                        #
#          NOTES: ---                                      	             #
#         AUTHOR: Arthur Duarte (arthurduarte@arthurduarte.com)		     #
#        VERSION: 1.0                                                        #
#           DATE: 03-20-2017 04:28PM                                         #
#                                                                            #
#============================================================================#
# Program definitions and variables	                                     #
#============================================================================#

# Report file.
REPORTFILE="/root/counts.log" 

#===  FUNCTION ==============================================================#
#         NAME: main                                                         #
#  DESCRIPTION: Main code.                                                   #
#   PARAMETERS: ---                                                          #
#       RETURN: ---                                                          #
#============================================================================#
main(){

 # Remove old report file.
 rm $REPORTFILE 2> /dev/null

 # Use a for loop to find all .log files inside the folder /var/logs.
 for f in $(find /var/log -name '*.log');do

  # Append a new line to the report file with the datetime, filename and number of lines data.
  echo "DATETIME: "$(date -r $f)" | FILENAME: "$f" | NUMBER OF LINES: "$(wc -l $f | awk '{print $1}') >> $REPORTFILE

 # End of the loop.
 done

}

#=== Main code execution ====================================================#
main
