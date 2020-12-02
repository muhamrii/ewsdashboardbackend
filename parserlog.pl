open my $handle, '<', $ARGV[0];
chomp(my @line = <$handle>);
close $handle;

my @line=`cat $ARGV[0]`;
my $flag=0;
my $flag1=0;
my $count=0;
my $DIR="$ARGV[1]";
my $SITE="$ARGV[0]";
$SITE =~ s/.log//g;
my $NOW="$ARGV[2]";
open(diskusage, '>', "${DIR}/importdb/${SITE}_diskusage.tmp") or die $!;
open(inodesusage, '>', "${DIR}/importdb/${SITE}_inodesusage.tmp") or die $!;
for my $i (0 .. $#line) {
        $flag=1 if $line[$i] =~ /(.*(df -kh).*)/;
        if ($flag eq 1) {
            $line[$i] =~ s/\s+/,/g;
            print diskusage $NOW.",".$SITE.",".$line[$i]."\n";
        }
        $flag=0 if $line[$i] =~ /(.*(IFree).*)/;
}
my $flag=0;
my $flag1=0;
for my $i (0 .. $#line) {
        $flag=1 if $line[$i] =~ /(.*(IFree).*)/;
        if ($flag eq 1) {
            $line[$i] =~ s/\s+/,/g;
            print inodesusage $NOW.",".$SITE.",".$line[$i]."\n";
        }
        $flag=0 if $line[$i] =~ /(.*(exit).*)/;
}
