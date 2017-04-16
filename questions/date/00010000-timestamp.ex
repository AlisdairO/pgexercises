|QUESTIONNAME|
Produce a timestamp for 1 a.m. on the 31st of August 2012
|QUESTION|
Produce a timestamp for 1 a.m. on the 31st of August 2012.
|QUERY|
select timestamp '2012-08-31 01:00:00';
|ANSWER|
<p>Here's a pretty easy question to start off with!  SQL has a bunch of different date and time types, which you can peruse at your leisure over at the excellent <a href="http://www.postgresql.org/docs/current/static/datatype-datetime.html">Postgres documentation</a>.  These basically allow you to store dates, times, or timestamps (date+time).</p>

<p>The approved answer is the best way to create a timestamp under normal circumstances.  You can also use casts to change a correctly formatted string into a timestamp, for example:</p>

<sql>
select '2012-08-31 01:00:00'::timestamp;
select cast('2012-08-31 01:00:00' as timestamp);
</sql>

<p>The former approach is a Postgres extension, while the latter is SQL-standard.  You'll note that in many of our earlier questions, we've used bare strings without specifying a data type.  This works because when Postgres is working with a value coming out of a timestamp column of a table (say), it knows to cast our strings to timestamps.</p>

<p>Timestamps can be stored with or without time zone information.  We've chosen not to here, but if you like you could format the timestamp like "2012-08-31 01:00:00 +00:00", assuming UTC.  Note that timestamp with time zone is a different type to timestamp - when you're declaring it, you should use <c>TIMESTAMP WITH TIME ZONE 2012-08-31 01:00:00 +00:00</c>.</p>

<p>Finally, have a bit of a play around with some of the different date/time serialisations described in the Postgres docs.  You'll find that Postgres is extremely flexible with the formats it accepts, although my recommendation to you would be to use the standard serialisation we've used here - you'll find it unambiguous and easy to port to other DBs.</p>
|HINT|
There's a bunch of ways to do this, but the easiest is probably to look at the <c>TIMESTAMP</c> keyword.
|SORTED|
0
|PAGEID|
4FBCBF61-D92D-460B-91EF-F295390794C0
|WRITEABLE|
0
