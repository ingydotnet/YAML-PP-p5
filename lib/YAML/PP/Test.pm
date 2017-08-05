package YAML::PP::Test;
use strict;
use warnings;

sub get_tags {
    my ($class, %args) = @_;
    my %id_tags;
    my $dir = $args{test_suite_dir} . "/tags";

    return unless -d $dir;
    opendir my $dh, $dir or die $!;
    my @tags = grep { not m/^\./ } readdir $dh;
    for my $tag (sort @tags) {
        opendir my $dh, "$dir/$tag" or die $!;
        my @ids = grep { -l "$dir/$tag/$_" } readdir $dh;
        $id_tags{ $_ }->{ $tag } = 1 for @ids;
        closedir $dh;
    }
    closedir $dh;
    return %id_tags;
}

sub get_tests {
    my ($class, %args) = @_;
    my $test_suite_dir = $args{test_suite_dir};
    my $dir = $args{dir};
    my $valid = $args{valid};

    my @dirs;
    if (-d $test_suite_dir) {
        my %id_tags = $class->get_tags( test_suite_dir => $test_suite_dir );

        opendir my $dh, $test_suite_dir or die $!;
        my @ids = grep { m/^[A-Z0-9]{4}\z/ } readdir $dh;
        @ids = grep {
            $valid
            ? not $id_tags{ $_ }->{error}
            : $id_tags{ $_ }->{error}
        } @ids;
        push @dirs, map { "$test_suite_dir/$_" } @ids;
        closedir $dh;

    }

    opendir my $dh, $dir or die $!;
    push @dirs, map { "$dir/$_" } grep { m/^v[A-Z0-9]{3}\z/ } readdir $dh;
    closedir $dh;

    return @dirs;
}

1;
