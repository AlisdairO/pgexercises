|QUESTIONNAME|
Subtract timestamps from each other
|QUESTION|
Find the result of subtracting the timestamp '2012-07-30 01:00:00' from the timestamp '2012-08-31 01:00:00'
|QUERY|
select timestamp '2012-08-31 01:00:00' - timestamp '2012-07-30 01:00:00' as interval;
|ANSWER|
<p>Subtracting timestamps produces an <c>INTERVAL</c> data type.  <c>INTERVAL</c>s are a special data type for representing the difference between two <c>TIMESTAMP</c> types.  When subtracting timestamps, Postgres will typically give an interval in terms of days, hours, minutes, seconds, without venturing into months.  This generally makes life easier, since months are of variable lengths.</p>

<p>One of the useful things about intervals, though, is the fact that they <i>can</i> encode months.  Let's imagine that I want to schedule something to occur in exactly one month's time, regardless of the length of my month.  To do this, I could use <c>[timestamp] + interval '1 month'</c>.</p>

<p>Intervals stand in contrast to SQL's treatment of <c>DATE</c> types.  Dates don't use intervals - instead, subtracting two dates will return an integer representing the number of days between the two dates.  You can also add integer values to dates.  This is sometimes more convenient, depending on how much intelligence you require in the handling of your dates!</o>
|HINT|
You can use the '-' symbol on timestamps
|SORTED|
0
|PAGEID|
6D111D5A-A6DD-408A-8634-8778EBCD7B5A
|WRITEABLE|
0
