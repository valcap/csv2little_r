#!/bin/bash

#############################################################
#
# Author  : Valerio Capecchi <capecchi@lamma.rete.toscana.it>
# Date    : 2013-05-13
# UpDate  : 2015-03-17
# Purpose : Convert csv files (comma separated value) into 
#           lttle_r format observation data files
#
#############################################################

# Argument(s)
if [ $# -ne 2 ] ; then
 echo "Usage: sh ./$0 csv_file variable SPD|DIR|TMP|BAR|IGR|UWND|VWND|THICK"
 echo "Example: sh ./$0 ../data/infile.csv TMP"
 echo ""
 exit 1
fi

# Functions
function notice {
  echo "+++"`date +%Y-%b-%d_%H:%M:%S`"+++ "$@
}

# Log file
if [ ! -d "../log" ]; then
  logfile=`basename $0 .sh`_`date +"%Y%m%d"`.log
else
  logfile=../log/`basename $0 .sh`_`date +"%Y%m%d"`.log
fi
exec 1>>../log/`basename $0 .sh`_`date +"%Y%m%d"`.log
exec 2>&1

# Check input file (input file exists and is not zero size)
datfile=$1
if [ ! -e "$datfile" ] || [ ! -s "$datfile" ]; then
  notice "input file is missing or is zero size..."
  notice "Exiting..."
  exit 1;
fi

# Check input variables
var=$2
if [ $var != 'SPD' ] && [ $var != 'DIR' ] && [ $var != 'TMP' ] && [ $var != 'BAR' ] && [ $var != 'IGR' ] && [ $var != 'UWND' ] && [ $var != 'VWND' ] && [ $var != 'THICK' ]; then
  notice "input variable must be one of SPD|DIR|TMP|BAR|IGR|UWND|VWND|THICK"
  notice "whereas input variable is $var"
  notice "Exiting..."
  exit 1; 
fi

# Check env file
envfile='../env/test.env'
if [ -f "$envfile" ]; then
  source $envfile
else
  notice "env file $envfile is missing..."
  notice "Exiting..."
  exit 1;
fi

# Check .f file
forfile=$SRCDIR'/csv2little_r.f.tmpl'
if [ ! -e $forfile ]; then
  notice "opss $forfile is missing";
  notice "Exiting..."
  exit 1;
fi

# Change directory and clean stuff
rm -f $WRKDIR/infile.csv $WRKDIR/csv2little_r.f $WRKDIR/pippo.exe
rm -f $WRKDIR/${fout}
cd $WRKDIR
cp $datfile $WRKDIR/infile.csv 

######################################################################################
# Main loop over variables: wind speed, wind direction, relative humidity and pressure
######################################################################################
for row in `cat $WRKDIR/infile.csv`
do
  # It supposes the input file like this
  # NAME_OF_STATION;LONGITUDE;LATITUDE;YYYYMMDD_hhmm;VALUE
  namP=`echo $row | cut -d';' -f1`
  lonP=`echo $row | cut -d';' -f2`
  latP=`echo $row | cut -d';' -f3`
  strP=$namP' '$lonP' '$latP' '
  if [ ${#strP} -gt 40 ]; then
    TMPL_STR=`echo $strP | cut -c1-40`
  else
    TMPL_STR=$strP
    while [ ${#TMPL_STR} -lt 40 ]
    do
      TMPL_STR=$TMPL_STR'x'
    done
  fi
  if [ ${#TMPL_STR} -ne 40 ]; then
    echo "boh...something went wrong"; exit 1;
  fi
  dateP=`echo $row | cut -d';' -f4`
  yyyyP=`echo $dateP | cut -c1-4`
  yyP=`echo $dateP | cut -c3-4`
  mmP=`echo $dateP | cut -c5-6`
  ddP=`echo $dateP | cut -c7-8`
  hhP=`echo $dateP | cut -c10-11`
  nnP=`echo $dateP | cut -c12-13`
  mdateP=$yyP$mmP$ddP$hhP
  case $var in
  BAR)
    VAL_P=`echo $row | cut -d';' -f5`
    if [[ -z "$VAL_P" || "$VAL_P" =~ "," ]]; then
      VAL_P='-888888.'
    fi
    VAL_DIR='-888888.'
    VAL_SPD='-888888.'
    VAL_RH='-888888.'
    VAL_TMP='-888888.'
    VAL_U='-888888.'
    VAL_V='-888888.'
    VAL_THICK='-888888.'
  ;;
  DIR)
    VAL_P='-888888.'
    VAL_DIR=`echo $row | cut -d';' -f5`
    if [[ -z "$VAL_DIR" || "$VAL_DIR" =~ "," ]]; then
      VAL_DIR='-888888.'
    fi
    VAL_SPD='-888888.'
    VAL_RH='-888888.'
    VAL_TMP='-888888.'
    VAL_U='-888888.'
    VAL_V='-888888.'
    VAL_THICK='-888888.'
  ;;
  SPD)
    VAL_P='-888888.'
    VAL_DIR='-888888.'
    VAL_SPD=`echo $row | cut -d';' -f5`
    if [[ -z "$VAL_SPD" || "$VAL_SPD" =~ "," ]]; then
      VAL_SPD='-888888.'
    fi
    VAL_RH='-888888.'
    VAL_TMP='-888888.'
    VAL_U='-888888.'
    VAL_V='-888888.'
    VAL_THICK='-888888.'
  ;;
  IGR)
    VAL_P='-888888.'
    VAL_DIR='-888888.'
    VAL_SPD='-888888.'
    VAL_RH=`echo $row | cut -d';' -f5`
    if [[ -z "$VAL_RH" || "$VAL_RH" =~ "," ]]; then
      VAL_RH='-888888.'
    fi
    VAL_TMP='-888888.'
    VAL_U='-888888.'
    VAL_V='-888888.'
    VAL_THICK='-888888.'
  ;;
  TMP)
    VAL_P='-888888.'
    VAL_DIR='-888888.'
    VAL_SPD='-888888.'
    VAL_RH='-888888.'
    VAL_TMP=`echo $row | cut -d';' -f5`
    if [[ -z "$VAL_TMP" || "$VAL_TMP" =~ "," ]]; then
      VAL_TMP='-888888.'
    fi
    VAL_U='-888888.'
    VAL_V='-888888.'
    VAL_THICK='-888888.'
  ;;
  THICK)
    VAL_P='-888888.'
    VAL_DIR='-888888.'
    VAL_SPD='-888888.'
    VAL_RH='-888888.'
    VAL_TMP='-888888.'
    VAL_THICK=`echo $row | cut -d';' -f5`
    if [[ -z "$VAL_THICK" || "$VAL_THICK" =~ "," ]]; then
      VAL_THICK='-888888.'
    fi
    VAL_U='-888888.'
    VAL_V='-888888.'
  ;;
  VWND)
    VAL_P='-888888.'
    VAL_DIR='-888888.'
    VAL_SPD='-888888.'
    VAL_RH='-888888.'
    VAL_TMP='-888888.'
    VAL_V=`echo $row | cut -d';' -f5`
    if [[ -z "$VAL_V" || "$VAL_V" =~ "," ]]; then
      VAL_V='-888888.'
    fi
    VAL_U='-888888.'
    VAL_THICK='-888888.'
  ;;
  UWND)
    VAL_P='-888888.'
    VAL_DIR='-888888.'
    VAL_SPD='-888888.'
    VAL_RH='-888888.'
    VAL_TMP='-888888.'
    VAL_U=`echo $row | cut -d';' -f5`
    if [[ -z "$VAL_U" || "$VAL_U" =~ "," ]]; then
      VAL_U='-888888.'
    fi
    VAL_V='-888888.'
    VAL_THICK='-888888.'
  ;;
  *)
    echo "boh...something went wrong with input parameters"; exit 1;
  esac
  seq_num=1

  # Terrain variable....stuff to fix here
  terP='-888888.'

  #
  ## Validate Fortran program
  cat $forfile \
      | sed -e "s/VAL_K/1/g" \
      | sed -e "s/TMPL_STR/$TMPL_STR/g" \
      | sed -e "s/TMPL_NAM/$namP/g" \
      | sed -e "s/TMPL_LON/$lonP/g" \
      | sed -e "s/TMPL_LAT/$latP/g" \
      | sed -e "s/VAL_TER/$terP/g" \
      | sed -e "s/VAL_Z/$terP/g" \
      | sed -e "s/VAL_MDATE_MINS/$nnP/g" \
      | sed -e "s/VAL_MDATE/$mdateP/g" \
      | sed -e "s/VAL_TMP/$VAL_TMP/g" \
      | sed -e "s/VAL_SPD/$VAL_SPD/g" \
      | sed -e "s/VAL_DIR/$VAL_DIR/g" \
      | sed -e "s/VAL_P/$VAL_P/g" \
      | sed -e "s/VAL_TD/$VAL_TD/g" \
      | sed -e "s/VAL_U/$VAL_U/g" \
      | sed -e "s/VAL_V/$VAL_V/g" \
      | sed -e "s/VAL_RH/$VAL_RH/g" \
      | sed -e "s/VAL_THICK/$VAL_THICK/g" \
      > $WRKDIR/csv2little_r.f

  #
  ## Compile Fortran program
  $FC $WRKDIR/csv2little_r.f -o $WRKDIR/pippo.exe
  if [ ! -e $WRKDIR/pippo.exe ]; then
    echo "opss cannot compile $WRKDIR/csv2little_r.f";
    rm -f $WRKDIR/pippo.exe;
    exit 1;
  fi

  #
  ## Run Fortran program
  $WRKDIR/pippo.exe
  if [ ! -e $WRKDIR/fort.2 ]; then
    echo "$WRKDIR/fort.2 is missing";
    echo "fortran program failed for some reasons";
    exit 1;
  else
    cat $WRKDIR/fort.2 >> $WRKDIR/$fout
    rm -f $WRKDIR/pippo.exe $WRKDIR/fort.2;
  fi
done

# Check output file
if [ ! -e $WRKDIR/$fout ]; then
  echo "boh something went wrong"; exit 1;
fi

## Ciao
rm -f $WRKDIR/infile.csv $WRKDIR/csv2little_r.f $WRKDIR/pippo.exe $WRKDIR/fort.2
exit 0;

