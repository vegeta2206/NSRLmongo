# NSRLmongo

This project allows anybody to create a NIST NSRL Database (https://www.nist.gov/itl/ssd/software-quality-group/national-software-reference-library-nsrl/nsrl-download/current-rds) in MongoDB container at ease.

Just follow the following steps :

1 - git clone https://github.com/vegeta2206/NSRLmongo.git

2 - you should get this arborescence :

	.
	├── create_DB.sh                => create NSRL database and drop existing collections
	├── data_db                     => Docker volume for DB : should be empty before the first start
	├── docker
	│   ├── apt.conf
	│   ├── Dockerfile              => build with : docker build -t nsrl:1.0 .
	│   ├── installNISTDB.sh
	│   └── wgetrc
	├── getshell.sh                 => get shell in a running container
	├── requirements.txt            => perl requirements for searchMongoDB.pl Client
	├── run.sh                      => start NSRL container
	├── searchMongoDB.pl            => NSRL Client
	└── sources                     => Docker volume for building DB
	    ├── NSRLFile.txt            => Should be extracted from rds_modernm.zip
	    ├── NSRLFile_utf8.txt       => Built by create_DB.sh
	    ├── NSRLMfg.txt             => Should be extracted from rds_modernm.zip
	    ├── NSRLMfg_utf8.txt        => Built by create_DB.sh
	    ├── NSRLOS.txt              => Should be extracted from rds_modernm.zip
	    ├── NSRLOS_utf8.txt         => Built by create_DB.sh
	    ├── NSRLProd.txt            => Should be extracted from rds_modernm.zip
	    ├── NSRLProd_utf8.txt       => Built by create_DB.sh
	    ├── rds_modernm.zip         => File to download from NIST Website
	    └── signatures.txt          => Should be extracted from rds_modernm.zip

