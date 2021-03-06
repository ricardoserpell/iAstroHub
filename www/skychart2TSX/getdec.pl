#!/usr/bin/perl -w
use IO::Socket;
use Cwd;

#
# example program to send sequential command to the program
#

$host = "127.0.0.1";
$port = "3292";
$eol = "\x0D\x0A";
$path = cwd;

  connectCDC();

  sendcmd( "GETDEC S");


sub sendcmd {
  my $cmd = shift;
  print STDOUT " Send CMD : $cmd \n";
  print $handle $cmd.$eol;                       # send command

  $line = <$handle>;
  if ($line =~ /$client/) {       # click form our client
     print STDOUT $line;
     }
  while (($line =~/^\.\r\n$/) or ($line =~ /^>/)) # keepalive and click on the chart
    {
     $line = <$handle>;
     if ($line =~ /$client/) {       # click form our client
        print STDOUT $line;
        }
    }
 # we go here after receiving response from our command
  if (($line =~ /^OK!/) or ($line =~ /^Bye!/) )
     {
     print STDOUT "Command success\n";
     }
  else {
     print STDOUT "Command failed: +$line+ \n";
	 exit;
     }

print STDOUT "$line\n";

my $d = substr($line,4,index($line, "d")-4);
print STDOUT "$d\n";
if (substr($d,0,1) eq "-" ) {
   system("echo -1 > coord_DEC.txt");
} else {
   system("echo 1 > coord_DEC.txt");
}
$d_abs=abs($d*1);
system("echo $d_abs >> coord_DEC.txt");

my $m = substr($line,index($line,"d")+1,index($line, "m")-index($line,"d")-1);
print STDOUT "$m\n";
system("echo $m >> coord_DEC.txt");

my $s = substr($line,index($line,"m")+1,index($line, "s")-index($line,"m")-1);
print STDOUT "$s\n";
system("echo $s >> coord_DEC.txt");

}

sub connectCDC {

# do the connection
$handle = IO::Socket::INET->new(Proto     => "tcp",
                                PeerAddr  => $host,
                                PeerPort  => $port)
          or die "cannot connect to Cartes du Ciel at $host port $port : $!";

$handle->autoflush(1);

print STDOUT "[Connected to $host:$port]\n";

# wait connection and get client chart name
  $line = <$handle>;
  print STDOUT $line;
  $line =~ /OK! id=(.*) chart=(.*)$/;
  $client = $1;
  $chart = $2;
  chop $chart;
  if ($client)
    {
     print STDOUT " We are connected as client $client , the active chart is $chart\n";
    }
    else { die " We are not connected \n"};
}
