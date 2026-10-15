#!/usr/bin/bash

usage() {
    echo "Usage: $0  [-d|--dir FILE_DIRECTORY] [-f|--file FILE]"
    echo "  -d, --dir		FILE_DIRECTORY	Specify the path to delete."
    echo "  -f, --file		FILE		Specify the file(s) to delete."
}

DIR=""
FILE_ARRAY=()



while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            if [[ $# -lt 2 || $2 == "-" ]]; then
            	echo "Error: -d requires 1 argument."
            	exit 2
            fi
            DIR="$2"
            shift 2
            ;;
	-f|--file)
	    shift
	    while [[ $# -gt 0 && "$1" != -.* && $1 != "--" ]]; do
	    	echo "Processing $1"
	    	FILE_ARRAY+=("$1")
	    	shift
	    done
	    if [[ ${#FILE_ARRAY[@]} -eq 0 ]]; then
	    	echo "Error: -f requires at least 1 arguments"
	    	exit 2
	    fi
	    ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming Error"
            exit 3
            ;;
    esac
done

if [[ ! -d "$DIR" ]]; then
	echo "Error: Directory $DIR does not exist"
	exit 2
fi


inexistent_file=0
for item in ${FILE_ARRAY[@]}; do
	if [[ ! -f $DIR/$item ]]; then
		inexistent_file=1
		echo "Error: File $DIR/$item does not exist"
	fi
done
if [[ $inexistent_file -ne 0 ]]; then
	exit 2
fi


if [[ ${#FILE_ARRAY[@]} -eq 0 ]]; then
	rm -rf $DIR/*
	echo "Cleaned all the files in $DIR"
else
	for item in ${FILE_ARRAY[@]}; do
		rm -rf $DIR/$item
		echo "Cleaned file $DIR/$item"
	done
fi

