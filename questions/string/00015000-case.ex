|QUESTIONNAME|
Perform a case-insensitive search
|QUESTION|
Perform a case-insensitive search to find all facilities whose name begins with 'tennis'.  Retrieve all columns.
|QUERY|
select * from cd.facilities where upper(name) like 'TENNIS%';
|ANSWER|
<p>There's no direct operator for case-insensitive comparison in standard SQL.  Fortunately, we can take a page from many other language's books, and simply force all values into upper case when we do our comparison.  This renders case irrelevant, and gives us our result.</p>

<p>Alternatively, Postgres does provide the <c>ILIKE</c> operator, which performs case insensitive searches.  This isn't standard SQL, but it's arguably more clear.</p>

<p>You should realise that running a function like <c>UPPER</c> over a column value prevents Postgres from making use of any indexes on the column (the same is true for <c>ILIKE</c>).  Fortunately, Postgres has got your back: rather than simply creating indexes over columns, you can also create indexes over <a href="http://www.postgresql.org/docs/current/static/indexes-expressional.html">expressions</a>.  If you created an index over <c>UPPER(name)</c>, this query could use it quite happily.</p>
|HINT|
Use the <c>UPPER</c> function or the <c>ILIKE</c> operator.
|SORTED|
0
|PAGEID|
9e7b8f08-2ba2-11e3-a5aa-0023df7f7ec4
|WRITEABLE|
0
