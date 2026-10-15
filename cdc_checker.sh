#!/usr/bin/bash

usage() {
    echo "Usage: $0 [--sv] [-t|--top TOP_MODULE] [-d|--dir FILE_DIRECTORY] [-c|--constr CONSTRAINT_FILE] [-p|--constr-dir CONSTRAINT_DIRECTORY] [-o|--output OUTPUT_FILE]"
    echo "  --sv                                        Specify whether the design contains any systemverilog files."
    echo "  -n, --netlist	NETLIST			Specify the netlist to be analyzed. (Required, if custom yosys script is used)(Should be .json)"
    echo "  -m, --netlist-dir	PATH_TO_NETLIST		Specify the path to netlist "
    echo "  -t, --top           TOP_MODULE              Specify the name of top module."
    echo "  -d, --dir           FILE_DIRECTORY          Specify the path to the design."
    echo "  -c, --constr        CONSTRAINT_FILE         Specify the name of constraint file. Must be of the format .SDC or .XDC"
    echo "  -p, --constr-dir    CONSTRAINT_DIRECTORY    Specify the path to constraint file."
    echo "  -o, --output        OUTPUT_FILE             Specify the name of output file which will be automatically stored with the design. (Optional)"
    echo "  -h, --help                                  Display this message."

}

SHORT="t:d:c:p:hn:o:m:"
LONG="sv,top:,dir:,netlist:,constr:,constr-dir:,help,output:,netlist-dir:"

PARSED=$(getopt --options=$SHORT --longoptions=$LONG --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1
fi

eval set -- "$PARSED"

has_netlist=0
has_top_module=0
TOP_MODULE=""
CONSTR=""
DIR=""
NETLIST=""
NET_DIR=""
OUTPUT_FILE=""
file_format="v"
CONSTR_DIR=""

while true; do
    case "$1" in
        --sv)
            file_format="sv"
            shift
            ;;
        -t|--top)
	    has_top_module=1
            TOP_MODULE="$2"
            shift 2
            ;;
        -d|--dir)
            DIR="$2"
            shift 2
            ;;
        -c|--constr)
            CONSTR="$2"
            shift 2
            ;;
        -p|--constr-dir)
            CONSTR_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
	-n|--netlist)
	    has_netlist=1
	    NETLIST="$2"
	    shift 2
	    ;;
	-m|--netlist-dir)
	    NET_DIR="$2"
	    shift 2
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



if [ $has_top_module -eq 1 ] && [ $has_netlist -eq 1 ]; then
    echo "Error:Both netlist and top module cannot be provided together. Use either -t|--top with -d|--dir or -n|--netlist with -m|--netlist-dir"
    usage
    exit 1
fi

if [[ -z "$TOP_MODULE" && -z "$NETLIST" ]]; then
    echo "Error:-t|--top option or -n|--netlist option is necessary and requires exactly 1 argument"
    usage
    exit 1
fi
if [[ -z "$DIR" && -z "$NET_DIR" ]]; then
    echo "Error:-d|--dir or -m|--netlist-dir option is necessary and requires exactly 1 argument"
    usage
    exit 1
fi
if [[ -z "$CONSTR" ]]; then
    echo "Error:-c|--constr option is necessary and requires exactly 1 argument"
    usage
    exit 1
fi

if [[ $has_netlist -eq 1 ]]; then
    [[ -n "$NETLIST" && -n "$NET_DIR" ]] ||
        { echo "Error: -n and -m are both required."; exit 2; }
elif [[ $has_top_module -eq 1 ]]; then
    [[ -n "$TOP_MODULE" && -n "$DIR" ]] ||
        { echo "Error: -t and -d are both required."; exit 2; }
else
    echo "Error: Specify either -t with -d or -n with -m."
    exit 2
fi


if [[ $has_netlist -eq 1 ]]; then
	WORK_FILE=$NETLIST
	WORK_DIR=$NET_DIR
	echo "NETLIST: $WORK_FILE"
	echo "WORKING DIRECTORY: $WORK_DIR"
elif [[ $has_top_module -eq 1 ]]; then
	WORK_DIR=$DIR
	WORK_FILE=$TOP_MODULE
	echo "TOP MODULE: $WORK_FILE"
	echo "WORKING DIRECTORY: $WORK_DIR"
fi

if [[ -z "$CONSTR_DIR" ]]; then
    CONSTR_DIR="$WORK_DIR"
fi

echo "CONSTRAINT FILE: $CONSTR_DIR/$CONSTR"

if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE="${WORK_FILE%.*}_cdc_report.json"
fi

OUTPUT_DIR="$WORK_DIR/../CDC_REPORTS"
echo "OUTPUT FILE: $OUTPUT_DIR/$OUTPUT_FILE"



chmod -R g+w $WORK_DIR
[ ! -d $OUTPUT_DIR ] && mkdir "$OUTPUT_DIR"

FILESET="$WORK_DIR/*.$file_format"
echo "FILESET: $FILESET"
NETLIST_JSON="$TOP_MODULE"_netlist.json

if [[ $has_netlist -eq 1 ]]; then
	uv run rtl-buddy-cdc analyze \
    	--netlist $NET_DIR/$NETLIST \
    	--sdc $CONSTR_DIR/$CONSTR \
    	--format json \
    	--output $OUTPUT_DIR/$OUTPUT_FILE
    	status=$?
    	
elif [[ $has_top_module -eq 1 ]]; then
	uv run rtl-buddy-cdc lint \
	--top $TOP_MODULE \
	--sdc $CONSTR_DIR/$CONSTR \
	--format json \
	--keep-json $OUTPUT_DIR/$NETLIST_JSON \
	--output $OUTPUT_DIR/$OUTPUT_FILE \
	$FILESET
	status=$?
fi

if [[ ! -f $OUTPUT_DIR/$OUTPUT_FILE ]]; then
	echo "Error ($status): Output FIle  was not generated: $OUTPUT_DIR/$OUTPUT_FILE"
	exit $status
fi

if [[ $status -ne 0 ]]; then
	echo "Error: CDC check failed with error code $status"
	echo "Check errors at: $OUTPUT_DIR/$OUTPUT_FILE"
	exit 0
fi

echo "CDC check completed successfully"


if grep -Eiq '"(error|warning)"' "$OUTPUT_DIR/$OUTPUT_FILE"; then
    echo "The design contains some CDC violations!"
else
    echo "The design is CDC Safe!"
fi

echo "For debugging/viewing reports, check $OUTPUT_DIR/$OUTPUT_FILE"
