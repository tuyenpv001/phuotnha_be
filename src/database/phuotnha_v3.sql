-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th1 12, 2024 lúc 03:52 PM
-- Phiên bản máy phục vụ: 10.4.25-MariaDB
-- Phiên bản PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `phuotnha`
--

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ADD_NEW_STORY` (IN `IDSTORY` VARCHAR(100), IN `IDUSER` VARCHAR(100), IN `IDMEDIASTORY` VARCHAR(100), IN `MEDIA` VARCHAR(150))   BEGIN
	INSERT INTO stories (uid_story, user_uid) VALUE (IDSTORY,IDUSER);
	INSERT INTO media_story(uid_media_story, media, story_uid) VALUE (IDMEDIASTORY, MEDIA, IDSTORY);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ALL_MESSAGE_BY_TRIP` (IN `ID_USER` VARCHAR(100), IN `ID_TRIP` VARCHAR(100))   BEGIN	
	SELECT * FROM trip_messages me
	WHERE me.target_trip_uid = ID_TRIP
	ORDER BY me.created_at DESC
	LIMIT 30;  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ALL_MESSAGE_BY_USER` (IN `UIDFROM` VARCHAR(100), IN `UIDTO` VARCHAR(100))   BEGIN	
	SELECT * FROM messages me
	WHERE me.source_uid = UIDFROM AND me.target_uid = UIDTO || me.source_uid = UIDTO AND me.target_uid = UIDFROM
	ORDER BY me.created_at DESC
	LIMIT 30;  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_AUTO_UPDATE_ACHIVEMENT` (IN `ID_USER` VARCHAR(100))   BEGIN
SET @countTrips = 0;
SET @countRate = 0.0;

SELECT  @countTrips := COUNT(trips.uid) from trips WHERE trips.user_uid = ID_USER;
SELECT  @countRate := AVG(trip_members.trip_rate) from trips,trip_members WHERE trips.user_uid = ID_USER AND trip_members.trip_uid = trips.uid;

IF @countTrips > 20 AND @countRate >= 4.5 THEN
    UPDATE person SET person.achievement = 'E' WHERE person.uid = ID_USER;
   ELSEIF @countTrips > 15 AND @countRate >= 3.5 THEN
	UPDATE person SET person.achievement = 'D' WHERE person.uid = ID_USER;
   ELSEIF @countTrips > 10 AND @countRate >= 2.5 THEN
	UPDATE person SET person.achievement = 'C' WHERE person.uid = ID_USER;
   ELSEIF @countTrips > 7 AND @countRate >= 1.5 THEN
	UPDATE person SET person.achievement = 'B' WHERE person.uid = ID_USER;
   ELSEIF @countTrips > 5 AND @countRate >= 0 THEN
	UPDATE person SET person.achievement = 'A' WHERE person.uid = ID_USER;
   ELSE
     UPDATE person SET person.achievement = 'O' WHERE person.uid = ID_USER;
   END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CHECK_DUPLICATE_TRIP` (IN `ID_USER` VARCHAR(100), IN `DATE_START` DATETIME, IN `DATE_END` DATETIME)   BEGIN
SELECT COUNT(trips.uid) as countTripCreated FROM trips
WHERE trips.user_uid = ID_USER
 AND ((trips.trip_date_start BETWEEN DATE_START AND DATE_END)
 OR (trips.trip_date_end BETWEEN DATE_START AND DATE_END)
 OR (DATE_START BETWEEN trips.trip_date_start AND trips.trip_date_end)
 OR (DATE_END BETWEEN trips.trip_date_start AND trips.trip_date_end)
);

SELECT COUNT(trip_members.uid) as countTripJoined FROM trip_members
INNER JOIN trips ON trips.uid = trip_members.trip_uid
WHERE trip_members.person_uid = ID_USER
  AND ((trips.trip_date_start BETWEEN DATE_START AND DATE_END)
 OR (trips.trip_date_end BETWEEN DATE_START AND DATE_END)
 OR (DATE_START BETWEEN trips.trip_date_start AND trips.trip_date_end)
 OR (DATE_END BETWEEN trips.trip_date_start AND trips.trip_date_end)
 );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DELETE_TRIP_BY_ID` (IN `ID_TRIP` VARCHAR(100))   BEGIN

DELETE FROM trip_save WHERE trip_save.trip_uid = ID_TRIP;
DELETE FROM trip_members WHERE trip_members.trip_uid = ID_TRIP;
DELETE FROM trip_schedule WHERE trip_schedule.trip_uid = ID_TRIP;
DELETE FROM trip_images WHERE trip_images.trip_uid = ID_TRIP;
DELETE FROM trip_recommend WHERE trip_recommend.trip_uid = ID_TRIP;
DELETE FROM trip_messages WHERE trip_messages.target_trip_uid = ID_TRIP;
DELETE FROM trips WHERE trips.uid = ID_TRIP;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_FOLLOWERS` (IN `IDUSER` VARCHAR(100))   BEGIN
	SELECT f.uid AS idFollower, f.followers_uid AS uid_user, f.date_followers, u.username, p.fullname, p.image AS avatar FROM followers f
	INNER JOIN users u ON f.followers_uid = u.person_uid
	INNER JOIN person p ON u.person_uid = p.uid
	WHERE f.person_uid = IDUSER;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_FOLLOWING` (IN `IDUSER` VARCHAR(100))   BEGIN
	SELECT f.uid AS uid_friend, f.friend_uid AS uid_user, f.date_friend, u.username, p.fullname, p.image AS avatar 
	FROM friends f
	INNER JOIN users u ON f.friend_uid = u.person_uid
	INNER JOIN person p ON u.person_uid = p.uid
	WHERE f.person_uid = IDUSER;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_MESSAGE_BY_TRIP` (IN `IDUSER` VARCHAR(100), IN `ID_TRIP` VARCHAR(100))   BEGIN
SELECT trip_messages.uid_message_trip,trip_messages.source_uid,trip_messages.target_trip_uid,trip_messages.message, u.username, p.image AS avatar
	FROM trip_messages
	INNER JOIN users u ON trip_messages.source_uid = u.person_uid
	INNER JOIN person p ON u.person_uid = p.uid
 	WHERE trip_messages.source_uid = IDUSER AND trip_messages.target_trip_uid = ID_TRIP
 	ORDER BY trip_messages.updated_at ASC;
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_MESSAGE_BY_USER` (IN `IDUSER` VARCHAR(100))   BEGIN
	SELECT ls.uid_list_chat, ls.source_uid, ls.target_uid, ls.last_message, ls.updated_at, p.fullname as username, p.image AS avatar
	FROM list_chats ls
	INNER JOIN users u ON ls.target_uid = u.person_uid
	INNER JOIN person p ON u.person_uid = p.uid
 	WHERE ls.source_uid = IDUSER
 	ORDER BY ls.updated_at ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_POSTS_FOR_SEARCH` (IN `ID` VARCHAR(100))   BEGIN
	SELECT img.post_uid AS post_uid, pos.is_comment, pos.type_privacy, pos.created_at, pos.person_uid, ANY_VALUE(username) AS username, per.image AS avatar, GROUP_CONCAT( DISTINCT img.image ) images  
	FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	INNER JOIN users us ON us.person_uid = pos.person_uid
	INNER JOIN person per ON per.uid = pos.person_uid
	WHERE pos.person_uid <> ID AND pos.type_privacy = 1
	GROUP BY img.post_uid
	ORDER BY pos.uid DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_POSTS_HOME` (IN `ID` VARCHAR(100))   BEGIN
SELECT  pos.uid AS post_uid, pos.is_comment, pos.type_privacy,pos.description ,pos.created_at, 
	(SELECT COUNT(co.post_uid) FROM comments co WHERE co.post_uid = pos.uid ) AS count_comment,
	(SELECT COUNT(li.post_uid) FROM likes li WHERE li.post_uid = pos.uid ) AS count_likes,
    (SELECT COUNT(li.user_uid) FROM likes li WHERE li.user_uid = ID AND li.post_uid = pos.uid )AS is_like,
    (SELECT images_post.image FROM images_post WHERE post_uid = images_post.post_uid LIMIT 1) as images,
        (SELECT COUNT(post_save.post_save_uid) FROM post_save WHERE post_save.person_uid = ID AND post_save.post_uid = pos.uid )AS is_save,
     pos.person_uid, per.fullname AS username, per.is_leader,
	per.image AS avatar
	FROM posts pos
    LEFT JOIN person per ON pos.person_uid = per.uid
	ORDER BY pos.created_at DESC;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_POST_BY_USER` (IN `ID` VARCHAR(100))   BEGIN
	SELECT img.post_uid AS post_uid, pos.is_comment, pos.type_privacy, pos.created_at, pos.person_uid, ANY_VALUE(username) AS username, 
	per.image AS avatar, GROUP_CONCAT( DISTINCT img.image ) images, 
	(SELECT COUNT(co.post_uid) FROM comments co WHERE co.post_uid = pos.uid ) AS count_comment,
	(SELECT COUNT(li.post_uid) FROM likes li WHERE li.post_uid = pos.uid ) AS count_likes,
	(SELECT COUNT(li.user_uid) FROM likes li WHERE li.user_uid = ID AND li.post_uid = pos.uid )AS is_like
	FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	INNER JOIN comments co ON co.post_uid = pos.uid
	INNER JOIN users us ON us.person_uid = pos.person_uid
	INNER JOIN person per ON per.uid = pos.person_uid
	WHERE per.uid = ID
	GROUP BY img.post_uid, co.post_uid 
	ORDER BY pos.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_STORIES_HOME` (IN `IDUSER` VARCHAR(100))   BEGIN
SELECT s.uid_story, p.fullname as username, p.image AS avatar, COUNT(ms.story_uid) AS count_story,ms.media
	FROM stories s
	INNER JOIN users u ON s.user_uid = u.person_uid
    INNER JOIN person p ON p.uid = u.person_uid
	INNER JOIN media_story ms ON s.uid_story = ms.story_uid
#	INNER JOIN friends f ON u.person_uid = f.friend_uid
#	INNER JOIN person p ON p.uid = f.friend_uid
#	WHERE f.person_uid =  IDUSER
	GROUP BY s.uid_story, u.username, p.image
    ORDER BY ms.created_at DESC
    ;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_TRIP` (IN `ID` VARCHAR(100))   BEGIN
SELECT  trip.uid as trip_uid,trip.user_uid, trip.trip_title, trip.trip_description,trip.trip_from,trip.trip_to,trip.trip_date_start,
    trip.trip_date_end,trip.trip_status,trip.trip_member,trip.created_at,
     (
        SELECT trip_image_url 
        FROM trip_images 
        WHERE trip_images.trip_uid = trip.uid 
        LIMIT 1
    ) as tripimages
    , per.fullname, per.uid AS userID, per.is_leader, per.image,per.achievement as userAchievement,
        (SELECT COUNT(trip_members.trip_uid) FROM trip_members WHERE trip_members.trip_uid = trip.uid) as totalMemberJoined,
        (SELECT IF(totalMemberJoined = trip.trip_member OR trip.trip_status = "completed", 1,0)) as isClose,
        (SELECT COUNT(*) from trip_members WHERE trip_members.person_uid = ID AND trip.uid = trip_members.trip_uid) as isJoined,
          (SELECT IF(trip.user_uid = ID, 1,0)) as isOwner,
           (SELECT AVG(person.score_prestige) from trip_members
           	INNER JOIN person ON person.uid = trip_members.person_uid
           	INNER JOIN trips ON trip_members.trip_uid = trips.uid
           WHERE trips.uid = trip_members.trip_uid
          ) as score
    FROM trips trip
    LEFT JOIN person per ON trip.user_uid =  per.uid
    WHERE trip.trip_status = 'open'
    ORDER BY trip.created_at DESC;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_TRIP_BY_USER` (IN `ID_USER` VARCHAR(100))   BEGIN
	SELECT trips.*, 
    (SELECT trip_images.trip_image_url FROM trip_images WHERE trips.uid = trip_images.trip_uid LIMIT 1) AS image,
    (SELECT COUNT(trip_members.uid) FROM trip_members WHERE trip_members.trip_uid = trips.uid) AS totalMemberJoined
    FROM trips WHERE trips.user_uid = ID_USER;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_TRIP_SCHEDULE` (IN `ID_USER` VARCHAR(100))   BEGIN
SELECT  trip.uid as trip_uid,trip.trip_title,trip.trip_from,trip.trip_to,trip.trip_date_start,
    trip.trip_date_end,trip.trip_status,trip.trip_member,trip.created_at,trip_images.trip_image_url as thumbnail,
    person.fullname, person.image as avatar, person.achievement,
        (SELECT COUNT(trip_members.trip_uid) FROM trip_members WHERE trip_members.trip_uid = trip.uid) as totalMemberJoined,
        (SELECT IF(trip.user_uid = ID_USER, 1,0)) as isOwner
    FROM trips trip
    LEFT JOIN trip_images ON trip.uid = trip_images.trip_uid
    LEFT JOIN trip_members ON trip.uid = trip_members.trip_uid
    LEFT JOIN person ON  trip_members.person_uid = person.uid OR trip.user_uid = person.uid
    WHERE trip.user_uid = ID_USER OR trip_members.person_uid =  ID_USER
    GROUP BY trip_uid
    ORDER BY trip.created_at DESC;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_COMMENTS_TRIP_BY_ID` (IN `ID_TRIP` VARCHAR(100))   BEGIN
SELECT trip_comment.uid,trip_comment.comment, person.fullname,person.achievement,person.is_leader,person.score_prestige,person.image as avatar
FROM trip_comment 
INNER JOIN person ON person.uid = trip_comment.person_uid
WHERE trip_comment.trip_uid = ID_TRIP;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_COMMNETS_BY_UIDPOST` (IN `IDPOST` VARCHAR(100))   BEGIN
	SELECT co.uid, co.`comment`, co.is_like, co.created_at, co.person_uid, co.post_uid, u.username, p.image AS avatar FROM comments co
	INNER JOIN users u ON co.person_uid = u.person_uid
	INNER JOIN person p ON p.uid = co.person_uid
	WHERE co.post_uid = IDPOST
	ORDER BY co.created_at ASC; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_DETAIL_TRIP_ID` (IN `ID_TRIP` VARCHAR(100), IN `ID_USER` VARCHAR(100))   BEGIN
SELECT  trip.uid as trip_uid,trip.user_uid, trip.trip_title, trip.trip_description,trip.trip_from,trip.trip_to,trip.trip_date_start,
    trip.trip_date_end,trip.trip_status,trip.trip_member,trip.created_at,
   per.fullname, per.uid AS userID, per.is_leader, per.image,per.achievement as userAchievement,
        (SELECT COUNT(trip_members.trip_uid) FROM trip_members WHERE trip_members.trip_uid = trip.uid) as totalMemberJoined,
        (SELECT IF(totalMemberJoined = trip.trip_member OR trip.trip_status = "completed", 1,0)) as isClose,
        (SELECT COUNT(*) from trip_members WHERE trip_members.person_uid = ID_USER AND trip.uid = trip_members.trip_uid) as isJoined,
         (SELECT COUNT(*) from trip_save WHERE trip_save.person_uid = ID_USER AND trip.uid = trip_save.trip_uid) as isSaved,
          (SELECT IF(trip.user_uid = ID_USER, 1,0)) as isOwner
    FROM 
    trips trip, person per WHERE trip.uid = ID_TRIP AND trip.user_uid =  per.uid;

    SELECT trip_images.uid,trip_images.trip_image_url from trip_images WHERE trip_images.trip_uid = ID_TRIP;
      SELECT * from trip_schedule WHERE trip_schedule.trip_uid = ID_TRIP;
      SELECT person.fullname,person.image as avatar, person.achievement from trip_members,person WHERE trip_members.trip_uid = ID_TRIP
      AND trip_members.person_uid = person.uid;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_DETAIL_TRIP_SCHEDULE` (IN `ID_TRIP` VARCHAR(100), IN `ID_USER` VARCHAR(100))   BEGIN
SELECT  trip.uid as trip_uid,trip.user_uid, trip.trip_title, trip.trip_description,trip.trip_from,trip.trip_to,trip.trip_date_start,
    trip.trip_date_end,trip.trip_status,trip.trip_member,trip.created_at,
   per.fullname, per.uid AS userID, per.is_leader, per.image,per.achievement as userAchievement,
        (SELECT COUNT(trip_members.trip_uid) FROM trip_members WHERE trip_members.trip_uid = trip.uid) as totalMemberJoined,
        (SELECT IF(totalMemberJoined = trip.trip_member OR trip.trip_status = "completed", 1,0)) as isClose,
        (SELECT COUNT(*) from trip_members WHERE trip_members.person_uid = ID_USER AND trip.uid = trip_members.trip_uid) as isJoined,
          (SELECT IF(trip.user_uid = ID_USER, 1,0)) as isOwner
    FROM trips trip, person per WHERE trip.uid = ID_TRIP AND trip.user_uid =  per.uid;

    SELECT trip_images.uid,trip_images.trip_image_url from trip_images WHERE trip_images.trip_uid = ID_TRIP;
      SELECT * from trip_schedule WHERE trip_schedule.trip_uid = ID_TRIP;
      SELECT person.fullname,person.image as avatar, person.achievement, trip_members.trip_role as role from trip_members,person WHERE trip_members.trip_uid = ID_TRIP
      AND trip_members.person_uid = person.uid;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_LIST_POST_SAVED_BY_USER` (IN `ID` VARCHAR(100))   BEGIN
	SELECT ps.post_save_uid, ps.post_uid, ps.person_uid,ps.date_save, per.image AS avatar, per.fullname,GROUP_CONCAT( DISTINCT img.image ) images, po.description 
    FROM post_save ps 
	INNER JOIN posts po ON ps.post_uid = po.uid
	INNER JOIN images_post img ON po.uid = img.post_uid
	INNER JOIN person per ON per.uid = po.person_uid
	INNER JOIN users us ON us.person_uid = ps.person_uid
	where ps.person_uid = ID
	GROUP BY ps.post_save_uid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_LOCATION_ALL_MEMBER_BY_TRIP_ID` (IN `ID_TRIP` VARCHAR(100))   BEGIN
#GET LEADER
SELECT users.lat, users.lng, person.image,person.fullname, 1 as isLeader FROM trips
INNER JOIN users ON users.person_uid = trips.user_uid
INNER JOIN person ON users.person_uid = person.uid
WHERE trips.uid = ID_TRIP;

#GET MEMBER
SELECT users.lat, users.lng, person.image,person.fullname, 0 as isMember FROM trip_members
INNER JOIN users ON users.person_uid = trip_members.person_uid
INNER JOIN person ON users.person_uid = person.uid
WHERE trip_members.trip_uid = ID_TRIP;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_MEMBERS_TRIP` (IN `ID_TRIP` VARCHAR(100))   BEGIN
SELECT trip_members.uid as trip_member_uid, trip_members.trip_uid,trip_members.person_uid,trip_members.trip_role as userRole,
person.fullname,person.image as avatar, person.achievement, 0 as isMember,
(SELECT trips.user_uid from trips where  trips.uid = ID_TRIP)  as trip_leader,
(SELECT IF(person_uid = trip_leader, 1, 0)) as isPermissionChangeRole
FROM trip_members
LEFT JOIN person ON trip_members.person_uid = person.uid
WHERE trip_members.trip_uid = ID_TRIP;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_NOTIFICATION_BY_USER` (IN `ID` VARCHAR(100))   BEGIN
	SELECT noti.uid_notification, noti.type_notification, noti.created_at, noti.user_uid, u.username, noti.followers_uid, s.username AS follower, pe.image AS avatar, noti.post_uid 
	FROM notifications noti
	INNER JOIN users u ON noti.user_uid = u.person_uid
	INNER JOIN users s ON noti.followers_uid = s.person_uid
	INNER JOIN person pe ON pe.uid = s.person_uid
	WHERE noti.user_uid = ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_POST_BY_IDPERSON` (IN `ID` VARCHAR(100))   BEGIN
	SELECT img.post_uid AS post_uid, pos.is_comment, pos.type_privacy, pos.created_at, GROUP_CONCAT( DISTINCT img.image ) images  
	FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	WHERE pos.person_uid = ID
	GROUP BY img.post_uid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_POST_BY_ID_PERSON` (IN `ID` VARCHAR(100))   BEGIN
	SELECT pos.uid, pos.is_comment, pos.type_privacy, pos.created_at, GROUP_CONCAT( DISTINCT img.image ) images FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	WHERE pos.person_uid = ID
	GROUP BY pos.uid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_PROFILE_USER` (IN `ID_USER` VARCHAR(100))   BEGIN
SELECT person.fullname, person.image, person.cover,person.is_leader, person.achievement,users.email, users.username,
	(SELECT COUNT(uid) FROM trips WHERE trips.user_uid = ID_USER) AS countTripCreated,
    (SELECT COUNT(uid) FROM trip_members WHERE trip_members.person_uid = ID_USER) AS countTripJoined,
    (SELECT COUNT(uid) FROM posts WHERE posts.person_uid = ID_USER) AS countPostCreated,
    (SELECT COUNT(uid) FROM followers WHERE followers.person_uid = ID_USER) AS countUserFollowing,
    (SELECT COUNT(uid) FROM followers WHERE followers.followers_uid = ID_USER) AS countUserFollower
from person, users
WHERE person.uid = ID_USER
AND person.uid = users.person_uid;

SELECT trips.uid as tripuid,trips.trip_title,
	IF(ROUND(AVG(trip_members.trip_rate), 2) IS NULL, 0.0,ROUND(AVG(trip_members.trip_rate), 2)) as avgRate,
COUNT(trip_members.person_uid) as memberJoined, COUNT(trip_members.trip_comment) as totalComment
FROM trips 
LEFT JOIN trip_members ON trips.uid = trip_members.trip_uid
WHERE trips.user_uid= ID_USER
GROUP BY tripuid;

SELECT trip_images.uid as tripuid,trip_images.trip_image_url as tripImage
FROM trips, trip_images 
WHERE trips.user_uid = ID_USER 
	AND trip_images.trip_uid = trips.uid;
    
SELECT images_post.uid as postuid, images_post.image postImage
FROM posts,images_post
WHERE posts.person_uid = ID_USER 
	AND posts.uid = images_post.post_uid;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_STORY_BY_USER` (IN `IDSTORY` VARCHAR(100))   BEGIN
	SELECT *
	FROM media_story ms
	WHERE ms.story_uid = IDSTORY;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_USER_BY_ID` (IN `ID` VARCHAR(100))   BEGIN
	SELECT p.uid, p.fullname, p.phone, p.image, p.cover, p.birthday_date, p.created_at, u.username, u.description, u.is_private, u.is_online, u.email
	FROM person p
	INNER JOIN users u ON p.uid = u.person_uid
	WHERE p.uid = ID AND p.state = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_IS_FRIEND` (IN `UID` VARCHAR(100), IN `FRIEND` VARCHAR(100))   BEGIN
	SELECT COUNT(uid) AS is_friend FROM friends
	WHERE person_uid = UID AND friend_uid = FRIEND
	LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_IS_PENDING_FOLLOWER` (IN `UIDPERSON` VARCHAR(100), IN `UIDFOLLOWER` VARCHAR(100))   BEGIN
	SELECT COUNT(uid_notification) AS is_pending_follower FROM notifications
	WHERE user_uid = UIDPERSON AND followers_uid = UIDFOLLOWER AND type_notification = '1';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_REGISTER_USER` (IN `uidPerson` VARCHAR(100), IN `fullname` VARCHAR(100), IN `username` VARCHAR(50), IN `email` VARCHAR(100), IN `pass` VARCHAR(100), IN `uidUser` VARCHAR(100), IN `temp` VARCHAR(50))   BEGIN
	INSERT INTO person(uid, fullname, image,cover) VALUE (uidPerson, fullname, 'avatar-default.png', 'cover_default.jpg');
	
	INSERT INTO users(uid, username, email, passwordd, person_uid, token_temp, email_verified) VALUE (uidUser, username, email, pass, uidPerson, temp, 1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEARCH_BY_KEYWORD` (IN `keyword` VARCHAR(255))   BEGIN

SELECT person.uid AS uid, person.fullname AS name,person.image AS image, 'user' as type
FROM person WHERE person.fullname LIKE CONCAT('%', keyword, '%')
ORDER BY person.achievement DESC;

SELECT trips.uid as uid, trips.trip_title as name,
(SELECT trip_images.trip_image_url FROM trip_images WHERE trip_images.trip_uid = trips.uid LIMIT 1) as image,
'trip' as type
FROM trips WHERE trips.trip_title LIKE CONCAT('%',keyword , '%')
ORDER BY trips.created_at DESC LIMIT 20;

SELECT posts.uid as uid,posts.description as name,
(SELECT images_post.image FROM images_post WHERE images_post.post_uid = posts.uid LIMIT 1) as image,
'post' as type
FROM posts WHERE posts.description LIKE CONCAT('%', keyword, '%') 
ORDER BY posts.created_at DESC LIMIT 20
;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEARCH_USERNAME` (IN `USERNAMEE` VARCHAR(100))   BEGIN
	SELECT pe.uid, pe.fullname, pe.image AS avatar, us.username FROM person pe
	INNER JOIN users us ON pe.uid = us.person_uid
	WHERE us.username LIKE CONCAT('%', USERNAMEE, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDATE_ACHIVEMENT_USER` (IN `ID_USER` VARCHAR(100))   BEGIN
SET @countTripCreated := 0;
SET @countTripCompleted := 0;
SET @avgTripCompleted := 0.0;
SET @tripHistoryCreated := 0;
SET @countTripHistoryCompleted := 0;	
SET @tripHistoryAvgRate:= 0.0;
SET @dateHistory := '2023-12-30';
SET @isExists := 0;
SELECT COUNT(*) INTO @isExists FROM user_history WHERE user_history.person_uid = ID_USER;

IF @isExists <> 0 THEN
	BEGIN
	SELECT user_history.count_trip_created INTO @tripHistoryCreated
    FROM user_history WHERE user_history.person_uid = ID_USER;

    SELECT user_history.avg_rate INTO @tripHistoryAvgRate
    FROM user_history WHERE user_history.person_uid = ID_USER;
    
 	SELECT user_history.count_trip_completed INTO @countTripHistoryCompleted
    FROM user_history WHERE user_history.person_uid = ID_USER;
    
    SELECT COUNT(trips.uid) INTO @countTripCreated FROM trips 
    WHERE trips.user_uid = ID_USER AND trips.created_at > @dateHistory;
    
    SELECT COUNT(trips.uid) INTO @countTripCompleted FROM trips 
    WHERE trips.user_uid = ID_USER AND trips.trip_status = 'completed' AND trips.created_at > @dateHistory;
    
    SELECT IF(AVG(trip_members.trip_rate) IS NULL, 0, AVG(trip_members.trip_rate)) INTO @avgTripCompleted
    FROM trip_members
    INNER JOIN trips ON trips.uid = trip_members.trip_uid
    WHERE trips.user_uid = ID_USER AND trips.created_at > @dateHistory  AND trip_members.trip_uid = trips.uid;
    
   # SELECT SUM(@tripHistoryCreated + @countTripCreated) INTO @countTripCreated;
    #SELECT SUM(@tripHistoryAvgRate + @avgTripCompleted) INTO  @avgTripCompleted;
   # SELECT SUM(@countTripHistoryCompleted + @countTripCompleted) INTO @countTripCompleted;
    SET @countTripCreated = @tripHistoryCreated + @countTripCreated;
    SET @avgTripCompleted = (@tripHistoryAvgRate + @avgTripCompleted) /2;
    SET @countTripCompleted = @countTripHistoryCompleted + @countTripCompleted;
    END;
ELSE
	BEGIN
	SELECT COUNT(trips.uid) INTO @countTripCreated FROM trips 
    WHERE trips.user_uid = ID_USER;
	SELECT COUNT(trips.uid) INTO @countTripCompleted FROM trips 
    WHERE trips.user_uid = ID_USER AND trips.trip_status = 'completed';
    SELECT IF(AVG(trip_members.trip_rate) IS NULL, 0, AVG(trip_members.trip_rate)) INTO @avgTripCompleted
    FROM trip_members
    INNER JOIN trips ON trips.uid = trip_members.trip_uid
    WHERE trips.user_uid = ID_USER AND trip_members.trip_uid = trips.uid;
    END;
END IF;

IF @countTripCreated > 9 OR @countTripCompleted  BETWEEN 0 AND 3 
   THEN  UPDATE person SET person.is_leader = 1, person.achievement = 'A' WHERE person.uid =  ID_USER;
ELSEIF @countTripCreated > 10 AND @countTripCompleted >  3 AND @avgTripCompleted BETWEEN 2 AND 3.2
   THEN  UPDATE person SET person.is_leader = 1, person.achievement = 'B' WHERE person.uid =  ID_USER;
ELSEIF @countTripCreated > 15 AND @countTripCompleted >  5 AND @avgTripCompleted BETWEEN 3 AND 4.2
   THEN UPDATE person SET person.is_leader = 1, person.achievement = 'C' WHERE person.uid =  ID_USER;
ELSEIF @countTripCreated > 15 AND @countTripCompleted >  5 AND @avgTripCompleted BETWEEN 3 AND 4.2
   THEN UPDATE person SET is_leader = 1, achievement = 'D' WHERE person.uid =  ID_USER;
ELSEIF @countTripCreated > 10 AND @countTripCompleted >  10 AND @avgTripCompleted BETWEEN 4 AND 4.5
   THEN UPDATE person SET person.is_leader = 1, person.achievement = 'E' WHERE person.uid =  ID_USER;
END IF;  

IF @avgTripCompleted BETWEEN 0 AND 2 
	THEN UPDATE person SET person.limit = 50.00 WHERE person.uid = ID_USER;
ELSEIF @avgTripCompleted BETWEEN 2.1 AND 3
	THEN UPDATE person SET person.limit = 100.00 WHERE person.uid = ID_USER;
END IF;

IF @isExists <> 0
THEN
	INSERT INTO user_history 					(user_history.person_uid,user_history.count_trip_created,user_history.count_trip_completed,user_history.avg_rate,user_history.created_at)
    VALUES (ID_USER,@countTripCreated, @countTripCompleted,@avgTripCompleted, NOW());
ELSE
    UPDATE user_history SET count_trip_created= @countTripCreated,count_trip_completed=@countTripCompleted,avg_rate=@avgTripCompleted,created_at= NOW() WHERE user_history.person_uid = ID_USER;
END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `call_video`
--

CREATE TABLE `call_video` (
  `uid` varchar(100) NOT NULL,
  `caller_uid` varchar(100) NOT NULL,
  `receiver_id` varchar(100) NOT NULL,
  `is_disabled` tinyint(4) NOT NULL,
  `session_call` text NOT NULL,
  `session_answer` text NOT NULL,
  `candidate` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `comments`
--

CREATE TABLE `comments` (
  `uid` varchar(100) NOT NULL,
  `comment` varchar(150) DEFAULT NULL,
  `is_like` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `person_uid` varchar(100) NOT NULL,
  `post_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `comments`
--

INSERT INTO `comments` (`uid`, `comment`, `is_like`, `created_at`, `person_uid`, `post_uid`) VALUES
('1b0bbd2c-f5e4-4bb8-b33f-333542316356', 'ọ', 0, '2024-01-10 21:32:34', '88fdc431-9c21-481f-823c-c0942d308249', '5db01bbb-dd33-44d8-83f5-173e023f4d1e'),
('6605799e-c4ab-4ef5-983e-5db11838cf4d', 'đẹp', 0, '2023-12-27 22:12:59', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '5db01bbb-dd33-44d8-83f5-173e023f4d1e');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `followers`
--

CREATE TABLE `followers` (
  `uid` varchar(100) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `followers_uid` varchar(100) NOT NULL,
  `date_followers` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `friends`
--

CREATE TABLE `friends` (
  `uid` varchar(100) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `friend_uid` varchar(100) NOT NULL,
  `date_friend` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `images_post`
--

CREATE TABLE `images_post` (
  `uid` varchar(100) NOT NULL,
  `image` varchar(255) NOT NULL,
  `post_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `images_post`
--

INSERT INTO `images_post` (`uid`, `image`, `post_uid`) VALUES
('078b11e9-3d9e-422c-9c2c-c4798014047f', '47e79a63-a543-4520-b232-aeb00218a2bf.jpg', '6eec9d0b-ed91-445b-82b9-5597dda6c046'),
('23ef4aae-8073-4a09-b01f-7606d080c672', '0a04412b-e0e7-4618-b8a9-2cb74f045087.jpg', '5db01bbb-dd33-44d8-83f5-173e023f4d1e'),
('f8f043a4-ec4e-42e9-88e5-e7e4f423811c', '9aa77804-f711-46ad-bcc1-fbc6d7ccae07.jpg', '6eec9d0b-ed91-445b-82b9-5597dda6c046');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `likes`
--

CREATE TABLE `likes` (
  `uid_likes` varchar(100) NOT NULL,
  `user_uid` varchar(100) NOT NULL,
  `post_uid` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `likes`
--

INSERT INTO `likes` (`uid_likes`, `user_uid`, `post_uid`, `created_at`) VALUES
('f7fefe49-7f55-4621-9eb6-b439f18b2f4a', '88fdc431-9c21-481f-823c-c0942d308249', '5db01bbb-dd33-44d8-83f5-173e023f4d1e', '2024-01-05 15:58:21');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `list_chats`
--

CREATE TABLE `list_chats` (
  `uid_list_chat` varchar(100) NOT NULL,
  `source_uid` varchar(100) NOT NULL,
  `target_uid` varchar(100) NOT NULL,
  `last_message` text DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `list_chats`
--

INSERT INTO `list_chats` (`uid_list_chat`, `source_uid`, `target_uid`, `last_message`, `updated_at`) VALUES
('cc5055a7-9f0a-4c23-a7d0-e4133b98d509', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '88fdc431-9c21-481f-823c-c0942d308249', 'hi', '2024-01-09 06:33:05'),
('cc9cae5a-eae6-47e3-8ded-f0db557a7127', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'call', '2024-01-09 07:41:04');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `list_trip_chat`
--

CREATE TABLE `list_trip_chat` (
  `uid` varchar(100) NOT NULL,
  `source_uid` varchar(100) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `last_message` varchar(255) NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `list_trip_chat`
--

INSERT INTO `list_trip_chat` (`uid`, `source_uid`, `trip_uid`, `last_message`, `updated_at`) VALUES
('318750f6-ff90-4a80-b34d-bc8d29ba5c37', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'dhhdh', '2024-01-06 14:34:49'),
('6b059a94-5fea-4942-b7e0-e5283e9e92d7', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'kjk', '2024-01-06 14:35:07');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `media_story`
--

CREATE TABLE `media_story` (
  `uid_media_story` varchar(100) NOT NULL,
  `media` varchar(150) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `story_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `media_story`
--

INSERT INTO `media_story` (`uid_media_story`, `media`, `created_at`, `story_uid`) VALUES
('8375f965-ab9b-4248-a32d-c89ce98eddd5', 'e274e835-f686-463f-9b76-f07343a8afdd.jpg', '2024-01-10 21:30:54', 'e1c05095-274b-4c63-900e-d63a42d62d04');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `messages`
--

CREATE TABLE `messages` (
  `uid_messages` varchar(100) NOT NULL,
  `source_uid` varchar(100) NOT NULL,
  `target_uid` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `messages`
--

INSERT INTO `messages` (`uid_messages`, `source_uid`, `target_uid`, `message`, `created_at`) VALUES
('017f7acc-c877-403e-b25e-5ac81044cfbb', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'call', '2024-01-09 14:41:05'),
('0403f3b2-5104-4d25-b8ea-8784930f94c4', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '88fdc431-9c21-481f-823c-c0942d308249', 'test nè', '2024-01-06 21:30:23'),
('04a60018-ffd0-4b5e-a163-20d0d4df91ef', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'ko', '2024-01-05 23:27:22'),
('3725cd60-323c-4792-addc-9248c8829f3b', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '88fdc431-9c21-481f-823c-c0942d308249', 'hi', '2024-01-06 21:29:26'),
('56b6d805-f31f-41dd-b733-8cd7f7d5e769', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'fffjhj', '2024-01-06 21:30:08'),
('5fa48b01-f84d-4d1a-bd37-f4773ad741cf', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'jsndd', '2024-01-04 01:30:56'),
('73ab5c9a-75cc-4cf4-b80c-e457a2721bb3', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '88fdc431-9c21-481f-823c-c0942d308249', 'ok', '2024-01-06 21:11:55'),
('77e418a5-0707-4729-86ff-256129e7aa25', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'hi', '2024-01-09 13:32:54'),
('e12fb34a-8ef9-471b-aa08-cd412b000171', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '88fdc431-9c21-481f-823c-c0942d308249', 'hi', '2024-01-09 13:33:05'),
('ed4b5dc9-2cfb-46ab-9719-eef699c89222', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'hi', '2024-01-04 01:30:33'),
('f9b55656-02ea-410a-b0c5-714183955b47', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '88fdc431-9c21-481f-823c-c0942d308249', 'fbffhdjdjs', '2024-01-06 21:30:15');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `mock_data`
--

CREATE TABLE `mock_data` (
  `uid` int(11) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `fullname` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `lat` double NOT NULL,
  `lng` double NOT NULL,
  `index` int(11) NOT NULL,
  `is_mark` enum('problem','no') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `mock_data`
--

INSERT INTO `mock_data` (`uid`, `trip_uid`, `user_id`, `fullname`, `image`, `lat`, `lng`, `index`, `is_mark`) VALUES
(1, '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'e3be559fa8240', 'Văn Hào', 'avatar-default.png', 10.7212, 106.60046, 712, 'no'),
(2, '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'e3be559fa8241', 'Nguyễn Tý', 'avatar-default.png', 10.73741, 106.61452, 80, 'no'),
(3, '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'e3be559fa8242', 'Tuấn Đạt', 'avatar-default.png', 10.74386, 106.62145, 618, 'no'),
(4, '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'e3be559fa8243', 'Văn Tuyển', 'avatar-default.png', 10.75377, 106.63399, 594, 'no');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notifications`
--

CREATE TABLE `notifications` (
  `uid_notification` varchar(100) NOT NULL,
  `type_notification` enum('like','comment','join','add_fr','start','role','cancel') NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `user_uid` varchar(100) DEFAULT NULL,
  `followers_uid` varchar(100) DEFAULT NULL,
  `post_uid` varchar(100) DEFAULT NULL,
  `is_read` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `notifications`
--

INSERT INTO `notifications` (`uid_notification`, `type_notification`, `created_at`, `user_uid`, `followers_uid`, `post_uid`, `is_read`) VALUES
('6968e794-b503-45ba-b6b8-f99763126569', 'comment', '2024-01-05 15:58:21', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '88fdc431-9c21-481f-823c-c0942d308249', '5db01bbb-dd33-44d8-83f5-173e023f4d1e', 0),
('7f43f4e4-f606-4e7c-aae6-6655838a2a2d', 'join', '2024-01-05 17:09:44', '88fdc431-9c21-481f-823c-c0942d308249', '', '9d5c0682-f721-4efe-9c32-9607ea58815c', 0),
('ef0f35c4-28d4-4c84-a0a4-3ea9e3ea4fcf', 'join', '2024-01-05 15:54:23', '88fdc431-9c21-481f-823c-c0942d308249', '', '9d5c0682-f721-4efe-9c32-9607ea58815c', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `person`
--

CREATE TABLE `person` (
  `uid` varchar(100) NOT NULL,
  `fullname` varchar(150) DEFAULT NULL,
  `phone` varchar(11) DEFAULT NULL,
  `image` varchar(250) DEFAULT NULL,
  `cover` varchar(50) DEFAULT NULL,
  `birthday_date` date DEFAULT NULL,
  `state` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp(),
  `is_leader` tinyint(1) NOT NULL DEFAULT 0,
  `achievement` enum('O','A','B','C','D','E') NOT NULL DEFAULT 'O',
  `limit` double NOT NULL DEFAULT 1000000000000,
  `score_prestige` double NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `person`
--

INSERT INTO `person` (`uid`, `fullname`, `phone`, `image`, `cover`, `birthday_date`, `state`, `created_at`, `updated_at`, `is_leader`, `achievement`, `limit`, `score_prestige`) VALUES
('1a0c6118-7acc-480f-91a7-f9f46ce77865', 'Văn Bí', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-24 23:06:56', '2023-12-24 23:06:56', 0, 'O', 1000000000000, 0),
('88fdc431-9c21-481f-823c-c0942d308249', 'Phan Tuyển', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-13 14:44:06', '2023-12-13 14:44:06', 1, 'A', 999999999989, 0),
('a44c4d90-b821-4700-9f2a-60744d8d2137', 'Mình Nhân', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-16 00:06:08', '2023-12-16 00:06:08', 0, 'O', 1000000000000, 0),
('bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'Văn Hào', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-22 23:01:02', '2023-12-22 23:01:02', 0, 'O', 1000000000000, 0),
('da3197f0-a250-47c2-bb68-2b43dee75d40', 'Trần Long', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-24 22:49:14', '2023-12-24 22:49:14', 0, 'O', 1000000000000, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `posts`
--

CREATE TABLE `posts` (
  `uid` varchar(100) NOT NULL,
  `is_comment` tinyint(1) DEFAULT 1,
  `type_privacy` varchar(3) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `upadted_at` datetime DEFAULT current_timestamp(),
  `person_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `posts`
--

INSERT INTO `posts` (`uid`, `is_comment`, `type_privacy`, `description`, `created_at`, `upadted_at`, `person_uid`) VALUES
('5db01bbb-dd33-44d8-83f5-173e023f4d1e', 1, '1', 'Buổi tối chill ngắm Landmark', '2023-12-26 20:22:01', '2023-12-26 20:22:01', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84'),
('6eec9d0b-ed91-445b-82b9-5597dda6c046', 1, '1', 'Tối Bạch Đằng', '2023-12-25 13:45:06', '2023-12-25 13:45:06', '88fdc431-9c21-481f-823c-c0942d308249');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `post_save`
--

CREATE TABLE `post_save` (
  `post_save_uid` varchar(100) NOT NULL,
  `post_uid` varchar(100) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `date_save` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `post_save`
--

INSERT INTO `post_save` (`post_save_uid`, `post_uid`, `person_uid`, `date_save`) VALUES
('2c37a63b-634f-482f-9315-a8bb181ea310', '5db01bbb-dd33-44d8-83f5-173e023f4d1e', '88fdc431-9c21-481f-823c-c0942d308249', '2024-01-08 17:07:23'),
('e4fc230c-cf62-41c9-87d2-3ee76bb68fa2', '5db01bbb-dd33-44d8-83f5-173e023f4d1e', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '2023-12-27 22:00:22');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `stories`
--

CREATE TABLE `stories` (
  `uid_story` varchar(100) NOT NULL,
  `user_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `stories`
--

INSERT INTO `stories` (`uid_story`, `user_uid`) VALUES
('e1c05095-274b-4c63-900e-d63a42d62d04', '88fdc431-9c21-481f-823c-c0942d308249'),
('227819b9-f97a-4788-833b-51e1e632f1ed', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trips`
--

CREATE TABLE `trips` (
  `uid` varchar(100) NOT NULL,
  `user_uid` varchar(100) NOT NULL,
  `trip_title` varchar(255) DEFAULT NULL,
  `trip_description` varchar(255) DEFAULT NULL,
  `trip_date_start` date DEFAULT NULL,
  `trip_date_end` date DEFAULT NULL,
  `trip_from` varchar(255) DEFAULT NULL,
  `trip_to` varchar(255) DEFAULT NULL,
  `trip_member` int(11) NOT NULL DEFAULT 0,
  `trip_status` enum('open','block','cancel','pending','is_beginning','completed') DEFAULT NULL,
  `safe_distance` double NOT NULL DEFAULT 200,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `trips`
--

INSERT INTO `trips` (`uid`, `user_uid`, `trip_title`, `trip_description`, `trip_date_start`, `trip_date_end`, `trip_from`, `trip_to`, `trip_member`, `trip_status`, `safe_distance`, `created_at`, `updated_at`) VALUES
('349a5c74-e31b-4cb3-87aa-e3be559fa824', '88fdc431-9c21-481f-823c-c0942d308249', 'Tắm biển Cần Giờ', 'Chuyến đi tắm biển giải tress', '2023-12-25', '2023-12-27', 'Ngã tư Thủ Đức', 'Biển Cần Giờ', 2, 'completed', 200, '2023-12-25 14:01:31', '2023-12-25 14:01:31'),
('9d5c0682-f721-4efe-9c32-9607ea58815c', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'Khám phá thác K50', 'Check-in thác k50', '2023-12-28', '2023-12-31', '448 Lê Văn Việt', 'Thác K50', 4, 'open', 200, '2023-12-26 20:31:04', '2023-12-26 20:31:04');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_comment`
--

CREATE TABLE `trip_comment` (
  `uid` int(11) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `person_uid` varchar(255) NOT NULL,
  `comment` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `trip_comment`
--

INSERT INTO `trip_comment` (`uid`, `trip_uid`, `person_uid`, `comment`, `created_at`, `updated_at`) VALUES
(1, '9d5c0682-f721-4efe-9c32-9607ea58815c', '88fdc431-9c21-481f-823c-c0942d308249', 'test ', '2024-01-11 17:40:02', '2024-01-11 17:40:02');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_images`
--

CREATE TABLE `trip_images` (
  `uid` varchar(100) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `trip_image_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `trip_images`
--

INSERT INTO `trip_images` (`uid`, `trip_uid`, `trip_image_url`) VALUES
('571417b0-54fc-4dc4-809a-d09072da41b7', '9d5c0682-f721-4efe-9c32-9607ea58815c', 'f9e5cd20-fa4d-4bbd-ae17-f38f87eaaa9c.jpg'),
('976d9ced-dc4d-43f0-88f4-75772610f055', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'ae90ed4d-469c-49d7-994a-22524f85f5a7.jpg'),
('ecc32fe2-3e87-4952-87bd-15a5d45d6c33', '9d5c0682-f721-4efe-9c32-9607ea58815c', 'e65f64a9-00bb-4a5b-aa0d-fb9fd400369c.jpg'),
('f68fd776-ff6a-4afa-8cd8-fa1800db9186', '349a5c74-e31b-4cb3-87aa-e3be559fa824', '40c26992-f3b7-4bd9-9e1d-30abc16ce8c5.png');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_members`
--

CREATE TABLE `trip_members` (
  `uid` varchar(100) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `trip_role` enum('member','pho_nhom','thu_quy','chot_doan') NOT NULL DEFAULT 'member',
  `trip_rate` double NOT NULL DEFAULT 0,
  `trip_comment` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `trip_members`
--

INSERT INTO `trip_members` (`uid`, `trip_uid`, `person_uid`, `trip_role`, `trip_rate`, `trip_comment`) VALUES
('a1531aba-4754-4a9a-91ce-4966ef3b07b1', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'thu_quy', 0, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_messages`
--

CREATE TABLE `trip_messages` (
  `uid_message_trip` varchar(100) NOT NULL,
  `source_uid` varchar(100) NOT NULL,
  `target_trip_uid` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `trip_messages`
--

INSERT INTO `trip_messages` (`uid_message_trip`, `source_uid`, `target_trip_uid`, `message`, `created_at`) VALUES
('1c538290-3e20-42ec-8990-77b6ad0f3eed', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'đhfh', '2024-01-06 21:31:34'),
('31335dd0-757b-413f-9bfd-33191edf724b', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'plpl', '2024-01-05 23:26:21'),
('80a29fab-a325-4b92-b3c9-ec58eb474c75', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'dhhdh', '2024-01-06 21:34:49'),
('83b101e9-876b-4d9c-959c-bd61ce83e66e', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'ooo', '2024-01-06 21:32:02'),
('96482bde-2ba3-481d-a6f8-d9082e43fb73', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'hi', '2024-01-05 22:39:06'),
('c8945fb8-dfb8-420d-ac7b-be68bf5b609d', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'kkk', '2024-01-06 21:31:04'),
('d2a2eb75-b037-4a03-b697-616d7a41c759', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'ok', '2024-01-06 21:31:43'),
('f636b81e-57cf-46fe-b1b4-fc91b62827f3', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'oo', '2024-01-06 21:32:13'),
('f7e28545-9312-427a-8740-98f2e0aa368d', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'kjk', '2024-01-06 21:35:07');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_recommend`
--

CREATE TABLE `trip_recommend` (
  `uid` varchar(100) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `trip_point` varchar(255) DEFAULT NULL,
  `trip_des_point` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_reopen`
--

CREATE TABLE `trip_reopen` (
  `uid_trip_reopen` varchar(100) NOT NULL,
  `uid_trip` varchar(100) NOT NULL,
  `date_start` date NOT NULL,
  `date_end` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_save`
--

CREATE TABLE `trip_save` (
  `uid` varchar(100) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `date_save` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_schedule`
--

CREATE TABLE `trip_schedule` (
  `uid` varchar(100) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `lat` double NOT NULL,
  `lng` double NOT NULL,
  `address_short` varchar(255) NOT NULL,
  `address_detail` varchar(255) NOT NULL,
  `isGasStation` tinyint(1) NOT NULL DEFAULT 0,
  `isRepairMotobike` tinyint(1) NOT NULL DEFAULT 0,
  `isEatPlace` int(11) NOT NULL DEFAULT 0,
  `isCheckIn` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `trip_schedule`
--

INSERT INTO `trip_schedule` (`uid`, `trip_uid`, `lat`, `lng`, `address_short`, `address_detail`, `isGasStation`, `isRepairMotobike`, `isEatPlace`, `isCheckIn`) VALUES
('6a79b4f1', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.859716, 106.789382, 'Công Ty TNHH Thương Mại Tân Hiệp\n', 'Lê Văn Việt, Tăng Nhơn Phú A, Quận 9, Thành phố Hồ Chí Minh', 1, 0, 0, 0),
('6a79b4f2', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.843558, 106.76981, 'Cơm tấm Calithiu', '659 Lê Văn Việt, Long Thạnh Mỹ, Quận 9, Thành phố Hồ Chí Minh', 0, 0, 1, 0),
('6a79b4f4', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.652101, 106.550042, 'Cửa Hàng Xăng Dầu Me Ry', 'VRXM+VXJ, Bình An, Dĩ An, Bình Dương', 1, 0, 0, 0),
('6a79b4f5', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.632874, 106.504845, 'Công ty TNHH Trạm xăng dầu Voi Lá', '327 QL1A, Tân Biên, Thành phố Biên Hòa, Đồng Nai', 1, 0, 0, 0),
('6a79b4f6', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.638122, 106.474348, 'Cầu Bến Lức', 'Vĩnh Cửu, Đồng Nai', 0, 0, 0, 1),
('6a79b4f7', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.63677, 106.46969, 'Nhung Sửa Xe Máy', 'Nhung Sửa Xe Máy', 0, 1, 0, 0),
('e3be559fa824', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.634497, 106.466266, 'Cà Phê Thiên Kim', 'Cà Phê Thiên Kim', 0, 0, 1, 0),
('e3be559fa825', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.624363, 106.458798, 'Sửa xe Tài', 'Sửa xe tài', 0, 1, 0, 0),
('e3be559fa826', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.621876, 106.457064, 'Cafe Võng Sao Mai', 'Cafe Võng Sao Mai', 0, 0, 1, 0),
('e3be559fa827', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.610013, 106.448762, 'Cửa Hàng Xăng Dầu 1', 'Cửa Hàng Xăng Dầu 1', 1, 0, 0, 0),
('e3be559fa828', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.593695, 106.438714, 'Cà Phê Cây Dừa', 'Cà Phê Cây Dừa', 0, 0, 1, 0),
('e3be559fa829', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.5900458, 106.437249, 'Tiệm sửa xe 149', 'Tiệm sửa xe 149', 1, 0, 0, 0),
('e3be559fa830', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.56413, 106.420634, 'Trạm Xăng Dầu Hiếu Phương', 'Trạm Xăng Dầu Hiếu Phương', 1, 0, 0, 0),
('e3be559fa831', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.557587, 106.411018, 'Cà Phê Võng 668', 'Cà Phê Võng 668', 0, 0, 1, 0),
('e3be559fa832', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.555816, 106.407572, 'Cầu Tân An Mới, Sông Vàm Cỏ Tây', 'Cầu Tân An Mới, Sông Vàm Cỏ Tây', 0, 0, 0, 1),
('e3be559fa833', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.536232, 106.393876, 'Hùng Sửa Honda', 'Hùng Sửa Honda', 0, 1, 0, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trip_start`
--

CREATE TABLE `trip_start` (
  `uid` int(11) NOT NULL,
  `trip_uid` varchar(100) NOT NULL,
  `trip_route` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `trip_start`
--

INSERT INTO `trip_start` (`uid`, `trip_uid`, `trip_route`) VALUES
(3, '349a5c74-e31b-4cb3-87aa-e3be559fa824', '{\"path\":[[10.93931,106.86912],[10.93972,106.8688],[10.93995,106.8686],[10.93999,106.86858],[10.94002,106.86855],[10.94005,106.86852],[10.94007,106.86848],[10.94008,106.86844],[10.94008,106.86843],[10.94009,106.86842],[10.94009,106.8684],[10.9401,106.86836],[10.94009,106.86833],[10.94009,106.86831],[10.94009,106.86831],[10.94009,106.8683],[10.94009,106.86829],[10.94008,106.86827],[10.94007,106.86823],[10.94006,106.86822],[10.94005,106.8682],[10.94002,106.86817],[10.93999,106.86814],[10.93996,106.86811],[10.93992,106.8681],[10.93988,106.86808],[10.93983,106.86808],[10.93979,106.86808],[10.93975,106.86809],[10.93971,106.8681],[10.9397,106.8681],[10.93967,106.86812],[10.93963,106.86815],[10.9396,106.86818],[10.9396,106.86819],[10.9391,106.8682],[10.93683,106.86815],[10.9367,106.86816],[10.93653,106.86818],[10.93637,106.86824],[10.93624,106.86824],[10.93478,106.86822],[10.93094,106.86815],[10.93046,106.86814],[10.92939,106.86814],[10.9287,106.86811],[10.92801,106.86803],[10.92782,106.868],[10.92754,106.86793],[10.92747,106.86792],[10.92737,106.86785],[10.92721,106.86781],[10.92641,106.86761],[10.92602,106.86749],[10.9256,106.86733],[10.92508,106.86711],[10.92457,106.86686],[10.92399,106.86653],[10.92349,106.86619],[10.92305,106.86586],[10.9227,106.86558],[10.92225,106.86516],[10.92146,106.86437],[10.91746,106.86031],[10.91276,106.85556],[10.90862,106.85137],[10.90847,106.85122],[10.9084,106.85116],[10.90776,106.85057],[10.90737,106.8502],[10.90638,106.84919],[10.90595,106.8487],[10.90559,106.84827],[10.90515,106.84769],[10.90475,106.84712],[10.90451,106.84675],[10.90443,106.84662],[10.90418,106.84618],[10.90391,106.84556],[10.90377,106.84517],[10.903,106.84309],[10.90264,106.84209],[10.90242,106.84146],[10.90171,106.83948],[10.90087,106.83714],[10.9,106.83475],[10.90012,106.8347],[10.89982,106.8339],[10.89968,106.83351],[10.89943,106.83279],[10.89904,106.83168],[10.89877,106.83086],[10.89864,106.83048],[10.89833,106.82962],[10.89798,106.82858],[10.89796,106.82848],[10.89795,106.82836],[10.89796,106.82813],[10.89785,106.82802],[10.89744,106.82767],[10.89727,106.82741],[10.89718,106.82731],[10.89707,106.82721],[10.89692,106.82698],[10.89665,106.82661],[10.89642,106.82633],[10.89634,106.82618],[10.89605,106.82578],[10.89557,106.82524],[10.89511,106.82476],[10.8946,106.8243],[10.89423,106.82402],[10.89378,106.82369],[10.89302,106.82313],[10.89185,106.82226],[10.8902,106.82105],[10.88964,106.82064],[10.88942,106.82048],[10.88893,106.82012],[10.88774,106.81925],[10.88699,106.81869],[10.88582,106.81783],[10.88384,106.81638],[10.88358,106.81618],[10.8831,106.81582],[10.88192,106.81495],[10.88108,106.81434],[10.88033,106.81379],[10.87924,106.81299],[10.87888,106.81272],[10.87861,106.81252],[10.87843,106.81233],[10.8774,106.81155],[10.87733,106.81145],[10.87714,106.81099],[10.87703,106.81091],[10.87541,106.80972],[10.87529,106.80963],[10.87475,106.80924],[10.87463,106.80916],[10.8734,106.80823],[10.87328,106.80814],[10.87245,106.80751],[10.87121,106.80661],[10.8711,106.80653],[10.87095,106.80642],[10.87043,106.80604],[10.86993,106.80562],[10.8692,106.80493],[10.86858,106.80423],[10.86846,106.8041],[10.86811,106.80362],[10.86783,106.80326],[10.86761,106.80296],[10.86733,106.80252],[10.86717,106.80259],[10.86707,106.80261],[10.86699,106.80262],[10.86693,106.80259],[10.86648,106.80182],[10.86608,106.80112],[10.8656,106.80028],[10.8646,106.79858],[10.86403,106.79761],[10.86324,106.79628],[10.86235,106.79478],[10.86219,106.79453],[10.86122,106.79296],[10.86119,106.79291],[10.86114,106.79286],[10.86094,106.79255],[10.86065,106.79209],[10.85812,106.78786],[10.85799,106.78765],[10.85799,106.78754],[10.85796,106.78745],[10.85744,106.78658],[10.85728,106.78631],[10.85664,106.78521],[10.85586,106.78387],[10.85427,106.78123],[10.8538,106.78044],[10.85243,106.77814],[10.85166,106.77684],[10.85131,106.77628],[10.85087,106.77565],[10.85045,106.77511],[10.85027,106.77488],[10.85008,106.77469],[10.84996,106.77457],[10.8499,106.77454],[10.84983,106.77453],[10.84926,106.77398],[10.84916,106.77389],[10.84866,106.77346],[10.84829,106.77319],[10.84833,106.77313],[10.84798,106.77288],[10.8473,106.77246],[10.84641,106.77194],[10.84558,106.77144],[10.84423,106.77066],[10.84258,106.76973],[10.84105,106.76888],[10.84014,106.76838],[10.83904,106.76775],[10.83759,106.76693],[10.83566,106.76582],[10.83559,106.76578],[10.83552,106.76574],[10.83545,106.76571],[10.83515,106.76553],[10.83411,106.76496],[10.83253,106.76407],[10.83167,106.76358],[10.83092,106.76316],[10.82963,106.76243],[10.82806,106.76156],[10.82668,106.76076],[10.82655,106.76069],[10.82532,106.76002],[10.82487,106.75975],[10.82407,106.75932],[10.82368,106.75913],[10.82314,106.7589],[10.82282,106.75878],[10.82227,106.75861],[10.82184,106.75848],[10.82107,106.75827],[10.82029,106.75812],[10.81952,106.75798],[10.81842,106.75778],[10.81732,106.75756],[10.81652,106.75743],[10.8157,106.75728],[10.81489,106.75715],[10.81259,106.75673],[10.811,106.75641],[10.81078,106.75636],[10.81021,106.75621],[10.80997,106.75613],[10.80981,106.75607],[10.8091,106.75582],[10.80868,106.75563],[10.80804,106.7553],[10.80745,106.75493],[10.80731,106.75484],[10.80696,106.7546],[10.80653,106.75426],[10.80609,106.75387],[10.80567,106.75346],[10.80541,106.75317],[10.80518,106.75291],[10.80483,106.75246],[10.80461,106.75215],[10.80436,106.75174],[10.80425,106.75157],[10.80415,106.75141],[10.80401,106.75117],[10.80367,106.75045],[10.8035,106.75004],[10.80332,106.74953],[10.80321,106.74916],[10.80314,106.7489],[10.803,106.74827],[10.80284,106.74752],[10.80274,106.74701],[10.80264,106.74645],[10.80253,106.74588],[10.8024,106.74522],[10.80225,106.74425],[10.80214,106.74367],[10.80167,106.74115],[10.80111,106.73816],[10.80084,106.73672],[10.80029,106.73371],[10.80025,106.7336],[10.80022,106.73354],[10.80019,106.73352],[10.80006,106.73294],[10.7999,106.73222],[10.79985,106.73198],[10.79987,106.73196],[10.79988,106.73189],[10.79985,106.73173],[10.79895,106.72707],[10.79874,106.72598],[10.79814,106.72261],[10.7981,106.72241],[10.79806,106.72229],[10.79802,106.72224],[10.79802,106.72202],[10.79802,106.72172],[10.79804,106.72155],[10.79806,106.72144],[10.7981,106.72121],[10.79817,106.72094],[10.79822,106.7208],[10.79852,106.72013],[10.79867,106.71985],[10.79894,106.71938],[10.79901,106.71935],[10.79907,106.7193],[10.79916,106.71916],[10.79942,106.71872],[10.79967,106.71828],[10.79988,106.71792],[10.8001,106.71742],[10.80027,106.71704],[10.80033,106.71687],[10.80035,106.71678],[10.80032,106.71669],[10.8004,106.71652],[10.8006,106.71603],[10.80072,106.71575],[10.80074,106.7157],[10.80084,106.71544],[10.80095,106.71513],[10.8012,106.71431],[10.80136,106.71374],[10.80141,106.71353],[10.80139,106.7135],[10.80138,106.71347],[10.80141,106.71327],[10.80145,106.71295],[10.80147,106.71271],[10.80151,106.71179],[10.80149,106.71126],[10.80146,106.71104],[10.8014,106.71066],[10.80123,106.70983],[10.80115,106.70952],[10.80112,106.70937],[10.80112,106.70932],[10.80113,106.70928],[10.80092,106.70867],[10.80093,106.70864],[10.80091,106.70856],[10.80076,106.70821],[10.80063,106.70795],[10.80026,106.70733],[10.79987,106.70672],[10.79958,106.70632],[10.79919,106.70586],[10.79888,106.70553],[10.79479,106.70164],[10.79458,106.70144],[10.79451,106.70138],[10.79394,106.7009],[10.79388,106.70085],[10.79336,106.70035],[10.793,106.70002],[10.79262,106.69965],[10.79263,106.69962],[10.79263,106.69958],[10.79263,106.69954],[10.79263,106.69951],[10.79263,106.69948],[10.79261,106.69942],[10.79258,106.69936],[10.79255,106.6993],[10.7925,106.69924],[10.7925,106.69923],[10.79245,106.69919],[10.79242,106.69917],[10.79239,106.69916],[10.79237,106.69915],[10.79234,106.69914],[10.79232,106.69914],[10.79229,106.69914],[10.79227,106.69914],[10.79222,106.69909],[10.79201,106.69889],[10.79194,106.69883],[10.79168,106.69859],[10.79114,106.69806],[10.79093,106.69786],[10.79066,106.6976],[10.79061,106.69755],[10.79059,106.69748],[10.79058,106.69739],[10.7906,106.69725],[10.79074,106.69711],[10.79083,106.697],[10.79097,106.69686],[10.79118,106.69662],[10.79164,106.69614],[10.79179,106.69598],[10.79181,106.69594],[10.79181,106.69582],[10.79118,106.69524],[10.79098,106.69504],[10.79067,106.69473],[10.79048,106.69455],[10.79025,106.6943],[10.79013,106.69419],[10.7898,106.69384],[10.78941,106.69348],[10.7892,106.69328],[10.78894,106.69302],[10.7887,106.69279],[10.78838,106.69247],[10.78818,106.69228],[10.78786,106.69197],[10.78745,106.69157],[10.7871,106.69124],[10.78701,106.69114],[10.78692,106.69105],[10.78677,106.6909],[10.78661,106.69075],[10.78654,106.69068],[10.78643,106.69056],[10.78627,106.6904],[10.78586,106.69002],[10.78541,106.68957],[10.78501,106.68917],[10.78492,106.68907],[10.78489,106.68904],[10.78455,106.6887],[10.78445,106.68861],[10.78421,106.68837],[10.78387,106.68803],[10.78378,106.68794],[10.78361,106.68777],[10.78328,106.68745],[10.78321,106.68738],[10.78266,106.68683],[10.78247,106.68664],[10.78178,106.68595],[10.78127,106.68543],[10.78009,106.68425],[10.77889,106.68304],[10.7785,106.68266],[10.77837,106.68253],[10.77824,106.68241],[10.77794,106.6821],[10.77787,106.68196],[10.77792,106.68195],[10.77796,106.68193],[10.778,106.68191],[10.77803,106.68189],[10.77806,106.68186],[10.77809,106.68182],[10.77811,106.68178],[10.77813,106.68174],[10.77814,106.6817],[10.77814,106.68166],[10.77814,106.68162],[10.77813,106.68158],[10.77812,106.68155],[10.7781,106.68152],[10.77809,106.68148],[10.77806,106.68145],[10.77802,106.68142],[10.77799,106.6814],[10.77795,106.68138],[10.77795,106.68138],[10.77791,106.68136],[10.77786,106.68136],[10.77783,106.68136],[10.7777,106.68121],[10.7774,106.68099],[10.77646,106.68048],[10.77562,106.68001],[10.77531,106.67984],[10.77521,106.67976],[10.77507,106.67962],[10.77498,106.6795],[10.7739,106.67775],[10.77304,106.67638],[10.77242,106.67538],[10.77221,106.67504],[10.77172,106.67425],[10.77164,106.67412],[10.77156,106.67399],[10.77137,106.67369],[10.77103,106.67309],[10.77098,106.67301],[10.77032,106.6718],[10.77012,106.67145],[10.77008,106.67137],[10.76988,106.67101],[10.76972,106.67072],[10.76944,106.67018],[10.76936,106.67012],[10.76927,106.66998],[10.76911,106.6697],[10.76873,106.66896],[10.76817,106.6679],[10.76766,106.66697],[10.76672,106.66528],[10.76669,106.6652],[10.76668,106.66511],[10.76654,106.66486],[10.76612,106.66409],[10.76606,106.66399],[10.76579,106.66347],[10.76538,106.66271],[10.76491,106.66184],[10.76469,106.66144],[10.76453,106.66113],[10.76437,106.66085],[10.76409,106.66032],[10.76401,106.66017],[10.76394,106.66004],[10.76391,106.65999],[10.76388,106.65993],[10.7638,106.65979],[10.76336,106.65898],[10.76264,106.65764],[10.76258,106.65754],[10.76229,106.65703],[10.76224,106.65694],[10.76216,106.6568],[10.76163,106.65582],[10.76151,106.6556],[10.76139,106.65538],[10.76106,106.65478],[10.76046,106.65369],[10.76023,106.65328],[10.75983,106.65254],[10.75972,106.65233],[10.75963,106.65216],[10.75954,106.65199],[10.75944,106.65181],[10.75922,106.65139],[10.75918,106.65132],[10.75894,106.65087],[10.75836,106.64979],[10.75813,106.64937],[10.75803,106.64919],[10.75792,106.64898],[10.75771,106.6486],[10.75755,106.6483],[10.75741,106.64804],[10.75713,106.64751],[10.75674,106.6468],[10.7563,106.64598],[10.7562,106.64579],[10.75596,106.64534],[10.75592,106.64531],[10.75587,106.64524],[10.75581,106.64516],[10.75489,106.64351],[10.75442,106.64275],[10.75436,106.64261],[10.75436,106.6426],[10.75434,106.64253],[10.75432,106.64227],[10.75435,106.64198],[10.75454,106.6403],[10.75458,106.63998],[10.75461,106.63984],[10.75466,106.6397],[10.75468,106.63949],[10.7547,106.6392],[10.75474,106.63885],[10.75475,106.63858],[10.75477,106.63825],[10.75479,106.63798],[10.75479,106.6378],[10.75479,106.63756],[10.75479,106.63742],[10.75477,106.63607],[10.75475,106.63587],[10.7547,106.63569],[10.75466,106.63555],[10.75456,106.6353],[10.75441,106.63504],[10.75421,106.63464],[10.75421,106.63464],[10.75422,106.63464],[10.75424,106.6346],[10.75425,106.63456],[10.75426,106.63451],[10.75427,106.63447],[10.75426,106.63443],[10.75425,106.63438],[10.75424,106.63434],[10.75422,106.6343],[10.75422,106.6343],[10.75419,106.63427],[10.75416,106.63424],[10.75416,106.63424],[10.75416,106.63424],[10.75413,106.63422],[10.75409,106.63419],[10.75406,106.63418],[10.75405,106.63418],[10.75405,106.63418],[10.75401,106.63417],[10.75396,106.63416],[10.75391,106.63417],[10.75391,106.63417],[10.75377,106.63399],[10.75368,106.63385],[10.75336,106.63335],[10.75308,106.63294],[10.75264,106.63234],[10.7525,106.63217],[10.75198,106.63153],[10.75064,106.62979],[10.74985,106.62879],[10.74978,106.62869],[10.74934,106.62813],[10.74825,106.62677],[10.74794,106.6264],[10.74607,106.6241],[10.74593,106.62393],[10.74584,106.62384],[10.74578,106.62379],[10.74573,106.62375],[10.74572,106.62371],[10.7457,106.62367],[10.74567,106.62364],[10.74565,106.62361],[10.74524,106.62311],[10.74478,106.62256],[10.74386,106.62145],[10.74349,106.621],[10.74336,106.62083],[10.74289,106.62022],[10.74249,106.61971],[10.74199,106.61908],[10.74199,106.61908],[10.74145,106.61843],[10.74125,106.6182],[10.7407,106.61755],[10.74039,106.6172],[10.7402,106.61696],[10.73989,106.6166],[10.73978,106.61647],[10.73966,106.61633],[10.73891,106.61546],[10.73867,106.61526],[10.73858,106.61519],[10.7385,106.61516],[10.73842,106.61515],[10.73836,106.61511],[10.73825,106.61504],[10.73795,106.61485],[10.7378,106.61476],[10.73741,106.61452],[10.73724,106.61443],[10.73717,106.61438],[10.73716,106.61432],[10.73711,106.61427],[10.73702,106.6142],[10.7363,106.61377],[10.73601,106.6136],[10.73555,106.61333],[10.73544,106.61326],[10.73497,106.61298],[10.73439,106.61268],[10.73322,106.61198],[10.73296,106.61183],[10.73142,106.61091],[10.73103,106.61067],[10.73094,106.61062],[10.73062,106.61038],[10.73035,106.61014],[10.73015,106.60994],[10.72998,106.60971],[10.72985,106.60954],[10.7298,106.60946],[10.72968,106.60928],[10.7293,106.60871],[10.72909,106.60838],[10.72894,106.60815],[10.72847,106.60746],[10.72844,106.60742],[10.7284,106.60739],[10.72828,106.60721],[10.72751,106.60598],[10.7273,106.60566],[10.72681,106.60493],[10.72648,106.60443],[10.72595,106.60364],[10.72581,106.60342],[10.7256,106.60313],[10.7254,106.60288],[10.72525,106.60272],[10.72513,106.60261],[10.7246,106.60218],[10.72431,106.60197],[10.72418,106.60185],[10.72412,106.60176],[10.72408,106.60167],[10.72405,106.60149],[10.72406,106.60147],[10.72407,106.60144],[10.72407,106.6014],[10.72407,106.60137],[10.72407,106.60132],[10.72406,106.60128],[10.72405,106.60124],[10.72403,106.6012],[10.724,106.60116],[10.72397,106.60113],[10.72394,106.6011],[10.7239,106.60108],[10.72386,106.60106],[10.72381,106.60105],[10.72377,106.60104],[10.72362,106.60099],[10.72344,106.60094],[10.72265,106.60082],[10.72244,106.60078],[10.72239,106.60077],[10.72233,106.60078],[10.7223,106.60077],[10.72183,106.60061],[10.7212,106.60046],[10.72089,106.60039],[10.7198,106.60019],[10.71956,106.60016],[10.71772,106.59985],[10.71661,106.59966],[10.71568,106.5995],[10.71448,106.5993],[10.7132,106.59907],[10.7127,106.59898],[10.71193,106.59885],[10.71165,106.5988],[10.71142,106.59878],[10.71132,106.59877],[10.71053,106.59872],[10.71029,106.59869],[10.70882,106.59844],[10.70844,106.59837],[10.70811,106.59831],[10.70739,106.59819],[10.70663,106.59806],[10.70614,106.59794],[10.70588,106.59787],[10.7055,106.59773],[10.70478,106.59742],[10.70441,106.59729],[10.70396,106.59721],[10.7035,106.5972],[10.70308,106.59719],[10.70242,106.59721],[10.70078,106.59729],[10.70022,106.5973],[10.69968,106.59729],[10.69924,106.59724],[10.69798,106.59704],[10.69734,106.59689],[10.69702,106.59679],[10.69674,106.5967],[10.69653,106.59664],[10.69424,106.59592],[10.69399,106.59584],[10.6928,106.59546],[10.69225,106.59528],[10.68748,106.59373],[10.68677,106.59348],[10.68666,106.59344],[10.6864,106.59333],[10.68626,106.59327],[10.68603,106.59316],[10.68587,106.59307],[10.68567,106.59296],[10.68513,106.59265],[10.68437,106.59208],[10.684,106.59173],[10.68373,106.59145],[10.68337,106.59108],[10.68276,106.59047],[10.68241,106.59011],[10.68194,106.58964],[10.68173,106.5894],[10.68159,106.58924],[10.68133,106.58893],[10.6808,106.5883],[10.68041,106.58783],[10.67955,106.58678],[10.67882,106.58593],[10.678,106.58496],[10.67733,106.58417],[10.67708,106.58389],[10.67576,106.58231],[10.67521,106.58173],[10.67504,106.58155],[10.67403,106.58051],[10.6726,106.57908],[10.67198,106.57846],[10.67138,106.57784],[10.6708,106.57714],[10.67034,106.57657],[10.66976,106.57585],[10.6692,106.57516],[10.66901,106.57491],[10.66872,106.57454],[10.66843,106.57418],[10.66768,106.57326],[10.66666,106.572],[10.66655,106.57186],[10.66606,106.57125],[10.6657,106.5708],[10.66487,106.56976],[10.66437,106.56915],[10.66426,106.56902],[10.66401,106.56866],[10.6636,106.56801],[10.6633,106.56755],[10.66296,106.56701],[10.66282,106.56677],[10.66194,106.56534],[10.66161,106.56479],[10.66131,106.56431],[10.66062,106.56317],[10.6605,106.56297],[10.66037,106.56275],[10.66032,106.56258],[10.66035,106.56215],[10.66033,106.56198],[10.66017,106.56163],[10.66016,106.5616],[10.65996,106.56134],[10.65975,106.56118],[10.65932,106.56094],[10.65923,106.56083],[10.659,106.56046],[10.65886,106.5602],[10.65883,106.56014],[10.65867,106.55985],[10.6583,106.5592],[10.65781,106.55831],[10.65731,106.55742],[10.65681,106.55654],[10.65646,106.55593],[10.65645,106.55592],[10.65581,106.55479],[10.65542,106.55416],[10.65528,106.55397],[10.65516,106.5538],[10.65435,106.55285],[10.653,106.55122],[10.65092,106.54866],[10.65049,106.54813],[10.65014,106.54768],[10.64958,106.54698],[10.64605,106.54261],[10.64477,106.54102],[10.64422,106.54034],[10.6441,106.54019],[10.64315,106.53902],[10.64278,106.53849],[10.64259,106.53821],[10.64231,106.53772],[10.64127,106.53583],[10.64007,106.53362],[10.63936,106.53233],[10.63898,106.53163],[10.63866,106.53104],[10.63769,106.52928],[10.63746,106.52876],[10.63722,106.52814],[10.63612,106.5253],[10.63482,106.52187],[10.63464,106.52132],[10.63433,106.51985],[10.63328,106.51459],[10.63272,106.51181],[10.63257,106.51106],[10.63235,106.50995],[10.63225,106.5094],[10.63219,106.50907],[10.63218,106.50861],[10.63218,106.50858],[10.63224,106.50818],[10.6326,106.50592],[10.63261,106.50582],[10.63313,106.50259],[10.63339,106.50084],[10.63349,106.50019],[10.63372,106.49888],[10.63393,106.49762],[10.63428,106.49603],[10.63502,106.49295],[10.63569,106.49027],[10.63575,106.49],[10.63586,106.48953],[10.63683,106.48532],[10.63696,106.4847],[10.63751,106.48222],[10.63752,106.48216],[10.63766,106.4815],[10.63785,106.48059],[10.63792,106.48026],[10.63808,106.47952],[10.63834,106.4783],[10.6384,106.47789],[10.63841,106.4777],[10.63842,106.4776],[10.63842,106.47728],[10.63836,106.47648],[10.63795,106.47234],[10.63791,106.47201],[10.63784,106.47172],[10.63774,106.47141],[10.63758,106.471],[10.63745,106.47072],[10.63726,106.47042],[10.63642,106.4692],[10.63632,106.46905],[10.63607,106.46868],[10.63458,106.46645],[10.6343,106.46605],[10.63402,106.46572],[10.63346,106.46522],[10.63298,106.46486],[10.63289,106.4648],[10.62814,106.46149],[10.6243,106.45883],[10.61806,106.45448],[10.61196,106.45018],[10.61084,106.44939],[10.60931,106.44824],[10.60704,106.44645],[10.60504,106.44487],[10.60385,106.44395],[10.60377,106.44389],[10.60359,106.44375],[10.60245,106.44288],[10.60224,106.44273],[10.60154,106.44227],[10.6007,106.44182],[10.59998,106.44149],[10.59903,106.44109],[10.59874,106.44096],[10.59841,106.44082],[10.59418,106.439],[10.58773,106.43621],[10.58688,106.43586],[10.58645,106.43568],[10.58535,106.43527],[10.5845,106.43496],[10.58313,106.43446],[10.58098,106.43367],[10.58027,106.43336],[10.57989,106.43315],[10.57886,106.43257],[10.57853,106.43238],[10.57788,106.43198],[10.57696,106.43132],[10.57618,106.43069],[10.57364,106.42843],[10.57241,106.42734],[10.57038,106.42554],[10.56818,106.4236],[10.56807,106.42352],[10.56649,106.42236],[10.56367,106.42035],[10.5635,106.42023],[10.56297,106.41985],[10.56211,106.41924],[10.56191,106.41908],[10.56171,106.41888],[10.5617,106.41884],[10.5617,106.4188],[10.56168,106.41877],[10.56167,106.41873],[10.56164,106.4187],[10.56162,106.41867],[10.56159,106.41865],[10.56155,106.41862],[10.56151,106.41861],[10.56143,106.41855],[10.56134,106.41845],[10.56126,106.41833],[10.55803,106.41189],[10.55695,106.40985],[10.55665,106.40929],[10.55594,106.40791],[10.55495,106.40591],[10.55467,106.40532],[10.55264,106.40134],[10.55234,106.40079],[10.55207,106.40037],[10.55158,106.3997],[10.55129,106.39934],[10.55064,106.39863],[10.55052,106.39851],[10.55036,106.39837],[10.55012,106.39815],[10.54975,106.39785],[10.54933,106.39754],[10.54872,106.39714],[10.54825,106.39685],[10.54759,106.39652],[10.54693,106.39625],[10.54616,106.39598],[10.54551,106.39577],[10.54422,106.3955],[10.54374,106.3954],[10.54077,106.39481],[10.53421,106.39353],[10.53373,106.39344],[10.53101,106.3929],[10.5301,106.39269],[10.52956,106.39255],[10.52897,106.39237],[10.52543,106.39124],[10.52447,106.39093],[10.52426,106.39094],[10.52416,106.39096],[10.52401,106.39084],[10.52391,106.3908],[10.52361,106.39072],[10.5225,106.39054],[10.52234,106.39049],[10.52123,106.38984],[10.52073,106.38954],[10.51956,106.38882],[10.51912,106.38855],[10.51865,106.38826],[10.51835,106.38807],[10.51737,106.38747],[10.51646,106.38694],[10.51127,106.38388],[10.50899,106.38255],[10.50662,106.3812],[10.50461,106.38004],[10.50313,106.37925],[10.50282,106.37908],[10.50267,106.379],[10.50225,106.37878],[10.5015,106.37838],[10.49667,106.37578],[10.49419,106.37445],[10.49153,106.37295],[10.49011,106.37207],[10.48909,106.37137],[10.48808,106.37068],[10.48801,106.37064],[10.48766,106.37043],[10.48708,106.37007],[10.48538,106.36888],[10.48531,106.36883],[10.48315,106.36731],[10.4797,106.3645],[10.4772,106.36246],[10.47568,106.36128],[10.47511,106.36084],[10.47427,106.36019],[10.47343,106.35955],[10.47206,106.35848],[10.46931,106.35635],[10.46801,106.35534],[10.4676,106.35503],[10.46615,106.35393],[10.46501,106.35306],[10.46488,106.35294],[10.46423,106.3522],[10.46372,106.35164],[10.4632,106.35119],[10.4629,106.35093],[10.46255,106.35069],[10.46186,106.35024],[10.46161,106.35008],[10.46111,106.34976],[10.46028,106.34923],[10.45982,106.34893],[10.45921,106.34856],[10.45752,106.3476],[10.45655,106.34705],[10.45457,106.34591],[10.45387,106.34551],[10.45341,106.34525],[10.45318,106.34512],[10.45251,106.34472],[10.4524,106.34466],[10.45096,106.34385],[10.4505,106.3436],[10.44996,106.34331],[10.4498,106.34322],[10.44958,106.34315],[10.4494,106.34311],[10.44921,106.34307],[10.44857,106.343],[10.44746,106.34288],[10.4469,106.34282],[10.44613,106.34274],[10.44565,106.34269],[10.44508,106.34264],[10.44404,106.34253],[10.44398,106.34253],[10.44208,106.34233],[10.44041,106.34214],[10.43681,106.34178],[10.43181,106.34128],[10.43084,106.34118],[10.43007,106.34109],[10.42846,106.34092],[10.42757,106.34083],[10.42634,106.3407],[10.42353,106.34041],[10.42291,106.34034],[10.42133,106.34018],[10.42105,106.34015],[10.42059,106.34011],[10.4201,106.34005],[10.41646,106.33967],[10.41552,106.33958],[10.41473,106.3395],[10.4145,106.33947],[10.41222,106.33923],[10.41093,106.3391],[10.41054,106.33906],[10.40921,106.33894],[10.40684,106.33872],[10.40636,106.33867],[10.40591,106.33863],[10.40351,106.33838],[10.40037,106.33806],[10.39842,106.33785],[10.3967,106.33767],[10.3959,106.33758],[10.39508,106.3375],[10.39403,106.3374],[10.39344,106.3374],[10.3934,106.33738],[10.39335,106.33736],[10.39307,106.33738],[10.39281,106.33742],[10.39261,106.33745],[10.39244,106.33748],[10.3924,106.33751],[10.39237,106.33754],[10.39211,106.33759],[10.39192,106.33764],[10.39169,106.33771],[10.38945,106.33849],[10.38818,106.33893],[10.38792,106.33902],[10.38657,106.33948],[10.38646,106.33951],[10.38586,106.33972],[10.38544,106.33986],[10.38416,106.34029],[10.38395,106.34034],[10.38382,106.34036],[10.38371,106.34035],[10.38362,106.34033],[10.3836,106.34031],[10.38358,106.34029],[10.38356,106.34026],[10.38353,106.34025],[10.3835,106.34023],[10.38346,106.34022],[10.38342,106.34021],[10.38338,106.34022],[10.38334,106.34022],[10.3833,106.34024],[10.38326,106.34026],[10.38323,106.34029],[10.38321,106.34031],[10.38319,106.34035],[10.38317,106.34038],[10.38316,106.34042],[10.38316,106.34046],[10.38303,106.3406],[10.38293,106.34068],[10.38258,106.34084],[10.38235,106.34092],[10.38061,106.34152],[10.38001,106.34173],[10.37861,106.34222],[10.37854,106.34225],[10.37836,106.34232],[10.37812,106.34244],[10.37785,106.3426],[10.37763,106.34275],[10.37744,106.3429],[10.37736,106.34297],[10.37697,106.34333],[10.37673,106.34361],[10.37664,106.34366],[10.37657,106.34367],[10.37652,106.34367],[10.37641,106.34364],[10.3757,106.34303],[10.37534,106.34271],[10.37517,106.34258],[10.37514,106.34256],[10.37498,106.34246],[10.37474,106.34236],[10.37451,106.34227],[10.37437,106.34224],[10.37345,106.34207],[10.37164,106.34175],[10.37129,106.34169],[10.37006,106.34149],[10.36937,106.34137],[10.36894,106.34129],[10.36872,106.34125],[10.36642,106.34084],[10.36621,106.3408],[10.36445,106.34051],[10.3643,106.3405],[10.36368,106.34048],[10.363,106.34047],[10.36261,106.34047],[10.36185,106.34046],[10.36101,106.34046],[10.36017,106.34044],[10.35852,106.34042],[10.3577,106.34041],[10.35689,106.3404],[10.35604,106.34039],[10.35477,106.34036],[10.3542,106.34035],[10.35381,106.34035],[10.3537,106.34035],[10.35352,106.34037],[10.35337,106.34032],[10.35325,106.34026],[10.35312,106.34018],[10.35294,106.34002],[10.35291,106.33996],[10.35279,106.33989],[10.35265,106.33988],[10.35254,106.3399],[10.35023,106.34056],[10.35017,106.34055],[10.35016,106.34055],[10.35008,106.34056],[10.35005,106.34057],[10.35002,106.34059],[10.34999,106.3406],[10.34996,106.34061],[10.34994,106.34063],[10.34993,106.34064],[10.34992,106.34065],[10.34807,106.34136],[10.34799,106.34145],[10.34794,106.3416],[10.34735,106.34174],[10.34691,106.34197],[10.34733,106.34339],[10.34691,106.34197],[10.34735,106.34174],[10.34794,106.3416],[10.35006,106.34117],[10.35012,106.34139],[10.35021,106.3417],[10.35025,106.34171],[10.35028,106.34172],[10.35031,106.34171],[10.35034,106.34171],[10.35038,106.34171],[10.35045,106.3417],[10.35047,106.34168],[10.35052,106.34164],[10.35184,106.34136],[10.35262,106.34121],[10.35285,106.34116],[10.35292,106.34114],[10.35297,106.34111],[10.35302,106.34107],[10.35312,106.3409],[10.35315,106.34083],[10.35319,106.34076],[10.35323,106.3407],[10.3533,106.34061],[10.35339,106.34055],[10.35356,106.34045],[10.35381,106.34045],[10.3542,106.34045],[10.35463,106.34046],[10.35604,106.34049],[10.35683,106.3405],[10.35852,106.34052],[10.361,106.34056],[10.36208,106.34056],[10.3626,106.34057],[10.36366,106.34058],[10.3643,106.3406],[10.36448,106.34061],[10.36576,106.34083],[10.36617,106.3409],[10.3664,106.34094],[10.36669,106.34099],[10.3687,106.34135],[10.36935,106.34146],[10.37005,106.34159],[10.37121,106.34178],[10.37163,106.34185],[10.37316,106.34212],[10.37431,106.34233],[10.37448,106.34237],[10.3747,106.34245],[10.37493,106.34255],[10.37512,106.34266],[10.37527,106.34278],[10.37583,106.34327],[10.37636,106.34373],[10.37645,106.3438],[10.37653,106.34383],[10.37659,106.34392],[10.37705,106.3434],[10.3773,106.34316],[10.37748,106.343],[10.3776,106.3429],[10.37769,106.34283],[10.3779,106.34269],[10.37817,106.34253],[10.37841,106.34241],[10.37857,106.34234],[10.37882,106.34225],[10.37989,106.34187],[10.38064,106.34161],[10.38261,106.34093],[10.38336,106.3407],[10.3834,106.34071],[10.38344,106.34071],[10.38347,106.3407],[10.38351,106.34069],[10.38354,106.34067],[10.38357,106.34065],[10.38359,106.34062],[10.38419,106.34039],[10.38452,106.34028],[10.38566,106.33989],[10.38795,106.33911],[10.38795,106.33911],[10.38874,106.33884],[10.38954,106.33856],[10.3904,106.33826],[10.39194,106.33774],[10.39213,106.33768],[10.3924,106.33763],[10.39246,106.33764],[10.39264,106.33762],[10.39281,106.33759],[10.39309,106.33755],[10.39333,106.33752],[10.39344,106.3375],[10.39392,106.3375],[10.39432,106.33752],[10.39441,106.33753],[10.39589,106.33768],[10.39631,106.33773],[10.39715,106.33782],[10.39788,106.3379],[10.39915,106.33803],[10.40094,106.33822],[10.40268,106.3384],[10.40455,106.33859],[10.40736,106.33887],[10.40795,106.33892],[10.40843,106.33897],[10.4092,106.33904],[10.41061,106.33918],[10.41336,106.33946],[10.41449,106.33958],[10.41556,106.33969],[10.41677,106.3398],[10.41745,106.33987],[10.42056,106.3402],[10.42186,106.34033],[10.42367,106.34052],[10.42438,106.3406],[10.42635,106.3408],[10.42761,106.34093],[10.42844,106.34102],[10.43006,106.34119],[10.43135,106.34133],[10.4325,106.34145],[10.43372,106.34157],[10.43656,106.34186],[10.43721,106.34192],[10.43875,106.34208],[10.43997,106.3422],[10.44039,106.34224],[10.44127,106.34234],[10.44273,106.3425],[10.44395,106.34263],[10.4446,106.34269],[10.44506,106.34273],[10.44612,106.34284],[10.44741,106.34297],[10.4487,106.34311],[10.44919,106.34317],[10.44938,106.3432],[10.44955,106.34324],[10.44976,106.34332],[10.44981,106.34334],[10.44992,106.3434],[10.45061,106.34378],[10.45136,106.34419],[10.45246,106.34481],[10.45313,106.34521],[10.45378,106.34557],[10.45453,106.34599],[10.45686,106.34734],[10.45716,106.34751],[10.45739,106.34765],[10.45892,106.34851],[10.45973,106.349],[10.4605,106.34949],[10.46086,106.34972],[10.4621,106.35052],[10.46273,106.35093],[10.46308,106.35121],[10.46365,106.35171],[10.46416,106.35227],[10.46481,106.353],[10.46494,106.35313],[10.46591,106.35387],[10.46628,106.35416],[10.46682,106.35457],[10.46748,106.35507],[10.46795,106.35542],[10.47151,106.35818],[10.47198,106.35855],[10.47381,106.35996],[10.47559,106.36134],[10.47663,106.36215],[10.47726,106.36264],[10.47963,106.36457],[10.48211,106.36659],[10.48309,106.36739],[10.48502,106.36875],[10.48532,106.36896],[10.48578,106.36928],[10.48696,106.37011],[10.48762,106.3705],[10.48799,106.37074],[10.488,106.37075],[10.48846,106.37106],[10.48896,106.3714],[10.48989,106.37204],[10.49148,106.37304],[10.49414,106.37453],[10.49888,106.37709],[10.50141,106.37845],[10.50226,106.3789],[10.50262,106.37909],[10.50277,106.37917],[10.50314,106.37937],[10.50403,106.37984],[10.50472,106.38021],[10.50658,106.38128],[10.50793,106.38205],[10.50843,106.38233],[10.50896,106.38262],[10.51122,106.38397],[10.51232,106.38462],[10.51642,106.38703],[10.51727,106.38753],[10.51831,106.38817],[10.51911,106.38866],[10.52004,106.38923],[10.52066,106.38961],[10.52126,106.38997],[10.52239,106.39064],[10.52251,106.39066],[10.5226,106.39069],[10.5227,106.39074],[10.52383,106.39146],[10.52386,106.39148],[10.52389,106.39151],[10.52393,106.39153],[10.52397,106.39154],[10.52402,106.39155],[10.52406,106.39155],[10.5241,106.39154],[10.52414,106.39153],[10.52418,106.39151],[10.52422,106.39149],[10.52425,106.39146],[10.52428,106.39143],[10.52431,106.3914],[10.52433,106.39136],[10.52434,106.39133],[10.52435,106.39129],[10.52447,106.39118],[10.52455,106.39115],[10.52467,106.39112],[10.52481,106.39114],[10.52538,106.39133],[10.52781,106.3921],[10.52953,106.39264],[10.53007,106.39279],[10.53098,106.393],[10.53371,106.39353],[10.5342,106.39363],[10.54075,106.39491],[10.54212,106.39518],[10.54238,106.39524],[10.54372,106.3955],[10.54522,106.39581],[10.54559,106.3959],[10.54632,106.39618],[10.54688,106.39637],[10.54754,106.39664],[10.54818,106.39697],[10.54866,106.39725],[10.54925,106.39764],[10.54967,106.39795],[10.55004,106.39824],[10.55024,106.39843],[10.5504,106.39858],[10.55055,106.39872],[10.55119,106.39942],[10.55148,106.39978],[10.55196,106.40044],[10.55223,106.40086],[10.55253,106.4014],[10.55295,106.40222],[10.55456,106.40538],[10.55487,106.40595],[10.55585,106.40795],[10.55656,106.40933],[10.55707,106.4103],[10.55769,106.41145],[10.55833,106.41269],[10.56117,106.41837],[10.56121,106.4185],[10.56123,106.41866],[10.56121,106.41868],[10.56119,106.4187],[10.56117,106.41874],[10.56115,106.41877],[10.56114,106.41881],[10.56113,106.41885],[10.56113,106.41889],[10.56114,106.41893],[10.56115,106.41897],[10.56117,106.41901],[10.56119,106.41905],[10.56122,106.41908],[10.56125,106.41911],[10.56129,106.41913],[10.56132,106.41915],[10.56136,106.41916],[10.56141,106.41917],[10.56145,106.41917],[10.56149,106.41916],[10.56153,106.41915],[10.56157,106.41913],[10.56176,106.41918],[10.56188,106.41923],[10.56208,106.41936],[10.56291,106.41995],[10.56343,106.42031],[10.56362,106.42045],[10.56505,106.42146],[10.5672,106.42302],[10.56812,106.42369],[10.57059,106.42588],[10.57304,106.42805],[10.57357,106.42851],[10.57614,106.4308],[10.57766,106.43209],[10.5782,106.43257],[10.57837,106.4327],[10.57851,106.43277],[10.57872,106.43288],[10.57941,106.43323],[10.58,106.43349],[10.58137,106.43393],[10.58309,106.43457],[10.58641,106.43578],[10.58793,106.43642],[10.59115,106.43781],[10.59406,106.43907],[10.59703,106.44035],[10.59733,106.44048],[10.59787,106.44069],[10.59853,106.44098],[10.59869,106.44105],[10.59895,106.44118],[10.59955,106.44157],[10.60333,106.4442],[10.60337,106.44423],[10.60357,106.44437],[10.60528,106.44563],[10.60828,106.4477],[10.6119,106.45027],[10.61406,106.4518],[10.61773,106.45438],[10.62368,106.45854],[10.62423,106.45892],[10.63121,106.46376],[10.63292,106.46495],[10.63339,106.4653],[10.63394,106.4658],[10.63421,106.46611],[10.63448,106.46651],[10.63523,106.46762],[10.63623,106.46912],[10.63624,106.46912],[10.63715,106.4705],[10.63733,106.4708],[10.63744,106.47103],[10.63753,106.47126],[10.63761,106.4715],[10.63767,106.47174],[10.63814,106.47664],[10.63821,106.47754],[10.63823,106.47794],[10.63824,106.47807],[10.63823,106.47828],[10.63816,106.47864],[10.63782,106.48024],[10.63752,106.48164],[10.6374,106.4822],[10.63686,106.48467],[10.63672,106.4853],[10.63644,106.48652],[10.6363,106.48714],[10.63611,106.48794],[10.63561,106.49012],[10.63472,106.49371],[10.63464,106.49409],[10.63417,106.496],[10.63386,106.49743],[10.63383,106.4976],[10.63366,106.49859],[10.63361,106.49886],[10.63356,106.49914],[10.63343,106.49993],[10.63338,106.50018],[10.63302,106.50257],[10.6325,106.50581],[10.63249,106.5059],[10.63213,106.50816],[10.63207,106.50857],[10.63208,106.50908],[10.63214,106.50941],[10.63247,106.51108],[10.63423,106.51988],[10.63454,106.52135],[10.63471,106.52191],[10.63602,106.52533],[10.63642,106.52638],[10.63736,106.52881],[10.63759,106.52933],[10.63794,106.52995],[10.63803,106.53012],[10.63997,106.53367],[10.64143,106.53635],[10.64228,106.53788],[10.6425,106.53827],[10.64309,106.53911],[10.64329,106.53937],[10.64413,106.54041],[10.64914,106.5466],[10.6495,106.54706],[10.65044,106.54824],[10.65327,106.55174],[10.65426,106.55293],[10.65508,106.55387],[10.65519,106.55403],[10.65533,106.55422],[10.65571,106.55484],[10.65633,106.55592],[10.65634,106.55594],[10.65679,106.55672],[10.6574,106.55777],[10.65746,106.55789],[10.65785,106.55857],[10.65843,106.55961],[10.65906,106.56074],[10.65913,106.56093],[10.65915,106.56118],[10.65915,106.56127],[10.65926,106.56177],[10.65939,106.56213],[10.65968,106.56248],[10.6598,106.56255],[10.66013,106.5627],[10.66028,106.56282],[10.66045,106.56306],[10.66054,106.56322],[10.66224,106.56601],[10.66285,106.56701],[10.66343,106.56795],[10.66393,106.56873],[10.66406,106.56891],[10.66426,106.56917],[10.66478,106.56982],[10.66574,106.57103],[10.66596,106.57131],[10.66615,106.57154],[10.66636,106.5718],[10.66794,106.57374],[10.66929,106.57546],[10.67068,106.57717],[10.67088,106.57741],[10.67131,106.57794],[10.67183,106.57849],[10.67297,106.57963],[10.67357,106.58023],[10.67394,106.58059],[10.67459,106.58125],[10.67558,106.58228],[10.67605,106.58283],[10.67696,106.5839],[10.67785,106.58499],[10.67909,106.58642],[10.67939,106.58678],[10.67973,106.58718],[10.68036,106.58794],[10.68095,106.58865],[10.68109,106.58882],[10.68147,106.58927],[10.68188,106.58975],[10.68267,106.59057],[10.68296,106.59086],[10.68387,106.59178],[10.68417,106.59209],[10.68447,106.59234],[10.68486,106.59262],[10.68504,106.59276],[10.68554,106.59303],[10.68581,106.59318],[10.68629,106.59343],[10.68674,106.59362],[10.68743,106.59386],[10.68831,106.59413],[10.68936,106.59449],[10.69221,106.59541],[10.69277,106.59559],[10.69408,106.59603],[10.69448,106.59616],[10.69529,106.59641],[10.69578,106.59656],[10.69608,106.59666],[10.69674,106.59687],[10.6972,106.59699],[10.69797,106.59717],[10.69812,106.59719],[10.69919,106.59737],[10.69958,106.59743],[10.6999,106.59746],[10.7002,106.59748],[10.70077,106.59747],[10.7024,106.59739],[10.70302,106.59736],[10.70378,106.59735],[10.70418,106.59739],[10.70428,106.5974],[10.70455,106.59749],[10.7051,106.59772],[10.70557,106.59793],[10.70582,106.59801],[10.70637,106.59817],[10.70719,106.59832],[10.70845,106.59855],[10.70916,106.59865],[10.70988,106.59878],[10.71024,106.59884],[10.71055,106.5989],[10.71114,106.59906],[10.71136,106.59911],[10.71162,106.59916],[10.71257,106.59933],[10.71362,106.59952],[10.71395,106.59957],[10.71646,106.6],[10.71741,106.60016],[10.71809,106.60028],[10.71881,106.6004],[10.71954,106.60054],[10.72114,106.60081],[10.72147,106.60086],[10.72206,106.60091],[10.72225,106.60095],[10.72229,106.60096],[10.72248,106.60103],[10.72254,106.60106],[10.72272,106.60114],[10.72352,106.60159],[10.72355,106.60162],[10.72359,106.60165],[10.72364,106.60167],[10.7242,106.6021],[10.72444,106.60228],[10.72464,106.60243],[10.72487,106.60262],[10.72511,106.60286],[10.72527,106.60304],[10.72544,106.60325],[10.72554,106.60339],[10.72574,106.60368],[10.72628,106.6045],[10.72664,106.60503],[10.72814,106.6073],[10.72827,106.60748],[10.72828,106.60754],[10.72829,106.60759],[10.72832,106.60765],[10.72849,106.60791],[10.72889,106.60851],[10.72935,106.60922],[10.72961,106.60961],[10.72978,106.60986],[10.72997,106.6101],[10.73022,106.61035],[10.73042,106.61052],[10.73047,106.61057],[10.73081,106.61082],[10.73099,106.61093],[10.73284,106.61204],[10.73398,106.61271],[10.73429,106.61289],[10.73475,106.61316],[10.7353,106.61349],[10.73652,106.61421],[10.73717,106.6146],[10.73733,106.6147],[10.73794,106.61506],[10.73818,106.61522],[10.73826,106.61527],[10.73838,106.61536],[10.73862,106.61556],[10.73872,106.61565],[10.73885,106.61579],[10.73946,106.61651],[10.7397,106.61679],[10.73989,106.61702],[10.74035,106.61756],[10.74063,106.61788],[10.74105,106.61837],[10.74175,106.6192],[10.7418,106.61926],[10.74195,106.61945],[10.74239,106.61999],[10.74277,106.62047],[10.7433,106.62113],[10.74351,106.62139],[10.74368,106.6216],[10.744,106.62198],[10.74449,106.62257],[10.74494,106.62311],[10.74504,106.62324],[10.7451,106.62332],[10.7453,106.62374],[10.7453,106.62378],[10.74531,106.62383],[10.74532,106.62386],[10.74534,106.62389],[10.74538,106.62393],[10.74542,106.62395],[10.74548,106.62397],[10.74551,106.62397],[10.74555,106.62397],[10.74558,106.62396],[10.74568,106.62401],[10.74576,106.62408],[10.74604,106.62444],[10.74644,106.62493],[10.74704,106.62566],[10.74776,106.62655],[10.74792,106.62675],[10.74805,106.62691],[10.74899,106.62807],[10.74906,106.62816],[10.74928,106.62845],[10.74966,106.62893],[10.75007,106.62945],[10.7509,106.63053],[10.75105,106.63072],[10.75132,106.63108],[10.75155,106.63137],[10.75179,106.63168],[10.75231,106.63232],[10.75245,106.6325],[10.75282,106.63298],[10.7529,106.63309],[10.75327,106.63366],[10.75354,106.63408],[10.75368,106.63433],[10.75368,106.63434],[10.75366,106.63438],[10.75366,106.63439],[10.75366,106.6344],[10.75365,106.63442],[10.75365,106.63446],[10.75365,106.6345],[10.75366,106.63454],[10.75367,106.63458],[10.75369,106.63462],[10.75371,106.63465],[10.75374,106.63469],[10.75376,106.63471],[10.75377,106.63471],[10.75381,106.63474],[10.75384,106.63476],[10.75388,106.63477],[10.75392,106.63478],[10.75396,106.63478],[10.754,106.63477],[10.75405,106.63477],[10.75405,106.63477],[10.7542,106.63498],[10.75431,106.63515],[10.75435,106.63525],[10.75439,106.63535],[10.7544,106.63542],[10.75442,106.63557],[10.75442,106.6359],[10.75444,106.6364],[10.75462,106.6378],[10.75464,106.63796],[10.75464,106.63803],[10.75455,106.63908],[10.7545,106.63959],[10.75444,106.64006],[10.75438,106.64044],[10.75433,106.64086],[10.75422,106.64184],[10.75415,106.64255],[10.75409,106.64314],[10.75426,106.64317],[10.75432,106.64318],[10.75445,106.64321],[10.7545,106.64326],[10.75454,106.64329],[10.75481,106.64334],[10.75481,106.64341],[10.75482,106.64347],[10.75486,106.64355],[10.75545,106.64462],[10.75576,106.64518],[10.75596,106.64556],[10.75652,106.64663],[10.75668,106.64693],[10.75712,106.64775],[10.75725,106.64798],[10.75743,106.64831],[10.75779,106.64898],[10.75802,106.64939],[10.75816,106.64966],[10.75826,106.64984],[10.75833,106.64997],[10.75843,106.65015],[10.75873,106.65071],[10.75901,106.65122],[10.75909,106.65137],[10.75913,106.65144],[10.75941,106.65196],[10.75974,106.65258],[10.76004,106.65314],[10.76013,106.6533],[10.76017,106.65338],[10.76029,106.6536],[10.76051,106.654],[10.76069,106.65433],[10.76079,106.65452],[10.76097,106.65485],[10.76109,106.65507],[10.76114,106.65517],[10.76143,106.6557],[10.76148,106.65579],[10.76158,106.65598],[10.76175,106.65629],[10.76185,106.65647],[10.76214,106.65699],[10.7622,106.65709],[10.76239,106.65744],[10.76307,106.65871],[10.76371,106.65988],[10.76377,106.65999],[10.76379,106.66003],[10.76381,106.66007],[10.76397,106.66036],[10.76409,106.66059],[10.76425,106.66088],[10.76436,106.66109],[10.76446,106.66127],[10.7646,106.66153],[10.7649,106.66208],[10.76509,106.66245],[10.76537,106.66296],[10.76567,106.66352],[10.76595,106.66404],[10.76636,106.6648],[10.76656,106.66517],[10.76664,106.66524],[10.76669,106.66532],[10.76691,106.6657],[10.76763,106.66699],[10.7687,106.66898],[10.76931,106.67016],[10.76933,106.6703],[10.76961,106.67079],[10.76977,106.67107],[10.76991,106.67133],[10.76996,106.67143],[10.77013,106.67173],[10.77028,106.67201],[10.77047,106.67234],[10.7709,106.67312],[10.77094,106.6732],[10.7711,106.67347],[10.77127,106.67376],[10.77145,106.67406],[10.77161,106.67431],[10.77171,106.67447],[10.77185,106.67471],[10.772,106.67494],[10.77211,106.67511],[10.77229,106.67541],[10.77246,106.67568],[10.77262,106.67594],[10.77276,106.67617],[10.77293,106.67644],[10.77308,106.67667],[10.77322,106.67691],[10.77375,106.67776],[10.77379,106.67782],[10.77415,106.6784],[10.77462,106.67915],[10.77488,106.67957],[10.77497,106.6797],[10.77513,106.67986],[10.77524,106.67994],[10.77534,106.68],[10.77677,106.68079],[10.7773,106.68108],[10.77753,106.68126],[10.77761,106.68147],[10.77758,106.6815],[10.77756,106.68154],[10.77755,106.68158],[10.77754,106.68162],[10.77754,106.68166],[10.77754,106.6817],[10.77755,106.68174],[10.77755,106.68174],[10.77757,106.68178],[10.77759,106.68182],[10.77762,106.68186],[10.77759,106.68196],[10.77716,106.68276],[10.77665,106.68367],[10.77666,106.68367],[10.77671,106.68373],[10.77683,106.68385],[10.77701,106.68404],[10.77718,106.68421],[10.77783,106.68488],[10.77838,106.68545],[10.77895,106.68606],[10.77949,106.68663],[10.78006,106.68724],[10.78023,106.68742],[10.78064,106.68786],[10.78119,106.68846],[10.78174,106.68904],[10.78234,106.68969],[10.78272,106.69008],[10.78306,106.69042],[10.78335,106.69072],[10.7834,106.69077],[10.78348,106.69085],[10.78433,106.69168],[10.7849,106.69224],[10.78548,106.69282],[10.78604,106.69337],[10.78643,106.69375],[10.78672,106.694],[10.78754,106.69474],[10.78802,106.69523],[10.78837,106.69558],[10.78879,106.69601],[10.78898,106.69618],[10.78946,106.69664],[10.78988,106.69703],[10.79005,106.6972],[10.79038,106.6975],[10.79101,106.69811],[10.7916,106.69868],[10.79186,106.69893],[10.79195,106.69905],[10.79213,106.69933],[10.79213,106.69935],[10.79213,106.6994],[10.79213,106.69944],[10.79215,106.69948],[10.79216,106.69953],[10.79219,106.6996],[10.79223,106.69964],[10.79223,106.69965],[10.79225,106.69968],[10.79229,106.69971],[10.79233,106.69974],[10.79236,106.69976],[10.79239,106.69977],[10.79241,106.69978],[10.79242,106.69978],[10.79244,106.69978],[10.79258,106.69992],[10.7929,106.70021],[10.79332,106.7006],[10.79377,106.70102],[10.79415,106.70138],[10.79429,106.7015],[10.79444,106.70164],[10.79464,106.7018],[10.79485,106.702],[10.79631,106.70339],[10.79872,106.70569],[10.79902,106.706],[10.79941,106.70646],[10.79969,106.70684],[10.80007,106.70745],[10.80044,106.70805],[10.80056,106.7083],[10.80067,106.70857],[10.8007,106.70861],[10.80074,106.70863],[10.80097,106.70926],[10.80101,106.70938],[10.80105,106.70944],[10.80108,106.70955],[10.80116,106.70985],[10.80138,106.71105],[10.80141,106.71127],[10.80143,106.71171],[10.8014,106.71237],[10.80137,106.71294],[10.80135,106.71306],[10.8013,106.71329],[10.80126,106.71346],[10.80123,106.7135],[10.80121,106.71352],[10.80109,106.71407],[10.80095,106.71459],[10.80079,106.71511],[10.80059,106.71564],[10.80058,106.71567],[10.80045,106.71598],[10.80025,106.71646],[10.80017,106.71663],[10.8001,106.71665],[10.80003,106.71671],[10.79996,106.71682],[10.7999,106.71691],[10.7997,106.71732],[10.79935,106.71797],[10.79871,106.71905],[10.79868,106.71913],[10.79866,106.71923],[10.7984,106.71971],[10.79825,106.71981],[10.79811,106.72005],[10.7981,106.72008],[10.79786,106.72063],[10.79777,106.72114],[10.79774,106.72145],[10.79774,106.72233],[10.79779,106.72266],[10.79813,106.72471],[10.79859,106.72715],[10.7994,106.73156],[10.79946,106.73184],[10.7995,106.73204],[10.79953,106.73215],[10.79957,106.73221],[10.79959,106.73223],[10.79971,106.73261],[10.79995,106.73349],[10.8,106.73368],[10.79998,106.73373],[10.79998,106.73381],[10.80004,106.73419],[10.80048,106.73654],[10.80184,106.74388],[10.80188,106.74412],[10.80196,106.74457],[10.80197,106.74484],[10.80197,106.7451],[10.80192,106.74552],[10.80189,106.74586],[10.8019,106.74599],[10.80191,106.74609],[10.80198,106.7465],[10.80202,106.74662],[10.80204,106.74672],[10.80212,106.7469],[10.80234,106.74733],[10.80247,106.74763],[10.80257,106.74789],[10.80263,106.7481],[10.80271,106.7484],[10.8028,106.74889],[10.80291,106.74935],[10.80299,106.74964],[10.80311,106.74997],[10.80318,106.75016],[10.80335,106.75059],[10.80371,106.75133],[10.80396,106.75178],[10.80421,106.75217],[10.80442,106.75249],[10.80501,106.75324],[10.80531,106.75357],[10.80571,106.75398],[10.80586,106.75412],[10.80602,106.75426],[10.80633,106.75454],[10.80685,106.75494],[10.8071,106.75512],[10.80738,106.75532],[10.80784,106.75559],[10.80839,106.75588],[10.80857,106.75596],[10.80888,106.75609],[10.80937,106.75629],[10.8097,106.7564],[10.81012,106.75653],[10.8107,106.75669],[10.81093,106.75674],[10.81252,106.75706],[10.81483,106.75749],[10.81564,106.75762],[10.81647,106.75777],[10.81666,106.7578],[10.81681,106.75783],[10.81787,106.75806],[10.81887,106.75826],[10.81903,106.75828],[10.81903,106.75828],[10.81967,106.75833],[10.82082,106.75856],[10.8209,106.75864],[10.82102,106.75869],[10.82154,106.75883],[10.82212,106.75898],[10.82237,106.75907],[10.82303,106.75932],[10.82329,106.7594],[10.82406,106.75969],[10.82433,106.75986],[10.82559,106.76059],[10.82583,106.76071],[10.82645,106.76104],[10.82659,106.76111],[10.82756,106.76166],[10.82846,106.76217],[10.82887,106.76239],[10.83033,106.76321],[10.83181,106.76404],[10.83217,106.76424],[10.83453,106.7656],[10.83493,106.76582],[10.83527,106.76601],[10.83534,106.76604],[10.83541,106.76608],[10.83635,106.76662],[10.83802,106.76756],[10.83885,106.76802],[10.83985,106.76859],[10.84021,106.76879],[10.84257,106.7701],[10.84445,106.77117],[10.84502,106.77151],[10.84547,106.77177],[10.8461,106.77217],[10.84751,106.77303],[10.84777,106.77319],[10.8482,106.77349],[10.84848,106.7737],[10.84877,106.77394],[10.84896,106.77412],[10.84905,106.77421],[10.84969,106.77481],[10.84994,106.77508],[10.85028,106.77548],[10.85065,106.77597],[10.85119,106.77668],[10.8513,106.77684],[10.8514,106.777],[10.85421,106.78175],[10.8549,106.78289],[10.85564,106.78415],[10.85621,106.78509],[10.85657,106.78572],[10.85701,106.78647],[10.85716,106.78674],[10.85771,106.78765],[10.85774,106.78768],[10.85777,106.7877],[10.85785,106.78774],[10.85797,106.78794],[10.85865,106.78908],[10.85865,106.78918],[10.85868,106.78927],[10.85873,106.78937],[10.86035,106.79211],[10.8608,106.79288],[10.86187,106.79473],[10.86297,106.79657],[10.864,106.79825],[10.86415,106.79849],[10.86455,106.79917],[10.86484,106.79966],[10.86506,106.80001],[10.86549,106.80069],[10.86559,106.80086],[10.86562,106.80094],[10.86565,106.801],[10.86568,106.80125],[10.86572,106.80142],[10.86584,106.80164],[10.86602,106.80197],[10.8665,106.8028],[10.86669,106.80307],[10.86724,106.80384],[10.86729,106.80392],[10.86739,106.804],[10.86759,106.80426],[10.86778,106.8045],[10.86795,106.8047],[10.86815,106.80494],[10.86835,106.80516],[10.86901,106.80582],[10.86947,106.80624],[10.86994,106.80664],[10.87056,106.80711],[10.87059,106.80714],[10.87069,106.80721],[10.87145,106.80776],[10.87193,106.80812],[10.87244,106.80848],[10.87289,106.8088],[10.87369,106.8094],[10.8742,106.8098],[10.8743,106.80988],[10.87457,106.81009],[10.87461,106.81013],[10.87464,106.81018],[10.87484,106.81034],[10.875,106.81045],[10.8761,106.81127],[10.87672,106.81171],[10.87702,106.81192],[10.87743,106.81221],[10.87794,106.81257],[10.87892,106.81329],[10.88201,106.81555],[10.88263,106.816],[10.8827,106.81598],[10.88283,106.81596],[10.88289,106.81595],[10.88369,106.81653],[10.88433,106.817],[10.88586,106.81812],[10.88624,106.8184],[10.88798,106.81968],[10.88823,106.81986],[10.88846,106.82004],[10.88952,106.82081],[10.89009,106.82123],[10.8931,106.82344],[10.89313,106.82347],[10.89338,106.82365],[10.89376,106.82393],[10.89388,106.82402],[10.89442,106.82443],[10.89474,106.8247],[10.89497,106.82491],[10.89509,106.82504],[10.89554,106.82552],[10.89588,106.82591],[10.89593,106.82598],[10.89626,106.82643],[10.89661,106.82699],[10.89677,106.82729],[10.89696,106.82763],[10.89712,106.82796],[10.89731,106.82839],[10.89767,106.82927],[10.89773,106.82943],[10.89802,106.83025],[10.89833,106.83107],[10.8987,106.83206],[10.8993,106.83368],[10.89956,106.83443],[10.89964,106.8344],[10.89981,106.83484],[10.9007,106.83722],[10.90153,106.8395],[10.90226,106.8415],[10.90242,106.84195],[10.9025,106.84219],[10.90367,106.84524],[10.90381,106.84561],[10.90413,106.84621],[10.90437,106.84665],[10.90447,106.8468],[10.9047,106.84716],[10.9051,106.84773],[10.90554,106.8483],[10.9059,106.84873],[10.90633,106.84923],[10.90732,106.85025],[10.90769,106.85065],[10.90796,106.85093],[10.90826,106.85123],[10.90834,106.85131],[10.90836,106.85135],[10.90842,106.85142],[10.91263,106.85568],[10.91733,106.86043],[10.91971,106.86284],[10.92133,106.8645],[10.92213,106.86529],[10.92258,106.86571],[10.92294,106.866],[10.92339,106.86633],[10.9239,106.86668],[10.92449,106.86702],[10.92496,106.86727],[10.9254,106.86747],[10.92583,106.86765],[10.92634,106.86782],[10.927,106.86799],[10.92723,106.86803],[10.92732,106.86804],[10.92741,106.86803],[10.92754,106.86806],[10.92781,106.86812],[10.92799,106.86816],[10.9287,106.86824],[10.92939,106.86826],[10.93071,106.86824],[10.93461,106.86831],[10.93562,106.86833],[10.93639,106.86834],[10.93653,106.86839],[10.93669,106.86841],[10.93683,106.86843],[10.9391,106.86846],[10.93921,106.86847],[10.93932,106.86855],[10.93938,106.86864],[10.9394,106.86875],[10.93939,106.86884],[10.93935,106.86897],[10.939,106.86925],[10.93905,106.86932],[10.93931,106.86912]]}');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `uid` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `is_private` tinyint(1) DEFAULT 0,
  `is_online` tinyint(1) DEFAULT 0,
  `email` varchar(100) NOT NULL,
  `passwordd` varchar(100) NOT NULL,
  `email_verified` tinyint(1) DEFAULT 0,
  `person_uid` varchar(100) NOT NULL,
  `notification_token` varchar(255) DEFAULT NULL,
  `token_temp` varchar(100) DEFAULT NULL,
  `lat` double DEFAULT NULL,
  `lng` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`uid`, `username`, `description`, `is_private`, `is_online`, `email`, `passwordd`, `email_verified`, `person_uid`, `notification_token`, `token_temp`, `lat`, `lng`) VALUES
('5c737b38-680f-4700-98c8-3dba6ac401c9', 'ha123', NULL, 0, 1, 'hao@gmail.com', '$2b$10$x90AprmfknN0tsWg5EFxdOpVLQvl1FeGyaWoLhZc6iDbS.FxOHr0O', 1, 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', NULL, '98969', NULL, NULL),
('78c38b16-f205-4bb1-a7ea-7eceb18f2c25', 'long.tran', NULL, 0, 0, 'long@gmail.com', '$2b$10$/gZl4zqldkUAktt/rTtReuNoJ8MC74X/uTrJvOmgcZ/wDNREePo2a', 1, 'da3197f0-a250-47c2-bb68-2b43dee75d40', NULL, '84734', NULL, NULL),
('7be887d7-50aa-4c41-96e0-547cd13de582', 'van.bi', NULL, 0, 0, 'bi@gmail.com', '$2b$10$cnGpeRRRp7S3pDORBWuqteTiI21e.UTVnKyn70edbwMRnhT5omP..', 1, '1a0c6118-7acc-480f-91a7-f9f46ce77865', NULL, '77421', NULL, NULL),
('984d9723-d4a7-4fa8-a22d-80dff65d87c3', 'tuyenpv', NULL, 0, 1, 'tuyenpv2703@gmail.com', '$2b$10$WTZI4oaMNOvKNCyAFtah..zDIQkXI6g.tdoX4zZS2M6jOkAhOHxsa', 1, '88fdc431-9c21-481f-823c-c0942d308249', NULL, '47046', 10.77813, 106.68174),
('d1788589-475e-498e-a8f6-6e5c1a3ff9d8', 'minh.nhan', NULL, 0, 0, 'nhan@gmail.com', '$2b$10$cv3o7DMgJ1zqyRo1MNj8e.QlDJ8x6y8xG/pkDwaM.pN6.Zk0fvLp.', 1, 'a44c4d90-b821-4700-9f2a-60744d8d2137', NULL, '69328', NULL, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_history`
--

CREATE TABLE `user_history` (
  `uid` int(11) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `count_trip_created` int(11) NOT NULL,
  `count_trip_completed` int(11) NOT NULL,
  `avg_rate` double NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `user_history`
--

INSERT INTO `user_history` (`uid`, `person_uid`, `count_trip_created`, `count_trip_completed`, `avg_rate`, `created_at`) VALUES
(1, '88fdc431-9c21-481f-823c-c0942d308249', 10, 2, 2.5, '2024-01-10 23:05:53');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `call_video`
--
ALTER TABLE `call_video`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `person_uid` (`person_uid`),
  ADD KEY `post_uid` (`post_uid`);

--
-- Chỉ mục cho bảng `followers`
--
ALTER TABLE `followers`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `person_uid` (`person_uid`),
  ADD KEY `followers_uid` (`followers_uid`);

--
-- Chỉ mục cho bảng `friends`
--
ALTER TABLE `friends`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `person_uid` (`person_uid`),
  ADD KEY `friend_uid` (`friend_uid`);

--
-- Chỉ mục cho bảng `images_post`
--
ALTER TABLE `images_post`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `post_uid` (`post_uid`);

--
-- Chỉ mục cho bảng `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`uid_likes`),
  ADD KEY `user_uid` (`user_uid`),
  ADD KEY `post_uid` (`post_uid`);

--
-- Chỉ mục cho bảng `list_chats`
--
ALTER TABLE `list_chats`
  ADD PRIMARY KEY (`uid_list_chat`),
  ADD KEY `source_uid` (`source_uid`),
  ADD KEY `target_uid` (`target_uid`);

--
-- Chỉ mục cho bảng `list_trip_chat`
--
ALTER TABLE `list_trip_chat`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `media_story`
--
ALTER TABLE `media_story`
  ADD PRIMARY KEY (`uid_media_story`),
  ADD KEY `story_uid` (`story_uid`);

--
-- Chỉ mục cho bảng `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`uid_messages`),
  ADD KEY `source_uid` (`source_uid`),
  ADD KEY `target_uid` (`target_uid`);

--
-- Chỉ mục cho bảng `mock_data`
--
ALTER TABLE `mock_data`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`uid_notification`);

--
-- Chỉ mục cho bảng `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `person_uid` (`person_uid`);

--
-- Chỉ mục cho bảng `post_save`
--
ALTER TABLE `post_save`
  ADD PRIMARY KEY (`post_save_uid`),
  ADD KEY `post_uid` (`post_uid`),
  ADD KEY `person_uid` (`person_uid`);

--
-- Chỉ mục cho bảng `stories`
--
ALTER TABLE `stories`
  ADD PRIMARY KEY (`uid_story`),
  ADD KEY `user_uid` (`user_uid`);

--
-- Chỉ mục cho bảng `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `trip_name` (`trip_title`);

--
-- Chỉ mục cho bảng `trip_comment`
--
ALTER TABLE `trip_comment`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `trip_images`
--
ALTER TABLE `trip_images`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `trip_members`
--
ALTER TABLE `trip_members`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `trip_messages`
--
ALTER TABLE `trip_messages`
  ADD PRIMARY KEY (`uid_message_trip`);

--
-- Chỉ mục cho bảng `trip_recommend`
--
ALTER TABLE `trip_recommend`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `trip_reopen`
--
ALTER TABLE `trip_reopen`
  ADD PRIMARY KEY (`uid_trip_reopen`);

--
-- Chỉ mục cho bảng `trip_save`
--
ALTER TABLE `trip_save`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `trip_schedule`
--
ALTER TABLE `trip_schedule`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `trip_start`
--
ALTER TABLE `trip_start`
  ADD PRIMARY KEY (`uid`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`uid`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `person_uid` (`person_uid`);

--
-- Chỉ mục cho bảng `user_history`
--
ALTER TABLE `user_history`
  ADD PRIMARY KEY (`uid`),
  ADD UNIQUE KEY `person_uid` (`person_uid`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `mock_data`
--
ALTER TABLE `mock_data`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `trip_comment`
--
ALTER TABLE `trip_comment`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `trip_start`
--
ALTER TABLE `trip_start`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `user_history`
--
ALTER TABLE `user_history`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`);

--
-- Các ràng buộc cho bảng `followers`
--
ALTER TABLE `followers`
  ADD CONSTRAINT `followers_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `followers_ibfk_2` FOREIGN KEY (`followers_uid`) REFERENCES `person` (`uid`);

--
-- Các ràng buộc cho bảng `friends`
--
ALTER TABLE `friends`
  ADD CONSTRAINT `friends_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `friends_ibfk_2` FOREIGN KEY (`friend_uid`) REFERENCES `person` (`uid`);

--
-- Các ràng buộc cho bảng `images_post`
--
ALTER TABLE `images_post`
  ADD CONSTRAINT `images_post_ibfk_1` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`);

--
-- Các ràng buộc cho bảng `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`user_uid`) REFERENCES `users` (`person_uid`),
  ADD CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`);

--
-- Các ràng buộc cho bảng `list_chats`
--
ALTER TABLE `list_chats`
  ADD CONSTRAINT `list_chats_ibfk_1` FOREIGN KEY (`source_uid`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `list_chats_ibfk_2` FOREIGN KEY (`target_uid`) REFERENCES `person` (`uid`);

--
-- Các ràng buộc cho bảng `media_story`
--
ALTER TABLE `media_story`
  ADD CONSTRAINT `media_story_ibfk_1` FOREIGN KEY (`story_uid`) REFERENCES `stories` (`uid_story`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`source_uid`) REFERENCES `users` (`person_uid`),
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`target_uid`) REFERENCES `users` (`person_uid`);

--
-- Các ràng buộc cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_uid`) REFERENCES `users` (`person_uid`),
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`followers_uid`) REFERENCES `users` (`person_uid`),
  ADD CONSTRAINT `notifications_ibfk_3` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`);

--
-- Các ràng buộc cho bảng `posts`
--
ALTER TABLE `posts`
  ADD CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`);

--
-- Các ràng buộc cho bảng `post_save`
--
ALTER TABLE `post_save`
  ADD CONSTRAINT `post_save_ibfk_1` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`),
  ADD CONSTRAINT `post_save_ibfk_2` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`);

--
-- Các ràng buộc cho bảng `stories`
--
ALTER TABLE `stories`
  ADD CONSTRAINT `stories_ibfk_1` FOREIGN KEY (`user_uid`) REFERENCES `users` (`person_uid`);

--
-- Các ràng buộc cho bảng `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`);

DELIMITER $$
--
-- Sự kiện
--
CREATE DEFINER=`root`@`localhost` EVENT `delete_story_after_24h` ON SCHEDULE EVERY 60 MINUTE STARTS '2024-01-08 16:47:37' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    -- Các câu lệnh SQL bạn muốn thực hiện mỗi phút
   DELETE FROM media_story WHERE created_at < ( CURRENT_TIMESTAMP - INTERVAL 1 DAY );
  END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
