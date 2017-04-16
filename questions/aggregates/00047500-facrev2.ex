|QUESTIONNAME|
Find facilities with a total revenue less than 1000
|QUESTION|
Produce a list of facilities with a total revenue less than 1000.  Produce an output table consisting of facility name and revenue, sorted by revenue.  Remember that there's a different cost for guests and members!
|QUERY|
select name, revenue from (
	select facs.name, sum(case 
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) as revenue
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as agg where revenue < 1000
order by revenue;
|ANSWER|
<p>You may well have tried to use the <c>HAVING</c> keyword we introduced in an earlier exercise, producing something like below:</p>

<sql>
select facs.name, sum(case 
		when memid = 0 then slots * facs.guestcost
		else slots * membercost
	end) as revenue
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.name
	having revenue < 1000
order by revenue;
</sql>

<p>Unfortunately, this doesn't work!  You'll get an error along the lines of <c>ERROR: column "revenue" does not exist</c>.  Postgres, unlike some other RDBMSs like SQL Server and MySQL, doesn't support putting column names in the <c>HAVING</c> clause.  This means that for this query to work, you'd have to produce something like below:</p>

<sql>
select facs.name, sum(case 
		when memid = 0 then slots * facs.guestcost
		else slots * membercost
	end) as revenue
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.name
	having sum(case 
		when memid = 0 then slots * facs.guestcost
		else slots * membercost
	end) < 1000
order by revenue;
</sql>

<p>Having to repeat significant calculation code like this is messy, so our anointed solution instead just wraps the main query body as a subquery, and selects from it using a <c>WHERE</c> clause.  In general, I recommend using <c>HAVING</c> for simple queries, as it increases clarity.  Otherwise, this subquery approach is often easier to use.</p>
|HINT|
You may find <c>HAVING</c> difficult to use here.  Try a subquery instead.  You'll probably also need a <c>CASE</c> statement.
|SORTED|
1
|PAGEID|
FD4B1491-C3D6-4E46-90B0-1B6CB861C505
|WRITEABLE|
0
