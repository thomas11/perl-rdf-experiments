#!/usr/bin/env perl

# RDF Triple Count.
#
# ./tc.pl -f {rdfxml|nquads|ntriples|rdfjson|rdfa|turtle} file

use strict;
use warnings;

use File::Slurp;
use Getopt::Std;
use RDF::Trine;

# setup
my $base_uri    = undef;
my $inmem_store = RDF::Trine::Store::Memory->new;
my $model       = RDF::Trine::Model->new( $inmem_store );

my %opts;
getopt('f:', \%opts);

my ($inputfile, $format) = @ARGV;

# TODO how to give the Trine parser a filehandle? You cannot slurp large files.
my $rdf       = read_file($inputfile);

my $parser = RDF::Trine::Parser->new( $opts{f} );
$parser->parse_into_model( $base_uri, $rdf, $model );

print $model->size . "\n";
