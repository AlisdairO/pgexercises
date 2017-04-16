|QUESTIONNAME|
List the total slots booked per facility
|QUESTION|
Produce a list of the total number of slots booked per facility.  For now, just produce an output table consisting of facility id and slots, sorted by facility id.
|QUERY|
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	group by facid
order by facid;
|ANSWER|
<p>Other than the fact that we've introduced the <c>SUM</c> aggregate function, there's not a great deal to say about this exercise.  For each distinct facility id, the <c>SUM</c> function adds together everything in the slots column.  
|HINT|
For this one you'll need to check out the <c>SUM</c> aggregate function.
|SORTED|
1
|PAGEID|
2049E915-DDB0-4E1E-BEB1-37731FA22C3A
|WRITEABLE|
0
