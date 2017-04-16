|QUESTIONNAME|
Work out the number of days in each month of 2012
|QUESTION|
For each month of the year in 2012, output the number of days in that month.  Format the output as an integer column containing the month of the year, and a second column containing an interval data type.
|QUERY|
select 	extract(month from cal.month) as month,
	(cal.month + interval '1 month') - cal.month as length
	from
	(
		select generate_series(timestamp '2012-01-01', timestamp '2012-12-01', interval '1 month') as month
	) cal
order by month;
|ANSWER|
<p>This answer shows several of the concepts we've learned.  We use the <c>GENERATE_SERIES</c> function to produce a year's worth of timestamps, incrementing a month at a time.  We then use the <c>EXTRACT</c> function to get the month number.  Finally, we subtract each timestamp + 1 month from itself.</p>

<p>It's worth noting that subtracting two timestamps will always produce an interval in terms of days (or portions of a day).  You won't just get an answer in terms of months or years, because the length of those time periods is variable.</p>
|HINT|
Subtracting two timestamps will give you the interval you're looking for.  You can use the <c>EXTRACT</c> function to get the month from a timestamp.
|SORTED|
0
|PAGEID|
DA480CB7-CA03-4E37-833F-65A4DB72B181
|WRITEABLE|
0
