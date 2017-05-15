#!/bin/bash



#=========================================================================================================
#  FUNCTION
#
#     fnSetDebug           (msg)                  Write Debug Level Traces.
#     fnPrintDebug         ()                     Print Debug file.
#     fnPrintOutput        ()                     Print Output file.
#     fnCreateTmpFiles     ()                     Create temp files that we are going to use into the program.
#     fnCleanTmpFiles      ()                     Delete all tmp files.
#     fnCheckXwindows      ()                     Check if we are in X-windows.
#     fnCheckOutput        (consoleOpt)           Check if we show result in console or in X-Windows.
#     fnCreateDpkgList     ()                     Create a file with packages list installed in the system.
#     fnInitialize         (PROCESS, PID)         Initialize script config.
#     fnShowCenter         (dataOut, lengthLine)  Prints lines centered.
#     fnGetDpkgDetail      (pack)                 Get Details from dpkg command with -l option.
#     fnGetTotalTimeString (nanoSecondsIN)        Return a string with time in format hh:mm:ss.nnnnnn from nanoseconds parameter.
#     fnShowTotalTime      (iniTime, endTime)     Print time difference between two times parameters.
#     fnGetLinkedFile      (fileIN)               Return original file of symbolic Link.
#     fnGetArgv            (optionA, optionB)     Get Script's argument variables.
#
#=========================================================================================================

#----------------------------------------------
#    Function: fnSetDebug
# Description: Write Debug Level Traces.
function fnSetDebug() {

   # Input
   local __msg=$1

   local _debugActived=$gActivatedDebug

   if [ $_debugActived -eq 1 ];
   then
      echo "[DEBUG] $__msg"                >> $gTmpDebugFile
   fi
}  
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnPrintDebug
# Description: Print Debug file.
function fnPrintDebug() {

   local _debugActived=$gActivatedDebug

   if [ $_debugActived -eq 1 ];
   then
     echo ""
     echo "+++[DEBUG]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
     cat $gTmpDebugFile
     echo "+++[DEBUG]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
     echo ""
   fi
}  
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnPrintOutput
# Description: Print Output file.
function fnPrintOutput() {

   # Input
   local __outputOpt=$gXwinOutput

   fnSetDebug "Print Output: [$__outputOpt] [$gTmpOutput]"

   if [ $__outputOpt -eq 1 ];
   then
     cat $gTmpOutput | xmessage -default okay -file - &
   else
     cat $gTmpOutput
   fi
}  
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnCreateTmpFiles
# Description: Create temp files that we are
#              going to use into the program.
#
function fnCreateTmpFiles() {

   # Create temp files.
   touch $gTmpFilePacks
   touch $gTmpDebugFile
   touch $gTmpDpkgList
   touch $gTmpOutput

   fnSetDebug "Create file: [$gTmpFilePacks]"
   fnSetDebug "Create file: [$gTmpDpkgList]"
   fnSetDebug "Create file: [$gTmpOutput]"
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnCleanTmpFiles
# Description: Delete all tmp files.
#
function fnCleanTmpFiles() {

   # Variables.
   local _debugActived=$gActivatedDebug

   if [ $_debugActived -eq 0 ];
   then
      rm $gTmpFilePacks
      rm $gTmpDebugFile
      rm $gTmpDpkgList
      rm $gTmpOutput
   fi
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnCheckXwindows
# Description: Check if we are in X-windows.
#
function fnCheckXwindows() {

   # Variables.
   local _cmdError=0
   local _xWinOpt="ENABLE"

   # Check X-windows.
   xrandr &> /dev/null   
   _cmdError=$?

   gIsXwinActive=0
   if [ $_cmdError -eq 0 ]; then gIsXwinActive=1; fi

   if [ $gIsXwinActive -eq 0 ]; then _xWinOpt="DISABLE"; fi

   fnSetDebug "  X-windows: [$_xWinOpt]"
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnCheckOutput
# Description: Check if we show result in console or in X-Windows.
#
function fnCheckOutput() {

   # Input.
   local __consoleOpt=$1
  
   # Variables.
   local _opt="X-windows"

   gXwinOutput=1
   if [ "$__consoleOpt" == "-console" ];
   then
      gXwinOutput=0
      _opt="Console"
   fi

   fnSetDebug "      Ouput: [$_opt]"
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnCreateDpkgList
# Description: Create a file with packages list
#              installed in the system.
#
function fnCreateDpkgList() {

  # Input.
  local __dpkgFile=$gTmpDpkgList

  fnSetDebug "  DPKG list: [$__dpkgFile]"

  dpkg -l > $__dpkgFile
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnInitialize
# Description: Initialize script config.
#
function fnInitialize() {

   # Parámetros de Entrada.
   local __PROCESS=$1
   local __PID=$2

   # Script setup
   gProcessNAME=`basename $__PROCESS`
   gProcessPID=$__PID
   gPatternFiles=""
   gPatternFilesearched=""

   # Options' setup.
   gActivatedDebug=0
   gIsXwinActive=0
   gXwinOutput=0

   # Files and directories setup.
   gBinPath="/usr/bin"

   local _tmpDirectory="/tmp"
   local _tmpFilename="$_tmpDirectory/${gProcessNAME%.*}_$gProcessPID"

   # Temp files.
   gTmpFilePacks=${_tmpFilename}_files
   gTmpDebugFile=${_tmpFilename}_debug
   gTmpDpkgList=${_tmpFilename}_dpkglist
   gTmpOutput=${_tmpFilename}_ouput

   # Variable's lenght setup.
   gLenghtLine=100                  # Maximum length for output line.
   gLenghtFilename=45               # Maximum length for File's name.
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnShowCenter
# Description: Prints lines centered.
#
function fnShowCenter() {

  # Parámetros de Entrada.
  local __dataOut=$1
  local __lengthLine=$2

  # Variables.
  local longData=${#__dataOut}
  local leftSpace=$(((($__lengthLine-$longData)/2)+$longData))
  local rightSpace=$(($__lengthLine-$leftSpace))

  printf "%*s%*s\n" $leftSpace "$__dataOut" $rightSpace ""
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnGetDpkgDetail
# Description: Get Details from dpkg command with
#              -l option.
#
function fnGetDpkgDetail() {

   # Input.
   local __packIN=$1

   # Output.
   local __versionOUT=$2
   local __DetailsOUT=$3

   # Variables.
   local _dpkgFile=$gTmpDpkgList
   local _dpkg=""
   local _dpkgVersion=$2
   local _dpkgDescription=$3

   #_dpkg=`dpkg -l | grep "$__packIN" | awk -v awkParam=$__packIN '$2 == awkParam'`
   _dpkg=`grep "$__packIN" $_dpkgFile| awk -v awkParam=$__packIN '$2 == awkParam'`
    
   if [ -z "$_dpkg" ];
   then
      #_dpkg=`dpkg -l | grep "$__packIN" | awk -v awkParam=$__packIN:amd64 '$2 == awkParam'`
      _dpkg=`grep "$__packIN" $_dpkgFile | awk -v awkParam=$__packIN:amd64 '$2 == awkParam'`
   fi
    
   _dpkgVersion=`echo $_dpkg | cut -d" " -f3`
   _dpkgDescription=`echo $_dpkg | cut -d" " -f5-`
   _dpkgDescription=`echo "$_dpkgDescription" | sed 's/'\''//g'`

   eval $__versionOUT="'$_dpkgVersion'"
   eval $__DetailsOUT="'$_dpkgDescription'"
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnGetTotalTimeString
# Description: Return a string with time in format hh:mm:ss.nnnnnn
#              from nanoseconds parameter.
#
function fnGetTotalTimeString() {

   # Parámetros de Entrada.
   local __nanoSecondsIN=$1
   local __=$2

   local retString=$2
   local iNanoSeconds=0
   local iSeconds=0
   local iMinutes=0
   local iHours=0


   let iSeconds=($__nanoSecondsIN)/1000000000
   let iNanoSeconds=($__nanoSecondsIN)%1000000000

   let iMinutes=$iSeconds/60

   if [ $iMinutes -gt 0 ];
   then
      let iSeconds=$iSeconds%60

      let iHours=$iMinutes/60

      if [ $iHours -gt 0 ];
      then
         let iMinutes=$iMinutes%60      
      fi
   fi

   retString=`printf "%02d:%02d:%02d.%010d" "$iHours" "$iMinutes" "$iSeconds" "$iNanoSeconds"`

   eval $__="'$retString'"
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnShowTotalTime
# Description: Print time difference between two
#              times parameters.
#
function fnShowTotalTime() {

   # Input parameters.
   local __iniTime=$1
   local __endTime=$2

   # Variables.
   local nsTotalTime=0
   local fnGetTotalTimeString=""

   let nsTotalTime=$__endTime-$__iniTime

   fnGetTotalTimeString "$nsTotalTime" strTotalTime

   echo " . Time used: [$strTotalTime]"
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnGetLinkedFile
# Description: Return original file of symbolic Link
#
function fnGetLinkedFile() {

   # Parámetros de Entrada.
   local __fileIN=$1
   local __=$2

   if [ -h "$__fileIN" ];
   then

      _linkFile=`readlink $__fileIN`    

      _dirLink=`dirname $__fileIN`
      _dirType="`echo $_linkFile | cut -d"/" -f1`"

      if [ "$_dirType" != "" ];
      then
         if [ "$_dirType" == ".." ];
         then
            _linkFile="${_dirLink%/*}/${_linkFile##*../}"
         else
            _linkFile="$_dirLink/$_linkFile"
         fi
      fi

      fnGetLinkedFile "$_linkFile" _retFile

   else
      _retFile=$__fileIN
   fi

   eval $__="'$_retFile'"
}
#
#----------------------------------------------

#----------------------------------------------
#    Function: fnGetArgv
# Description: Get Script's argument variables.
#
function fnGetArgv() {
   # Parámetros de Entrada.
   local __optionA=$1
   local __optionB=$2

   gPatternFiles="$__optionA"
   if [ $gXwinOutput -eq 0 ]; then gPatternFiles="$__optionB"; fi
   if [ $gIsXwinActive -eq 0 ]; then gXwinOutput=0; fi

   gPatternFilesearched="$gBinPath/$gPatternFiles"
}
#
#----------------------------------------------





#=========================================================================================================
#  MAIN
#=========================================================================================================

#----------------------------------------------
# Initialize script config.
fnInitialize "$0" "$$"

nsIniTime=`date +%s%N`
#----------------------------------------------

#----------------------------------------------
# Temp files.
fnCreateTmpFiles
#----------------------------------------------

#----------------------------------------------
# Set TRUE value in gIsXwinActive variable if we are in X-windows.
fnCheckXwindows

# Set TRUE value in gXwinOutput variable if we want to show output in X-windows.
fnCheckOutput "$1"

# Get script's argument variables.
fnGetArgv "$1" "$2"
#----------------------------------------------

#----------------------------------------------
# Create a packages list installed in the system.
fnCreateDpkgList
#----------------------------------------------

#----------------------------------------------
# Process all files in directory.
fnSetDebug "======================================="

for fullPathFile in $( ls -d $gPatternFilesearched* )
do
  isProcessed=1
  
  uCommand=${fullPathFile##*/}

  fnSetDebug "----------------------------------------"
  fnSetDebug "          Command: [$uCommand]"

  #printf "%s;%s;%s\n" "Filename" "Packages" "Packages Details"

  # Only process files, not directories.
  if [[ $isProcessed -eq 1 && -d $fullPathFile ]];
  then
     
     printf "%s;%s;%s\n" "$uCommand" "----<DIRECTORY>" ""                 >> $gTmpFilePacks

     fnSetDebug "         Packages: [DIRECTORY]"
     isProcessed=0
  fi

  # Comprobamos si es un enlace simbólico
  if [[ $isProcessed -eq 1 && -h $fullPathFile ]];
  then
    uCommand="$uCommand (*link)"

    fnGetLinkedFile "$fullPathFile" linkedFile
    fullPathFile=$linkedFile

    fnSetDebug "Symbol Link found: [$linkedFile]"
  fi

  if [ $isProcessed -eq 1 ];
  then

    packCount=0

    for pack in $( dpkg -S $fullPathFile 2> /dev/null | grep -v "desviado" | cut -d":" -f1 | sort -u )
    do
      let packCount+=1

      pack=`echo "$pack" | sed 's/,//g'`

      fnGetDpkgDetail "$pack" dpkgVersion dpkgDescription

      printf "%s;%s;%s\n" "$uCommand" "$pack" "$dpkgDescription"          >> $gTmpFilePacks
    
      fnSetDebug "         Packages: [$pack]"

    done

    if [ $packCount -eq 0 ];
    then
       
       printf "%s;%s;%s\n" "$uCommand" "----<NOT FOUND>" ""               >> $gTmpFilePacks

       fnSetDebug "         Packages: [NOT FOUND]"
    fi
  fi

done

fnSetDebug "======================================="

nsEndTime=`date +%s%N`
#----------------------------------------------


#----------------------------------------------
# Print title and pattern searched.
echo ""                                                                                                    >> $gTmpOutput
fnShowCenter "================================" $gLenghtLine                                               >> $gTmpOutput
fnShowCenter "==  getUserCommandInfo  v1.0  ==" $gLenghtLine                                               >> $gTmpOutput
fnShowCenter "================================" $gLenghtLine                                               >> $gTmpOutput
echo ""                                                                                                    >> $gTmpOutput
#----------------------------------------------

#----------------------------------------------
# Print total time.
echo "--------------------------------------------------"                                                  >> $gTmpOutput
echo ""                                                                                                    >> $gTmpOutput
echo " .    Search: [$gPatternFilesearched*]"                                                              >> $gTmpOutput
fnShowTotalTime "$nsIniTime" "$nsEndTime"                                                                  >> $gTmpOutput
echo ""                                                                                                    >> $gTmpOutput
echo "--------------------------------------------------"                                                  >> $gTmpOutput
echo ""                                                                                                    >> $gTmpOutput
#----------------------------------------------

#----------------------------------------------
# Print Packages Info.
iNumPacks=`awk '{ printf "%40s\n", $2 | "sort -u" }' FS=";" $gTmpFilePacks | wc -l`
fnShowCenter "=====================================" $gLenghtLine                                          >> $gTmpOutput
fnShowCenter "PACKAGES: [$iNumPacks]" $gLenghtLine                                                         >> $gTmpOutput
fnShowCenter "=====================================" $gLenghtLine                                          >> $gTmpOutput

if [ $iNumPacks -eq 0 ];
then
  fnShowCenter "NOT FOUND" $gLenghtLine                                                                    >> $gTmpOutput
else
  awk '{ printf "%45s: %-90s\n", "["$2"]", "["$3"]" | "sort -u" }' FS=";" $gTmpFilePacks | grep -v "\-<"   >> $gTmpOutput
fi
fnShowCenter "=====================================" $gLenghtLine                                          >> $gTmpOutput
echo ""                                                                                                    >> $gTmpOutput
#----------------------------------------------

#----------------------------------------------
# Print file's packages Info order by file name.
iNumCommands=`awk '{ printf "%40s\n", $1 | "sort -u" }' FS=";" $gTmpFilePacks | wc -l`
echo "================================================================================"                    >> $gTmpOutput
echo "Commands ($gPatternFilesearched): [$iNumCommands]"                                                   >> $gTmpOutput
echo "--------------------------------"                                                                    >> $gTmpOutput
printf "%*s%7s%-40s\n" "$gLenghtFilename" "COMMAND" "" "PACKAGES"                                          >> $gTmpOutput
printf "%.0s-" $(eval "echo {1.."$(($gLenghtFilename))"}")                                                 >> $gTmpOutput
printf "%.0s " $(eval "echo {1..7}")                                                                       >> $gTmpOutput
printf "%.0s-" $(eval "echo {1.."$(($gLenghtFilename))"}")                                                 >> $gTmpOutput
printf "\n"                                                                                                >> $gTmpOutput
awk '{ printf "%45s%7s%-40s\n", "["$1"]", " <---> ", "["$2"]" }' FS=";" $gTmpFilePacks                     >> $gTmpOutput
echo "================================================================================"                    >> $gTmpOutput
echo ""                                                                                                    >> $gTmpOutput
#----------------------------------------------

#----------------------------------------------
# Print file's packages Info order by package.
echo "================================================================================"                            >> $gTmpOutput
echo "Packages ($gPatternFilesearched): [$iNumPacks]"                                                              >> $gTmpOutput
echo "--------------------------------"                                                                            >> $gTmpOutput
printf "%*s%7s%-40s\n" "$gLenghtFilename" "PACKAGES" "" "COMMAND"                                                  >> $gTmpOutput
printf "%.0s-" $(eval "echo {1.."$(($gLenghtFilename))"}")                                                         >> $gTmpOutput
printf "%.0s " $(eval "echo {1..7}")                                                                               >> $gTmpOutput
printf "%.0s-" $(eval "echo {1.."$(($gLenghtFilename))"}")                                                         >> $gTmpOutput
printf "\n"                                                                                                        >> $gTmpOutput
awk '{ printf "%45s%7s%-40s\n", "["$2"]", " <---> ", "["$1"]" | "sort -u" }' FS=";" $gTmpFilePacks | grep -v "\-<" >> $gTmpOutput
echo "================================================================================"                            >> $gTmpOutput
echo ""                                                                                                            >> $gTmpOutput
#----------------------------------------------

fnPrintDebug
fnPrintOutput

fnCleanTmpFiles

exit 0
