|QUESTIONNAME|
Clean up telephone numbers
|QUESTION|
The telephone numbers in the database are very inconsistently formatted.  You'd like to print a list of member ids and numbers that have had '-','(',')', and ' ' characters removed.  Order by member id.
|QUERY|
select memid, translate(telephone, '-() ', '') as telephone
    from cd.members
    order by memid;
|ANSWER|
<p>The most direct solution is probably the <c>TRANSLATE</c> function, which can be used to replace characters in a string.  You pass it three strings: the value you want altered, the characters to replace, and the characters you want them replaced with.  In our case, we want all the characters deleted, so our third parameter is an empty string.</p>
<p>As is often the way with strings, we can also use regular expressions to solve our problem.  The <c>REGEXP_REPLACE</c> function provides what we're looking for: we simply pass a regex that matches all non-digit characters, and replace them with nothing, as shown below.  The 'g' flag tells the function to replace as many instances of the pattern as it can find.  This solution is perhaps more robust, as it cleans out more bad formatting.</p>
<sql>
select memid, regexp_replace(telephone, '[^0-9]', '', 'g') as telephone
    from cd.members
    order by memid;
</sql>
<p>Making automated use of free-formatted text data can be a chore.  Ideally you want to avoid having to constantly write code to clean up the data before using it, so you should consider having your database enforce correct formatting for you. You can do this using a <a href="http://www.postgresql.org/docs/current/static/ddl-constraints.html"><c>CHECK</c></a> constraint on your column, which allow you to reject any poorly-formatted entry.  It's tempting to perform this kind of validation in the application layer, and this is certainly a valid approach.  As a general rule, if your database is getting used by multiple applications, favour pushing more of your checks down into the database to ensure consistent behaviour between the apps.</p>
<p>Occasionally, adding a constraint isn't feasible.  You may, for example, have two different legacy applications asserting differently formatted information.  If you're unable to alter the applications, you have a couple of options to consider.  Firstly, you can define a <a href="http://www.postgresql.org/docs/current/static/sql-createtrigger.html">trigger</a> on your table.  This allows you to intercept data before (or after) it gets asserted to your table, and normalise it into a single format.  Alternatively, you could build a <a href="http://www.postgresql.org/docs/current/static/sql-createview.html">view</a> over your table that cleans up information on the fly, as it's read out.  Newer applications can read from the view and benefit from more reliably formatted information.</p>
<p></p>
|HINT|
Consider the <c>TRANSLATE</c> or <c>REGEXP_REPLACE</c> functions.
|SORTED|
1
|PAGEID|
87cecbca-14fa-11e4-a0c7-8b4e1f3cc8a8
|WRITEABLE|
0
