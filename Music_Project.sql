create database music_database;
use music_database;

SELECT default_character_set_name FROM information_schema.SCHEMATA S WHERE schema_name = "music_database";

select * from album;

-- Easy Questions
-- 1) Who is the senior most employee based on job title ? 
select * from employee;
insert into employee
values(9,'Madan','Mohan','Senior General Manager', NULL , 'L7', '26-01-1961 00:00', '14-01-2016 00:00', '1008 Vrinda Ave MT', 'Edmonton', 'AB','Canada','T5K 2N1', '+1 (780) 428-9482' , '+1 (780) 428-3457', 'madan.mohan@chinookcorp.com');
select * from employee order by levels desc limit 1;

-- 2) Which countries have the most invoices ?
select billing_country, count(*) from invoice 
group by billing_country
order by count(*) desc limit 5;

-- 3) What are the top 3 values of total invoice ?
select total from invoice order by total desc limit 3 ;

-- 4) Which city has the best customers ? We would like to throw a promotional Music Festival in the city where we made the most money. Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name and sum of all invoice totals
select billing_city, sum(total) as 'invoice_total' from invoice
group by billing_city
order by invoice_total desc limit 1;

-- 5) Who is the best customer ? The customer who has spent the most money will be declared as the best customer. Write a query that returns the person who has spent the most money. 
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select i.customer_id, c.first_name, c.last_name, sum(total) as 'total'
from invoice i
join customer c
on i.customer_id = c.customer_id
group by i.customer_id
order by total desc limit 1;

-- Moderate Questions
-- 1) Write a query to return the email, first_name, last_name and genre of all rock music listeners. Return your list alphabetically by email starting with A
select distinct(email), first_name, last_name, g.name
from customer c 
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name like '%Rock%'
order by email;

-- 2) Let's invite the artist who have written the most rock music in our dataset. Write a query that returns the artist name and total track count of the top 10 rock bands
select a.artist_id, at.name, count(*) as 'no_of_songs' from track t
join album a on t.album_id = a.album_id
join artist at on a.artist_id = at.artist_id
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
group by at.artist_id
order by no_of_songs desc
limit 10;

/* 3) Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-- Advanced Level Questions
 /* 1) Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
select c.first_name, c.last_name, at.name, sum(il.unit_price*il.quantity) as 'total_spent' from invoice i
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album a on t.album_id = a.album_id
join artist at on a.artist_id = at.artist_id
join customer c on i.customer_id = c.customer_id
group by c.customer_id , at.artist_id
order by total_spent desc;

/* 2) We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
with cte as (
select c.country, g.name, sum(i.total) as 'amount', row_number() over(partition by country order by sum(i.total) desc) as 'row_no'
from invoice i 
join customer c on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
group by c.country, g.name
)
select * from cte where row_no <= 1;

/* 3) Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
with cte as (
select c.country, c.first_name, c.last_name, sum(i.total) as 'money_spent',
row_number() over(partition by country order by sum(i.total) desc) as 'row_no'
from invoice i 
join customer c on c.customer_id = i.customer_id
group by country, c.customer_id
)
select * from cte where row_no <= 1;








