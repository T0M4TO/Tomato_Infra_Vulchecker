# -*- coding: utf-8 -*-

import os
import tarfile
import sys
import 


if len(sys.argv) != 2:
	print("You have to run script with argument(Result Tarfile)")
	sys.exit()

result = sys.argv[1]

output_dir="TEMP"

if not os.path.isdir(output_dir) :
	os.mkdir(output_dir)

result = tarfile.open(result, "r")
for member in result.getmembers():
	if member.isreg():
		member.name = os.path.basename(member.name)
		result.extract(member,output_dir)


