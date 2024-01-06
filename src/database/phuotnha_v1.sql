-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th1 06, 2024 lúc 06:43 AM
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ALL_MESSAGE_BY_TRIP` (IN `UIDFROM` VARCHAR(100), IN `UIDTO` VARCHAR(100))   BEGIN	
	SELECT * FROM trip_messages me
	WHERE me.source_uid = UIDFROM AND me.target_trip_uid = UIDTO || me.source_uid = UIDTO AND me.target_trip_uid = UIDFROM
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_MESSAGE_BY_TRIP` (IN `IDUSER` VARCHAR(100))   BEGIN
SELECT trip_messages.uid_message_trip,trip_messages.source_uid,trip_messages.target_trip_uid,trip_messages.message, u.username, p.image AS avatar
	FROM trip_messages
	INNER JOIN users u ON trip_messages.source_uid = u.person_uid
	INNER JOIN person p ON u.person_uid = p.uid
 	WHERE trip_messages.source_uid = IDUSER
 	ORDER BY trip_messages.updated_at ASC;
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_MESSAGE_BY_USER` (IN `IDUSER` VARCHAR(100))   BEGIN
	SELECT ls.uid_list_chat, ls.source_uid, ls.target_uid, ls.last_message, ls.updated_at, u.username, p.image AS avatar
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
	GROUP BY s.uid_story, u.username, p.image;
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
          (SELECT IF(trip.user_uid = ID, 1,0)) as isOwner
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
	SELECT ps.post_save_uid, ps.post_uid, ps.person_uid,ps.date_save, per.image AS avatar, per.fullname,GROUP_CONCAT( DISTINCT img.image ) images FROM post_save ps 
	INNER JOIN posts po ON ps.post_uid = po.uid
	INNER JOIN images_post img ON po.uid = img.post_uid
	INNER JOIN person per ON per.uid = ps.person_uid
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEARCH_USERNAME` (IN `USERNAMEE` VARCHAR(100))   BEGIN
	SELECT pe.uid, pe.fullname, pe.image AS avatar, us.username FROM person pe
	INNER JOIN users us ON pe.uid = us.person_uid
	WHERE us.username LIKE CONCAT('%', USERNAMEE, '%');
END$$

DELIMITER ;

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
('cc9cae5a-eae6-47e3-8ded-f0db557a7127', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'ko', '2024-01-05 16:27:21');

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
('6b059a94-5fea-4942-b7e0-e5283e9e92d7', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'plpl', '2024-01-05 16:26:19');

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
('2e13ef3e-ec72-4701-b9cf-6e76b337deea', 'a85e7ea7-d471-45d4-9186-b20a7c959421.jpg', '2024-01-06 00:16:22', 'e1c05095-274b-4c63-900e-d63a42d62d04'),
('4a7c2e77-2652-4725-bead-65db25b6b7ef', '068338e9-7d4c-4b88-9cdb-4c6d74c84264.jpg', '2024-01-06 01:13:47', '227819b9-f97a-4788-833b-51e1e632f1ed'),
('b73f407f-426f-48dd-a919-8bbda710ea30', '0e73094c-6f99-407f-add8-91eb5f978966.jpg', '2024-01-06 01:17:26', '227819b9-f97a-4788-833b-51e1e632f1ed');

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
('04a60018-ffd0-4b5e-a163-20d0d4df91ef', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'ko', '2024-01-05 23:27:22'),
('5fa48b01-f84d-4d1a-bd37-f4773ad741cf', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'jsndd', '2024-01-04 01:30:56'),
('ed4b5dc9-2cfb-46ab-9719-eef699c89222', '88fdc431-9c21-481f-823c-c0942d308249', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'hi', '2024-01-04 01:30:33');

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
  `achievement` enum('O','A','B','C','D','E') NOT NULL DEFAULT 'O'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `person`
--

INSERT INTO `person` (`uid`, `fullname`, `phone`, `image`, `cover`, `birthday_date`, `state`, `created_at`, `updated_at`, `is_leader`, `achievement`) VALUES
('1a0c6118-7acc-480f-91a7-f9f46ce77865', 'Văn Bí', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-24 23:06:56', '2023-12-24 23:06:56', 0, 'O'),
('88fdc431-9c21-481f-823c-c0942d308249', 'Phan Tuyển', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-13 14:44:06', '2023-12-13 14:44:06', 0, 'O'),
('a44c4d90-b821-4700-9f2a-60744d8d2137', 'Mình Nhân', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-16 00:06:08', '2023-12-16 00:06:08', 0, 'O'),
('bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'Văn Hào', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-22 23:01:02', '2023-12-22 23:01:02', 0, 'O'),
('da3197f0-a250-47c2-bb68-2b43dee75d40', 'Trần Long', NULL, 'avatar-default.png', 'cover_default.jpg', NULL, 1, '2023-12-24 22:49:14', '2023-12-24 22:49:14', 0, 'O');

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
('72348532-2105-4e27-9b03-82730e0768ee', '5db01bbb-dd33-44d8-83f5-173e023f4d1e', '88fdc431-9c21-481f-823c-c0942d308249', '2024-01-05 14:15:00'),
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
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `trips`
--

INSERT INTO `trips` (`uid`, `user_uid`, `trip_title`, `trip_description`, `trip_date_start`, `trip_date_end`, `trip_from`, `trip_to`, `trip_member`, `trip_status`, `created_at`, `updated_at`) VALUES
('349a5c74-e31b-4cb3-87aa-e3be559fa824', '88fdc431-9c21-481f-823c-c0942d308249', 'Tắm biển Cần Giờ', 'Chuyến đi tắm biển giải tress', '2023-12-25', '2023-12-27', 'Ngã tư Thủ Đức', 'Biển Cần Giờ', 2, 'is_beginning', '2023-12-25 14:01:31', '2023-12-25 14:01:31'),
('9d5c0682-f721-4efe-9c32-9607ea58815c', 'bd89e386-abfc-4065-9b00-3f64ec4c9c84', 'Khám phá thác K50', 'Check-in thác k50', '2023-12-28', '2023-12-31', '448 Lê Văn Việt', 'Thác K50', 4, 'open', '2023-12-26 20:31:04', '2023-12-26 20:31:04');

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
('31335dd0-757b-413f-9bfd-33191edf724b', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'plpl', '2024-01-05 23:26:21'),
('96482bde-2ba3-481d-a6f8-d9082e43fb73', '88fdc431-9c21-481f-823c-c0942d308249', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 'hi', '2024-01-05 22:39:06');

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
('6a79b4f1', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.845335, 106.794301, 'Lê Văn Việt', 'Lê Văn Việt, Tăng Nhơn Phú A, Quận 9, Thành phố Hồ Chí Minh', 0, 0, 0, 0),
('6a79b4f2', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.849808, 106.811701, 'Trạm Xăng Dầu Tân Phú', '659 Lê Văn Việt, Long Thạnh Mỹ, Quận 9, Thành phố Hồ Chí Minh', 1, 0, 0, 0),
('6a79b4f3', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.893267, 106.82379, 'Trạm Tiếp Nhiên Liệu Hiệp Phú 2', '78/2C Đ. Võ Nguyên Giáp, Bình An, Dĩ An, Bình Dương', 1, 0, 0, 0),
('6a79b4f4', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.845335, 106.794301, 'Cây xăng Tây Nam - BQP', 'VRXM+VXJ, Bình An, Dĩ An, Bình Dương', 1, 0, 0, 0),
('6a79b4f5', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 10.961922, 106.881669, 'Trạm Xăng Dầu Tân Biên', '327 QL1A, Tân Biên, Thành phố Biên Hòa, Đồng Nai', 1, 0, 0, 0),
('6a79b4f6', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 11.035085, 107.014836, 'Sửa Xe Hà Luật', 'Vĩnh Cửu, Đồng Nai', 0, 1, 0, 0),
('6a79b4f7', '349a5c74-e31b-4cb3-87aa-e3be559fa824', 11.100594, 107.044709, 'Hồ trị an', 'Tôn Đức Thắng, TT. Vĩnh An, Vĩnh Cửu, Đồng Nai', 0, 0, 0, 0);

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
('984d9723-d4a7-4fa8-a22d-80dff65d87c3', 'tuyenpv', NULL, 0, 1, 'tuyenpv2703@gmail.com', '$2b$10$WTZI4oaMNOvKNCyAFtah..zDIQkXI6g.tdoX4zZS2M6jOkAhOHxsa', 1, '88fdc431-9c21-481f-823c-c0942d308249', NULL, '47046', NULL, NULL),
('d1788589-475e-498e-a8f6-6e5c1a3ff9d8', 'minh.nhan', NULL, 0, 0, 'nhan@gmail.com', '$2b$10$cv3o7DMgJ1zqyRo1MNj8e.QlDJ8x6y8xG/pkDwaM.pN6.Zk0fvLp.', 1, 'a44c4d90-b821-4700-9f2a-60744d8d2137', NULL, '69328', NULL, NULL);

--
-- Chỉ mục cho các bảng đã đổ
--

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
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`uid`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `person_uid` (`person_uid`);

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
