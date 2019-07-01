-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jul 01, 2019 at 03:16 PM
-- Server version: 5.7.20-log
-- PHP Version: 7.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `azure`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `password` varchar(48) NOT NULL,
  `level` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `password`, `level`) VALUES
(1, 'qwerty', 9);

-- --------------------------------------------------------

--
-- Table structure for table `ban`
--

CREATE TABLE `ban` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `by` smallint(5) UNSIGNED NOT NULL,
  `reason` varchar(32) NOT NULL,
  `date` int(10) UNSIGNED NOT NULL,
  `expire` int(10) UNSIGNED NOT NULL,
  `playerIP` varchar(15) NOT NULL,
  `adminIP` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `bill`
--

CREATE TABLE `bill` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `pid` smallint(5) UNSIGNED NOT NULL,
  `type` tinyint(4) NOT NULL COMMENT '0 - regular, 1 - salary',
  `cash` mediumint(8) NOT NULL COMMENT 'Can be negative'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `business`
--

CREATE TABLE `business` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `type` tinyint(3) UNSIGNED NOT NULL,
  `pid` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `x` float(8,4) NOT NULL,
  `y` float(8,4) NOT NULL,
  `z` float(8,4) NOT NULL,
  `icon` tinyint(3) UNSIGNED NOT NULL COMMENT '0 - no icon, 1 - owner has bought an icon',
  `url` tinytext NOT NULL COMMENT 'url of music that streamed to the player when he enters'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `car`
--

CREATE TABLE `car` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `pid` smallint(5) UNSIGNED NOT NULL,
  `model` smallint(5) UNSIGNED NOT NULL,
  `x` float(8,4) NOT NULL,
  `y` float(8,4) NOT NULL,
  `z` float(8,4) NOT NULL,
  `a` float(4,1) NOT NULL,
  `health` float(5,1) UNSIGNED NOT NULL DEFAULT '1000.0',
  `fuel` tinyint(3) UNSIGNED NOT NULL DEFAULT '100',
  `engine` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `doors` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `lights` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `plate` varchar(10) NOT NULL DEFAULT 'Azure RP',
  `color1` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `color2` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `pjob` tinyint(3) UNSIGNED NOT NULL DEFAULT '3',
  `spoiler` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `hood` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `roof` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `sideskirt` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `nitro` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '0 - no, 1 - yes (NOT addvehiclecomponent!)',
  `exhaust` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `wheels` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `hydraulics` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `fbump` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `rbump` smallint(5) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `car`
--

INSERT INTO `car` (`id`, `pid`, `model`, `x`, `y`, `z`, `a`, `health`, `fuel`, `engine`, `doors`, `lights`, `plate`, `color1`, `color2`, `pjob`, `spoiler`, `hood`, `roof`, `sideskirt`, `nitro`, `exhaust`, `wheels`, `hydraulics`, `fbump`, `rbump`) VALUES
(1, 1, 560, 1670.5833, -2112.7366, 13.1993, 9.6, 1000.0, 0, 0, 1, 1, 'Azure RP', 1, 1, 2, 1138, 0, 1032, 1026, 1, 1028, 1079, 1, 1169, 1141),
(2, 1, 411, -17.9092, -13.9743, 2.8598, 0.0, 1000.0, 0, 0, 0, 1, 'Azure RP', 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `gangzones`
--

CREATE TABLE `gangzones` (
  `id` tinyint(4) NOT NULL,
  `gang` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'gang id',
  `minx` float(10,6) NOT NULL,
  `miny` float(10,6) NOT NULL,
  `maxx` float(10,6) NOT NULL,
  `maxy` float(10,6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `gangzones`
--

INSERT INTO `gangzones` (`id`, `gang`, `minx`, `miny`, `maxx`, `maxy`) VALUES
(1, 5, 2430.337402, -1622.946655, 2542.304443, -1742.005859),
(2, 5, 2340.447266, -1622.946655, 2430.337402, -1742.005859),
(3, 5, 2206.893555, -1622.946655, 2340.447266, -1742.005859),
(4, 5, 2206.893555, -1742.005859, 2407.571045, -1823.911743),
(5, 6, 2090.631592, -1570.947144, 2206.893555, -1630.998047),
(6, 5, 2090.631592, -1630.998047, 2206.893555, -1755.170776),
(7, 5, 2123.333252, -1755.170776, 2206.893555, -1838.198242),
(8, 5, 1830.000000, -1533.073608, 2043.796021, -1610.526123),
(9, 5, 1943.971313, -1610.526123, 2002.244751, -1755.170776),
(10, 5, 2002.244751, -1610.526123, 2090.631592, -1755.170776),
(11, 6, 1820.301147, -1882.884766, 1955.170654, -1934.404541),
(12, 5, 1805.033325, -1962.999023, 1927.070557, -2060.303223),
(13, 5, 1822.712158, -2060.303223, 1918.832275, -2160.377441),
(14, 6, 1655.925049, -2060.303223, 1822.712158, -2160.377441),
(15, 6, 2410.953613, -1980.744751, 2541.186279, -2040.397827),
(16, 5, 2615.978760, -1975.969849, 2715.370850, -2042.705444),
(17, 6, 2715.370850, -1895.205200, 2820.431152, -1996.998657),
(18, 5, 2728.000000, -1258.650024, 2856.887939, -1658.650024),
(19, 5, 2728.000000, -1153.646606, 2856.887939, -1258.650024),
(20, 5, 2595.364502, -1049.767456, 2640.048828, -1134.980469),
(21, 5, 2300.788330, -1000.000000, 2595.364502, -1125.000000),
(22, 6, 2345.884766, -1125.000000, 2532.637207, -1150.778809),
(23, 6, 2433.093994, -937.917175, 2604.848877, -1000.000000),
(24, 5, 1975.810669, -950.389893, 2300.788330, -1110.000000),
(25, 5, 1866.998657, -1110.000000, 2068.465088, -1261.105469),
(26, 5, 2068.465088, -1110.000000, 2171.587646, -1220.619751),
(27, 5, 2068.465088, -1220.619751, 2171.587646, -1300.997437),
(28, 5, 2068.465088, -1300.997437, 2171.587646, -1384.755615),
(29, 5, 2171.587646, -1301.678955, 2285.000000, -1384.755615),
(30, 5, 2171.587646, -1220.619751, 2285.000000, -1301.678955),
(31, 5, 2285.000000, -1160.340454, 2370.785400, -1384.755615),
(32, 5, 2370.785400, -1260.000000, 2450.217041, -1444.494751),
(33, 5, 2450.217041, -1260.000000, 2509.879150, -1444.494751),
(34, 5, 2450.217041, -1186.105225, 2571.409424, -1260.000000),
(35, 5, 2571.409424, -1186.105225, 2641.157471, -1260.000000),
(36, 5, 2641.157471, -1186.105225, 2728.000000, -1260.000000),
(37, 5, 2211.577881, -1384.755615, 2273.169189, -1485.764160),
(38, 5, 2120.982666, -1384.755615, 2211.577881, -1509.339478);

-- --------------------------------------------------------

--
-- Table structure for table `gun`
--

CREATE TABLE `gun` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `weapon` tinyint(3) UNSIGNED NOT NULL,
  `ammo` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `house`
--

CREATE TABLE `house` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `pid` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `int` tinyint(3) UNSIGNED NOT NULL,
  `class` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `builder` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `builded` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'class / materials: 0/3, 1/6, 2/9, 3/12',
  `price` mediumint(8) UNSIGNED NOT NULL DEFAULT '500000',
  `door` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `house`
--

INSERT INTO `house` (`id`, `pid`, `x`, `y`, `z`, `int`, `class`, `builder`, `builded`, `price`, `door`) VALUES
(2, 0, 315.834, -1770.3, 4.6514, 0, 2, 0, 0, 2850000, 0),
(3, 1, 1667.48, -2106.94, 14.0722, 0, 0, 1, 3, 600000, 0),
(4, 0, 1673.67, -2122.46, 14.146, 0, 0, 1, 3, 650000, 0),
(5, 0, 1695.44, -2125.84, 13.81, 0, 0, 1, 2, 700000, 0),
(6, 0, 1684.83, -2098.16, 13.8343, 0, 0, 0, 0, 650000, 0);

-- --------------------------------------------------------

--
-- Table structure for table `member`
--

CREATE TABLE `member` (
  `id` smallint(5) UNSIGNED NOT NULL COMMENT 'player id',
  `fid` tinyint(3) UNSIGNED NOT NULL COMMENT 'fraction id',
  `rank` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `member`
--

INSERT INTO `member` (`id`, `fid`, `rank`) VALUES
(1, 5, 7);

-- --------------------------------------------------------

--
-- Table structure for table `skill`
--

CREATE TABLE `skill` (
  `id` smallint(5) UNSIGNED NOT NULL COMMENT 'player id',
  `pistol` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `spistol` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `deagle` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `shotgun` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `mp5` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `m4` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `ak47` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `skill`
--

INSERT INTO `skill` (`id`, `pistol`, `spistol`, `deagle`, `shotgun`, `mp5`, `m4`, `ak47`) VALUES
(1, 100, 100, 0, 0, 100, 100, 100);

-- --------------------------------------------------------

--
-- Table structure for table `sms`
--

CREATE TABLE `sms` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `to` mediumint(8) UNSIGNED NOT NULL,
  `from` mediumint(8) UNSIGNED NOT NULL,
  `text` varchar(128) NOT NULL,
  `date` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `username` varchar(24) NOT NULL,
  `password` varchar(32) NOT NULL,
  `name` varchar(15) DEFAULT NULL,
  `surname` varchar(15) DEFAULT NULL,
  `health` float(5,2) UNSIGNED NOT NULL DEFAULT '100.00',
  `armour` float(5,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `x` float(7,3) NOT NULL DEFAULT '1446.000',
  `y` float(7,3) NOT NULL DEFAULT '-2286.900',
  `z` float(6,2) NOT NULL DEFAULT '13.60',
  `a` float(4,1) NOT NULL DEFAULT '88.0' COMMENT 'Rotation angle',
  `interior` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `world` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `sex` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `age` tinyint(3) UNSIGNED NOT NULL DEFAULT '18',
  `agePoints` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `lived` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `passport` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `skin` smallint(5) UNSIGNED NOT NULL DEFAULT '4',
  `cash` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `drugs` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `metal` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `work` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `earnings` mediumint(8) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Added every 10 minutes',
  `minutes` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'How much minutes played',
  `fraction` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `isWorking` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `rank` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `rankName` varchar(10) DEFAULT NULL COMMENT 'Unused',
  `fSkin` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `mute` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `fstyle` tinyint(3) UNSIGNED NOT NULL DEFAULT '15',
  `box` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `kongfu` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `kickbox` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `pistol` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `spistol` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `deagle` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `mp5` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `shotgun` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `m4` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `ak47` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `w1` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `a1` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `w2` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `a2` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `w3` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `a3` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `w4` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `a4` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `w5` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `a5` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `w6` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `a6` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `w7` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `a7` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `w9` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `a9` smallint(5) UNSIGNED DEFAULT '0',
  `online` tinyint(3) UNSIGNED NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `username`, `password`, `name`, `surname`, `health`, `armour`, `x`, `y`, `z`, `a`, `interior`, `world`, `sex`, `age`, `agePoints`, `lived`, `passport`, `skin`, `cash`, `drugs`, `metal`, `work`, `earnings`, `minutes`, `fraction`, `isWorking`, `rank`, `rankName`, `fSkin`, `mute`, `fstyle`, `box`, `kongfu`, `kickbox`, `pistol`, `spistol`, `deagle`, `mp5`, `shotgun`, `m4`, `ak47`, `w1`, `a1`, `w2`, `a2`, `w3`, `a3`, `w4`, `a4`, `w5`, `a5`, `w6`, `a6`, `w7`, `a7`, `w9`, `a9`, `online`) VALUES
(1, 'username', 'qwerty', 'Имя', 'Фамилия', 10.00, 0.00, 1689.395, -2078.793, 14.74, 243.2, 0, 0, 1, 24, 28, 1, 1, 294, 10000, 10, 10, 0, 0, 9, 5, 0, 8, '', 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 31, 10000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `wardrobe`
--

CREATE TABLE `wardrobe` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `pid` smallint(5) UNSIGNED NOT NULL,
  `skinid` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `warehouse`
--

CREATE TABLE `warehouse` (
  `id` tinyint(3) UNSIGNED NOT NULL COMMENT 'fraction id',
  `metal` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `cash` mediumint(8) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ban`
--
ALTER TABLE `ban`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bill`
--
ALTER TABLE `bill`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `business`
--
ALTER TABLE `business`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `car`
--
ALTER TABLE `car`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `gangzones`
--
ALTER TABLE `gangzones`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `gun`
--
ALTER TABLE `gun`
  ADD KEY `id` (`id`);

--
-- Indexes for table `house`
--
ALTER TABLE `house`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `member`
--
ALTER TABLE `member`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `skill`
--
ALTER TABLE `skill`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sms`
--
ALTER TABLE `sms`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `wardrobe`
--
ALTER TABLE `wardrobe`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `warehouse`
--
ALTER TABLE `warehouse`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bill`
--
ALTER TABLE `bill`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `business`
--
ALTER TABLE `business`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `car`
--
ALTER TABLE `car`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `gangzones`
--
ALTER TABLE `gangzones`
  MODIFY `id` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `house`
--
ALTER TABLE `house`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `sms`
--
ALTER TABLE `sms`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `wardrobe`
--
ALTER TABLE `wardrobe`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
