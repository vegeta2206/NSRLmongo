#!/bin/bash


/usr/bin/mongo nistdb --eval "db.NSRLFile.drop()"
/usr/bin/mongo nistdb --eval "db.NSRLMfg.drop()"
/usr/bin/mongo nistdb --eval "db.NSRLOS.drop()"
/usr/bin/mongo nistdb --eval "db.NSRLProd.drop()"

echo -e "########################################\n"
echo -e "### Converting files source to UTF-8  ###\n"
echo -e "########################################\n"

if [ ! -f /data/sources/NSRLFile_utf8.txt ]; then
	echo -e "NSRLFile.txt in progress...\n"
	iconv -f ISO-8859-1 -t UTF-8 /data/sources/NSRLFile.txt -o /data/sources/NSRLFile_utf8.txt
fi
if [ -f /data/sources/NSRLFile_utf8.txt ]; then
        echo -e "NSRLFile.txt Deletion...\n"
        /bin/rm -f /data/sources/NSRLFile.txt
fi

if [ ! -f /data/sources/NSRLMfg_utf8.txt ]; then
	echo -e "NSRLMfg.txt in progress...\n"
	iconv -f ISO-8859-1 -t UTF-8 /data/sources/NSRLMfg.txt -o /data/sources/NSRLMfg_utf8.txt
fi
if [ -f /data/sources/NSRLMfg_utf8.txt ]; then
        echo -e "NSRLMfg.txt Deletion...\n"
        /bin/rm -f /data/sources/NSRLMfg.txt
fi


if [ ! -f /data/sources/NSRLOS_utf8.txt ]; then
	echo -e "NSRLOS.txt in progress...\n"
	iconv -f ISO-8859-1 -t UTF-8 /data/sources/NSRLOS.txt -o /data/sources/NSRLOS_utf8.txt
fi
if [ -f /data/sources/NSRLOS_utf8.txt ]; then
        echo -e "NSRLOS.txt Deletion...\n"
        /bin/rm -f /data/sources/NSRLOS.txt
fi


if [ ! -f /data/sources/NSRLProd_utf8.txt ]; then
	echo -e "NSRLProd.txt in progress...\n"
	iconv -f ISO-8859-1 -t UTF-8 /data/sources/NSRLProd.txt -o /data/sources/NSRLProd_utf8.txt
fi
if [ -f /data/sources/NSRLProd_utf8.txt ]; then
        echo -e "NSRLFile.txt Deletion...\n"
        /bin/rm -f /data/sources/NSRLProd.txt
fi

echo -e "Conversion finished !\n\n"

echo -e "\nCreate NSRLFile.SHA-1 indexes NSRLFile in progress...\n"
/usr/bin/mongo nistdb --eval "db.NSRLFile.createIndex({ 'SHA-1':1})"

echo -e "\nCreate NSRLFile.MD5 indexes in progress...\n"
/usr/bin/mongo nistdb --eval "db.NSRLFile.createIndex({ 'MD5':1})"

echo -e "\nCreate NSRLFile.MD5 indexes in progress...\n"
/usr/bin/mongo nistdb --eval "db.NSRLFile.createIndex({ 'CRC32':1})"

echo -e "\nCreate NSRLFile.MD5 indexes in progress...\n"
/usr/bin/mongo nistdb --eval "db.NSRLFile.createIndex({ 'FileName':1})"

echo -e "\nCreate NSRLFile.MD5 indexes in progress...\n"
/usr/bin/mongo nistdb --eval "db.NSRLFile.createIndex({ 'FileSize':1})"

echo -e "\nCreate NSRLMfg.MfgCode indexes...\n"
/usr/bin/mongo nistdb --eval "db.NSRLMfg.createIndex({'MfgCode':1})"

echo -e "\nCreate NSRLOS.OpSystemCode in progress...\n"
/usr/bin/mongo nistdb --eval "db.NSRLOS.createIndex({'OpSystemCode':1})"

echo -e "\nCreate NSRLProd.ProductCode indexes in progress...\n"
/usr/bin/mongo nistdb --eval "db.NSRLProd.createIndex({'ProductCode':1})"


echo -e "########################################\n"
echo -e "### Importing Data                   ###\n"
echo -e "########################################\n"

echo -e "\nNSRLFile_utf8.txt in progress...\n"
/usr/bin/mongoimport -h localhost:27017 -d nistdb -c NSRLFile --headerline --type csv --file /data/sources/NSRLFile_utf8.txt --numInsertionWorkers=16

echo -e "\nNSRLMfg_utf8.txt in progress...\n"
/usr/bin/mongoimport -h localhost:27017 -d nistdb -c NSRLMfg --headerline --type csv --file /data/sources/NSRLMfg_utf8.txt --numInsertionWorkers=16

echo -e "\nNSRLOS_utf8.txt in progress...\n"
/usr/bin/mongoimport -h localhost:27017 -d nistdb -c NSRLOS --headerline --type csv --file /data/sources/NSRLOS_utf8.txt  --numInsertionWorkers=16

echo -e "\nNSRLProd_utf8.txt in progress...\n"
/usr/bin/mongoimport -h localhost:27017 -d nistdb -c NSRLProd --headerline --type csv --file /data/sources/NSRLProd_utf8.txt --numInsertionWorkers=16

echo -e "\nImports finished !\n\n"

echo -e "JOB Finished !"

