/* Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


/* What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC


/*Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
*/

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1


/* Who is the best customer? The customer who has spent the most money will be declared the best customer. */

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;

/*Email, first name, last name, & Genre of all Rock Music
listeners.*/

Select Distinct email,first_name,last_name
from public.customer as C join public.invoice as i on c.customer_id = i.customer_id
join public.invoice_line on i.invoice_id = invoice_line.invoice_id
where track_id in (select track_id from public.track
where genre_id = 1::varchar)
order by email

Select Distinct email,first_name,last_name,genre.name as Name
from public.customer as C join public.invoice as i on c.customer_id = i.customer_id
join public.invoice_line on i.invoice_id = invoice_line.invoice_id
join public.track on track.track_id = invoice_line.track_id
join public.genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email

/* Let's invite the artists who have written the most rock music in our dataset.  */

Select artist.name,artist.artist_id as name, count(album.artist_id) as total_Rock_Music from 
public.artist join public.album on artist.artist_id = album.artist_id
join public.track on track.album_id = album.album_id
join public.genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by total_Rock_Music desc
LIMIT 10;

/* Q7: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

Select track.name , track.milliseconds from public.track
where track.milliseconds > (select avg(milliseconds) from public.track)
order by track.milliseconds desc


/*Find how much amount spent by each customer on artists? */

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/*We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. */

with popular_genre as 
(
    select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id, 
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno 
    from invoice_line 
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select country,name as Popular_Music_Genre,purchases from popular_genre where rowno <= 1

/* Determines the customer that has spent the most on music for each country. */

with customter_with_country as (
		select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	    row_number() over(partition by billing_country order by sum(total) desc) as rowno 
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from customter_with_country where rowno <= 1