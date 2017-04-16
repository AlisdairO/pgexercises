|QUESTIONNAME|
Pad zip codes with leading zeroes
|QUESTION|
The zip codes in our example dataset have had leading zeroes removed from them by virtue of being stored as a numeric type.  Retrieve all zip codes from the members table, padding any zip codes less than 5 characters long with leading zeroes.  Order by the new zip code.
|QUERY|
select lpad(cast(zipcode as char(5)),5,'0') zip from cd.members order by zip
|ANSWER|
<p>Postgres' <c>LPAD</c> function is the star of this particular show. It does basically what you'd expect: allow us to produce a padded string.  We need to remember to cast the zipcode to a string for it to be accepted by the <c>LPAD</c> function.</p>
<p>When inheriting an old database, It's not that unusual to find wonky decisions having been made over data types.  You may wish to fix mistakes like these, but have a lot of code that would break if you changed datatypes.  In that case, one option (depending on performance requirements) is to create a <a href="http://www.postgresql.org/docs/current/static/sql-createview.html">view</a> over your table which presents the data in a fixed-up manner, and gradually migrate.</p>
|HINT|
Check out the <c>LPAD</c> function.  You'll also need to cast the zipcode column to a character string.
|SORTED|
0
|PAGEID|
0483f866-2b9f-11e3-8908-0023df7f7ec4
|WRITEABLE|
0
