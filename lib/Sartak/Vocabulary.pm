package Sartak::Vocabulary;
use strict;
use warnings;
use Template::Declare::Tags;

our $japanese = $0 =~ /japanese/i;

my %count;
my %seen;
my $prev_date = '';
sub word {
    my %args = @_;

    my $new_date = $prev_date ne $args{date};
    $prev_date = $args{date};

    my @dates = ($args{date} =~ /^(((\d\d\d\d)-\d\d)-\d\d)$/, 'all time');
    $count{$_}++ for @dates;

    warn "Already seen $args{word}\n" if $seen{$args{word}}++;

    if ($new_date) {
        dt {
            id is $args{date};
            outs $args{date};
        }
    }

    dd {
        title is $args{word} . ': ' . join '; ', map { "#$count{$_} for $_" } @dates;

        for my $field ('word', 'definition', 'english') {
            next if !$args{$field};

            span {
                class is $field;
                if ($field eq 'word' && $args{furigana}) {
                    outs_raw "<ruby><rb>";
                }

                if (ref $args{$field}) {
                    outs_raw ${ $args{$field} };
                }
                else {
                    outs $args{$field};
                }

                if ($field eq 'word' && $args{furigana}) {
                    outs_raw "</rb><rp>(</rp><rt>$args{furigana}</rt><rp>)</rp></ruby>";
                }
            }
        }
    };
}

my $imported;
sub import {
    my $class  = shift;
    my $caller = caller;
    $imported = 1;

    strict->import;
    warnings->import;

    # I don't feel like messing with Exporter, Sub::Exporter, etc.
    eval "
        package $caller;
        use Template::Declare::Tags;
    ";

    die $@ if $@;

    no strict 'refs';
    for my $export (qw/word/) {
        *{$caller.'::'.$export} = $class->can($export);
    }

    my $title = $japanese ? "サータックの新しい語彙" : "Sartak's New Vocabulary";

    print << "EOF";
<!DOCTYPE HTML>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
        <style type="text/css">
            .word {
                font-weight: bold;
            }
            .last-updated {
                font-style: italic;
                text-align: right;
            }
            rp, rt {
                font-size: 75%;
            }
        </style>
        <title>$title</title>
    </head>
    <body>
        <h1>$title</h1>
EOF

    if ($japanese) {
        print '<a href="vocabulary.html">(English)</a>';
    }
    else {
        print '<a href="語彙.html">(Japanese)</a>';
    }

    print ' <a href="https://github.com/sartak/vocabulary">(GitHub)</a>';
    print '<hr />';
    print '<dl>';
}

END {
    if ($imported && !$?) {
        Template::Declare->buffer->flush;
        my $timestamp = gmtime;

        print '</dl><hr />';
        print '<p class="last-updated">';

        if ($japanese) {
            print "$timestampに更新した";
        }
        else {
            print "Last updated at $timestamp.";
        }

        print '</p></body></html>';
    }

    warn "Learned " . scalar(keys %seen) . ($japanese ? " Japanese" : " English") . " words\n";
}

1;

