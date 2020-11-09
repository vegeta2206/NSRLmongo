#!/usr/bin/perl

use MongoDB;
use JSON;
use Time::HiRes qw( gettimeofday tv_interval );
use Term::ANSIColor;
use Storable;

$debug=1;
$t0=[gettimeofday];					#start timer
$client = MongoDB->connect('mongodb://127.0.0.1');	#connect db
if ($debug>0) {
	$t0=&printExecTime("MongoDB Connect OK") ;
}
$nistdb = $client->get_database( 'nistdb' );		#use nistdb
if ($debug>0) {
	$t0=&printExecTime("MongoDB get_database(nistdb)") ;
}


=for
###########################

	IMPORTANT 

###########################
1 - Disable IPV6 in sysctl.conf
2 - reload conf with sysctl -p
3 - check effectiveness with cat /proc/sys/net/ipv6/conf/all/disable_ipv6 

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Alternate search through MongoDB Shell : mongo nistdb --eval "db.NSRLFile.find({ 'MD5':'92CBBED0CCF37464EC706F885FE618B4' }).pretty()" --quiet

=cut

###################
### Functions	###
###################

# print help -------------------------------------------------------------------------------------------------
sub usage() {
	print color("red"), "==============================\n========== USAGE =============\n==============================\n\n";
	print color("reset"), "$0 <property>=<value> <alldetails>\n\n";
	print "\t <property> should be MD5,SHA-1,CRC32 or FieName\n";
	print "\t <value> should varchar(32) if MD5 or varchar(40) if SHA-1 value\n";
	print "\t <all details> should be set to <all> if all details are wished\n\n";
	print "\t Examples :\n";
	print "\t $0 MD5=92CBBED0CCF37464EC706F885FE618B4\n";
	print "\t $0 SHA-1=00000A881D8A26FD1830129305ACEC0A6CCCDDD4\n";
	print "\t $0 CRC32=C8B8446D\n";
	print "\t $0 FileName=\"abcd.tmp\"\n";
	print "\t $0 FileName=\"abcd.t*\" (search like)\n";
	print "\t $0 MD5=92CBBED0CCF37464EC706F885FE618B4 all (search with details)\n\n";

	if ($debug>0) {
		$t0=&printExecTime("print help");
	}
}#end sub


# print execution time -------------------------------------------------------------------------------------------------
sub printExecTime() {
		my ($message)=@_;
                $elapsed = tv_interval ( $t0, [gettimeofday])*1000;
                my $t0=[gettimeofday];     #reset timer
		print color("yellow");
                $etime=sprintf("%8.2f",$elapsed);
		print "[$etime ms] $message\n";
		print color("reset");
		return $t0;
}

# search productcode in NSRLProd ---------------------------------------------------------------------------------------------
sub getProductProperties() {
	my ($productcode)=@_;

	my $productscodes = $nistdb->get_collection( 'NSRLProd' );
	my $productname = $productscodes->find( { "ProductCode" => $productcode });
	my $record=0;
	while ( my $product = $productname->next) {
		++$record;
		print "\tL ProductName     ($record)      : ".$product->{'ProductName'}."\n";
		print "\tL ProductVersion  ($record)      : ".$product->{'ProductVersion'}."\n";
		print color("red"),"\tL OpSystemCode    ($record)      : ".$product->{'OpSystemCode'}."\n";
		if (length($product->{'OpSystemCode'})>0) {
			&getOsProperties($product->{'OpSystemCode'});
		}
		print color("reset"),"\tL Language        ($record)      : ".$product->{'Language'}."\n";
		print "\tL ApplicationType ($record)      : ".$product->{'ApplicationType'}."\n";
		print "\tL MfgCode         ($record)      : ".$product->{'MfgCode'}."\n";
		if (length($product->{'MfgCode'})>0) {
			&getMfgProperties($product->{'MfgCode'});
		}
		print color("green"), "\t-----------------------------------------------------------------------\n\n",color("reset");
	} #end while
}#end sub


# search opsystemcode in NSRLOS ---------------------------------------------------------------------------------------------
sub getOsProperties() {
        my ($ossystemcode)=@_;

        my $oscodes = $nistdb->get_collection( 'NSRLOS' );
        my $osnames = $oscodes->find( { "OpSystemCode" => $ossystemcode });
        while ( my $os = $osnames->next) {
                print color("magenta"), "\t\tL OpSystemName     : ".$os->{'OpSystemName'}."\n";
                print "\t\tL OsSystemVersion  : ".$os->{'OsSystemVersion'}."\n";
                print "\t\tL MfgCode          : ".$os->{'MfgCode'}."\n";
		if (length($os->{'MfgCode'})>0) {
			&getMfgProperties($os->{'MfgCode'});
		}#end if
        } #end while
}#end sub



# search mfgcode in NSRLMfg ---------------------------------------------------------------------------------------------
sub getMfgProperties() {
        my ($mfgcode)=@_;

        my $mfgcodes = $nistdb->get_collection( 'NSRLMfg' );
        my $mfgnames = $mfgcodes->find( { "MfgCode" => $mfgcode });
        while ( my $mfg = $mfgnames->next) {
                print "\t\tL MfgName          : ".$mfg->{'MfgName'}."\n";
        } #end while
}#end sub



# search hashkey in NSRLFile -------------------------------------------------------------------------------------------------
sub searchObj() {
	my ($hashkey, $hashvalue, $details_on)=@_;
	my $Files = $nistdb->get_collection( 'NSRLFile' );

	print "searchObj($hashkey, $hashvalue, $details_on)\n" if ($debug>1);

	if ($debug>0) {
		$t0=&printExecTime("MongoDB get_collection(NSRFile)");
	}
	if ($hashvalue =~/^(.*)(\*|\%|\?)/gi) {
		$values = $Files->find({$hashkey => qr/^$hashvalue/});
	} else {
		$values = $Files->find({$hashkey => $hashvalue});
	}
	if ($debug>0) {
		$t0=&printExecTime("MongoDB find($hashkey => $hashvalue)");
	}

	my $record=0;
	while (my $file = $values->next) {
	    ++$record;
	    print color("red"), "\n================================= Object N°$record matches =======================================\n";
	    print color("green"), "File No $record\n";
	    print "- sha1         : ".$file->{'SHA-1'}."\n";
	    print "- md5          : ".$file->{'MD5'}."\n";
	    print "- crc32        : ".$file->{'CRC32'}."\n";
	    print "- FileName     : ".$file->{'FileName'}."\n";
	    print "- FileSize     : ".$file->{'FileSize'}."\n";
	    print "- OpSystemCode : ".$file->{'OpSystemCode'}."\n";
	    print "- SpecialCode  : ".$file->{'SpecialCode'}."\n";
	    print "- ProductCode  : ".$file->{'ProductCode'}."\n",color("reset");

	    if ( (length($file->{'ProductCode'})>0) && ($details_on==1) ) {
	        &getProductProperties($file->{'ProductCode'});
	        }

	    print "\n";
	}
	if ($debug>0) {
		$t0=&printExecTime("MongoDB exit while");
	}
	return $record;
}


###################
### START	###
###################
if ($debug>1) {
        print "ARGV hashkey : $ARGV[0]\n";
        print "ARGV mode    : $ARGV[1]\n";
}

if (scalar(@ARGV)>0) 
{
	#Recherche par Hash
	if ($ARGV[0]=~/^(MD5|SHA\-1|CRC32)(\:|\=)(.*)$/gi) {

		if (defined($ARGV[1])) {
			$record=&searchObj(uc($1),uc($3),1);
		} else {
			$record=&searchObj(uc($1),uc($3),0);
		}

		print color("green"), "Records matching : $record\n\n";
		$t0=&printExecTime("Finished !");
		print color("reset");

	} elsif ($ARGV[0]=~/^(FileName)(\:|\=)(.*)/gi) {

                if (defined($ARGV[1])) {
                        $record=&searchObj($1,$3,1);
                } else {
                        $record=&searchObj($1,$3,0);
                }

                print color("green"), "Records matching : $record\n\n";
                $t0=&printExecTime("Finished !");
                print color("reset");

	} elsif ($ARGV[0]=~/^(FileSize)(\:|\=)(.*)/gi) {

                if (defined($ARGV[1])) {
                        $record=&searchObj($1,$3,1);
                } else {
                        $record=&searchObj($1,$3,0);
                }

                print color("green"), "Records matching : $record\n\n";
                $t0=&printExecTime("Finished !");
                print color("reset");
	
	} else {
		print "One or more arguments are not allowed\n";
		&usage();
		exit;
	}
} else {
	# missing params
	&usage();
	exit;
}

