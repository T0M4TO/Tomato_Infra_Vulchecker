#!/bin/sh
echo "########################################################################";
echo "#                      Infra Vulerability Checker                      #";
echo "#                                               Made By : Tomato       #";
echo "########################################################################";
echo "1. CentOS 7";
echo "2. Apache";
echo "3. Mysql";
echo "########################################################################";
echo -e "Select Your Target : \c";
read os;
if [ ! -d log ] ; then
	mkdir log
fi
logfile=`date +%Y%m%d_%H%M%S`
logfile=log/log_$logfile
case $os in
1) echo "Collecting Data... Do not close the terminal... Please wait" && sh CentOS_7/Infra_Vul_Checker\(CentOS_7\).sh | tee $logfile ;;
2) echo "Collecting Data... Do not close the terminal... Please wait" && sh Apache/Infra_Vul_Checker\(Apache\).sh | tee $logfile ;;
3) echo "Mysql" ;;
*) echo "INVALID NUMBER!" ;;
esac
echo "Finish!";
