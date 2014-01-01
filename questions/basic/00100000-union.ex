|QUESTIONNAME|
Combining results from multiple queries
|QUESTION|
You, for some reason, want a combined list of all surnames and all facility names.  Yes, this is a contrived example :-).  Produce that list!
|QUERY|
select distinct surname 
	from cd.members
union all
select distinct name
	from cd.facilities;
|ANSWER|
<p>The <c>UNION</c> operator does what you might expect: combines two tables into one.  The caveat is that both tables must have the same number of columns and compatible data types.
<p><c>UNION</c> removes duplicate rows, while <c>UNION ALL</c> does not.  Use <c>UNION ALL</c> by default, unless you care about duplicate results.
|HINT|
Look up the SQL keyword <c>UNION</c>
|SORTED|
0
|PAGEID|
D1382ED0-D0C9-4D55-8998-B1090D128368
