|QUESTIONNAME|
Rank members by (rounded) hours used
|QUESTION|
Produce a list of members (including guests), along with the number of hours they've booked in facilities, rounded to the nearest ten hours.  Rank them by this rounded figure, producing output of first name, surname, rounded hours, rank.  Sort by rank, surname, and first name.
|QUERY|
select firstname, surname,
	((sum(bks.slots)+10)/20)*10 as hours,
	rank() over (order by ((sum(bks.slots)+10)/20)*10 desc) as rank

	from cd.bookings bks
	inner join cd.members mems
		on bks.memid = mems.memid
	group by mems.memid
order by rank, surname, firstname;
|ANSWER|
<p>This answer isn't a great stretch over our previous exercise, although it does illustrate the function of <c>RANK</c> better.  You can see that some of the clubgoers have an equal rounded number of hours booked in, and their rank is the same.  If position 2 is shared between two members, the next one along gets position 4.  There's a different function, <c>DENSE_RANK</c>, that would assign that member position 3 instead.</p>

<p>It's worth noting the technique we use to do rounding here.  Adding 5, dividing by 10, and multiplying by 10 has the effect (thanks to integer arithmetic cutting off fractions) of rounding a number to the nearest 10.  In our case, because slots are half an hour, we need to add 10, divide by 20, and multiply by 10.  One could certainly make the argument that we should do the slots -> hours conversion independently of the rounding, which would increase clarity.</p>

<p>Talking of clarity, this rounding malarky is starting to introduce a noticeable amount of code repetition.  At this point it's a judgement call, but you may wish to factor it out using a subquery as below:</p>

<sql>
select firstname, surname, hours, rank() over (order by hours desc) from
	(select firstname, surname,
		((sum(bks.slots)+10)/20)*10 as hours

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
