#!/bin/sh

pip install pymysql >/dev/null 2>&1
pip install PyJWT >/dev/null 2>&1
pip install requests >/dev/null 2>&1

python /tmp/db_populate.py
