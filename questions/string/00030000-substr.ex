|QUESTIONNAME|
Count the number of members whose surname starts with each letter of the alphabet
|QUESTION|
You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet.  Sort by the letter, and don't worry about printing out a letter if the count is 0.
|QUERY|
select substr (mems.surname,1,1) as letter, count(*) as count 
    from cd.members mems
    group by letter
    order by letter
|ANSWER|
<p>This exercise is fairly straightforward.  You simply need to retrieve the first letter of the member's surname, and do some basic aggregation to achieve a count.  We use the <c>SUBSTR</c> function here, but there's a variety of other ways you can achieve the same thing.  The <c>LEFT</c> function, for example, returns you the first n characters from the left of the string.  Alternatively, you could use the <c>SUBSTRING</c> function, which allows you to use regular expressions to extract a portion of the string.</p>
<p>One point worth noting: as you can see, string functions in SQL are based on 1-indexing, not the 0-indexing that you're probably used to.  This will likely trip you up once or twice before you get used to it :-)</p>
|HINT|
You'll need the <c>SUBSTR</c> function here, combined with some aggregation.
|SORTED|
1
|PAGEID|
eeac2498-12a5-11e4-8bf7-537359e34291
|WRITEABLE|
0
