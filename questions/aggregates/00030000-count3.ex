|QUESTIONNAME|
Count the number of recommendations each member makes.
|QUESTION|
Produce a count of the number of recommendations each member has made.  Order by member ID.
|QUERY|
select recommendedby, count(*) 
	from cd.members
	where recommendedby is not null
	group by recommendedby
order by recommendedby;
|ANSWER|
<p>Previously, we've seen that aggregation functions are applied to a column of values, and convert them into an aggregated scalar value.  This is useful, but we often find that we don't want just a single aggregated result: for example, instead of knowing the total amount of money the club has made this month, I might want to know how much money each different facility has made, or which times of day were most lucrative.</p>

<p>In order to support this kind of behaviour, SQL has the <c>GROUP BY</c> construct.  What this does is batch the data together into groups, and run the aggregation function separately for each group.  When you specify a <c>GROUP BY</c>, the database produces an aggregated value for each distinct value in the supplied columns.  In this case, we're saying 'for each distinct value of recommendedby, get me the number of times that value appears'.</p>

|HINT|
Try investigating <c>GROUP BY</c> with your count this time.  Don't forget to filter out null recommenders!
|SORTED|
1
|PAGEID|
494C7BF9-F6D0-464F-A8A4-9C6814C6FF4A
|WRITEABLE|
0
