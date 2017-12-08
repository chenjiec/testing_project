#!/bin/sh

#-----------------------------------------------
# FIXED VALUES
#-----------------------------------------------

evcd=$1
ports="20|21|22"


#-----------------------------------------------
# MAIN
#-----------------------------------------------

if [ $# -ne 1 ]; then
   echo "Usage: $0 <evcd>" >&2
   exit 1
fi

if [ ! -e "${evcd}" ]; then
   echo "Error: ${evcd} not found." >&2
   exit 1
fi


tmpdir=$(mktemp -d)
trap 'rm -rf "${tmpdir}"' EXIT INT TERM HUP
fixed_evcd=${tmpdir}/fixed.evcd

awk '{ 
   if($NF ~ /^<('"${ports}"')$/) {
      gsub("X","N",$1);
      gsub("L","D",$1);
      gsub("H","U",$1);
   }
   gsub("\\[-1:0\\]","[1:2]");
   print
}' ${evcd} > ${fixed_evcd}

mv -v ${fixed_evcd} ${evcd}
