|QUESTIONNAME|
Matching against multiple possible values
|QUESTION|
How can you retrieve the details of facilities with ID 1 and 5?  Try to do it without using the <c>OR</c> operator.
|QUERY|
select *
	from cd.facilities 
	where 
		facid in (1,5);
|ANSWER|
<p>The obvious answer to this question is to use a <c>WHERE</c> clause that looks like <c>where facid = 1 or facid = 5</c>.  An alternative that is easier with large numbers of possible matches is the <c>IN</c> operator.  The <c>IN</c> operator takes a list of possible values, and matches them against (in this case) the facid. If one of the values matches, the where clause is true for that row, and the row is returned.
<p>The <c>IN</c> operator is a good early demonstrator of the elegance of the relational model.  The argument it takes is not just a list of values - it's actually a table with a single column.  Since queries also return tables, if you create a query that returns a single column, you can feed those results into an <c>IN</c> operator.  To give a toy example:
<sql>
select * 
	from cd.facilities
	where
		facid in (
			select facid from cd.facilities
			);
</sql>

This example is functionally equivalent to just selecting all the facilities, but shows you how to feed the results of one query into another.  The inner query is called a <i>subquery</i>.
|HINT|
Try looking up the SQL <c>IN</c> operator.
|SORTED|
0
|PAGEID|
4BFEFCED-9F88-4D90-BB1E-45DFCB960F25
|WRITEABLE|
0
