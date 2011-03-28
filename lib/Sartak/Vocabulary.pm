package Sartak::Vocabulary;
use strict;
use warnings;
use Template::Declare::Tags;

our $japanese = $0 =~ /japanese/i;

sub word {
    my %args = @_;

    li {
        for my $field ('date', 'word', 'definition', 'english') {
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
    }
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
            .date {
                font-style: italic;
                font-size: .8em;
            }
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
        print '<hr />';
    }
    else {
        print '<a href="語彙.html">(Japanese)</a>';
        print '<hr />';
    }

    print '<ul>';
}

END {
    if ($imported && !$?) {
        Template::Declare->buffer->flush;
        my $timestamp = gmtime;

        print '</ul><hr />';
        print '<p class="last-updated">';

        if ($japanese) {
            print "$timestampに更新した";
        }
        else {
            print "Last updated at $timestamp.";
        }

        print '</p></body></html>';
    }
}

1;

