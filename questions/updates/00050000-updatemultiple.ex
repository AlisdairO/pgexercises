|QUESTIONNAME|
Update multiple rows and columns at the same time
|QUESTION|
We want to increase the price of the tennis courts for both members and guests. Update the costs to be 6 for members, and 30 for guests.
|QUERY|
update cd.facilities
    set
        membercost = 6,
        guestcost = 30
    where facid in (0,1);
|ANSWER|
The <c>SET</c> clause accepts a comma separated list of values that you want to update.
|HINT|
The <c>SET</c> clause can update multiple columns.
|SORTED|
1
|PAGEID|
f0d7e446-0e04-41b3-b5c6-dcaa9c89645a
|WRITEABLE|
1
|RETURNTABLE|
cd.facilities
