|QUESTIONNAME|
Basic string searches
|QUESTION|
How can you produce a list of all facilities with the word 'Tennis' in their name?
|QUERY|
select *
	from cd.facilities 
	where 
		name like '%Tennis%'; 
|ANSWER|
<p>SQL's <c>LIKE</c> operator provides simple pattern matching on strings.  It's pretty much universally implemented, and is nice and simple to use - it just takes a string with the <c>%</c> character matching any string, and <c>_</c> matching any single character.  In this case, we're looking for names containing the word 'Tennis', so putting a % on either side fits the bill.</p>
<p>There's other ways to accomplish this task: Postgres supports regular expressions with the <c>~</c> operator, for example.  Use whatever makes you feel comfortable, but do be aware that the <c>LIKE</c> operator is much more portable between systems.</p>
|HINT|
Try looking up the SQL <c>LIKE</c> operator.
|SORTED|
0
|PAGEID|
8EF314B3-651C-481E-B3ED-17A8968411C4
|WRITEABLE|
0
