#!/bin/bash

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <live hieradir> <example hieradir>"
  exit 1
fi

liveDir=$1
exampleDir=$2

declare -A exampleFiles

# Create an array of example-files for later use.
for file in $(ls -1 $exampleDir); do
  # Skip files which are not valid yaml files.
  if [[ ! $file =~ ^(.*\.yaml).*$ ]]; then
    continue
  fi
  exampleFiles["${BASH_REMATCH[1]//./_}"]="${exampleDir}/$file"
done

# For each file in the live dir:
for file in $(ls -1 $liveDir); do
  declare -A keys

  # Skip files which are not valid yaml files.
  if [[ ! $file =~ ^(.*\.yaml)$ ]]; then
    continue
  fi

  # Skip the user configuration, as the number og keys ther varies.
  if [[ $file =~ ^(users.yaml)$ ]]; then
    continue
  fi
  
  # Print an error if the file does not exist in the example dir.
  if [[ -z ${exampleFiles["${file//./_}"]} ]]; then
    echo "$file does not exist in example directory"
    continue
  fi

  fileFull="${liveDir}/$file"

  # Collect keys from live data
  for line in $(cat $liveDir/$file); do
    if [[ $line =~ ^(([a-zA-Z0-9\_@]+::)*[a-zA-Z0-9\_@]+):.*$ ]]; then
      key="${BASH_REMATCH[1]//:/_c_}"
      key="${key//@/_at_}"
      keys["$key"]=1
    fi
  done

  # Collect keys from example data, and store the diff
  for line in $(cat ${exampleFiles["${file//./_}"]}); do
    if [[ $line =~ ^(([a-zA-Z0-9\_@]+::)*[a-zA-Z0-9\_@]+):.*$ ]]; then
      key="${BASH_REMATCH[1]//:/_c_}"
      key="${key//@/_at_}"
      
      if [[ -z ${keys["$key"]} ]]; then
        keys["$key"]=2
      else
        keys["$key"]=0
      fi
    fi
  done

  # Print a summary
  allok=1
  for key in ${!keys[@]}; do
    value=${keys["$key"]}
    key="${key//_at_/@}"
    key="${key//_c_/:}"
    if [[ $value -eq 1 ]]; then
      allok=0
      echo "The key \"$key\" in $file only exists in the LIVE data"
    elif [[ $value -eq 2 ]]; then
      allok=0
      echo "The key \"$key\" in $file only exists in the DEMO data"
    fi
  done
  
  # Print a message if the file looks OK
  if [[ $allok -eq 1 ]]; then
    echo "The file $file looks up to date!"
  fi

  unset keys
done
