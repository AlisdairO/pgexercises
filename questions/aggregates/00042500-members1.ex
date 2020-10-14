|QUESTIONNAME|
Find the count of members who have made at least one booking
|QUESTION|
Find the total number of members (including guests) who have made at least one booking.
|QUERY|
select count(distinct memid) from cd.bookings
|ANSWER|
<p>Your first instinct may be to go for a subquery here.  Something like the below:</p>

<sql>
select count(*) from 
	(select distinct memid from cd.bookings) as mems</sql>

<p>This does work perfectly well, but we can simplify a touch with the help of a little extra knowledge in the form of <c>COUNT DISTINCT</c>.  This does what you might expect, counting the distinct values in the passed column.</p>

|HINT|
Take a look at <c>COUNT DISTINCT</c>
|SORTED|
0
|PAGEID|
54410370-8C3A-4A1D-ADF7-1CFFE8810C28
|WRITEABLE|
0
