#!/bin/sh

################################################################################
#
# renameProject.sh
#
# author: Jackie Myrose
# date: June 4, 2013
# version: 1.0
#
# This script will copy an android project to a new project directory name
# and replace/rename all files within to work as expected under the new name.
# Project names that contain characters other than alpha-numeric, spaces or
# underscores MAY not work properly with this script. Use at your own risk!
# Be CERTAIN to backup your project(s) before renaming.
#
# One simple rule:
# 
# 1) The old project name cannot contain the new project name, so for instance,
#    renaming "MyStuff" to "MyStuff2" will not work. If you really need to do
#    this, rename the project to a temp name, then rename again.
#
#
# Installation:
#
# Copy (this) file "renameProject.sh" to your file system, and invoke:
#
#   chmod 755 renameProject.sh
#
# to make it executable.
#
# usage:
#
#   renameProject.sh <NewProjectName>
#
# examples:
#
#   ./renameProject.sh NewName
#   ./renameProject.sh "New Name"
#
################################################################################

OLDNAME="Skeleton App"
NEWNAME=$1

# remove bad characters
OLDNAME=`echo "${OLDNAME}" | sed -e "s/[^a-zA-Z0-9_ -]//g"`
NEWNAME=`echo "${NEWNAME}" | sed -e "s/[^a-zA-Z0-9_ -]//g"`

TMPFILE=/tmp/androidRename.$$

if [ "$OLDNAME" = "" -o "$NEWNAME" = "" ]; then
  echo "usage: $0 <NewProjectName>"
  exit
fi

echo "${NEWNAME}" | grep "${OLDNAME}" > /dev/null
if [ $? -eq 0 ]; then
  echo "Error: New project name cannot contain old project name. Use a tmp name first. Terminating."
  exit
fi

#if [ ! -d "${OLDNAME}" ]; then
#  echo "ERROR: \"${OLDNAME}\" must be a directory"
#  exit
#fi 

# set new project directory
if [ -d "${NEWNAME}" ]; then
  echo "ERROR: project directory \"${NEWNAME}\" exists. Terminating."
  exit
fi

# be sure tmp file is writable
cp /dev/null ${TMPFILE}
if [ $? -ne 0 ]; then
  echo "tmp file ${TMPFILE} is not writable. Terminating."
  exit
fi

# create project name with no spaces
OLDNAMENOSPACE=`echo "${OLDNAME}" | sed -e "s/ //g"`
NEWNAMENOSPACE=`echo "${NEWNAME}" | sed -e "s/ //g"`

# create project name with no spaces and lowercase
OLDNAMELOWER=`echo "${OLDNAME}" | sed -e "s/ //g" | tr '[A-Z]' '[a-z]'`
NEWNAMELOWER=`echo "${NEWNAME}" | sed -e "s/ //g" | tr '[A-Z]' '[a-z]'`

# copy project directory
echo copying project directory from "${OLDNAMENOSPACE}" to "${NEWNAMENOSPACE}"
cp -rp "${OLDNAMENOSPACE}" "${NEWNAMENOSPACE}"

# remove build directories
echo removing build directories from "${NEWNAMENOSPACE}"
rm -rf "${NEWNAMENOSPACE}/bin"
rm -rf "${NEWNAMENOSPACE}/gen"

#find text files, replace text
find "${NEWNAMENOSPACE}/." | while read currFile
do
    # find files that are of type text
    file "${currFile}" | grep "text" > /dev/null
    if [ $? -eq 0 ]; then
	# see if old proj name with no spaces is in the text
	grep "${OLDNAMENOSPACE}" "${currFile}" > /dev/null
	if [ $? -eq 0 ]; then
	    #replace the text with new proj name
	    echo found "${OLDNAMENOSPACE}" in "${currFile}", replacing...
	    sed -e "s/${OLDNAMENOSPACE}/${NEWNAMENOSPACE}/g" "${currFile}" > ${TMPFILE}
	    mv ${TMPFILE} "${currFile}"
	    cp /dev/null ${TMPFILE}
	fi
	# see if old proj name lower case no spaces is in the text
	grep "${OLDNAMELOWER}" "${currFile}" > /dev/null
	if [ $? -eq 0 ]; then
	    # replace the text with new proj name
	    echo found "${OLDNAMELOWER}" in "${currFile}", replacing...
	    sed -e "s/${OLDNAMELOWER}/${NEWNAMELOWER}/g" "${currFile}" > ${TMPFILE}
	    mv ${TMPFILE} "${currFile}"
	    cp /dev/null ${TMPFILE}
	fi
	# see if old proj name is in the text
	grep "${OLDNAME}" "${currFile}" > /dev/null
	if [ $? -eq 0 ]; then
	    # replace the text with new proj name
	    echo found "${OLDNAME}" in "${currFile}", replacing...
	    sed -e "s/${OLDNAME}/${NEWNAME}/g" "${currFile}" > ${TMPFILE}
	    mv ${TMPFILE} "${currFile}"
	    cp /dev/null ${TMPFILE}
	fi
    fi
done

# clean up old dir
rm -rf ${OLDNAMENOSPACE}

echo finished.