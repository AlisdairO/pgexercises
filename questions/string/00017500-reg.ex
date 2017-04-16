|QUESTIONNAME|
Find telephone numbers with parentheses
|QUESTION|
You've noticed that the club's member table has telephone numbers with very inconsistent formatting.  You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.
|QUERY|
select memid, telephone from cd.members where telephone ~ '[()]';
|ANSWER|
We've chosen to answer this using regular expressions, although Postgres does provide other string functions like <c>POSITION</c> that would do the job at least as well.  Postgres implements POSIX regular expression matching via the <c>~</c> operator. If you've used regular expressions before, the functionality of the operator will be very familiar to you.</p>

<p>As an alternative, you can use the SQL standard <c>SIMILAR TO</c> operator.  The regular expressions for this have similarities to the POSIX standard, but a lot of differences as well. Some of the most notable differences are:</p>

<ul>
<li>As in the <c>LIKE</c> operator, <c>SIMILAR TO</c> uses the '_' character to mean 'any character', and the '%' character to mean 'any string'.
<li>A <c>SIMILAR TO</c> expression must match the whole string, not just a substring as in posix regular expressions.  This means that you'll typically end up bracketing an expression in '%' characters.
<li>The '.' character does not mean 'any character' in <c>SIMILAR TO</c> regexes: it's just a plain character.
</ul>

<p>The <c>SIMILAR TO</c> equivalent of the given answer is shown below:</p>

<sql>select memid, telephone from cd.members where telephone similar to '%[()]%';</sql>

<p>Finally, it's worth noting that regular expressions usually don't use indexes.  Generally you don't want your regex to be responsible for doing heavy lifting in your query, because it will be slow.  If you need fuzzy matching that works fast, consider working out if your needs can be met by <a href="http://www.postgresql.org/docs/current/static/textsearch.html">full text search</a>.</p>

|HINT|
Look up the ~ or <c>SIMILAR TO</c> operators in the Postgres docs.
|SORTED|
1
|PAGEID|
9df31ff6-3f20-11e3-8372-0023df7f7ec4
|WRITEABLE|
0
