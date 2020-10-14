|QUESTIONNAME|
Produce a numbered list of members
|QUESTION|
Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining.  Remember that member IDs are not guaranteed to be sequential.
|QUERY|
select row_number() over(order by joindate), firstname, surname
	from cd.members
order by joindate
|ANSWER|
<p>This exercise is a simple bit of window function practise!  You could just as easily use <c>count(*) over(order by joindate)</c> here, so don't worry if you used that instead.</p>
<p>In this query, we don't define a partition, meaning that the partition is the entire dataset.  Since we define an order for the window function, for any given row the window is: start of the dataset -> current row.</p>
|HINT|
Read up on the <c>ROW_NUMBER</c> window function.
|SORTED|
1
|PAGEID|
09229A41-91FA-4D34-BF5D-6380F7E27AF1
|WRITEABLE|
0
