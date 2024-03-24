-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th1 08, 2024 lúc 10:40 AM
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

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `media_story`
--
ALTER TABLE `media_story`
  ADD PRIMARY KEY (`uid_media_story`),
  ADD KEY `story_uid` (`story_uid`);

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `media_story`
--
ALTER TABLE `media_story`
  ADD CONSTRAINT `media_story_ibfk_1` FOREIGN KEY (`story_uid`) REFERENCES `stories` (`uid_story`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
