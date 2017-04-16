|QUESTIONNAME|
Work out the number of seconds between timestamps
|QUESTION|
Work out the number of seconds between the timestamps '2012-08-31 01:00:00' and '2012-09-02 00:00:00'
|QUERY|
select extract(epoch from (timestamp '2012-09-02 00:00:00' - '2012-08-31 01:00:00'));
|ANSWER|
<p>The above answer is a Postgres-specific trick.  Extracting the epoch converts an interval or timestamp into a number of seconds, or the number of seconds since epoch (January 1st, 1970) respectively.  If you want the number of minutes, hours, etc you can just divide the number of seconds appropriately.</p>

<p>If you want to write more portable code, you will unfortunately find that you cannot use <c>extract epoch</c>.  Instead you will need to use something like:</p>

<sql>
select 	extract(day from ts.int)*60*60*24 +
	extract(hour from ts.int)*60*60 + 
	extract(minute from ts.int)*60 +
	extract(second from ts.int)
	from
		(select timestamp '2012-09-02 00:00:00' - '2012-08-31 01:00:00' as int) ts
</sql>

<p>This is, as you can observe, rather awful.  If you're planning to write cross platform SQL, I would consider having a library of common user defined functions for each DBMS, allowing you to normalise any common requirements like this.  This keeps your main codebase a lot cleaner.</p>
|HINT|
You can do this by extracting the epoch from the interval between two timestamps.
|SORTED|
0
|PAGEID|
91F9C895-3651-4ACF-936E-91635428EB6D
|WRITEABLE|
0
