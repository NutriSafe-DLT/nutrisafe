
#!/bin/bash
#
#####################################################################################################################
# Description                                                                                                       #
#
# This work is licensed under a Creative Commons Attribution 4.0 International License
# (http://creativecommons.org/licenses/by/4.0/).
#
# Author(s): Tim Reimers, Andreas Hermann, Razvan Hrestic
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
ORGANIZATION_TYPE=peerOrganization
ORGANIZATION_DOMAIN=authority.de

# -------------------------------------------------------------------------------------------------------------------
# Section:      printHelp()
# Description:  Print the usage message
# -------------------------------------------------------------------------------------------------------------------
function printHelp() {
  echo "Usage: "
  echo "  create_crypto_for_peer_organisation.sh <[-f <path for .yaml file>]>"
  echo "    -f <Path to .yaml File> - specify yaml path"
  echo "    -d <DNS-like Domain Name> - specify organization domain e.g. brangus.de"
  echo "  create_crypto_for_peer_organisation.sh -h (print this message)"
}

# -------------------------------------------------------------------------------------------------------------------
# Section:      Parameters
# Description:  List of script parameters
# -------------------------------------------------------------------------------------------------------------------
while getopts "h?f:d:t:x" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  f)
    PATH_TO_YAML_FILE=$OPTARG
    ;;
  d)
    ORGANIZATION_DOMAIN=$OPTARG
    ;;
  t)
    ORGANIZATION_TYPE=$OPTARG
    ;;
  esac
done

# -------------------------------------------------------------------------------------------------------------------
# Section:      cryptogen extend 
# Description:  Generates crypto material for a given peer organisation, checks first to see if it was previously generated
# Parameter:    $PATH_TO_YAML_FILE, $ORGANISATION_DOMAIN
# Example:      create_crypto_for_peer_organisation.sh -f ./crypto_config_ilda.yaml -d ilda.de
# -------------------------------------------------------------------------------------------------------------------
# Global parameter: Name of admin user for said organization
# RM command below is faulty.
#rm -rf "./crypto-config/"$ORGANISATION_TYPE"/"$ORGANISATION_DOMAIN/*

if cryptogen generate --config=$PATH_TO_YAML_FILE ; then
  echo "Successfully generated crypto material for $ORGANIZATION_DOMAIN"
  if [ "$ORGANIZATION_TYPE" = "peerOrganization" ] ; then
    echo "Copying public certificates for Admin user..."
    cp "./crypto-config/ordererOrganizations/unibw.de/tlsca/tlsca.unibw.de-cert.pem" "./crypto-config/"$ORGANIZATION_TYPE"s/"$ORGANIZATION_DOMAIN".de/users/Admin@"$ORGANIZATION_DOMAIN".de/tls/"
  fi
else
  echo "Something went wrong with the crypto material generation, please check output and logs."
fi

