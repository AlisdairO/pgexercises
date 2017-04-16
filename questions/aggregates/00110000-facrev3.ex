|QUESTIONNAME|
Find the top three revenue generating facilities
|QUESTION|
Produce a list of the top three revenue generating facilities (including ties).  Output facility name and rank, sorted by rank and facility name. 
|QUERY|
select name, rank from (
	select facs.name as name, rank() over (order by sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) desc) as rank
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as subq
	where rank <= 3
order by rank;
|ANSWER|
<p>This question doesn't introduce any new concepts, and is just intended to give you the opportunity to practise what you already know.  We use the <c>CASE</c> statement to calculate the revenue for each slot, and aggregate that on a per-facility basis using <c>SUM</c>.  We then use the <c>RANK</c> window function to produce a ranking, wrap it all up in a subquery, and extract everything with a rank less than or equal to 3.</p>
|HINT|
Yet another question based on the <c>RANK</c> window function!  Remember the relative complexity of calculating the revenue of a facility, since you need to count for the different costs for the GUEST user..
|SORTED|
1
|PAGEID|
487D2223-28C4-4DB9-8DCD-F5E31490782D
|WRITEABLE|
0
