#!/usr/bin/env perl

# Small toy app to play with RDF::Trine. Read an RDF/XML file and
# print it out again. Add argument 'json' to print it as JSON.

use strict;
use warnings;

use File::Slurp;
use Getopt::Std;
use RDF::Trine;

# setup
my $base_uri    = 'http://purl.uniprot.org/core';
my $inmem_store = RDF::Trine::Store::Memory->new;
my $model       = RDF::Trine::Model->new( $inmem_store );

my %args;
getopts('i:o:', \%args);
my $in_format  = $args{i} || 'rdfxml';
my $out_format = $args{o} || 'rdfxml';

my $file = shift @ARGV;

my $rdf = read_file($file);

my $parser = RDF::Trine::Parser->new( $in_format );
$parser->parse_into_model( $base_uri, $rdf, $model );

warn "Read " . $model->size . " statements.\n";

my $serializer = RDF::Trine::Serializer->new( $out_format );
print $serializer->serialize_model_to_string($model), "\n";
