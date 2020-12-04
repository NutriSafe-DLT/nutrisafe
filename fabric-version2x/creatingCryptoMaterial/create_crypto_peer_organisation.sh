
#!/bin/bash
#
#####################################################################################################################
# Description                                                                                                       #
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


# -------------------------------------------------------------------------------------------------------------------
# Section:      Parameters
# Description:  Default parameters
# -------------------------------------------------------------------------------------------------------------------
PATH_TO_YAML_FILE=./crypto_config_authority.yaml
ORGANISATION_TYPE=peerOrganization
ORGANISATION_DOMAIN=authority.de

# -------------------------------------------------------------------------------------------------------------------
# Section:      printHelp()
# Description:  Print the usage message
# -------------------------------------------------------------------------------------------------------------------
function printHelp() {
  echo "Usage: "
  echo "  create_crypto_for_peer_organisation.sh <[-f <path for .yaml file>]>"
  echo "    -f <Path to .yaml File> - specify yaml path"
  echo "  create_crypto_for_peer_organisation.sh -h (print this message)"
}

# -------------------------------------------------------------------------------------------------------------------
# Section:      Parameters
# Description:  List of script parameters
# -------------------------------------------------------------------------------------------------------------------
while getopts "h?f:x" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  f)
    PATH_TO_YAML_FILE=$OPTARG
    ;;
  esac
done

# -------------------------------------------------------------------------------------------------------------------
# Section:      cryptogren generate
# Description:  Generate crypto material for organisation
# Parameter:    $PATH_TO_YAML_FILE
# Example:      create_crypto_for_peer_organisation.sh -f ./crypto_config_ilda.yaml
# -------------------------------------------------------------------------------------------------------------------
rm -rf "./crypto-config/"$ORGANISATION_TYPE"/"$ORGANISATION_DOMAIN/*

if cryptogen generate --config=$PATH_TO_YAML_FILE ; then
  echo "Successfully generated crypto material!"
else
  echo "Something went wrong with the crypto material generation, please check output and logs."
fi
