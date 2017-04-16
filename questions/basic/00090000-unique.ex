|QUESTIONNAME|
Removing duplicates, and ordering results
|QUESTION|
How can you produce an ordered list of the first 10 surnames in the members table?  The list must not contain duplicates.
|QUERY|
select distinct surname 
	from cd.members
order by surname
limit 10;
|ANSWER|
<p>There's three new concepts here, but they're all pretty simple. 
<ul><li>Specifying <c>DISTINCT</c> after <c>SELECT</c> removes duplicate rows from the result set.  Note that this applies to <i>rows</i>: if row A has multiple columns, row B is only equal to it if the values in all columns are the same.  As a general rule, don't use <c>DISTINCT</c> in a willy-nilly fashion - it's not free to remove duplicates from large query result sets, so do it as-needed.
<li>Specifying <c>ORDER BY</c> (after the <c>FROM</c> and <c>WHERE</c> clauses, near the end of the query) allows results to be ordered by a column or set of columns (comma separated).
<li>The <c>LIMIT</c> keyword allows you to limit the number of results retrieved.  This is useful for getting results a page at a time, and can be combined with the <c>OFFSET</c> keyword to get following pages.  This is the same approach used by MySQL and is very convenient - you may, unfortunately, find that this process is a little more complicated in other DBs.
</ul>
|HINT|
Look up the SQL keywords <c>DISTINCT</c>, <c>ORDER BY</c>, and <c>LIMIT</c>.
|SORTED|
1
|PAGEID|
DA27B853-5E1A-441F-8EE0-211CE617F003
|WRITEABLE|
0
