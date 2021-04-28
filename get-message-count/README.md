- [Count Messages](#count-messages)
  - [Prerequisite](#prerequisite)
  - [Overview](#overview)
    - [How to execute this script](#how-to-execute-this-script)
      - [Step 01: Prepare input file](#step-01-prepare-input-file)
      - [Step 02: Execute the script](#step-02-execute-the-script)
      - [Step 03: Validating the results](#step-03-validating-the-results)

# Count Messages

## Prerequisite
- This script uses [kafkacat](https://github.com/edenhill/kafkacat), Please install them for your platform [from here](https://github.com/edenhill/kafkacat)
- This script also assumes the machine on which you are executing it has connection to the Kafka cluster

## Overview
This script is used to count number of messages in a Kafka topic

### How to execute this script

#### Step 01: Prepare input file
Prepare input file, Input file should be of the format  `<TOPIC_NAME>,<INCLUDE_FLAG>`
  - TOPIC_NAME - Topic name 
  - INCLUDE_FLAG - Flag(Yes/No) to count OR exclude a topic

#### Step 02: Execute the script
Execute the script by running the command `./get-message-count.sh localhost:9094 /input/demo.txt`

 - `localhost:9094` is the BOOTSTRAP_SERVERS
 - `/input/demo.txt` is the path for the input file which was prepared in step 01.

> Make sure the script has execute permission by running `chmod 0774 get-message-count.sh`

#### Step 03: Validating the results
Script execution will generate html and csv report in `reports` sub directory. Here is how an report would look like.

![image info](./img/sample-report.JPG)
  
