|QUESTIONNAME|
Working with dates
|QUESTION|
How can you produce a list of members who joined after the start of September 2012?
Return the memid, surname, firstname, and joindate of the members in question. 
|QUERY|
select memid, surname, firstname, joindate 
	from cd.members
	where joindate >= '2012-09-01';
|ANSWER|
This is our first look at SQL timestamps.  They're formatted in descending order of magnitude: <c>YYYY-MM-DD HH:MM:SS.nnnnnn</c>.  We can compare them just like we might a unix timestamp, although getting the differences between dates is a little more involved (and powerful!).  In this case, we've just specified the date portion of the timestamp.  This gets automatically cast by postgres into the full timestamp <c>2012-09-01 00:00:00</c>.
|HINT|
Look up the SQL timestamp format, and remember that you can compare dates much like you would integer values.
|SORTED|
0
|PAGEID|
36AF8D4D-2F2B-4FE4-B335-6B72A115A1D8
|WRITEABLE|
0
