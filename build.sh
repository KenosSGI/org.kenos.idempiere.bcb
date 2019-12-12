#!/bin/bash

configure () {
	echo

	# Ask for iDempiere folder
	while true; do
	read -e -p "Select the absolute location of iDempiere project [$PWD/../idempiere]: " IDEMPIERE_FOLDER
	case $IDEMPIERE_FOLDER in
		"" ) if [ ! -f "$PWD/../idempiere/org.idempiere.parent/pom.xml" ]; then echo "Error:	File pom.xml not found => $IDEMPIERE_FOLDER/org.idempiere.parent/pom.xml"; else IDEMPIERE_FOLDER="$PWD/../idempiere"; break; fi;;
		* ) if [ ! -f "$IDEMPIERE_FOLDER/org.idempiere.parent/pom.xml" ]; then echo "Error:	File pom.xml not found => $IDEMPIERE_FOLDER/org.idempiere.parent/pom.xml"; else break; fi;;
	esac
	done
	
	if [[ ! $IDEMPIERE_FOLDER == \/* ]]
	then
		echo
		echo "ERROR: Path must be absolute from root /, do not use ~, ./, or ../"
		echo
		exit 1
	fi

	# Ask for LBR folder
	while true; do
	read -e -p "Select the absolute location of upstrem project (LBR or KenosERP) [$PWD/../org.kenos.idempiere.lbr]: " UPSTREAM_FOLDER
	case $UPSTREAM_FOLDER in
		"" ) if [ ! -f "$PWD/../org.kenos.idempiere.lbr/pom.xml" ]; then echo "Error:	Features not found => $UPSTREAM_FOLDER/pom.xml"; else UPSTREAM_FOLDER="$PWD/../org.kenos.idempiere.lbr"; break; fi;;
		* ) if [ ! -f "$UPSTREAM_FOLDER/pom.xml" ]; then echo "Error:	Features not found => $UPSTREAM_FOLDER/pom.xml"; else break; fi;;
	esac
	done
	
	if [[ ! $UPSTREAM_FOLDER == \/* ]]
	then
		echo
		echo "ERROR: Path must be absolute from root /, do not use ~, ./, or ../"
		echo
		exit 1
	fi

	# Ask for Extra Plugins folder
	while true; do
	read -e -p "Select the absolute location of Extra Plugins [$PWD/..]: " EXTRA_FOLDER
	case $EXTRA_FOLDER in
		"" ) EXTRA_FOLDER="$PWD/.."; break;;
		* ) break;;
	esac
	done
	
	if [[ ! $EXTRA_FOLDER == \/* ]]
	then
		echo
		echo "ERROR: Path must be absolute from root /, do not use ~, ./, or ../"
		echo
		exit 1
	fi
	
	# Copy template
	cp pom.xml.template pom.xml
	
	common_part=$PWD
	back=
	while [ "${IDEMPIERE_FOLDER#$common_part}" = "${IDEMPIERE_FOLDER}" ]; do
	  common_part=$(dirname $common_part)
	  back="../${back}"
	done
	
	echo
	echo "Updating pom.xml ... done"
	CURRENT_DIR="$(echo ${back}${IDEMPIERE_FOLDER#$common_part/} | sed 's/\//\\\//g' | sed 's/ /\\ /g')"
	COMMAND="sed -i.bak 's/\${IDEMPIERE-FOLDER}/$CURRENT_DIR/g' pom.xml"
	
	# Change path on pom.xml
	eval $COMMAND
	
	common_part=$PWD
	back=
	while [ "${UPSTREAM_FOLDER#$common_part}" = "${UPSTREAM_FOLDER}" ]; do
	  common_part=$(dirname $common_part)
	  back="../${back}"
	done
	
	echo
	echo "Updating #1 pom.xml ... done"
	CURRENT_DIR="$(echo ${back}${UPSTREAM_FOLDER#$common_part/} | sed 's/\//\\\//g' | sed 's/ /\\ /g')"
	COMMAND="sed -i.bak 's/\${UPSTREAM-FOLDER}/$CURRENT_DIR/g' pom.xml"
	
	# Change path on pom.xml
	eval $COMMAND
	
	common_part=$PWD
	back=
	while [ "${EXTRA_FOLDER#$common_part}" = "${EXTRA_FOLDER}" ]; do
	  common_part=$(dirname $common_part)
	  back="../${back}"
	done
	
	echo
	echo "Updating #2 pom.xml ... done"
	CURRENT_DIR="$(echo ${back}${EXTRA_FOLDER#$common_part/} | sed 's/\//\\\//g' | sed 's/ /\\ /g')"
	COMMAND="sed -i.bak 's/\${EXTRA-FOLDER}/$CURRENT_DIR/g' pom.xml"
	
	# Change path on pom.xml
	eval $COMMAND
	rm pom.xml.bak
	echo
}

build () {
	mvn verify -Didempiere.target=org.kenos.idempiere.lbr.p2.targetplatform $*
}

clear

echo ===================================
echo	 Build Localization Brazil
echo	 Created By Ricardo Santana
echo	 \(www.kenos.com.br\)
echo ===================================
echo 

if [ -f "pom.xml" ]
then
	# Ask for iDempiere folder
	while true; do
	read -t 20 -e -p "Configure iDempiere and LBR folders on pom.xml and target-plarform? [N]: " yn
	case $yn in
	    ""  ) build $*; break;;
		[Yy]* ) configure; build $*; break;;
		[Nn]* ) build $*; break;;
		* ) echo "Please select a valid option. Type Y or N.";;
	esac
	done
	
# No pom.xml found, configure is mandatory	
else
	configure; build $*
fi

exit 0
