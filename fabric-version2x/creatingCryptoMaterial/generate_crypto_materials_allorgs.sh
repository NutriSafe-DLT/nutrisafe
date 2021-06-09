#!/bin/bash
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
rm -rf "./crypto-config/"

./create_crypto_peer_organization.sh -f crypto_config_unibw.yml -d unibw.de -t ordererOrganization
for filename in ./*.yaml; do ./create_crypto_peer_organization.sh -f $filename -d $(echo $filename| awk '{split($0,a,"_"); print substr(a[3],1,length(a[3])-5)}'); done