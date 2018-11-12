SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `new`
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
  `plate` varchar(10) NOT NULL DEFAULT 'New RP',
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

-- --------------------------------------------------------

--
-- Table structure for table `member`
--

CREATE TABLE `member` (
  `id` smallint(5) UNSIGNED NOT NULL COMMENT 'player id',
  `fid` tinyint(3) UNSIGNED NOT NULL COMMENT 'fraction id',
  `rank` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
