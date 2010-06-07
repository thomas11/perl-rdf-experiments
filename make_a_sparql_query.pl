#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp;
use RDF::Query;
use RDF::Query::Algebra::BasicGraphPattern;
use RDF::Query::Algebra::GroupGraphPattern;
use RDF::Query::Algebra::Triple;
use RDF::Query::Node::Literal;
use RDF::Query::Node::Resource;
use RDF::Query::Node::Variable;
use RDF::Trine;
use RDF::Trine::Model;
use RDF::Trine::Namespace qw ( rdf );
use RDF::Trine::Store::SPARQL;

# setup
my $BASE    = 'http://purl.uniprot.org/';
my $UNIPROT = RDF::Trine::Namespace->new('http://purl.uniprot.org/core/');

my $store   = RDF::Trine::Store::Memory->new;
my $model   = RDF::Trine::Model->new($store);

my $file = shift;
my $rdf  = read_file($file);

my $parser = RDF::Trine::Parser::Turtle->new;
$parser->parse_into_model( $BASE, $rdf, $model );

my $p12345  = RDF::Trine::Node::Resource->new( $BASE.'uniprot/P12345' );
my $result_prop = 'date';

my $patterns = [ new_triple($p12345,
                            $UNIPROT->created,
                            new_var($result_prop)) ];
my $project  = new_basic_project($patterns, $result_prop);

# Manual SELECT will soon be unnecessary.
my $sparql = "SELECT " . $project->as_sparql;
print $sparql, "\n\n";

my $results = new RDF::Query($sparql)->execute( $model );
while (my $triple = $results->next) {
    my $result = $triple->{ $result_prop };
    print "--> ", $result, "\n";
}


sub new_var {
    my ($var) = @_;
    return scalar RDF::Query::Node::Variable->new($var);
}

sub new_triple {
    my ($s, $p, $o) = @_;
    return scalar new RDF::Query::Algebra::Triple($s, $p, $o)
}

sub new_basic_project {
    my ($patterns_ref, $result_prop) = @_;

    my $bgp = new RDF::Query::Algebra::BasicGraphPattern(@$patterns_ref);
    my $ggp = new RDF::Query::Algebra::GroupGraphPattern($bgp);

    return scalar RDF::Query::Algebra::Project->new($ggp,
                                                    [new_var($result_prop)]);
}
