|QUESTIONNAME|
Calculate the payback time for each facility
|QUESTION|
Based on the 3 complete months of data so far, calculate the amount of time each facility will take to repay its cost of ownership.  Remember to take into account ongoing monthly maintenance.  Output facility name and payback time in months, order by facility name.  Don't worry about differences in month lengths, we're only looking for a rough value here!
|QUERY|
select 	facs.name as name,
	facs.initialoutlay/((sum(case
			when memid = 0 then slots * facs.guestcost
			else slots * membercost
		end)/3) - facs.monthlymaintenance) as months
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.facid
order by name;
|ANSWER|
<p>In contrast to all our recent exercises, there's no need to use window functions to solve this problem: it's just a bit of maths involving monthly revenue, initial outlay, and monthly maintenance.  Again, for production code you might want to clarify what's going on a little here using a subquery (although since we've hard-coded the number of months, putting this into production is unlikely!).  A tidied-up version might look like:</p>

<sql>
select 	name, 
	initialoutlay / (monthlyrevenue - monthlymaintenance) as repaytime 
	from 
		(select facs.name as name, 
			facs.initialoutlay as initialoutlay,
			facs.monthlymaintenance as monthlymaintenance,
			sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end)/3 as monthlyrevenue
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.facid
	) as subq
order by name;
</sql>

<p>But, I hear you ask, what would an automatic version of this look like?  One that didn't need to have a hard-coded number of months in it?  That's a little more complicated, and involves some date arithmetic.  I've factored that out into a CTE to make it a little more clear.</p>

<sql>
with monthdata as (
	select 	mincompletemonth,
		maxcompletemonth,
		(extract(year from maxcompletemonth)*12) +
			extract(month from maxcompletemonth) -
			(extract(year from mincompletemonth)*12) -
			extract(month from mincompletemonth) as nummonths 
	from (
		select 	date_trunc('month', 
				(select max(starttime) from cd.bookings)) as maxcompletemonth,
			date_trunc('month', 
				(select min(starttime) from cd.bookings)) as mincompletemonth
	) as subq
)
select 	name, 
	initialoutlay / (monthlyrevenue - monthlymaintenance) as repaytime 
	
	from
		(select facs.name as name,
			facs.initialoutlay as initialoutlay,
			facs.monthlymaintenance as monthlymaintenance,
			sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end)/(select nummonths from monthdata) as monthlyrevenue
			
			from cd.bookings bks
			inner join cd.facilities facs
				on bks.facid = facs.facid
			where bks.starttime < (select maxcompletemonth from monthdata)
			group by facs.facid
		) as subq
order by name;
</sql>

<p>This code restricts the data that goes in to complete months.  It does this by selecting the maximum date, rounding down to the month, and stripping out all dates larger than that.  Even this code is not completely-complete.  It doesn't handle the case of a facility making a loss.  Fixing that is not too hard, and is left as (another) exercise for the reader!</p>

|HINT|
There's no need to use window functions to solve this problem.  Hard-code the number of months for an easy time, calculate them for a tougher one.
|SORTED|
1
|PAGEID|
185D4EC4-A501-4CB8-ABA3-04CD964A1CF6
|WRITEABLE|
0
