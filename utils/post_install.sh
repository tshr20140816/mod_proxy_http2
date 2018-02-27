#!/bin/bash

set -x

date
start_date=$(date)

chmod 755 start_web.sh

gcc --version

# ***** postgresql *****

postgres_user=$(echo ${DATABASE_URL} | awk -F':' '{print $2}' | sed -e 's/\///g')
postgres_password=$(echo ${DATABASE_URL} | grep -o '/.\+@' | grep -o ':.\+' | sed -e 's/://' | sed -e 's/@//')
postgres_server=$(echo ${DATABASE_URL} | awk -F'@' '{print $2}' | awk -F':' '{print $1}')
postgres_dbname=$(echo ${DATABASE_URL} | awk -F'/' '{print $NF}')

echo ${postgres_user}
echo ${postgres_password}
echo ${postgres_server}
echo ${postgres_dbname}

export PGPASSWORD=${postgres_password}

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
SELECT file_name
      ,length(file_base64_text)
  FROM t_files
 ORDER BY file_name
__HEREDOC__
cat /tmp/sql_result.txt

# ***** env *****

export PATH="/tmp/usr/bin:${PATH}"
export LD_LIBRARY_PATH=/tmp/usr/lib

export CFLAGS="-march=native -O2"
export CXXFLAGS="$CFLAGS"

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
SELECT file_base64_text
  FROM t_files
 WHERE file_name = 'usr_gettext_aria2.tar.bz2'
__HEREDOC__

# ***** /tmp/usr *****

cd /tmp

mkdir -m 777 usr

set +x
echo $(cat /tmp/sql_result.txt | head -n 3 | tail -n 1) > /tmp/usr.tar.bz2.base64.txt
set -x
base64 -d /tmp/usr.tar.bz2.base64.txt > /tmp/usr.tar.bz2
tar xf /tmp/usr.tar.bz2 -C /tmp/usr --strip=1

ls -Rlang /tmp/usr

cd /tmp
time aria2c -x2 http://ftp.jaist.ac.jp/pub/apache//httpd/httpd-2.4.29.tar.bz2
rm httpd-2.4.29.tar.bz2
time wget http://ftp.jaist.ac.jp/pub/apache//httpd/httpd-2.4.29.tar.bz2
rm httpd-2.4.29.tar.bz2
time aria2c -x2 http://apache.claz.org/httpd/httpd-2.4.29.tar.bz2
rm httpd-2.4.29.tar.bz2
time aria2c -x2 http://apache.claz.org/httpd/httpd-2.4.29.tar.bz2
rm httpd-2.4.29.tar.bz2
# wget http://www.apache.org/dyn/closer.cgi/httpd/ -O -

time aria2c http://apache.cs.utah.edu/httpd/httpd-2.4.29.tar.bz2 http://apache.claz.org/httpd/httpd-2.4.29.tar.bz2 \
  http://apache.mesi.com.ar/httpd/httpd-2.4.29.tar.bz2
rm httpd-2.4.29.tar.bz2

echo ${start_date}
date
