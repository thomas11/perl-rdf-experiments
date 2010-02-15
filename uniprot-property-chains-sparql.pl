#!/usr/bin/env perl


# A toy program written to explore existing Perl RDF modules.
#
# $ ./trine-sparql.pl 'recommendedName->fullName' will, for each
# uniprot:Protein in the store, print out all their full recommended
# names. In general, the program will follow a '->'-separated property
# chain on each protein in the store, and print the values of the last
# property.
#
# It's very crude at the moment, and expects you have a running SPARQL
# endpoint with a HTTP interface (SPARQL Protocol) on
# http://localhost:8000/sparql/, that has some UniProt entries.
#
# The SPARQL query is built either programmatically using RDF::Query,
# or textually (construct_query_textual) so you don't need RDF::Query.

use RDF::Query;
use RDF::Query::Algebra::BasicGraphPattern;
use RDF::Query::Algebra::GroupGraphPattern;
use RDF::Query::Algebra::Triple;
use RDF::Query::Node::Literal;
use RDF::Query::Node::Resource;
use RDF::Query::Node::Variable;
use RDF::Trine;
use RDF::Trine::Model;
use RDF::Trine::Store::SPARQL;

# setup
my $NAMESPACES = {
  UNIPROT => 'http://purl.uniprot.org/core/',
  RDF     => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
};

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
  push @patterns, new_is_a_triple($prot_var,
                                  new_resource('Protein', 'UNIPROT'));

  # Construct query triple chain.
  my $subject = $prot_var;
  foreach my $prop (@$props_ref) {
    # TODO namespaces other than uniprot
    my $predicate = new_resource($prop);
    my $object    = new_var($prop);
    push @patterns, new_triple($subject, $predicate, $object);
    $subject      = $object;
  }

  my $bgp = new RDF::Query::Algebra::BasicGraphPattern(@patterns);
  my $ggp = new RDF::Query::Algebra::GroupGraphPattern($bgp);

  my $project = RDF::Query::Algebra::Project->new($ggp,
                                                  [new_var($result_prop)]);

  my $sparql = "select " . $project->as_sparql;
  warn $sparql;

  return scalar new RDF::Query($sparql);
}

sub new_resource {
  my ($res, $ns) = @_;
  my $ns_uri = $NAMESPACES->{$ns};
  $ns_uri    = $NAMESPACES->{UNIPROT} if not defined $ns_uri;
  return scalar RDF::Query::Node::Resource->new($ns_uri . $res);
}

sub new_var {
  my ($var) = @_;
  return scalar RDF::Query::Node::Variable->new($var);
}

sub new_triple {
  my ($s, $p, $o) = @_;
  return scalar new RDF::Query::Algebra::Triple($s, $p, $o)
}

sub new_is_a_triple {
  my ($var, $resource) = @_;
  return scalar new_triple($var, new_resource('type', 'RDF'), $resource);
}


### TEXTUAL SPARQL CONSTRUCTION ###

sub namespace {
  my ($str) = @_;
  return ($str =~ ':') ? $str : ':'.$str;
}

sub construct_query_textual {
  my ($props_ref, $result_prop) = @_;

  my $prop_chain_query = ' ?p';
  foreach my $prop (@$props_ref) {
    $prop_chain_query .= " " . namespace($prop) . " ?$prop .\n  ?$prop ";
  }
  $prop_chain_query .= namespace($result_prop) . " ?$result_prop";

  my $protein_query_template = "select ?$result_prop where {
  ?p rdf:type :Protein .";

  my $sparql = NAMESPACES .
  "$protein_query_template
   $prop_chain_query
  }
  ";
  return scalar new RDF::Query($sparql);
}
