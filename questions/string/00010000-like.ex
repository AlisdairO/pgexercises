|QUESTIONNAME|
Find facilities by a name prefix
|QUESTION|
Find all facilities whose name begins with 'Tennis'.  Retrieve all columns.
|QUERY|
select * from cd.facilities where name like 'Tennis%';
|ANSWER|
<p>The SQL <c>LIKE</c> operator is a highly standard way of searching for a string using basic matching.  The <c>%</c> character matches any string, while <c>_</c> matches any single character.</p>
<p>One point that's worth considering when you use <c>LIKE</c> is how it uses indexes.  If you're using the 'C' <a href="http://www.postgresql.org/docs/current/static/locale.html">locale</a>, any <c>LIKE</c> string with a fixed beginning (as in our example here) can use an index.  If you're using any other locale, <c>LIKE</c> will not use any index by default.  See <a href="http://www.postgresql.org/docs/current/static/indexes-opclass.html">here</a> for details on how to change that.</p>
|HINT|
Use the <c>LIKE</c> operator.
|SORTED|
0
|PAGEID|
5a966edc-2b9a-11e3-ab9e-0023df7f7ec4
|WRITEABLE|
0
