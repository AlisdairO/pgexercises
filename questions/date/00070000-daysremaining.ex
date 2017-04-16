|QUESTIONNAME|
Work out the number of days remaining in the month
|QUESTION|
For any given timestamp, work out the number of days remaining in the month.  The current day should count as a whole day, regardless of the time.  Use '2012-02-11 01:00:00' as an example timestamp for the purposes of making the answer.  Format the output as a single interval value.
|QUERY|
select (date_trunc('month',ts.testts) + interval '1 month') 
		- date_trunc('day', ts.testts) as remaining
	from (select timestamp '2012-02-11 01:00:00' as testts) ts
|ANSWER|
<p>The star of this particular show is the <c>DATE_TRUNC</c> function.  It does pretty much what you'd expect - truncates a date to a given minute, hour, day, month, and so on.  The way we've solved this problem is to truncate our timestamp to find the month we're in, add a month to that, and subtract our timestamp.  To ensure partial days get treated as whole days, the timestamp we subtract is truncated to the nearest day.</p>

<p>Note the way we've put the timestamp into a subquery.  This isn't required, but it does mean you can give the timestamp a name, rather than having to list the literal repeatedly.</p>
|HINT|
Take a look at the <c>DATE_TRUNC</c> function
|SORTED|
1
|PAGEID|
5CFRB62B-4C60-4D87-B99C-92610B44136F
|WRITEABLE|
0
