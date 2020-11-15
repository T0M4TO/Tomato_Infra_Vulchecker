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
case $os in
1) echo "one" ;;
2) sh Infra_Vul_Checker\(CentOS_7\).sh | tee result.txt ;;
3) echo "three" ;;
*) echo "INVALID NUMBER!" ;;
esac
