				            -- WELCOME TO ADVANCED SQL ANALYTICS PROJECT PRESENTATION --

/* This project is based on ig_clone database 
-- Before getting started, we need to follow two steps --
First Step: Copying the code to the work bench and executing it
Second step: View the tables to understand the data using commands below */
Select * from users;
Select * from likes;
Select * from photos;
Select * from comments;
Select * from tags;
Select * from photo_tags;
Select * from follow;

/* Following SQL Concepts are used to solve the questions:
1. Subquery (correlated and non correlated)
2. GROUP BY - GROUP BY statement is often used with aggregate functions to group the result-set by one or more columns.
3. ORDER BY - used to sort the result set in ascending or descending order
4. CTE - temporary result set that only exists for the duration of a query
5. JOINS - used to combine data or rows from two or more tables based on a common field between them
6. Windows functions - perform calculations across a set of rows and the rows retain their own identities ex-lag, lead, rank, etc */


								----------------------------------

-- QUESTION 1: How many times does the average user post?

/* USING SUBQUERY */
Select avg(a.ct) as Avg_Post_Per_User
 from 
 (                              
    Select count(p.user_id) as ct
     from Photos p right join
     users u on p.user_id = u.id
     group by u.id order by u.id
  ) a; 
  
            -- OR --

/* USING CTE */
With cnt as (
             Select u.id, count(p.user_id) as ct
             from Photos p right join
             users u on p.user_id = u.id
             group by u.id order by u.id
             )
Select avg(ct) as Avg_Post_Per_User from cnt;

                                 ----------------------------------
  
-- QUESTION 2: Find the top 5 most used hashtags --

/* USING JOIN */
Select tag_name as Top_5_Tags from tags t inner join photo_tags pt on t.id = pt.tag_id 
group by pt.tag_id order by count(*) desc limit 5;

                   -- OR --
/* USING CTE */                  
With tag_cnt as (
                 Select tag_id, count(*) as ct
                 from photo_tags
                 group by tag_id order by ct desc limit 5
                 )
Select tag_name as Top_5_Tags from tags tg inner join tag_cnt tc on tg.id = tc.tag_id;

                                ----------------------------------

-- "QUESTION 3: Find users who have liked every single photo on the site" --

Select username 
from users where id in 
					  (
                       Select l.user_id 
                       from likes l 
                       group by l.user_id 
                       having count(*) = (
					                      Select distinct count(*) as Total_Photos_Posted 
						                  from photos
                                          )
                                          );


                                ---------------------------------- 
                                
-- QUESTION 4: Retrieve a list of users along with their usernames and the rank of their account 
-- creation, ordered by the creation date in ascending order.

Select id, username, rank() over (order by created_at) as Ranking
from users;

								---------------------------------- 
                                 
-- QUESTION 5: List the comments made on photos with their comment texts, photo URLs, and usernames of users who
-- posted the comments. Include the comment count for each photo

Select u.id as User_ID, username, comment_text, image_url, count(photo_id) 
over (PARTITION BY PHOTO_ID) AS Comment_count from users u right join comments c on u.id = c.user_id
left join photos p on c.photo_id = p.id;

								---------------------------------- 

-- QUESTION 6: For each tag, show the tag name and the number of photos associated with that tag. 
-- Rank the tags by the number of photos in descending order.

Select t.id, t.tag_name, Photos_Per_Tag, 
rank() over (order by Photos_Per_Tag desc, tag_name asc) as 'Rank'
from tags t inner join (
SELECT tag_id, count(tag_id) as Photos_Per_Tag FROM photo_tags group by tag_id) as n 
where t.id = n.tag_id;

             -- OR --
             
/* USING Dense_rank function */
Select t.id, t.tag_name, Photos_Per_Tag, 
dense_rank() over (order by Photos_Per_Tag desc, tag_name asc) as Ranking
from tags t inner join (
SELECT tag_id, count(tag_id) as Photos_Per_Tag FROM photo_tags group by tag_id) as n 
where t.id = n.tag_id;

                                ---------------------------------- 

-- QUESTION 7: List the usernames of users who have posted photos along with the count of photos they 
-- have posted. Rank them by the number of photos in descending order.

Select user_id, username, count(*) as Photos_Per_User, 
Rank() over (order by count(*) desc) as 'Rank'
from photos p inner join users u on p.user_id = u.id group by user_id;

              -- OR --
              
With cte as (
             Select user_id, username, count(*) as Photos_Per_User
             from photos p inner join users u on p.user_id = u.id group by user_id
             )
Select user_id, username, Photos_Per_User, Rank() over (order by Photos_Per_User desc) as 'Rank' from cte;

                                ---------------------------------- 
                                
-- QUESTION 8: Display the username of each user along with the creation date of their first posted photo 
-- and the creation date of their next posted photo.

Select username as User_Name, p.created_at as First_Photo, lead(p.created_at) over (order by p.created_At) as Next_Photo
from photos p inner join users u on p.user_id = u.id group by p.user_id, p.created_at;

								---------------------------------- 

-- QUESTION 9: For each comment, show the comment text, the username of the commenter, and
-- the comment text of the previous comment made on the same photo

Select photo_id, comment_text, lag(comment_text) 
over (partition by photo_id order by c.id) as Previous_comment, username 
from comments c left join users u on c.user_id = u.id;

							    ---------------------------------- 

-- QUESTION 10: Show the username of each user along with the number of photos they have posted and 
-- the number of photos posted by the user before them and after them, based on the creation date.

Select username, count(user_id) as Photo_Count, 
lag(count(user_id)) over (order by u.created_at) as Post_by_User_Before,
lead(count(user_id)) over (order by u.created_at) as Post_by_User_After
from users u left join photos p on u.id = p.user_id group by u.id;

								 ---------------------------------- 

                                         -- THANKS FOR YOUR TIME --
                                          -- END OF THE PROJECT --