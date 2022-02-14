#!/usr/bin/perl

use strict;
use warnings;
use utf8;


my $autowin = shift;

binmode(STDOUT, ":utf8");
binmode(STDIN, ":encoding(utf8)");


# $tables->{$table}->{rows}->[$row]->{$colname} = $value
# $tables->{$table}->{colnames}->[$col] = $colname
# $tables->{$table}->{keycol} = $keycolname;
# $tables->{$table}->{hash}->{$keyval}->{$colname} = $value;
my $tables = {};


my $curtable = undef;
my @colnames = ();
my $curkey = undef;
while(<>) {
    chomp;

    if(/^\s*$/) {
        # nothing to do
    } elsif(/^#.*$/) {
        # nothing to do
    } elsif(/^::(.*)$/) {
        $curtable = $1;
        if(!defined $tables->{$curtable}) {
            $tables->{$curtable} = {rows => [],
                                    colnames => undef,
                                    keycol => undef,
                                    hash => {}};
        }
    } elsif(/^--(.*)$/) {
        @colnames = split /\t/, $1;
        for(my $i = 0; $i < scalar @colnames; ++$i) {
            if($colnames[$i] =~ /^\*(.*)$/) {
                $curkey = $1;
                $colnames[$i] = $1;
            }
        }
        $tables->{$curtable}->{colnames} = [@colnames] if !defined $tables->{$curtable}->{colnames};
        $tables->{$curtable}->{keycol} = $curkey if !defined $tables->{$curtable}->{keyvol};
    } else {
        my @vals = split /\t/, $_;
        my $thing = {};
        foreach(@colnames) {
            $thing->{$_} = shift @vals;
        }
        push @{$tables->{$curtable}->{rows}}, $thing;
        if(defined $curkey && defined $thing->{$curkey}) {
            if(!defined $tables->{$curtable}->{hash}->{$thing->{$curkey}}) {
                $tables->{$curtable}->{hash}->{$thing->{$curkey}} = $thing;
            } else {
                die "ERROR: Hash collision in table [$curtable], using key column [$curkey], value [$thing->{$curkey}]\n";
            }
        } else {
            die "ERROR: Table [$curtable]: Don't have a current key or this row [$_] doesn't have a value for the key [".(defined $curkey ? $curkey : "(undef)")."]\n";
        }
    }
}


# print "\n";
# printf "%30s: %26s\n", "Game", "Location";
# print "----------------------------------------------------------------\n";
# foreach (@{$tables->{"Games"}->{rows}}) {
#     my ($lat, $long) = normCoords($_->{Location});
#     printf "%30s: (%11.6f, %11.6f)\n", $_->{Game}, $lat, $long;
# }
# print "\n";
my $games = $tables->{"Games"}->{hash};

# foreach (sort keys %{$tables}) {
#     my $table = $_;
#     print "\n";
#     printf "%20s (%15s):  ", $table, $tables->{$table}->{keycol};
#     my $first = $tables->{$table}->{rows}->[0];
#     foreach(sort keys %{$first}) {
#         printf "%15s",$_;
#     }
# }
#print "\n";

my @team_cols = ();

foreach (keys %{$tables}) {
    my $table = $_;
    if($tables->{$table}->{keycol} eq "Team") {
        foreach(@{$tables->{$table}->{colnames}}) {
            push @team_cols, {table=>$table, col=>$_};
        }
    }
}


# print "Team columns:\n";
# foreach(sort {$a->{col} cmp $b->{col}} @team_cols) {
#     printf "  %15s ($_->{table})\n", $_->{col};
# }
# print "\n";


my $teams = {};
my $regions = {};
my $seeds = {};

# $tdata->{$team}->{$colname} = $value
my $tdata = {};

foreach(@{$tables->{"PPG"}->{rows}}) {
    if(!defined $teams->{$_->{Team}}) {
        $teams->{$_->{Team}} = [ "PPG" ];
        $regions->{$_->{Team}} = [ $_->{Region} ];
        $seeds->{$_->{Team}} = [ $_->{Seed} ];
    } else {
        push @{$teams->{$_->{Team}}}, "PPG";
        push @{$regions->{$_->{Team}}}, $_->{Region};
        push @{$seeds->{$_->{Team}}}, $_->{Seed};
    }

    my $team = $_->{Team};
    my $row = $_;

    if(!defined $tdata->{$team}) {
        $tdata->{$team} = {};
    }

    foreach(keys %{$row}) {
        $tdata->{$team}->{$_} = $row->{$_};
    }
}

foreach(@{$tables->{"Overall PWR RTG"}->{rows}}) {
    if(!defined $teams->{$_->{Team}}) {
        $teams->{$_->{Team}} = [ "Overall PWR RTG" ];
        $regions->{$_->{Team}} = [ $_->{Region} ];
        $seeds->{$_->{Team}} = [ $_->{Seed} ];
    } else {
        push @{$teams->{$_->{Team}}}, "Overall PWR RTG";
        push @{$regions->{$_->{Team}}}, $_->{Region};
        push @{$seeds->{$_->{Team}}}, $_->{Seed};
    }

    my $team = $_->{Team};
    my $row = $_;

    if(!defined $tdata->{$team}) {
        $tdata->{$team} = {};
    }

    foreach(keys %{$row}) {
        $tdata->{$team}->{$_} = $row->{$_};
    }
}

foreach(@{$tables->{"Seeds"}->{rows}}) {
    if(!defined $teams->{$_->{Team}}) {
        $teams->{$_->{Team}} = [ "Seeds" ];
        $regions->{$_->{Team}} = [ $_->{Region} ];
        $seeds->{$_->{Team}} = [ $_->{Seed} ];
    } else {
        push @{$teams->{$_->{Team}}}, "Seeds";
        push @{$regions->{$_->{Team}}}, $_->{Region};
        push @{$seeds->{$_->{Team}}}, $_->{Seed};
    }

    my $team = $_->{Team};
    my $row = $_;

    if(!defined $tdata->{$team}) {
        $tdata->{$team} = {};
    }

    foreach(keys %{$row}) {
        $tdata->{$team}->{$_} = $row->{$_};
    }
}

foreach(@{$tables->{"Home PWR RTG"}->{rows}}) {
    if(!defined $teams->{$_->{Team}}) {
        $teams->{$_->{Team}} = [ "Home PWR RTG" ];
        $regions->{$_->{Team}} = [ $_->{Region} ];
        $seeds->{$_->{Team}} = [ $_->{Seed} ];
    } else {
        push @{$teams->{$_->{Team}}}, "Home PWR RTG";
        push @{$regions->{$_->{Team}}}, $_->{Region};
        push @{$seeds->{$_->{Team}}}, $_->{Seed};
    }

    my $team = $_->{Team};
    my $row = $_;

    if(!defined $tdata->{$team}) {
        $tdata->{$team} = {};
    }

    foreach(keys %{$row}) {
        $tdata->{$team}->{$_} = $row->{$_};
    }
}

foreach(@{$tables->{"Away PWR RTG"}->{rows}}) {
    if(!defined $teams->{$_->{Team}}) {
        $teams->{$_->{Team}} = [ "Away PWR RTG" ];
        $regions->{$_->{Team}} = [ $_->{Region} ];
        $seeds->{$_->{Team}} = [ $_->{Seed} ];
    } else {
        push @{$teams->{$_->{Team}}}, "Away PWR RTG";
        push @{$regions->{$_->{Team}}}, $_->{Region};
        push @{$seeds->{$_->{Team}}}, $_->{Seed};
    }

    my $team = $_->{Team};
    my $row = $_;

    if(!defined $tdata->{$team}) {
        $tdata->{$team} = {};
    }

    foreach(keys %{$row}) {
        $tdata->{$team}->{$_} = $row->{$_};
    }
}

foreach(@{$tables->{"SOS PWR RTG"}->{rows}}) {
    if(!defined $teams->{$_->{Team}}) {
        $teams->{$_->{Team}} = [ "SOS PWR RTG" ];
        $regions->{$_->{Team}} = [ $_->{Region} ];
        $seeds->{$_->{Team}} = [ $_->{Seed} ];
    } else {
        push @{$teams->{$_->{Team}}}, "SOS PWR RTG";
        push @{$regions->{$_->{Team}}}, $_->{Region};
        push @{$seeds->{$_->{Team}}}, $_->{Seed};
    }

    my $team = $_->{Team};
    my $row = $_;

    if(!defined $tdata->{$team}) {
        $tdata->{$team} = {};
    }

    foreach(keys %{$row}) {
        $tdata->{$team}->{$_} = $row->{$_};
    }
}

foreach(@{$tables->{"OPPG"}->{rows}}) {
    if(!defined $teams->{$_->{Team}}) {
        $teams->{$_->{Team}} = [ "OPPG" ];
        $regions->{$_->{Team}} = [ $_->{Region} ];
        $seeds->{$_->{Team}} = [ $_->{Seed} ];
    } else {
        push @{$teams->{$_->{Team}}}, "OPPG";
        push @{$regions->{$_->{Team}}}, $_->{Region};
        push @{$seeds->{$_->{Team}}}, $_->{Seed};
    }

    my $team = $_->{Team};
    my $row = $_;

    if(!defined $tdata->{$team}) {
        $tdata->{$team} = {};
    }

    foreach(keys %{$row}) {
        $tdata->{$team}->{$_} = $row->{$_};
    }
}


# print "Teams:\n";
# foreach(sort keys %{$teams}) {
#     printf "  %20s: ", $_;
#     foreach(@{$teams->{$_}}) {
#         printf "%20s ", $_;
#     }
#     print "\n";

#     printf "  %20s  ", "";
#     my $region = $regions->{$_}->[0];
#     foreach(@{$regions->{$_}}) {
#         my $pref = "";
#         my $postf = "";
#         if($_ ne $region) {
#             $pref = "[0;1;31m";
#             $postf = "[0m";
#         }
#         printf "$pref%20s$postf ", $_;
#     }
#     print "\n";

#     printf "  %20s  ", "";
#     my $seed = $seeds->{$_}->[0];
#     foreach(@{$seeds->{$_}}) {
#         my $pref = "";
#         my $postf = "";
#         if($_ ne $seed) {
#             $pref = "[0;1;31m";
#             $postf = "[0m";
#         }
#         printf "$pref%20s$postf ", $_;
#     }
#     print "\n";
# }
# print "\n";

my $regionseeds = {};


#print "\n";
#printf "%20s %15s %10s %4s %4s %26s ","Team","Conf","Region","Seed","Rank","Location";
#printf "%6s %6s %6s %6s %6s ","Record","SOSP","OP","HP","AP";
#printf "%6s %6s %6s %6s %6s %6s ","PPG_O","PPG_H","PPG_A","OPPG_O","OPPG_H","OPPG_A";
#printf "%6s %6s %6s %6s","OPR","SOSPR","HPR","APR";
#print "\n";
#print "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n";
foreach(sort {$tdata->{$a}->{S_Rank} <=> $tdata->{$b}->{S_Rank}} keys %{$tdata}) {
    my $cur = $tdata->{$_};
    # Team, conference, region, seed, s_rank, s_record, SOSP_record, OP_Record, HP_Record, AP_Record
#    printf "%-20s %15s %10s %4d %4d (%11.6f, %11.6f) ",
#    $cur->{Team}, $cur->{Conference}, $cur->{Region}, $cur->{Seed}, $cur->{S_Rank}, normCoords($cur->{Location});
#    printf "%6s %6s %6s %6s %6s",
#    $cur->{S_Record}, $cur->{SOSP_Record}, $cur->{OP_Record}, $cur->{HP_Record}, $cur->{AP_Record};
#    printf "%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f ",
#    $cur->{PPG_Overall}, $cur->{PPG_Home}, $cur->{PPG_Away}, $cur->{OPPG_Overall}, $cur->{OPPG_Home}, $cur->{OPPG_Away};
#    printf "%6.1f %6.1f %6.1f %6.1f ",
#    $cur->{OP_Rating}, $cur->{SOSP_Rating}, $cur->{HP_Rating}, $cur->{AP_Rating};
#    print "\n";

    $regionseeds->{$cur->{Region}} = {} if !defined $regionseeds->{$cur->{Region}};
    $regionseeds->{$cur->{Region}}->{$cur->{Seed}} = $cur;

    $cur->{Rounds} = 1;

    foreach(sort keys %{$tables->{"Seed Games"}->{hash}->{$cur->{Seed}}}) {
        if($_ ne "Seed") {
            my $game = $cur->{Region}." ".$tables->{"Seed Games"}->{hash}->{$cur->{Seed}}->{$_};
            my $dist = distCoords($cur->{Location}, $tables->{Games}->{hash}->{$game}->{Location});
            $cur->{"Round $_ Game"} = $game;
            $cur->{"Round $_ Distance"} = $dist;

#            printf "    Round $_: %-46s (%11.6f, %11.6f)  dist = %15.6f m\n",
#            $game, normCoords($tables->{Games}->{hash}->{$game}->{Location}), $dist;

            if($_ == 1) {
                $games->{$game}->{players} = [] if !defined $games->{$game}->{players};
                push @{$games->{$game}->{players}}, $cur->{Team};
            }
        }
    }

    foreach(sort keys %{$tables->{"Final Games"}->{hash}->{$cur->{Region}}}) {
        if($_ ne "Region") {
            my $game = $tables->{"Final Games"}->{hash}->{$cur->{Region}}->{$_};
            my $dist = distCoords($cur->{Location}, $tables->{Games}->{hash}->{$game}->{Location});
            $cur->{"Round $_ Game"} = $game;
            $cur->{"Round $_ Distance"} = $dist;

#            printf "    Round $_: %-46s (%11.6f, %11.6f)  dist = %15.6f m\n",
#            $game, normCoords($tables->{Games}->{hash}->{$game}->{Location}), $dist;
        }
    }
}

#print "\n";

my @region_order = ("Midwest","West","South","East");
my @seed_order = (1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15);

## Go through all the games, display the players, ask for a choice...

open TTY, '<', '/dev/tty';

print "===========================================================================================\n";
print "Picking Winners\n";
print "===========================================================================================\n";
print "\n";
print "-------------------------------------------------------------------------------------------\n";
print "\n";
my $num = 0;
my $max = scalar keys %{$games};
foreach(sort {$games->{$a}->{Round} <=> $games->{$b}->{Round}} keys %{$games}) {
    my $game = $games->{$_};
    ++$num;
    print "Picking for Round $game->{Round}, Game $num of $max ($game->{Game}):\n";

    my $player = 0;

    printf "          %-20s %-15s %4s %4s %14s ","Team","Conf","Seed","Rank","Distance";
    printf "%6s %6s %6s %6s %6s %6s ","PPG_O","PPG_H","PPG_A","OPPG_O","OPPG_H","OPPG_A";
    printf "%6s %6s %6s %6s","OPR","SOSPR","HPR","APR";
    print "\n";
    foreach (@{$game->{players}}) {
        my $cur = $tdata->{$_};
        printf "  Team $player: %-20s %-15s %4d %4d %11.0f km ",
        $cur->{Team}, $cur->{Conference}, $cur->{Seed}, $cur->{S_Rank}, $cur->{"Round $game->{Round} Distance"}/1000;
        printf "%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f ",
        $cur->{PPG_Overall}, $cur->{PPG_Home}, $cur->{PPG_Away}, $cur->{OPPG_Overall}, $cur->{OPPG_Home}, $cur->{OPPG_Away};
        printf "%6.1f %6.1f %6.1f %6.1f ",
        $cur->{OP_Rating}, $cur->{SOSP_Rating}, $cur->{HP_Rating}, $cur->{AP_Rating};
        print "\n";

        ++$player;
    }

    my $winner=undef;
    my $conf = 0;
    my $tweight = 0;
    my @p = ();
    if(scalar @{$game->{players}} == 2) {
        my $team0 = $tdata->{$game->{players}->[0]};
        my $d0 = $team0->{"Round $game->{Round} Distance"}/1000;
        my $team1 = $tdata->{$game->{players}->[1]};
        my $d1 = $team1->{"Round $game->{Round} Distance"}/1000;
        print "\n";
        printf  "(%5s)%-20s %9s %9s     Prediction\n", "Wght","Algorithm", "Team0","Team1";
        # Here, run a few numbers to help out.


        # Rank prediction
        push @p, { name => "Rank",
                   weight => 0.05,
                   val0 => ($team0->{S_Rank}-1) * (-100/68) + 100,
                   val1 => ($team1->{S_Rank}-1) * (-100/68) + 100
        };


        # OPR prediction
        push @p, { name => "OPR",
                   weight => 1.0,
                   val0 => $team0->{OP_Rating},
                   val1 => $team1->{OP_Rating}
        };


        # SOSPR prediction
        push @p, { name => "SOSPR",
                   weight => 0.010,
                   val0 => $team0->{SOSP_Rating},
                   val1 => $team1->{SOSP_Rating}
        };

        # # HPR/APR prediction purely using closer team
        # push @p, { name => "HPRAPR_straight",
        #            weight => 0.20,
        #            val0 => (($d0 < $d1) ? $team0->{HP_Rating}:$team0->{AP_Rating}),
        #            val1 => (($d1 < $d0) ? $team1->{HP_Rating}:$team1->{AP_Rating})
        # };


        # HPR/APR prediction, using HPR if distance is less than 250km, APR otherwise
        push @p, { name => "HPRAPR_250",
                   weight => 0.15,
                   val0 => (($d0 < 250) ? $team0->{HP_Rating}:$team0->{AP_Rating}),
                   val1 => (($d1 < 250) ? $team1->{HP_Rating}:$team1->{AP_Rating})
        };

        # Scaled HPR/APR using relative distance metrics
        push @p, { name => "HPRAPR_scaled",
                   weight => 0.010,
                   val0 => $team0->{AP_Rating} + ($team0->{AP_Rating} - $team0->{HP_Rating}) * $d0/($d0+$d1),
                   val1 => $team1->{AP_Rating} + ($team1->{AP_Rating} - $team1->{HP_Rating}) * $d1/($d0+$d1)
        };

        # Scaled PPG and OPPG using relative SOSPR metrics
        push @p, { name => "PPG_SOS",
                   weight => 0.130,
                   val0 => 0.9*$team0->{SOSP_Rating}/100 * $team0->{PPG_Overall} + 100/$team1->{SOSP_Rating} * $team1->{OPPG_Overall},
                   val1 => 0.9*$team1->{SOSP_Rating}/100 * $team1->{PPG_Overall} + 100/$team0->{SOSP_Rating} * $team0->{OPPG_Overall}
        };

        # Scaled PPG_H/PPG_A and OPPG_H/OPPG_A using relative SOSPR and distance metrics
        my $PPG_0 = $team0->{PPG_Away} + ($team0->{PPG_Away} - $team0->{PPG_Home}) * $d0/($d0+$d1);
        my $OPPG_0 = $team0->{OPPG_Away} + ($team0->{OPPG_Away} - $team0->{OPPG_Home}) * $d0/($d0+$d1);
        my $PPG_1 = $team1->{PPG_Away} + ($team1->{PPG_Away} - $team1->{PPG_Home}) * $d1/($d0+$d1);
        my $OPPG_1 = $team1->{OPPG_Away} + ($team1->{OPPG_Away} - $team1->{OPPG_Home}) * $d1/($d0+$d1);

        push @p, { name => "PPG_dscale",
                   weight => 0.20,
                   val0 => 0.9*$team0->{SOSP_Rating}/100 * $PPG_0 + 100/$team1->{SOSP_Rating} * $OPPG_1,
                   val1 => 0.9*$team1->{SOSP_Rating}/100 * $PPG_1 + 100/$team0->{SOSP_Rating} * $OPPG_0
        };













        my $c0 = 0;
        my $c1 = 0;
        my $t0 = 0;
        my $t1 = 0;

        foreach (@p) {
            my $c = $_;
            $c->{outcome} = $c->{val0} > $c->{val1} ? 0:1;
            $c->{conf} = abs($c->{val0} - $c->{val1});
            my $po = $c->{outcome} ? "  1":"0";
            printf "(%5.3f)%-20s %9.3f %9.3f  -> %s\n", $c->{weight}, $c->{name}, $c->{val0}, $c->{val1}, $po;

            if($c->{outcome}) {
                $c1 += $c->{weight} * $c->{conf};
                ++$t1;
            } else {
                $c0 += $c->{weight} * $c->{conf};
                ++$t0;
            }

        }

        print "\n";
        if($c1 - $c0 > 0.01) {
            $winner = 1;
            $conf = $c1-$c0;
            $tweight = $t1;
        } elsif($c0 - $c1 > 0.01) {
            $winner = 0;
            $conf = $c0-$c1;
            $tweight = $t0;
        }

        if(defined $winner) {
            printf "Best prediction: $winner (%5.3f vs %5.3f)",$c0,$c1;

            if($winner != $p[0]->{outcome}) {
                print "  UPSET PREDICTED!!!";
            }
            print "\n";
        }
        print "\n";

    } else {
        print "Wrong number of teams\n";
    }

    ## ask for winning team (0 or 1)
    if(!defined $autowin || !defined $winner || ($autowin eq "unan" && $tweight < scalar @p)) {
        my $val = undef;
        while(!defined $val || ($val ne "" && $val ne "0" && $val ne "1")) {
            print "Please select winning team (0 or 1)";
            if(defined $winner) {
                print " (defaults to $winner)";
            }
            print ": ";
            chomp($val = <TTY>);
            if(!defined $winner && $val eq "") {
                $val = undef;
            }
        }

        if($val ne "") {
            $winner = $val;
        }
    }


    my $t_win = $game->{players}->[$winner];

    print "\n*** WINNER: (Team $winner) $tdata->{$t_win}->{Seed} $t_win !!!\n\n";

    ++$tdata->{$t_win}->{Rounds};
    $game->{Winner} = $t_win;
    my $nr = $game->{Round} + 1;

    if(defined $tdata->{$t_win}->{"Round $nr Game"}) {
        my $ng = $games->{$tdata->{$t_win}->{"Round $nr Game"}};
        $ng->{players} = [] if !defined $ng->{players};
        push @{$ng->{players}}, $t_win;
    }

    print "-------------------------------------------------------------------------------------------\n";
    print "\n";
}

close TTY;

print "\n";
print "===========================================================================================\n";
print "Generating Bracket\n";
print "===========================================================================================\n";
print "\n";

## Display the finished bracket
printf "   %-20s %-20s %-20s %-20s %-20s %-20s %-20s\n","Round 1","Round 2", "Round 3", "Round 4", "Round 5","Round 6","Champion";
my $count = 0;
foreach(@region_order) {
    my $region = $_;

    if($count % 64 == 0) {
        print '=' x (3+21*7);
        print "\n";
    } elsif($count % 32 == 0) {
        print '=' x (3+21*5);
        print "\n";
    } elsif($count % 16 == 0) {
        print '=' x (3+21*4);
        print "\n";
    }

    print "$region\n";
    foreach(@seed_order) {
        my $seed = $_;
        my $team = $regionseeds->{$region}->{$seed};

        if($count % 64 == 0) {
            print '-' x (3+21*7);
            print "\n";
        } elsif($count % 32 == 0) {
            print '-' x (3+21*5);
            print "\n";
        } elsif($count % 16 == 0) {
            print '-' x (3+21*4);
            print "\n";
        } elsif($count % 8 ==0) {
            print '-' x (3+21*3);
            print "\n";
        } elsif($count % 4==0) {
            print '-' x (3+21*2);
            print "\n";
        } elsif($count % 2==0) {
            print '-' x (3+21);
            print "\n";
        }

        printf "%2d ", $seed;

        for(my $i = 0; $i < $team->{Rounds}; ++$i) {
            printf "%-20s ", $team->{Team};
        }

        print "\n";

        ++$count;

    }
}

print '=' x (3+21*7);
print "\n";





exit;


sub normCoords {
    my ($l) = @_;

    my $lat = undef;
    my $long = undef;

    if($l =~ /^(.*)°(.*)′(.*)″N (.*)°(.*)′(.*)″W$/) {
        $lat = $1 + $2/60 + $3/60/60;
        $long = -($4 + $5/60 + $6/60/60);
    } elsif($l =~ /^(.*)°(.*)′(.*)″N (.*)°(.*)′W$/) {
        $lat = $1 + $2/60 + $3/60/60;
        $long = -($4 + $5/60);
    } elsif($l =~ /^(.*)°(.*)′(.*)″N (.*)°W$/) {
        $lat = $1 + $2/60 + $3/60/60;
        $long = -$4;
    } elsif($l =~ /^(.*)°(.*)′N (.*)°(.*)′(.*)″W$/) {
        $lat = $1 + $2/60;
        $long = -($3 + $4/60 + $5/60/60);
    } elsif($l =~ /^(.*)°(.*)′N (.*)°(.*)′W$/) {
        $lat = $1 + $2/60;
        $long = -($3 + $4/60);
    } elsif($l =~ /^(.*)°(.*)′N (.*)°W$/) {
        $lat = $1 + $2/60;
        $long = -$3;
    } elsif($l =~ /^(.*)°N (.*)°(.*)′(.*)″W$/) {
        $lat = $1;
        $long = -($2 + $3/60 + $4/60/60);
    } elsif($l =~ /^(.*)°N (.*)°(.*)′W$/) {
        $lat = $1;
        $long = -($2 + $3/60);
    } elsif($l =~ /^(.*)°N (.*)°W$/) {
        $lat = $1;
        $long = -$2;
    } else {
        die "WHOOPS: Confused by [$l]\n";
    }


    return ($lat, $long);
}


sub distCoords {
    my ($l1, $l2) = @_;

    my ($phi1,$lambda1) = normCoords($l1);
    my ($phi2,$lambda2) = normCoords($l2);
    $phi1 *= 3.14159265/180;
    $phi2 *= 3.14159265/180;
    $lambda1 *= 3.14159265/180;
    $lambda2 *= 3.14159265/180;

    my $delphi = abs($phi1 - $phi2);
    my $dellambda = abs($lambda1 - $lambda2);

    my $top1 = (cos($phi2) * sin($dellambda));
    $top1 *= $top1;
    my $top2 = (cos($phi1) * sin($phi2)) - (sin($phi1) * cos($phi2) * cos($dellambda));
    $top2 *= $top2;
    my $top = sqrt($top1 + $top2);
    my $bot = (sin($phi1)*sin($phi2) + cos($phi1)*cos($phi2)*cos($dellambda));

    my $dist = 6371009 * atan2($top, $bot);
    return $dist;
}
