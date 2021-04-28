#!/bin/bash
#######################################################################################################
#  Script Name       : get-message-count.sh                                                           #
#  created by        : Siva Nadesan                                                                   #
#  created date      : 2021-04-09                                                                     #
#  Syntax            : ./get-message-count.sh <BOOTSTRAP_SERVERS> <FILE_NAME>                         #
#                    : BOOTSTRAP_SERVERS - KSQL host and port number in host:port format              #
#                    : FILE_NAME - Full path of file with list of table\stream to be deleted          #
#  Input file format : <TOPIC_NAME>,<INCLUDE_FLAG>                                                    #
#                    : TOPIC_NAME - Topic name                                                        #
#                    : INCLUDE_FLAG - Flag(Yes/No) to count OR exclude a topic                        #
#  Example           : ./get-message-count.sh localhost:9094 /input/demo.txt                          #
#######################################################################################################

#######################################################################################################
# Find the Script Name automatically                                                                  #
#######################################################################################################

ScriptNameWithExt=$(basename "$0")
extension="${ScriptNameWithExt##*.}"
SCRIPT_NAME="${ScriptNameWithExt%.*}"

echo "**************************************************************************"
echo "SCRIPT_NAME            : "$SCRIPT_NAME
echo "**************************************************************************"

#######################################################################################################
# Find the location of scripts and check for logs dir, create if don't exist                          #
#######################################################################################################

THISDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$THISDIR/logs" ]; then
   echo "INFO                   : logs directory exists"
else
   mkdir -p "$THISDIR/logs" 2>/dev/null
   chmod 777 "$THISDIR/logs"
fi

if [ -d "$THISDIR/temp" ]; then
   echo "INFO                   : temp directory exists"
else
   mkdir -p "$THISDIR/temp" 2>/dev/null
   chmod 777 "$THISDIR/temp"
fi

if [ -d "$THISDIR/reports" ]; then
   echo "INFO                   : reports directory exists"
else
   mkdir -p "$THISDIR/reports" 2>/dev/null
   chmod 777 "$THISDIR/reports"
fi

#######################################################################################################
# Read Arguments                                                                                      #
#######################################################################################################

echo "INFO                   : Total arguments.." $#

if [ $# -ge 2 ]; then
   echo "INFO                   : Received the correct number of input parameters"
else
   echo " "
   echo "ERROR                  : Syntax:" $SCRIPT_NAME "<BOOTSTRAP_SERVERS> <FILE_NAME>"
   exit
fi

BOOTSTRAP_SERVERS=$1
BOOTSTRAP_SERVERS=$(echo $BOOTSTRAP_SERVERS | tr '[:upper:]' '[:lower:]')
echo "INFO-BOOTSTRAP_SERVERS :" $BOOTSTRAP_SERVERS

FILE_NAME=$2
#FILE_NAME=$(echo $FILE_NAME | tr '[:upper:]' '[:lower:]')
echo "INFO-FILE_NAME         :" $FILE_NAME

#######################################################################################################
# Location of log files and any supporting files                                                      #
#######################################################################################################

LOGDIR=$(echo $THISDIR"/logs" | tr '[:upper:]' '[:lower:]')
echo "INFO-LOGDIR            :" $LOGDIR

TEMPDIR=$(echo $THISDIR"/temp" | tr '[:upper:]' '[:lower:]')
echo "INFO-TEMPDIR           :" $TEMPDIR

REPORTSDIR=$(echo $THISDIR"/reports" | tr '[:upper:]' '[:lower:]')
echo "INFO-REPORTSDIR        :" $REPORTSDIR

INPUTDIR=$(echo $THISDIR"/input" | tr '[:upper:]' '[:lower:]')
echo "INFO-INPUTDIR          :" $INPUTDIR

#######################################################################################################
# Protect files created by this script.                                                               #
#######################################################################################################

umask u=rw,g=rw,o=rw

#######################################################################################################
# Read Current System time stamp                                                                      #
#######################################################################################################

CURR_DATE=$(date "+%Y-%m-%d%H:%M:%S")
CURR_DATE=$(echo $CURR_DATE | sed 's/[^A-Za-z0-9_]/_/g')

#######################################################################################################
# Open up a new log and supporting files for todays run                                               #
#######################################################################################################

LOGFILE=$LOGDIR"/"$SCRIPT_NAME"_"$CURR_DATE".log"
touch $LOGFILE

TEMPFILE=$TEMPDIR"/"$SCRIPT_NAME".dat"
touch $TEMPFILE

REPORTSFILE=$REPORTSDIR"/"$SCRIPT_NAME"_"$CURR_DATE".html"
touch $REPORTSFILE
REPORTSCSV=$REPORTSDIR"/"$SCRIPT_NAME"_"$CURR_DATE".csv"
echo "Topic,Count" >>$REPORTSCSV

#######################################################################################################
# Delete previous tmp file                                                                            #
#######################################################################################################

rm $TEMPFILE >$TEMPFILE

#######################################################################################################
# Create and write the log header message                                                             #
#######################################################################################################

echo $(date "+%Y-%m-%d%H:%M:%S") "-" $SCRIPT_NAME "Started" >$LOGFILE

#######################################################################################################
# Insert Seperator                                                                                    #
#######################################################################################################

echo ' ' >>$LOGFILE

#######################################################################################################
# Copy static HTML Header to the report file                                                          #
#######################################################################################################

cat $INPUTDIR/html/part_10.html >$REPORTSFILE

#######################################################################################################
# All processing logic goes here                                                                      #
#######################################################################################################

#Read the input file with list of table/streams and loop until end of file to apply the properties
while read topic_names; do

   if [[ -n $topic_names ]]; then
      topic_name=$(echo $topic_names | cut -d',' -f1 | tr -d '\n\r')
      topic_name_lower=$(echo $topic_names | cut -d',' -f1 | tr '[:upper:]' '[:lower:]' | tr -d '\n\r')
      include_flag=$(echo $topic_names | cut -d',' -f2 | tr '[:upper:]' '[:lower:]' | tr -d '\n\r')

      if [[ "$include_flag" == "$topic_name_lower" ]]; then
         include_flag='y'
      fi

      echo "**************************************************************************" >>$LOGFILE
      echo $(date "+%Y-%m-%d%H:%M:%S") "- Processing : " $topic_name >>$LOGFILE
      echo "**************************************************************************" >>$LOGFILE
      echo "" >>$LOGFILE

      echo "INFO-topic_name           :" $topic_name >>$LOGFILE
      echo "INFO-include_flag         :" $include_flag >>$LOGFILE

      if [[ $include_flag = 'y' ]] || [[ $include_flag = 'yes' ]] || [[ -z $include_flag ]]; then
         count_command=$(echo "kafkacat -C -b $BOOTSTRAP_SERVERS -t $topic_name -X security.protocol=SSL -o beginning -e -q | wc -l")

         echo "Issuing Command           : " $count_command >>$LOGFILE
         count_command_output=$(eval $count_command)
         echo $count_command_output >>$LOGFILE

         echo "INFO-now-processing    : " $topic_name"," $count_command_output

         echo "<td>$topic_name</td>" >>$REPORTSFILE
         echo "<td>$count_command_output</td>" >>$REPORTSFILE

         echo "</tr>" >>$REPORTSFILE

         echo $topic_name","$count_command_output >>$REPORTSCSV

         echo '==========================================================================' >>$LOGFILE
         echo "" >>$LOGFILE

      else
         count_command=$(echo '')
      fi

   fi

done \
   <$FILE_NAME

#######################################################################################################
# Copy static HTML Footer to the report file                                                          #
#######################################################################################################
cat $INPUTDIR/html/part_20.html >>$REPORTSFILE

#######################################################################################################
# write trailer log record                                                                            #
#######################################################################################################
echo $(date "+%Y-%m-%d%H:%M:%S") "-" $SCRIPT_NAME "finished" >>$LOGFILE

exit 0
