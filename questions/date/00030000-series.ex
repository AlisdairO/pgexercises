|QUESTIONNAME|
Generate a list of all the dates in October 2012
|QUESTION|
Produce a list of all the dates in October 2012.  They can be output as a timestamp (with time set to midnight) or a date.
|QUERY|
select generate_series(timestamp '2012-10-01', timestamp '2012-10-31', interval '1 day') as ts;
|ANSWER|
<p>One of the best features of Postgres over other DBs is a simple function called <c>GENERATE_SERIES</c>.  This function allows you to generate a list of dates or numbers, specifying a start, an end, and an increment value.  It's extremely useful for situations where you want to output, say, sales per day over the course of a month.  A typical way to do that on a table containing a list of sales might be to use a <c>SUM</c> aggregation, grouping by the date and product type.  Unfortunately, this approach has a flaw: if there are no sales for a given day, it won't show up!  To make it work properly, you need to left join from a sequential list of timestamps to the aggregated data to fill in the blank spaces.</p>

<p>On other database systems, it's not uncommon to keep a 'calendar table' full of dates, with which you can perform these joins.  Alternatively, on some systems you can write an analogue to generate_series using recursive CTEs.  Fortunately for us, Postgres makes our lives a lot easier!</p>
|HINT|
Take a look at Postgres' <c>GENERATE_SERIES</c> function
|SORTED|
0
|PAGEID|
65DF6CDB-3FA3-489D-8269-4D418BA306DA
|WRITEABLE|
0
