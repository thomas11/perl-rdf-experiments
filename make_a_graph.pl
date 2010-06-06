#!/usr/bin/env perl

# A toy program written to explore RDF::Query. This one creates a
# small graph programmatically.

use strict;
use warnings;

use RDF::Trine::Model;
use RDF::Trine::Namespace qw ( rdf );
use RDF::Trine::Node::Literal;
use RDF::Trine::Node::Resource;
use RDF::Trine::Serializer;
use RDF::Trine::Statement;
use RDF::Trine::Store::Memory;


my $BASE   = 'http://purl.uniprot.org/';

my %namespaces = ();
sub namespace {
    my ($section) = @_;
    my $ns = $namespaces{$section};
    if (not $ns) {
        my $url = $BASE . $section . '/';
        $ns = RDF::Trine::Namespace->new($url);
        $namespaces{$section} = $ns;
    }
    return $ns;
}

my $ONTOLOGY = namespace('core');

sub new_resource {
    my ($name, $section) = @_;
    return RDF::Trine::Node::Resource->new( $name, namespace($section) );
}

sub new_literal {
    my ($str) = @_;
    return RDF::Trine::Node::Literal->new( $str );
}


## Create the graph
##   <uniprot/P12345> uniprot:created "1989-10-01" ;
##       uniprot:enzyme <enzyme/2.6.1.1> ;
##       a uniprot:Protein .

my $p12345 = new_resource('P12345', 'uniprot');

sub new_s {
    my ($s, $p, $o) = @_;
    return RDF::Trine::Statement->new($s, $p, $o);
}

my @stmts = (
  new_s($p12345, $ONTOLOGY->created, new_literal('1989-10-01')),
  new_s($p12345, $ONTOLOGY->enzyme,  new_resource('2.6.1.1', 'enzyme')),
  new_s($p12345, $rdf->type,         $ONTOLOGY->Protein)
);

my $model = RDF::Trine::Model->new( RDF::Trine::Store::Memory->new );
foreach my $stmt (@stmts) {
    $model->add_statement($stmt);
}

my $serializer = RDF::Trine::Serializer->new( 'turtle' );
print $serializer->serialize_model_to_string($model), "\n";
