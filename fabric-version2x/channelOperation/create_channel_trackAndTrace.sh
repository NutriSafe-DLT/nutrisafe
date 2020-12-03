#!/bin/bash
#
#####################################################################################################################
# Description                                                                                                       #
# This scripts creates a transaction to create an channel.                                                          #
# Afterwards the transaction needs to be signed and committed (please have look at policy for channel creation      #
#                                                                                                                   #
#
# This work is licensed under a Creative Commons Attribution 4.0 International License
# (http://creativecommons.org/licenses/by/4.0/).
#
# Author(s): Tim Reimers, Andreas Hermann
# NutriSafe Research Project
# Institute for Protection and Dependability
# Department of Computer Science
# Bundeswehr University Munich
#####################################################################################################################


#####################################################################################################################
# Parameters                                                                                                        #
#####################################################################################################################
### The fabric configuration path has to be set to the configtx.yaml ###
CFG_PATH=../config

### Name of the  channel ###
CHANNEL_ID=trackandtrace

### Name of the transaction file ###
TRANSACTION_FILE="../configTransactions/"$CHANNEL_ID"_creation.tx"

### Name of the profile defined in the configtx.yaml ###
CONFIG_PROFILE=MoreOrgChannel


#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

export FABRIC_CFG_PATH=$CFG_PATH


# -------------------------------------------------------------------------------------------------------------------
# Section:      printHelp()
# Description:  Print the usage message
# -------------------------------------------------------------------------------------------------------------------
function printHelp() {
  echo "Usage: "
  echo "  create_channel_weichkaese.sh [-p <path for config directory>] [-f <path for .yaml file>] [-o <organisation name from .yaml file] [-c <cli Name>]>"
  echo "    -p <Path for config dir> - specify config path"
  echo "    -f <Path to .yaml File> - specify yaml path"
  echo "    -o <Organisation Name from .yaml file> - organisation name from .yaml file"
  echo "    -c <cli Name> - cli Name"
  echo "  create_channel_cheese.sh -h (print this message)"
}

# -------------------------------------------------------------------------------------------------------------------
# Section:      Parameters
# Description:  List of script parameters
# -------------------------------------------------------------------------------------------------------------------
while getopts "h?o:f:c:p:x" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  p)
   CFG_PATH=$OPTARG
    ;;
  f)
   TRANSACTION_FILE=$OPTARG
    ;;
  o)
    CONFIG_PROFILE=$OPTARG
    ;;
  c)
    CHANNEL_ID=$OPTARG
    ;;
  esac
done

# -------------------------------------------------------------------------------------------------------------------
# Section:      rm
# Description:  Remove and create config directory
# -------------------------------------------------------------------------------------------------------------------

if [ -f $TRANSACTION_FILE ]; then
  rm $TRANSACTION_FILE
fi
# -------------------------------------------------------------------------------------------------------------------
# Section:      configxtxgen
# Description:  generate channel configuration transaction
# Parameter:    $TX_FILE
#               $CHANNEL_ID_NAME
#               $ORG_NAME
# Example:      create_channel_weichkaese.sh -f /pathTo/TXFile.tx -c ChannelID -o MoreOrgChannel
# -------------------------------------------------------------------------------------------------------------------
configtxgen -profile $CONFIG_PROFILE -outputCreateChannelTx $TRANSACTION_FILE -channelID $CHANNEL_ID 
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi
