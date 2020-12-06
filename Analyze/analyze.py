# -*- coding: utf-8 -*-

import os
import tarfile
import sys
import mysql.connector
import configparser
import csv

class Database:
	def connect_db(self):
		config = configparser.ConfigParser()
		config.read("sql.ini")
		self.conn = mysql.connector.connect(
				host = config.get("DBinfo","HOST"),
				user = config.get("DBinfo","ID"),
				password = config.get("DBinfo","PW"),
				database = config.get("DBinfo","DB")
		)
		self.cursor = self.conn.cursor()
	def insert_db(self,data):
		query = "insert into test values(%s, %d, %d, %d, %s, %s)"
		self.cursor.executemany(query, data)
		self.conn.commit()


if __name__ == "__main__":
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
	
	f = open(output_dir+'/result.csv', 'r', encoding='utf-8')
	lines = csv.reader(f)
	data = []
	tmp=0
	for line in lines:
		if tmp==0:
			tmp=1
		else:
			backdata = open(output_dir+'/'+line[0], 'r', encoding='utf-8').read()
			line.append(backdata)
			data.append(tuple(line))

	db = Database()
	db.connect_db()
#	db.insert_db(
	
	backdata.close()
	f.close()
