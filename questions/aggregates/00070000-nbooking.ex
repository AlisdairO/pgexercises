|QUESTIONNAME|
List each member's first booking after September 1st 2012
|QUESTION|
Produce a list of each member name, id, and their first booking after September 1st 2012.  Order by member ID.
|QUERY|
select mems.surname, mems.firstname, mems.memid, min(bks.starttime) as starttime
	from cd.bookings bks
	inner join cd.members mems on
		mems.memid = bks.memid
	where starttime >= '2012-09-01'
	group by mems.surname, mems.firstname, mems.memid
order by mems.memid;
|ANSWER|
<p>This answer demonstrates the use of aggregate functions on dates.  <c>MIN</c> works exactly as you'd expect, pulling out the lowest possible date in the result set.  To make this work, we need to ensure that the result set only contains dates from September onwards.  We do this using the <c>WHERE</c> clause.</p>

<p>You might typically use a query like this to find a customer's next booking.  You can use this by replacing the date '2012-09-01' with the function <c>now()</c></p>
|HINT|
Take a look at the <c>MIN</c> aggregate function
|SORTED|
1
|PAGEID|
CF73B932-CE2E-4FE4-AA8E-D00976DFC45B
|WRITEABLE|
0
