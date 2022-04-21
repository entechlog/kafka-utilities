#!/bin/bash

#######################################################################################################
#  Script Name       : simple-lag-checker.sh                                                          #
#  created by        : Siva Nadesan                                                                   #
#  created date      : 2022-04-20                                                                     #
#  Syntax            : ./simple-lag-checker.sh \                                                      #
#                      --kafka_home <kafka_home> --bootstrap_servers <bootstrap_servers> \            #
#                      --command_config <command_config> --consumer_groups <consumer_groups>          #
#                    : kafka_home         : path in which kafka is installed                          #
#                    : bootstrap_servers  : kafka host and port number in host:port format            #
#                    : command_config     : full path for command config file                         #
#                    : consumer_groups    : filter to fetch all consumers with matching pattern       #
#  Example           : ./simple-lag-checker.sh \                                                      #
#                      --kafka_home /kafka --bootstrap_servers localhost:9094 \                       #
#                      --command_config client.properties --consumer_groups connect                   #
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
if [ $# -ge 3 ]; then
   echo "INFO                   : Received the correct number of input parameters"
else
   echo "ERROR                  : Received incorrect number of input parameters"
   echo "ERROR                  : Syntax:" "./"$SCRIPT_NAME".sh" "<KAFKA_HOME> <BOOTSTRAP_SERVERS> <CONSUMER_GROUPS>"
   exit
fi
 
INVALID_ARGS=$(echo 'FALSE')

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

   if [[ $v != @(kafka_home|bootstrap_servers|command_config|consumer_groups) ]]; then
      INVALID_ARGS=$(echo 'TRUE')
   fi

  shift
done

if [[ $INVALID_ARGS == 'TRUE' ]]; then
   echo "ERROR                  : Received invalid parameters"
   echo "ERROR                  : Syntax:" "./"$SCRIPT_NAME".sh" "<KAFKA_HOME> <BOOTSTRAP_SERVERS> <CONSUMER_GROUPS>"
   exit
fi

echo "INFO-KAFKA_HOME        :" $kafka_home
KAFKA_BIN="${kafka_home}/bin"
echo "INFO-KAFKA_BIN         :" $KAFKA_BIN

BOOTSTRAP_SERVERS=$(echo $bootstrap_servers | tr '[:upper:]' '[:lower:]')
echo "INFO-BOOTSTRAP_SERVERS :" $bootstrap_servers

echo "INFO-COMMAND_CONFIG    :" $command_config
echo "INFO-CONSUMER_GROUPS   :" $consumer_groups

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
echo "topic_name,group_name,client_name,partition,current_offset,end_offset,lag" >>$REPORTSCSV

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

cd $KAFKA_BIN

if [[ -n $consumer_groups ]]; then
   consumer_groups_command=$(echo "./kafka-consumer-groups.sh --command-config $command_config --bootstrap-server $bootstrap_servers --list | grep $consumer_groups")
else
   consumer_groups_command=$(echo "./kafka-consumer-groups.sh --command-config $command_config --bootstrap-server $bootstrap_servers --list")
fi

echo "Issuing Command        : " $consumer_groups_command >> $LOGFILE
consumer_groups=$(eval $consumer_groups_command)

# Read list of consumers and get details from them
for consumer_group in $consumer_groups; do

   if [[ -n $consumer_group ]]; then
      echo "**************************************************************************" >>$LOGFILE
      echo $(date "+%Y-%m-%d%H:%M:%S") "- Processing : " $consumer_group >>$LOGFILE
      echo "**************************************************************************" >>$LOGFILE
      echo "" >>$LOGFILE
      echo "INFO-consumer_group    : " $consumer_group >>$LOGFILE
      echo "INFO-now-processing    : " $consumer_group
      consumer_group_detail_command=$(echo "./kafka-consumer-groups.sh --command-config $command_config --bootstrap-server $bootstrap_servers --group $consumer_group --describe | grep $consumer_group")
      echo "Issuing Command        : " $consumer_group_detail_command >> $LOGFILE
      consumer_group_detail=$(eval $consumer_group_detail_command)
      OLDIFS="$IFS"

      IFS=$'\n'
      for consumer_group_line in $consumer_group_detail; do
         topic_name=$(echo $consumer_group_line | awk '{print $2}')
         group_name=$(echo $consumer_group_line | awk '{print $1}')
         client_name=$(echo $consumer_group_line | awk '{print $9}')
         partition=$(echo $consumer_group_line | awk '{print $3}')
         current_offset=$(echo $consumer_group_line | awk '{print $4}')
         end_offset=$(echo $consumer_group_line | awk '{print $5}')
         lag=$(echo $consumer_group_line | awk '{print $6}')

         echo "<td>$topic_name</td>" >>$REPORTSFILE
         echo "<td>$group_name</td>" >>$REPORTSFILE
         echo "<td>$client_name</td>" >>$REPORTSFILE
         echo "<td>$partition</td>" >>$REPORTSFILE
         echo "<td>$current_offset</td>" >>$REPORTSFILE
         echo "<td>$end_offset</td>" >>$REPORTSFILE

         if [[ -z "$lag" || "$lag" = " " || "$lag" = "" || "$lag" = "-" ]]; then
            lag=$(echo 0)
         fi

         if [ $lag -gt 25000 ]; then
            echo "<td style='background-color:#FFAE00'>$lag</td>" >>$REPORTSFILE
         elif [ $lag -gt 50000 ]; then
            echo "<td style='background-color:#FF0000'>$lag</td>" >>$REPORTSFILE
         else
            echo "<td>$lag</td>" >>$REPORTSFILE
         fi

         echo "</tr>" >>$REPORTSFILE
         echo $topic_name","$group_name","$client_name","$partition","$current_offset","$end_offset","$lag >>$REPORTSCSV
      done

      IFS="$OLDIFS"

      echo '==========================================================================' >>$LOGFILE
      echo "" >>$LOGFILE

   else
      count_command=$(echo '')
   fi

done

#######################################################################################################
# Copy static HTML Footer to the report file                                                          #
#######################################################################################################

cat $INPUTDIR/html/part_20.html >>$REPORTSFILE

#######################################################################################################
# write trailer log record                                                                            #
#######################################################################################################

echo $(date "+%Y-%m-%d%H:%M:%S") "-" $SCRIPT_NAME "finished" >>$LOGFILE
exit 0
