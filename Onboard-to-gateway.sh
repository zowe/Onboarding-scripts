#!/bin/sh

################################################################################
# This program and the accompanying materials are made available under the terms of the
# Eclipse Public License v2.0 which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright IBM Corporation 2018
################################################################################
clear
echo "Zowe Extender Installation Script V1.0"
echo "=============================="
echo
echo "The installation process will request the following information:"
echo
echo "o The location of the Zowe installation on this server"
echo "o The Base Url and documentation link of the Rest API being added to the gateway"
echo
echo "Other default values have already specified"
echo

################################################################################
# The following fields to be filled in by implementing extenders team
################################################################################
defaultServiceId="xtdrsvcid" 	# lowercase only
defaultTitle="Product name"
defaultDescription="Product description"
defaultCatalogUiTileId="xtdrCatalogUiTileId"
defaultHomePageRelativeUrl="" # Usually home page is the same as the base URL 

defaultGatewayUrl1="api/v1"
defaultServiceUrl1="api/v1/xtdrServiceId"
defaultGatewayUrl2="ui/v1"
defaultServiceUrl2="ui/v1/xtdrServiceId"
# Additional gateway and services will require further changes to script later

defaultApiId="no.id.ea"
defaultGatewayUrl=$defaultGatewayUrl1
defaultApiVersion="1.0.0"

defaultCatalogTileTitle="My Product in catalog"
defaultCatalogTileDescription="My Product description in catalog"

################################################################################
# Start
################################################################################
echo "Enter 'Y' to continue:"
read rep
if [ "$rep" != "Y" ] && [ "$rep" != "y" ]
	then
	    echo
	    exit 0
fi

# Create a temp directory to be a working directory for sed replacements
TEMP_DIR=$PWD/temp_"`date +%Y-%m-%d`"
mkdir -p $TEMP_DIR


################################################################################
# Specify the Zowe Installation search
# Populates $zoweinstall
################################################################################
echo "Searching for zowe installations on this machine.."
echo "This may take a few moments.."
def=""
loop=1
for i in $(find /u/stonecc -type f -name /api-mediation/api-defs/zos.yml 2>&1 | grep -v 'Permission denied');
do
	if [ $loop -eq 1 ]
		then
			echo
			echo "Located the following possibilities.."
	fi
	loop=0
    echo "==> ${i%%/api-mediation/api-defs/zos.yml}"
    def=${i%%/api-mediation/api-defs/zos.yml}
done
loop=1
while [ $loop -eq 1 ]
do
    echo
    echo "Please enter the zowe installation directory path or press ENTER to default to $def:"
    read zoweinstall
    if [ "$zoweinstall" = "" ]
	    then
	        zoweinstall=$def
    fi
    zowecheck=$zoweinstall/api-mediation/api-def
    if [ ! -d $zoweinstall/api-mediation/api-defs ]
	    then
	        echo "zowe install path $zoweinstall does not appear to be a valid Zowe installation"
	        echo "enter 'X' to abort installation or press ENTER to retry"
	        read rep
	        if [ "$rep" = "X" ] || [ "$rep" = "x" ]
	        then
	           exit 0
	        fi
	else
		if [ "$zoweinstall" = "$def" ]
			then
				loop=0
		else
	        echo "$zoweinstall appears valid, enter 'Y' to accept or ENTER to specify an alternative"
	        read rep
	        if [ "$rep" = "Y" ] || [ "$rep" = "y" ]
	        then
	           loop=0
	        fi
	    fi    
    fi
done

################################################################################
# Specify the Onboarding product location
# Populates $serviceLocation
################################################################################
loop=1
while [ $loop -eq 1 ]
do
	echo "Please provide the base location of your provided service or press 'X' to exit."
	echo "This will be in the format https://myserver.mycompany.com:8080. for example.."
    read serviceLocation
    if [ "$serviceLocation" = "X" ] || [ "$serviceLocation" = "x" ]
		then
	    	exit 0
    else 
    	if [ "$serviceLocation" = "" ]
	    	then
	        	echo "No location specified"
		else 
		    nohttp=${serviceLocation##*//}
			ip=${nohttp%%:*}
			#echo $ip
			ping -c5 $ip > /dev/null 
			if [ $? -eq 0 ]
				then
					echo "$ip is ok"
					loop=0
			fi 
		fi      
    fi
done
echo

STATIC_DEF_CONFIG=$zoweinstall"/api-mediation/api-defs"
################################################################################
# Specify the Onboarding product location for documentation
# Populates $externalLocation
################################################################################
loop=1
while [ $loop -eq 1 ]
do
	echo "Now provide the location of external documentation 'X' to exit."
	echo "This will be in the format https://myserver.mycompany.com:8080/documents. for example.."
    read externalLocation
    if [ "$externalLocation" = "X" ] || [ "$externalLocation" = "x" ]
		then
	    	exit 0
    else 
    	if [ "$externalLocation" = "" ]
	    	then
	        	echo "No location specified"
		else 
				loop=0
		fi      
    fi
done
echo

################################################################################
# Create YAML file
################################################################################
if [ -f $STATIC_DEF_CONFIG/$defaultServiceId.yml ]
	then
		rm $STATIC_DEF_CONFIG/$defaultServiceId.yml	
fi
		
cat <<EOF >"$TEMP_DIR/$defaultServiceId.yml"
# Static definition for $defaultServiceId
#
#	
services:
    - serviceId: $defaultServiceId
      title: $defaultTitle
      description: $defaultDescription
      catalogUiTileId: $defaultCatalogUiTileId
      instanceBaseUrls:
        - $serviceLocation
      homePageRelativeUrl :$defaultHomePageRelativeUrl  # Home page may be at the same URL
      routedServices:
        - gatewayUrl: $defaultGatewayUrl1
          serviceRelativeUrl: $defaultServiceUrl1
        - gatewayUrl: $defaultGatewayUrl2
          serviceRelativeUrl: $defaultServiceUrl2          
      apiInfo:
        - apiId: $defaultApiId
          gatewayUrl: $defaultGatewayUrl
          version: $defaultApiVersion
          documentationUrl: $externalLocation

catalogUiTiles:
    $defaultCatalogUiTileId:
        title: $defaultCatalogTileTitle
        description: $defaultCatalogTileDescription
EOF

iconv -f IBM-1047 -t IBM-850 $TEMP_DIR/$defaultServiceId.yml > $STATIC_DEF_CONFIG/$defaultServiceId.yml	
chmod 766 $STATIC_DEF_CONFIG/$defaultServiceId.yml

# remove the working directory
rm -rf $TEMP_DIR

echo "Configuration created and process complete."
echo "Please restart the server to complete the on-boarding"