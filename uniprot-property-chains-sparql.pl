#!/usr/bin/env perl

# A toy program written to explore RDF::Query.
#
# It's very crude at the moment, and expects you have a running SPARQL
# endpoint with a HTTP interface (SPARQL Protocol) on
# http://localhost:8000/sparql/, that has some UniProt entries.
#
# $ ./uniprot-property-chains--sparql.pl 'recommendedName->fullName'
# will, for each uniprot:Protein in the store, print out all their
# full recommended names. In general, the program will follow a
# '->'-separated property chain on each protein in the store, and
# print the values of the last property.

use strict;
use warnings;

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
my $UNIPROT = RDF::Trine::Namespace->new('http://purl.uniprot.org/core/');

# I used 4store. Anything that implements the SPARQL Protocol
# <http://www.w3.org/TR/2008/REC-rdf-sparql-protocol-20080115/#query-bindings-http>
# should be fine.
my $store    = RDF::Trine::Store::SPARQL->new('http://localhost:8000/sparql/');
my $model    = RDF::Trine::Model->new($store);


if (@ARGV < 1) {
  die "Please give a property chain on a Protein, separated by '->'.\n";
}
my ($prop_chain) = @ARGV;
my @props = split('->', $prop_chain);

# TODO support more than one result property.
my $result_prop = $props[-1];

my $query = construct_query_bgp(\@props, $result_prop);

my $results = $query->execute( $model );
while (my $triple = $results->next) {
  my $result = $triple->{ $result_prop };
  print defined $result ? $result : "No $result_prop found!", "\n";
}


### Helpers ###

sub construct_query_bgp {
  my ($props_ref, $result_prop) = @_;
  my $prot_var = new_var('p');

  my @patterns = ();

  # We're asking for a Protein. That's mostly unnecessary as it's
  # unlikely anything else would match a property chain matching a
  # UniProt protein, but why not.
  push @patterns, new_triple($prot_var, $rdf->type, $UNIPROT->Protein);

  # Construct query triple chain.
  my $subject = $prot_var;
  foreach my $prop (@$props_ref) {
    # TODO namespaces other than uniprot
    my $object    = new_var($prop);
    push @patterns, new_triple($subject, $UNIPROT->$prop, $object);
    $subject      = $object;
  }

  my $project = new_basic_project(\@patterns, $result_prop);

  my $sparql = "select " . $project->as_sparql;
  warn $sparql;

  return scalar new RDF::Query($sparql);
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
