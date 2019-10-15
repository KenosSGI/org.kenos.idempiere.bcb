#!/bin/bash

configure () {
	echo

	# Ask for iDempiere folder
	while true; do
	read -e -p "Select the absolute location of iDempiere project [$PWD/../iDempiere6.2]: " IDEMPIERE_FOLDER
	case $IDEMPIERE_FOLDER in
		"" ) if [ ! -f "$PWD/../iDempiere6.2/org.idempiere.parent/pom.xml" ]; then echo "Error:	File pom.xml not found => $IDEMPIERE_FOLDER/org.idempiere.parent/pom.xml"; else IDEMPIERE_FOLDER="$PWD/../iDempiere6.2"; break; fi;;
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
	read -e -p "Select the absolute location of LBR project [$PWD/../org.kenos.idempiere.lbr-6.2]: " LBR_FOLDER
	case $LBR_FOLDER in
		"" ) if [ ! -f "$PWD/../org.kenos.idempiere.lbr-6.2/org.kenos.idempiere.lbr.p2/target/repository/content.jar" ]; then echo "Error:	Features not found => $LBR_FOLDER/org.kenos.idempiere.lbr.p2/target/repository/"; else LBR_FOLDER="$PWD/../org.kenos.idempiere.lbr-6.2"; break; fi;;
		* ) if [ ! -f "$LBR_FOLDER/org.kenos.idempiere.lbr.p2/target/repository/content.jar" ]; then echo "Error:	Features not found => $LBR_FOLDER/org.kenos.idempiere.lbr.p2/target/repository/"; else break; fi;;
	esac
	done
	
	if [[ ! $LBR_FOLDER == \/* ]]
	then
		echo
		echo "ERROR: Path must be absolute from root /, do not use ~, ./, or ../"
		echo
		exit 1
	fi
	
	common_part=$PWD
	back=
	while [ "${IDEMPIERE_FOLDER#$common_part}" = "${IDEMPIERE_FOLDER}" ]; do
	  common_part=$(dirname $common_part)
	  back="../${back}"
	done
	
	echo
	echo "Updating pom.xml ... done"
	CURRENT_DIR="$(echo ${back}${IDEMPIERE_FOLDER#$common_part/} | sed 's/\//\\\//g' | sed 's/ /\\ /g')"
	COMMAND="sed 's/\${IDEMPIERE-FOLDER}/$CURRENT_DIR/g' pom.xml.template > pom.xml.tmp"
	
	# Change path on pom.xml
	eval $COMMAND
	
	common_part=$PWD
	back=
	while [ "${LBR_FOLDER#$common_part}" = "${LBR_FOLDER}" ]; do
	  common_part=$(dirname $common_part)
	  back="../${back}"
	done
	
	echo
	echo "Updating #1 pom.xml ... done"
	CURRENT_DIR="$(echo ${back}${LBR_FOLDER#$common_part/} | sed 's/\//\\\//g' | sed 's/ /\\ /g')"
	COMMAND="sed 's/\${LBR-FOLDER}/$CURRENT_DIR/g' pom.xml.tmp > pom.xml"
	
	# Change path on pom.xml
	eval $COMMAND
	rm pom.xml.tmp
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

exit 0
