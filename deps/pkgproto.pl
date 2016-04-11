#!/usr/bin/perl -w

my $path = ".";
my $out = "../include/";

my @list = `find $path/* -type d -printf "%f\n"`;

while (my $sub = shift @list) {
    chop($sub);

    if ($sub eq $path or $sub eq "." or $sub eq '..') {
        next;
    }

    handle_sub($sub);
}

sub handle_sub {
    my $sub = shift;
    my @list = `find $path/$sub/* -type f -printf "%f\n"`;

    open(F, ">$path/pkgproto.tmp") or die("create tmp file $path/pkgproto.tmp failed");
    while (my $file = shift @list) {
        chop($file);
        $file =~ s/sdl$/h/;
        print F "#include \"$sub/$file\"\n";
    }

    close(F);
    `cmp -s $out/$sub\_msg.h $path/pkgproto.tmp`;
    if ($? ne 0) {
        `cp -f $path/pkgproto.tmp $out/$sub\_msg.h`;
    }
    `rm -f $path/pkgproto.tmp`;
}


