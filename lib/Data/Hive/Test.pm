use strict;
use warnings;
package Data::Hive::Test;
# ABSTRACT: a bundle of tests for Data::Hive stores

use Data::Hive;

use Test::More 0.94; # subtest

=head1 SYNOPSIS

  use Test::More;

  use Data::Hive::Test;
  use Data::Hive::Store::MyNewStore;

  Data::Hive::Test->test_new_hive({ store_class => 'MyNewStore' });

  # rest of your tests for your store

  done_testing;

=head1 DESCRIPTION

Data::Hive::Test is a library of tests that should be passable for any
conformant L<Data::Hive::Store> implementation.  It provides a method for
running a suite of tests -- which may expand or change -- that check the
behavior of a hive store by building a hive around it and testing its behavior.

=method test_new_hive

  Data::Hive::Test->test_new_hive( $desc, \%args_to_NEW );

This method expects an (optional) description followed by a hashref of
arguments to be passed to Data::Hive's C<L<NEW|Data::Hive/NEW>> method.  A new
hive will be constructed with those arguments and a single subtest will be run,
including subtests that should pass against any conformant Data::Hive::Store
implementation.

If the tests pass, the method will return the hive.  If they fail, the method
will return false.

=cut

sub test_new_hive {
  my ($self, $desc, $arg) = @_;
  
  if (@_ == 2) {
    $arg  = $desc;
    $desc = "hive tests from Data::Hive::Test";
  }

  $desc = "Data::Hive::Test: $desc";

  my $hive;

  my $passed = subtest $desc => sub {
    $hive = Data::Hive->NEW($arg);

    isa_ok($hive, 'Data::Hive');

    subtest 'value of one' => sub {
      ok(! $hive->one->EXISTS, "before being set, ->one doesn't EXISTS");

      $hive->one->SET(1);

      ok($hive->one->EXISTS, "after being set, ->one EXISTS");

      is($hive->one->GET,      1, "->one->GET is 1");
      is($hive->one->GET(10),  1, "->one->GET(10) is 1");
    };

    subtest 'value of zero' => sub {
      ok(! $hive->zero->EXISTS, "before being set, ->zero doesn't EXISTS");

      $hive->zero->SET(0);

      ok($hive->zero->EXISTS, "after being set, ->zero EXISTS");

      is($hive->zero->GET,      0, "->zero->GET is 0");
      is($hive->zero->GET(10),  0, "->zero->GET(10) is 0");
    };

    subtest 'value of empty string' => sub {
      ok(! $hive->empty->EXISTS, "before being set, ->empty doesn't EXISTS");

      $hive->empty->SET('');

      ok($hive->empty->EXISTS, "after being set, ->empty EXISTS");

      is($hive->empty->GET,     '', "/empty is ''");
      is($hive->empty->GET(10), '', "->empty->GET(10) is ''");
    };

    subtest 'undef, existing value' => sub {
      ok(! $hive->undef->EXISTS, "before being set, ->undef doesn't EXISTS");

      $hive->undef->SET(undef);

      ok($hive->undef->EXISTS, "after being set, ->undef EXISTS");

      is($hive->undef->GET,    undef, "/undef is undef");
    };

    subtest 'non-existing value' => sub {
      ok(! $hive->missing->EXISTS, "before being set, ->missing doesn't EXISTS");

      is($hive->missing->GET,    undef, "->missing is undef");

      ok(! $hive->missing->EXISTS, "mere GET-ing won't cause ->missing to EXIST");

      is($hive->missing->GET(1),    1, " == ->missing->GET(1)");
      is($hive->missing->GET(0),    0, "0 == ->missing->GET(0)");
      is($hive->missing->GET(''),  '', "'' == ->missing->GET('')");
    };

    is_deeply(
      [ sort $hive->KEYS  ],
      [ qw(empty one undef zero) ],
      "we have the right top-level keys",
    );
  };

  return $passed ? $hive : ();
}

1;