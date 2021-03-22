#!/bin/bash

for filename in ./*.yaml; do ./create_crypto_peer_organization.sh -f $filename; done