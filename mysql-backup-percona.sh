#!/usr/bin/sh

# Incremental Backups with percona tool
# create by kevin

User=root
Pwd=123456
Inb=/usr/bin/innobackupex
Date=`date +%Y-%m-%d`
Bak_home=/home/mysql_data
F_bak=/home/mysql_data/full_bak/$Date
I_bak=/home/mysql_data/incremental_bak/$Date


Login="--user=$User --password=$Pwd"
[[ -x /home/mysql_data/full_bak ]] || mkdir -p /home/mysql_data/full_bak
[[ -x /home/mysql_data/incremental_bak ]] || mkdir -p /home/mysql_data/incremental_bak
[[ -x /home/mysql_data/log ]] || mkdir -p /home/mysql_data/log

#full backup
if [[ -x $F_bak ]];then
	break
else
	$Inb $Login $F_bak
fi

#incremental backup
c=`ls -dl  /home/mysql_data/incremental_bak/* |wc -l`
nfile=`ls -td /home/mysql_data/incremental_bak/*|head -1`

if [[ $c -ge 1 ]];then
	$Inb $Login --incremental $I_bak --incremental-dir $nfile
else
	#first time to run bakcup
	$Inb $Login --incremental $I_bak --incremental-dir $F_bak
fi




