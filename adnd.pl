#!/usr/bin/perl -w

use strict;
use XML::Simple;
use vars qw($VERSION %IRSSI);

my $xsl = XML::Simple->new();
my $scene = $xsl->XMLin('/home/irssi/.irssi/scripts/map.xml');

#print $scene->{rooms}->{room}->{'1'}->{'description'};

#foreach my $roomnumber (keys (%{$scene->{rooms}->{room}})){
#  print $roomnumber.': '.$scene->{rooms}->{room}->{$roomnumber}->{'description'};
#  print "[".$scene->{rooms}->{room}->{$roomnumber}->{'characters'}."]\n";
#  print "[".$scene->{rooms}->{room}->{$roomnumber}->{'exits'}."]\n";
#}

foreach my $nick (keys (%{$scene->{characters}->{character}})){
  print $nick.' '.$scene->{characters}->{character}->{$nick}->{'activity'};
}

sub adnd {
  # $data = "nick/#channel :text"
  #my ($server, $data, $nick, $address) = @_;
  my ($server, $data, $nick, $mask, $target) = @_;
  
  #print "$data : $nick : $mask : $target ";
      my $room = 0;  
      if ( exists $scene->{characters}->{character}->{$nick} ) { 
          $room = $scene->{characters}->{character}->{$nick}->{'room'};
      }
      else { 
          $scene->{characters}->{character}->{$nick}->{'room'} = 1;
          $scene->{characters}->{character}->{$nick}->{'activity'} = " boklaszik ";
          $room = 1;
      }
  #    
  # MEGYUNK VALAMERRE    
  #    
  if ( $data =~ /^E|D|K|NY$/i ) {
      # print "megyunk valamerre $data"; 
      my $room = 0;  
      if ( exists $scene->{characters}->{character}->{$nick} ) { 
          $room = $scene->{characters}->{character}->{$nick}->{'room'};
      }
      else { 
          $scene->{characters}->{character}->{$nick}->{'room'} = 1;
          $room = 1;
      }
      my @exits = split(/,/, $scene->{rooms}->{room}->{$room}->{exits});
      my $nextroom = 0;
      foreach my $direction (@exits) {
        if ( $direction =~ /^\Q$data\E([0-9]+)/i ) {
            $nextroom = $1;
            # print "kovetkezo szoba: $nextroom";
        }
      }
      if ( $nextroom > 0 ) { 
        $scene->{characters}->{character}->{$nick}->{'room'} = $nextroom;
        
        my @characters = split(/,/,$scene->{rooms}->{room}->{$room}->{'characters'});
        my @whostay;
        foreach my $character (@characters) { 
            if ( $character ne $nick ) {
              push @whostay, $character;
            }
        }
        $scene->{rooms}->{room}->{$room}->{'characters'} = join(",",@whostay);
        
        my $message = " $nick: ".$scene->{rooms}->{room}->{$nextroom}->{'description'};

        if ( exists $scene->{rooms}->{room}->{$nextroom}->{'characters'} && $scene->{rooms}->{room}->{$nextroom}->{'characters'} =~ /^[^HASH.+]/) {
          my @characters = split(/,/,$scene->{rooms}->{room}->{$nextroom}->{'characters'});
          foreach my $character (@characters) { 
            $message .= " $character ".$scene->{characters}->{character}->{$character}->{'activity'}.".";
          }
          push @characters, $nick;
          $scene->{rooms}->{room}->{$nextroom}->{'characters'} = join(",",@characters);
        }
        if ( exists $scene->{rooms}->{room}->{$nextroom}->{'objects'} && $scene->{rooms}->{room}->{$nextroom}->{'objects'} =~ /^[^HASH.+]/) {
            $message .= " Ezeket latod: ".$scene->{rooms}->{room}->{$nextroom}->{'objects'}.".";
          
        }
        
        $server->command('/msg '.$target.$message);
      } 
  }
  
  #
  # FELVESZUNK VALAMIT
  #
  if ( $data =~ /^felvesz ([a-zA-Z ]+)$/ ) { 
      my $object = $1;
      my @hands;
      if ( exists $scene->{characters}->{character}->{$nick}->{'hands'} && $scene->{characters}->{character}->{$nick}->{'hands'}=~ /^[^HASH.+]/) {
          @hands = split(/,/,$scene->{characters}->{character}->{$nick}->{'hands'});
      }
      my $count = @hands;
      if ( $count < 3 ) { 
      
      my $room = 0;  
      if ( exists $scene->{characters}->{character}->{$nick} ) { 
          $room = $scene->{characters}->{character}->{$nick}->{'room'};
      }
      else { 
          $scene->{characters}->{character}->{$nick}->{'room'} = 1;
          $room = 1;
      }
      if ( exists $scene->{rooms}->{room}->{$room}->{objects} && $scene->{rooms}->{room}->{$room}->{objects} =~ /^[^HASH.+]/ && $scene->{rooms}->{room}->{$room}->{objects} =~ /\Q$object\E/i ) { 
        my @objects_in_room = split(/,/,$scene->{rooms}->{room}->{$room}->{objects});
        my @newobjects;

        foreach my $obj (@objects_in_room) {
           if ( $obj eq $object ) { 
               if ( exists $scene->{characters}->{character}->{$nick}->{'hands'} && $scene->{characters}->{character}->{$nick}->{'hands'}=~ /^[^HASH.+]/) {
                 @hands = split(/,/,$scene->{characters}->{character}->{$nick}->{'hands'});
               }
               push @hands, $object;
               $scene->{characters}->{character}->{$nick}->{'hands'} = join(",",@hands);
               $server->command('/msg '.$target." $nick: felvettel egy $object -t");
           }
           else {
               push @newobjects, $obj;
           }
        }
        $scene->{rooms}->{room}->{$room}->{objects} = join(",",@newobjects);
      }
      else { 
        $server->command('/msg '.$target." $nick: nincs itt $object");
      }
      
      }
      else {
        $server->command('/msg '.$target." $nick: egyszerre csak harom targy lehet nalad. valamit rakjal le. (".$count.")");
      }
      
  }
  
  #
  # LERAKUNK VALAMIT
  #
  if ( $data =~ /^lerak ([a-zA-Z ]+)$/ ) {
      my $object = $1;
      my $room = 0;  
      if ( exists $scene->{characters}->{character}->{$nick} ) { 
          $room = $scene->{characters}->{character}->{$nick}->{'room'};
      }
      else { 
          $scene->{characters}->{character}->{$nick}->{'room'} = 1;
          $room = 1;
      }
      if ( exists $scene->{characters}->{character}->{$nick}->{hands} && $scene->{characters}->{character}->{$nick}->{hands} =~ /^[^HASH.+]/ && $scene->{characters}->{character}->{$nick}->{hands} =~ /\Q$object\E/i ) {
        my @objects_in_hand = split(/,/,$scene->{characters}->{character}->{$nick}->{hands});
        my @objects;
        my @newobjects;
        foreach my $obj (@objects_in_hand) {
           if ( $obj eq $object ) { 
               if ( exists $scene->{rooms}->{room}->{$room}->{'objects'} && $scene->{rooms}->{room}->{$room}->{'objects'}=~ /^[^HASH.+]/) {
                 @objects = split(/,/,$scene->{rooms}->{room}->{$room}->{'objects'});
               }
               push @objects, $object;
               $scene->{rooms}->{room}->{$room}->{'objects'} = join(",",@objects);
               $server->command('/msg '.$target." $nick: leraktal egy $object -t");
           }
           else {
               push @newobjects, $obj;
           }
        }
        $scene->{characters}->{character}->{$nick}->{hands} = join(",",@newobjects);
      }
      else { 
          $server->command('/msg '.$target." $nick: nincs nalad $object");
      }
                                                            
  }
  
  #
  # SEGITSEG
  #
  if ( $data =~ /^segitseg$/ ) { 
      $server->command('/msg '.$target.' e, d, k, ny, felvesz, lerak, csinal, vizsgal, nalam, hasznal, korulnez');
  }
  
  #
  # megvaltoztatjuk egy karakter activity informaciojat
  #
  if ( $data =~ /^csinal ([a-zA-Z ]+)$/ ) {
      $scene->{characters}->{character}->{$nick}->{activity} = $1;
  }
  
  #
  # megmondunk valamit egy targyrol vagy egy karakterrol
  #
  if ( $data =~ /^vizsgal ([a-zA-Z\[\]0-9 ]+)$/ ) {
      my $object = $1;
      my $vanilyen = 0;
      if ( $scene->{rooms}->{room}->{$room}->{characters} =~ /\Q$object\E/i ) {
         #van ilyen szemely a szobaban
         $server->command('/msg '.$target." $nick : $object ".$scene->{characters}->{character}->{$object}->{'activity'});
         $server->command('/msg '.$target." $nick : ezeket latod nala: ".$scene->{characters}->{character}->{$object}->{'hands'});
         $vanilyen =1;
      }
      if ( $scene->{rooms}->{room}->{$room}->{objects} =~ /\Q$object\E/i ) { 
         #van ilyen targy a szobaban
         $server->command('/msg '.$target." $nick : ".$scene->{objects}->{object}->{$object}->{'description'});
         $vanilyen =1;
      }
      if ( !$vanilyen ) {
         $server->command('/msg '.$target." $nick : nincs itt ilyen");
      }
  }
  
  #
  # megmondjuk mi van az adott karakter kezeben
  #
  if ( $data =~ /^nalam$/ ) {
      $server->command('/msg '.$target." $nick kezeben van: ".$scene->{characters}->{character}->{$nick}->{hands});
  }
  
  #
  # megmondjuk mi van az adott helyszinen
  #
  if ( $data =~ /^korulnez$/ ) {
        my $message = " $nick: ".$scene->{rooms}->{room}->{$room}->{'description'};

        if ( exists $scene->{rooms}->{room}->{$room}->{'characters'} && $scene->{rooms}->{room}->{$room}->{'characters'} =~ /^[^HASH.+]/) {
          my @characters = split(/,/,$scene->{rooms}->{room}->{$room}->{'characters'});
          foreach my $character (@characters) { 
            $message .= " $character ".$scene->{characters}->{character}->{$character}->{'activity'}.".";
          }
        }
        if ( exists $scene->{rooms}->{room}->{$room}->{'objects'} && $scene->{rooms}->{room}->{$room}->{'objects'} =~ /^[^HASH.+]/) {
            $message .= " Ezeket latod: ".$scene->{rooms}->{room}->{$room}->{'objects'}.".";
        }
        
        $server->command('/msg '.$target.$message);
  }
  
  
  #
  # hasznalunk egy targyat
  #
  if ( $data =~ /^hasznal ([a-zA-Z ]+)$/ ) {
      my $object = $1;
      if ( $scene->{characters}->{character}->{$nick}->{'hands'} =~ /\Q$object\E/ ) { 
      	  my $target_type = $scene->{objects}->{object}->{$object}->{'type'};
          my $target_character = $scene->{objects}->{object}->{$object}->{'target'};
          my $valid_scene = 0;
          if ( $target_type eq "character" ) {
            $valid_scene = $scene->{rooms}->{room}->{$room}->{'characters'} =~ /\Q$target_character\E/;
          }
          if ( $target_type eq "room" ) {
            if ( $room == $target_character ) { 
              $valid_scene = 1 ;
			}
          }
          if ( $valid_scene && $scene->{objects}->{object}->{$object}->{'provides'} ne "") {
              $server->command("/msg $target $nick: ".$scene->{objects}->{object}->{$object}->{'success'});
              if ( $scene->{objects}->{object}->{$object}->{'provides'} ne "null" ) {
                my @hand = split(/,/,$scene->{characters}->{character}->{$nick}->{'hands'});
                push @hand, $scene->{objects}->{object}->{$object}->{'provides'};
                my $counter = $scene->{objects}->{object}->{$object}->{'counter'};
                $counter--;
                if ($counter <= 0) { 
                  $scene->{objects}->{object}->{$object}->{'provides'} = "";
                }
                $scene->{objects}->{object}->{$object}->{'counter'} = $counter;
                $scene->{characters}->{character}->{$nick}->{'hands'} = join(",",@hand);
              }
          }
          else { 
            if ($valid_scene && $scene->{objects}->{object}->{$object}->{'provides'} eq "") {
              $server->command("/msg $target $nick: ezt mar hasznaltak.");
            }
            else {
              $server->command("/msg $target $nick: ".$scene->{objects}->{object}->{$object}->{'fail'});
            }
          }
      }
      else {
          $server->command('/msg '.$target." $nick: nincs nalad $object");
      }
  }

}

sub sig_nick {
  my ($server, $newnick, $nick, $address) = @_;
  $newnick =~ s/://;
  if ( exists $scene->{characters}->{character}->{$nick} ) {
      print "nickvaltas $nick => $newnick";
      $scene->{characters}->{character}->{$newnick} = $scene->{characters}->{character}->{$nick};
      undef $scene->{characters}->{character}->{$nick};
  }
}


Irssi::signal_add_last('message public', "adnd");
Irssi::signal_add_last('event nick', "sig_nick");
