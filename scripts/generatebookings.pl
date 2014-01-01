#!/usr/bin/perl
use strict;
my @memberstarts = (
[0,'2012-07-01 00:00:00'],
[1,'2012-07-02 12:02:05'],
[2,'2012-07-02 12:08:23'],
[3,'2012-07-03 09:32:15'],
[4,'2012-07-03 10:25:05'],
[5,'2012-07-09 10:44:09'],
[6,'2012-07-15 08:52:55'],
[7,'2012-07-25 08:59:12'],
[8,'2012-07-25 16:02:35'],
[9,'2012-07-25 17:09:05'],
[10,'2012-08-03 19:42:37'],
[11,'2012-08-06 16:32:55'],
[12,'2012-08-10 14:23:22'],
[13,'2012-08-10 14:28:01'],
[14,'2012-08-10 16:22:05'],
[15,'2012-08-10 17:52:03'],
[16,'2012-08-15 10:34:25'],
[17,'2012-08-16 11:32:47'],
[20,'2012-08-19 14:55:55'],
[21,'2012-08-26 09:32:05'],
[22,'2012-08-29 08:32:41'],
[24,'2012-09-01 08:44:42'],
[26,'2012-09-02 18:43:05'],
[27,'2012-09-05 08:42:35'],
[28,'2012-09-15 08:22:05'],
[29,'2012-09-17 12:27:15'],
[30,'2012-09-18 19:04:01'],
[33,'2012-09-18 19:32:05'],
[35,'2012-09-19 11:32:45'],
[36,'2012-09-22 08:36:38'],
[37,'2012-09-26 18:08:45']
);

my @facilities = (
	{
		name => "Tennis Court 1",
		current => 4,
		end => 80,
		guestlikelihood => 0.3,
		avgbooklength => 3,
		generality => 0.3
	},
	{
		name => "Tennis Court 2",
		current => 0,
		end => 75,
		guestlikelihood => 0.3,
		avgbooklength => 3,
		generality => 0.3
	},
	{
		name => "Badminton Court",
		current => 0,
		end => 70,
		guestlikelihood => 0.1,
		avgbooklength => 3,
		generality => 0.2
	},
	{
		name => "Table Tennis",
		current => 3,
		end => 45,
		guestlikelihood => 0.05,
		avgbooklength => 2,
		generality => 0.6
	},
	{
		name => "Massage Room 1",
		current => 5,
		end => 95,
		guestlikelihood => 0.35,
		avgbooklength => 2,
		generality => 0.9
	},
	{
		name => "Massage Room 2",
		current => 0,
		end => 10,
		guestlikelihood => 0.7,
		avgbooklength => 2,
		generality => 0.1
	},
	{
		name => "Squash Court",
		current => 2,
		end => 70,
		guestlikelihood => 0.6,
		avgbooklength => 2,
		generality => 0.3
	},
	{
		name => "Snooker Table",
		current => 5,
		end => 50,
		guestlikelihood => 0.05,
		avgbooklength => 2,
		generality => 0.7
	},
	{
		name => "Pool Table",
		current => 5,
		end => 75,
		guestlikelihood => 0.05,
		avgbooklength => 1,
		generality => 0.2
	},
);


my @monthlengths = (31,29,31,30,31,30,31,31,30,31,30,31);

my $facilitycount = scalar(@facilities);;
my $open = 8;
my $close = 21;
my $slots = ($close - $open)*2;

my %memberbehaviour = ();
my $nextmember = 0;


my $maxdays = 92;
my $currenttotaldays = 0;

for (my $month = 7; $month < 10; $month++) {
	for(my $day = 1; $day <= $monthlengths[$month-1]; $day ++) {
		my $date = sprintf("2012-%02d-%02d",$month, $day);

		#generate booking data
		if($nextmember > 1) {

			#Record of bookings per facility for this day
			my @facilitybookings = ();
			for(my $i = 0; $i < $facilitycount; $i++) {
				my %hash;
				push(@facilitybookings, \%hash);
			}

			#Record of bookings for each member for this day
			#(to prevent them booking in twice in one time slot)
			my @memberbookings = ();
			for(my $i = 0; $i < scalar(@memberstarts) - 1; $i++) {
				my %hash;
				push(@memberbookings, \%hash);
			}

			#loop through facilities, generating bookings
			for(my $i = 0; $i < $facilitycount; $i++) {
				for(my $slot = 0; $slot < $slots; $slot++) {
					
					#likelihood of the facility being booked
					my $facprob = $facilities[$i]->{"current"};

					#if we haven't already booked this slot for the facility (as some bookings
					#last multiple slots), check whether we want to book
					if(rand(100) < $facprob && !exists($facilitybookings[$i]->{$slot})) {
						#yes we want to book
						my $memberno = 0; #guest

						#default to a booking by guest (id 0).  Each facility has a likelihood
						#of being booked by a guest vs a member.  Do a random test to see
						#if we want a member booking instead
						if(rand() > $facilities[$i]->{"guestlikelihood"}) {
							#not a guest!

							#for each facility, there's an array that defines the booking
							#probability for each member.  If 1 has a booking probability
							#of 10 and 2 has a booking probability of 3, it would look like
							#(111111111222).  We'd then do a random number between 0 and 12
							#, and pick the member at that location.  Hacky but easy!
							my $bookingcalc = $facilities[$i]->{"bookingprob"};
							my $numchances = scalar(@$bookingcalc)-1;
							
							#attempt to find a member who's not already booked.
							#if we can't, fall back to guest
							for(my $attempt = 0; $attempt < 10; $attempt++) {
								my $candidatemember = $bookingcalc->[int(rand($numchances))];
								my $found = 0;
								for(my $slotc = $slot; $slotc < $slot + $facilities[$i]->{"avgbooklength"}; $slotc++) {
									if(exists($memberbookings[$candidatemember]->{$slotc})) {
										$found = 1;
									}
								}
								if(!($found == 1)) {
									$memberno = $candidatemember;
									last;
								}
							}

						}
						
						#Each facility can be booked for a certain number of slots at a time
						#Book these future slots as required
						for(my $slotbooking = $slot; $slotbooking < $slot+$facilities[$i]->{"avgbooklength"}; $slotbooking++) {
							$facilitybookings[$i]->{$slotbooking} = $memberno;
							$memberbookings[$memberno]->{$slotbooking} = 1;
					#		print "OUT: fac $i slot $slotbooking mem $memberno \n";
						}
					} else {
						#we do not want to book the facility
						if(!exists($facilitybookings[$i]->{$slot})) {
							$facilitybookings[$i]->{$slot} = -1;
						}
					}
					
				}
				
			}

			#loop through the facility data, printing out the bookings for today
			for(my $i = 0; $i < scalar(@facilitybookings); $i++) {
				my $lastmember = -1;
				my $slotcount = 0;
				#loop through each slot (30 minutes).  Once we've finished
				#a complete 'run' of bookings (eg one might book tennis for
				#3 slots), print out the booking
				for(my $j = 0; $j < $slots; $j++) {
					my $curmember = $facilitybookings[$i]->{$j};
					$slotcount++;
					if($curmember != $lastmember) {
						if($lastmember != -1) {
							#output data
							print $i."	".$memberstarts[$lastmember]->[0]."	".calcTimeStamp($date, $j-$slotcount)."	".$slotcount."\n";
						}
						$lastmember = $curmember;
						$slotcount = 0;
					}
					
				}
		
			}
		}

		#Have new members started on this date?  If so add them to our data structures
		while($memberstarts[$nextmember]->[1] =~ /$date/) {
			if($nextmember != 0) {
				#overall member activity rate
				my $memberusage = (rand()+0.5)/1.5;
				
				#generate member behaviour per activity.  We want them to be very
				#active for someand not very active for others, better imitating
				#human behaviour
				my @activities = ();
				for (my $i = 0; $i < $facilitycount; $i++) {
					#is the facility generally used by lots of different people, or a hard core?
					#modify by this members usage rate
					my $facilitygenerality = $facilities[$i]->{"generality"}*$memberusage;
					my %behaviour;
					#users current usage of the facility, and their final usage.  Each member
					#will progress linearly towards their end usage rate
					my $currentusage = biasedRandom($facilitygenerality, 100);
					$behaviour{"current"} = $currentusage;
					$behaviour{"end"} = $currentusage + 2*(int(rand($currentusage)-($currentusage/2)));
					push(@activities, \%behaviour);
				}
				$memberbehaviour{$nextmember} = \@activities;
			}
			$nextmember++;
		}


		my $daysremaining = $maxdays - $currenttotaldays;
		#generate array of member facility booking probabilities each day, update member behaviour
		for(my $i = 0; $i < $facilitycount; $i++) {
			my $facilitycurrent = $facilities[$i]->{"current"};
			my $facilityend = $facilities[$i]->{"end"};

			#update facility usage.  Can randomise!
			$facilitycurrent = $facilitycurrent + ($facilityend - $facilitycurrent)/$daysremaining;
			$facilities[$i]->{"current"} = $facilitycurrent;

			my @facilitybooking = ();
			$facilities[$i]->{"bookingprob"} = \@facilitybooking;
			for(my $j = 0; $j < $nextmember-1; $j++) {
				
				my $memberfaccurrent = $memberbehaviour{$j}->[$i]->{"current"};
				my $memberfacend = $memberbehaviour{$j}->[$i]->{"end"};
				$memberfaccurrent = $memberfaccurrent + (($memberfacend - $memberfaccurrent)/$daysremaining);
				$memberbehaviour{$j}->[$i]->{"current"} = $memberfaccurrent;

				#HACK ALERT:  We build an array with the member ID repeated
				#n times, where n is the likelihood of this member getting
				#picked to do a thing.  This is used to randomly select users
				#for an activity
				for(my $k = 0; $k < $memberfaccurrent; $k++) {
					push(@facilitybooking,$j);
				}
			}

		}
		$currenttotaldays++;

	}
}


#generate a random number, biased towards being high or low
sub biasedRandom {
	my $likelihoodOfInterest = $_[0];
	my $scale = $_[1];
	if (rand() < $likelihoodOfInterest) {
		return int(((rand()+2)/3)*$scale);
	} else {
		return int((rand()/6)*$scale);
	}
}

#convert half hour slots into time stamps
sub calcTimeStamp {
	my $date = $_[0];
	my $slot = $_[1];
	my $hour = $open + int($slot/2);
	my $minute = 0;
	if ($slot % 2 == 1) {
		$minute = 30;
	}
	return sprintf("$date %02d:%02d:00", $hour, $minute);
}
