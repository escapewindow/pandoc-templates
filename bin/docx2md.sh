#!/usr/bin/env bash
# Convenience script for converting a docx to a single gfm.

function non_fatal_realpath() {
  path=$(realpath -q "$1" || echo "$1")
  echo "$path"
}

# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/
POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -i|--input)
    INFILE="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--output)
    OUTFILE="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--columns)
    COLUMNS="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--to)
    MDFORMAT="$2"
    shift # past argument
    shift # past value
    ;;
    -x|--overwrite)
    OVERWRITE="1"
    shift
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Default columns
: "${COLUMNS:=80}"

# Default markdown
: "${MDFORMAT:=markdown_strict}"

if ! type pandoc > /dev/null  2>&1; then
  echo "Can't execute pandoc. Is it installed and in your path?"
  exit 1
fi

# Does the input file exist?
if [ ! -f "${INFILE}" ]; then
  echo "'${INFILE}' not found."
  exit 1
else
  INFILE="$(non_fatal_realpath "$INFILE")"
fi

# If no output filename given, set it to INFILE and change .docx to .md
: "${OUTFILE:=${INFILE%.*}.md}"
OUTFILE="$(non_fatal_realpath "$OUTFILE")"

# Prompt for confirmation if ${OUTFILE} exists.
if [[ -f "$OUTFILE" && -z "$OVERWRITE" ]]; then
  echo "$OUTFILE exists. "
  echo "Do you want to overwrite it?"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) echo "Overwriting."; break;;
          No ) echo "Cancelling."; exit;;
      esac
  done
fi

# Run Pandoc
pandoc --from=docx --to="$MDFORMAT" --columns="$COLUMNS" --output="$OUTFILE" "$INFILE"
