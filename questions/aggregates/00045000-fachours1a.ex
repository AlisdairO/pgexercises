|QUESTIONNAME|
List facilities with more than 1000 slots booked
|QUESTION|
Produce a list of facilities with more than 1000 slots booked.  Produce an output table consisting of facility id and slots, sorted by facility id.
|QUERY|
select facid, sum(slots) as "Total Slots"
        from cd.bookings
        group by facid
        having sum(slots) > 1000
        order by facid
|ANSWER|
<p>It turns out that there's actually an SQL keyword designed to help with the filtering of output from aggregate functions.  This keyword is <c>HAVING</c>.</p>

<p>The behaviour of <c>HAVING</c> is easily confused with that of <c>WHERE</c>.  The best way to think about it is that in the context of a query with an aggregate function, <c>WHERE</c> is used to filter what data gets input into the aggregate function, while <c>HAVING</c> is used to filter the data once it is output from the function. Try experimenting to explore this difference!</p>

|HINT|
Try investigating the <c>HAVING</c> clause.
|SORTED|
1
|PAGEID|
B3124FAB-CD6E-44DD-ACDB-3D5B9DE4AFFA
|WRITEABLE|
0
