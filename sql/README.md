
# Introduction
This project is a hands-on SQL and RDBMS learning exercise focused on database design and query writing rather than application development. Based on a provided ERD, the relational database schema was implemented by writing SQL DDL statements to create the members, bookings, and facilities tables with appropriate primary and foreign key relationships. SQL queries were written to extract meaningful insights from the data, including joins, aggregations, filtering, and window functions. The project is intended for students and early-career data professionals preparing for data analyst or data engineer roles and demonstrates a solid understanding of relational data modeling, SQL querying, and structured problem solving. Version control using Git and GitHub was applied to organize and track changes to the project files.

# SQL Queries

###### Table Setup (DDL)

###### Creating Members Table

```sql
CREATE TABLE cd.members (
  memid INT PRIMARY KEY, 
  surname VARCHAR(200), 
  firstname VARCHAR(200), 
  address VARCHAR(300), 
  zipcode INT, 
  telephone VARCHAR(20), 
  recommendedby INT, 
  joindate TIMESTAMP, 
  CONSTRAINT members_pk PRIMARY KEY (memid), 
  CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby) REFERENCES cd.members(memid)
);
```
###### Creating Bookings Table
```sql
CREATE TABLE cd.bookings (
  bookid integer NOT NULL, 
  facid integer NOT NULL, 
  memid integer NOT NULL, 
  starttime timestamp NOT NULL, 
  slots integer NOT NULL, 
  CONSTRAINT bookings_pk PRIMARY KEY (bookid), 
  CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid), 
  CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
);
```
###### Creating Facilities Table
```sql
CREATE TABLE cd.facilities (
  facid integer NOT NULL, 
  name VARCHAR(100) NOT NULL, 
  membercost numeric NOT NULL, 
  guestcost numeric NOT NULL, 
  initialoutlay numeric NOT NULL, 
  monthlymaintenance numeric NOT NULL, 
  CONSTRAINT facilities_pk PRIMARY KEY (facid)
);
```
###### Question 1: The club is adding a new facility - a spa. Add it into the facilities table. Use the following values: facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
``` sql
INSERT INTO cd.facilities (
  facid, name, membercost, guestcost, 
  initialoutlay, monthlymaintenance
) 
VALUES 
  (9, 'Spa', 20, 30, 100000, 800);
```
###### Question 2: Automatically add the value for the next facid, rather than specifying it as a constant. Use the following values for everything else: 
	Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
```SQL
INSERT INTO cd.facilities (
  facid, name, membercost, guestcost, 
  initialoutlay, monthlymaintenance
) 
VALUES 
  (
    (
      SELECT 
        MAX(facid) + 1 
      FROM 
        cd.facilities
    ), 
    'Spa', 
    20, 
    30, 
    100000, 
    800
  );
```
###### Question 3: Update the initial outlay of the second tennis court to 10000 rather than 8000.
``` sql
UPDATE cd.facilities 
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';
```
###### Question 4: We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
```sql
UPDATE 
  cd.facilities 
SET 
  membercost = (
    SELECT 
      membercost * 1.1 
    FROM 
      cd.facilities 
    WHERE 
      name = 'Tennis Court 1'
  ), 
  guestcost = (
    SELECT 
      guestcost * 1.1 
    FROM 
      cd.facilities 
    WHERE 
      name = 'Tennis Court 1'
  ) 
WHERE 
  name = 'Tennis Court 2';
```
###### Question 5: Delete all bookings from the cd.bookings table. 
``` sql
DELETE 
FROM cd.bookings;
```
###### Question 6: Remove member 37, who has never made a booking, from our database. 
``` sql
DELETE 
FROM cd.members
WHERE memid = 37;
```
###### Question 7: Produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
```sql
SELECT 
  facid, 
  name, 
  membercost, 
  monthlymaintenance 
FROM 
  cd.facilities 
WHERE 
  membercost > 0 
  AND membercost < (1 / 50.0)* monthlymaintenance;
```
###### Question 8: Produce a list of all facilities with the word 'Tennis' in their name?
```sql
SELECT *
FROM cd.facilities
WHERE name like '%Tennis%';
```
###### Question 9: Retrieve the details of facilities with ID 1 and 5? 
```sql
SELECT *
FROM cd.facilities
WHERE facid in (1,5) ;
```
###### Question 10: Produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.
```sql
SELECT 
  memid, 
  surname, 
  firstname, 
  joindate 
FROM 
  cd.members 
WHERE 
  joindate >= '2012-09-01';
```
###### Question 11: A combined list of all surnames and all facility names.
```sql
SELECT 
  surname 
FROM 
  cd.members 
UNION 
  (
    SELECT 
      name 
    FROM 
      cd.facilities
  );
```
###### Question 12:  How can you produce a list of the start times for bookings by members named 'David Farrell'?
```sql
SELECT 
  starttime 
FROM 
  cd.bookings 
  INNER JOIN cd.members ON cd.bookings.memid = cd.members.memid 
WHERE 
  cd.members.surname = 'Farrell' 
  AND cd.members.firstname = 'David';
```
###### Question 13: How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
``` sql
SELECT 
  cd.bookings.starttime AS start, 
  cd.facilities.name 
FROM 
  cd.bookings 
  INNER JOIN cd.facilities ON cd.bookings.facid = cd.facilities.facid 
WHERE 
  cd.bookings.starttime >= '2012-09-21%' 
  and cd.bookings.starttime < '2012-09-22%' 
  and cd.facilities.name in (
    'Tennis Court 1', 'Tennis Court 2'
  );
```
###### Question 14: Produce a list of all members, along with their recommender
``` sql
SELECT 
  m.firstname as memfname, 
  m.surname as memsname, 
  r.firstname as recfname, 
  r.surname as recsname 
FROM 
  cd.members m 
  LEFT OUTER JOIN cd.members r on r.memid = m.recommendedby 
ORDER BY 
  memsname, 
  memfname;
```
###### Question 15: Produce a list of all members who have recommended another member
```sql
SELECT 
  DISTINCT r.firstname, 
  r.surname 
FROM 
  cd.members m 
  INNER JOIN cd.members r on r.memid = m.recommendedby 
ORDER BY
  surname, 
  firstname;
```

###### Question 16: Produce a list of all members, along with their recommender, using no joins.
```sql
SELECT 
  DISTINCT m.firstname || ' ' || m.surname as member, 
  (
    SELECT 
      r.firstname || ' ' || r.surname as recommender 
    FROM 
      cd.members r 
    WHERE 
      r.memid = m.recommendedby
  ) 
FROM 
  cd.members m 
ORDER BY 
  member;
```

###### Question 17: Format the names of members
```sql
SELECT surname || ', ' || firstname as name 
FROM cd.members;
```

###### Question 18: Find telephone numbers with parentheses
```sql
SELECT memid, telephone
FROM cd.members
WHERE telephone like '%(%';
```
###### Question 19: Count the number of members whose surname starts with each letter of the alphabet
```sql
SELECT 
  substr (cd.members.surname, 1, 1) as letter, 
  count(*) as count 
FROM 
  cd.members 
GROUP BY 
  letter 
ORDER BY 
  letter;
```
###### Question 20: Produce a count of the number of recommendations each member has made. Order by member ID.
```sql
SELECT 
  recommendedby, 
  count(*) 
FROM 
  cd.members 
WHERE 
  recommendedby IS NOT NULL 
GROUP BY 
  recommendedby 
ORDER BY 
  recommendedby;
```
###### Question 21: List the total slots booked per facility
```sql
SELECT 
  facid, 
  sum(slots) as "Total Slots" 
FROM 
  cd.bookings 
GROUP BY 
  facid 
ORDER BY 
  facid;
```
###### Question 22: List the total slots booked per facility in a given month
```sql
SELECT 
  facid, 
  sum(slots) as "Total Slots" 
FROM 
  cd.bookings 
WHERE 
  starttime >= '2012-09-01' 
  AND starttime < '2012-10-01' 
GROUP BY 
  facid 
ORDER BY 
  "Total Slots";
```
###### Question 23: List the total slots booked per facility per month
```sql
SELECT 
  facid, 
  extract(
    month 
    from 
      starttime
  ) as month, 
  sum(slots) as "Total Slots" 
FROM 
  cd.bookings 
WHERE 
  extract(
    year 
    from 
      starttime
  ) = 2012 
GROUP BY 
  facid, 
  month 
ORDER BY 
  facid, 
  month;
```
###### Question 24: Find the total number of members (including guests) who have made at least one booking.
```sql
SELECT 
  COUNT (DISTINCT memid) 
FROM 
  cd.bookings 
WHERE 
  slots > 0;
```
###### Question 25: List each member's first booking after September 1st 2012.
```sql
SELECT 
  m.surname, 
  m.firstname, 
  b.memid, 
  min(b.starttime) as starttime 
FROM 
  cd.bookings b 
  INNER JOIN cd.members m ON b.memid = m.memid 
WHERE 
  b.starttime >= '2012-09-01' 
GROUP BY 
  m.surname, 
  m.firstname, 
  b.memid 
ORDER BY 
  memid;
```

###### Question 26: Produce a list of member names, with each row containing the total member count
```sql
SELECT 
  count(*) over(), 
  firstname, 
  surname 
FROM 
  cd.members 
ORDER BY 
  joindate;
```
###### Question 27:  Produce a numbered list of members
```sql
SELECT 
  count(*) over(
    order by 
      joindate
  ) as row_number, 
  firstname, 
  surname 
FROM 
  cd.members 
ORDER BY 
  joindate;
```
###### Question 28:  Output the facility id that has the highest number of slots booked, again
```sql
SELECT 
  facid, 
  total 
FROM 
  (
    SELECT 
      facid, 
      sum(slots) total, 
      rank() over (
        order by 
          sum(slots) desc
      ) rank 
    FROM 
      cd.bookings 
    GROUP BY 
      facid
  ) AS ranked 
WHERE 
  rank = 1;
```
 




