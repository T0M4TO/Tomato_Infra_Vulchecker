#!/bin/sh
echo "########################################################################";
echo "#                      Infra Vulerability Checker                      #";
echo "#                                               Made By : Tomato       #";
echo "########################################################################";
echo "1. CentOS 6";
echo "2. CentOS 7";
echo "3. Ubuntu";
echo "########################################################################";
echo -e "Select Your OS : \c";
read os;
if [ ! -d log ] ; then
	mkdir log
fi
logfile=`date +%Y%m%d_%H%M%S`
logfile=log/log_$logfile
case $os in
1) echo "one" ;;
2) echo "Collecting Data... Do not close the terminal... Please wait" && sh Infra_Vul_Checker\(CentOS_7\).sh | tee $logfile ;;
3) echo "three" ;;
*) echo "INVALID NUMBER!" ;;
esac
echo "Finish!";
