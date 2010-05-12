#!/usr/bin/perl

use perl5i::latest;

use Config;
use ExtUtils::CBuilder;
use File::Spec;
use File::Temp qw(tempfile);

use Test::More;

my $perl5i;
my $script_dir = File::Spec->catdir("blib", "script");
for my $wrapper (qw(perl5i perl5i.bat)) {
    $perl5i = File::Spec->catfile($script_dir, $wrapper);
    last if -e $perl5i;
}

ok -e $perl5i, "perl5i command line wrapper was built";

ok system(qq[$perl5i "-Ilib" -e 1]) == 0, "  and it runs";

is `$perl5i "-Ilib" -e "say 'Hello'"`, "Hello\n", "Hello perl5i!";

like `$perl5i "-Ilib" -h`, qr/disable all warnings/, 'perl5i -h works as expected';

like `$perl5i "-Ilib" -e "\$^X->say"`, qr/perl5i/, '$^X is perl5i';

is `$perl5i -wle "print 'Hello'"`, "Hello\n", "compound -e";

# Check it takes code from STDIN
{
    use IPC::Open2;
    my($out, $in);
    ok open2( $out, $in, $perl5i ), "open2";
    print $in q[say "Hello"];
    close $in;

    is <$out>, "Hello\n", "reads code from stdin";
}

# And from a file
{
    my($fh, $file) = tempfile;
    print $fh "say 'Hello';";
    close $fh;

    is `perl5i $file`, "Hello\n", "program in a file";
}

done_testing;
