#!/bin/bash
# Use this command to create a new store.
# The name of the store can be passed as a parameter.

export SF_NPM_REGISTRY="http://platform-cli-registry.eng.sfdc.net:4880/"
export SF_S3_HOST="http://platform-cli-s3.eng.sfdc.net:9000/sfdx/media/salesforce-cli"

#templateName="b2c-lite-storefront"
templateName="B2B Commerce"

function echo_attention()  {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo -e "${green}$1${no_color}"
}

storename=""

function error_and_exit() {
   echo "$1"
   exit 1
}

if [ -z "$1" ]
then
    echo "A new store will be created... Please enter the name of the store (alphanumeric characters only): "
    read storename
else
    storename=$1
fi
sf community create experience --name "$storename" --template-name "B2B Commerce" --url-path-prefix "$storename" --description "Store $storename created by Quick Start script."
echo ""

storeId=""

while [ -z "${storeId}" ];
do
    echo_attention "Store not yet created, waiting 10 seconds..."
    storeId=$(sf data query --query "SELECT Id FROM WebStore WHERE Name='${storename}' LIMIT 1" --result-format csv |tail -n +2)
    sleep 10
done

echo ""

echo_attention "Store found with id ${storeId}"
echo ""

echo_attention "Pushing store sources..."
set -x
sf project deploy start --force
set +x

echo ""

echo_attention "Setting up the store and creating the buyer user..."

# Cleaning up if a previous run failed
rm -rf experience-bundle-package

./quickstart-setup-store.sh "${storename}" || error_and_exit "Store setup failed."
