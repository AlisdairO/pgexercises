|QUESTIONNAME|
Rank members by (rounded) hours used
|QUESTION|
Produce a list of members (including guests), along with the number of hours they've booked in facilities, rounded to the nearest ten hours.  Rank them by this rounded figure, producing output of first name, surname, rounded hours, rank.  Sort by rank, surname, and first name.
|QUERY|
select firstname, surname,
	round(sum(bks.slots) / 2, -1) as hours,
	rank() over (order by round(sum(bks.slots) / 2, -1) desc) as rank

	from cd.bookings bks
	inner join cd.members mems
		on bks.memid = mems.memid
	group by mems.memid
order by rank, surname, firstname;
|ANSWER|
<p>This answer isn't a great stretch over our previous exercise, although it does illustrate the function of <c>RANK</c> better.  You can see that some of the clubgoers have an equal rounded number of hours booked in, and their rank is the same.  If position 2 is shared between two members, the next one along gets position 4.  There's a different function, <c>DENSE_RANK</c>, that would assign that member position 3 instead.</p>

<p>It's worth noting the technique we use to do rounding here.  The <c>ROUND</c> function's second parameter is an integer that determines the number of decimal places after rounding. This way, specifying -1 works exactly as we expect: rounds to the nearest 10.</p>

<p>Talking of clarity, we can reduce the amount of code repetition.  At this point it's a judgement call, but you may wish to factor it out using a subquery as below:</p>

<sql>
select firstname, surname, hours, rank() over (order by hours desc) from
	(select firstname, surname,
		round(sum(bks.slots) / 2, -1) as hours

		from cd.bookings bks
		inner join cd.members mems
			on bks.memid = mems.memid
		group by mems.memid
	) as subq
order by rank, surname, firstname;
</sql>

|HINT|
You'll need the <c>RANK</c> window function again.  You can use integer arithmetic to accomplish rounding.
|SORTED|
1
|PAGEID|
8E69FABF-A485-48B5-AF08-0B6A0524FC3C
|WRITEABLE|
0
