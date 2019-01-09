
-- NOTE: do not use DELIMITER here
-- NOTE: do not use DEFINER for stored procedures and functions here

DROP PROCEDURE IF EXISTS _transferSkill;
CREATE PROCEDURE _transferSkill(
	IN `in_oldSkillTypeID` INT UNSIGNED,
	IN `in_newSkillTypeID` INT UNSIGNED
)
BEGIN

-- allocate needed skill with 0 values at first.
-- don't use "insert ... select on duplicate key update" here - it is not so safe for replication.
insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
	select c.ID, in_newSkillTypeID as SkillTypeID, 0 as newSkillAmount, 1 as newLockStatus
		from `character` c
		join skills s on s.CharacterID = c.ID
		where s.SkillTypeID = in_oldSkillTypeID
			and !exists(select * from skills_new sn where sn.CharacterID = c.ID and sn.SkillTypeID = in_newSkillTypeID)
		order by c.ID;

-- transfer skill values
update skills_new sn
	join skills s on sn.CharacterID = s.CharacterID and sn.SkillTypeID = in_newSkillTypeID and s.SkillTypeID = in_oldSkillTypeID
	set sn.SkillAmount = (sn.SkillAmount + s.SkillAmount);

-- empty old skill values
update skills
	set SkillAmount = 0
	where SkillTypeID = in_oldSkillTypeID;

-- allocate child skills, if our skill has value >= 30
insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
	select sn.CharacterID, stn.ID, 0 as newSkillAmount, 1 as newLockStatus
	from skill_type_new stn
	join skills_new sn on sn.SkillTypeID = stn.Parent
	where stn.Parent = in_newSkillTypeID
		and sn.SkillAmount >= 30*10000000
		and !exists(select * from skills_new sn2 where sn2.CharacterID = sn.CharacterID and sn2.SkillTypeID = stn.ID);

-- distribute skills with value > 100 to first child skill with value < 100
-- (we can't use ORDER BY and LIMIT in multiple-table update. Also, we can't use LIMIT in subqueries due to MariaDB compatibility reasons)
update skills_new sn
-- select sn.SkillAmount as oldVal, (sn.SkillAmount + (sn_base.SkillAmount - 100*10000000)) as newVal, sn.* from skills_new sn
	join skill_type_new stn on stn.ID = sn.SkillTypeID
	-- join skills_new sn_base on sn_base.SkillTypeID = stn.Parent and sn_base.CharacterID = sn.CharacterID -- we can't use updated table in subquery, so implicitly copy it into a temporary table
	join (select SkillTypeID, CharacterID, SkillAmount from skills_new where SkillTypeID = in_newSkillTypeID) as sn_base
		on sn_base.SkillTypeID = stn.Parent and sn_base.CharacterID = sn.CharacterID
	set sn.SkillAmount = (sn.SkillAmount + (sn_base.SkillAmount - 100*10000000))
	where sn_base.SkillAmount > 100*10000000
		-- and sn.SkillAmount < 100*10000000
		-- and stn.Parent = 1
		and stn.ID in
		(
			select min(stn2.ID)
			from skill_type_new stn2
			-- join skills_new sn2 on sn2.SkillTypeID = stn2.ID -- we can't use updated table in subquery, so implicitly copy it into a temporary table
			join (select SkillTypeID, CharacterID, SkillAmount from skills_new where SkillAmount < 100*10000000) as sn2
				on sn2.SkillTypeID = stn2.ID
			where stn2.Parent = in_newSkillTypeID
				and sn2.CharacterID = sn.CharacterID
				-- and sn2.SkillAmount < 100*10000000
		);
	-- order by stn.ID
	-- limit 1

-- cap skill values at 100
update skills_new
	set SkillAmount = 100*10000000
	where SkillAmount > 100*10000000;

END;

DROP FUNCTION IF EXISTS _getMaxSkillValue;
CREATE FUNCTION `_getMaxSkillValue`(
	`in_parentSkillValue` INT UNSIGNED
)
	RETURNS INT UNSIGNED
BEGIN
	declare skillAmountMult INT UNSIGNED DEFAULT 10000000;

	if(in_parentSkillValue < 30*skillAmountMult) then
		return 0;
	elseif(in_parentSkillValue < 60*skillAmountMult) then
		return (30*skillAmountMult - 1);
	end if;

	return 100*skillAmountMult;
END;

DROP PROCEDURE IF EXISTS _transferSkillStraight;
CREATE PROCEDURE _transferSkillStraight(
	IN `in_oldSkillTypeID` INT UNSIGNED,
	IN `in_newSkillTypeID` INT UNSIGNED
)
BEGIN

declare skillAmountMult INT UNSIGNED DEFAULT 10000000;

-- allocate needed skill with 0 values at first.
-- don't use "insert ... select on duplicate key update" here - it is not so safe for replication.
insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
	select c.ID, in_newSkillTypeID as SkillTypeID, 0 as newSkillAmount, 1 as newLockStatus
		from `character` c
		join skills s on s.CharacterID = c.ID
		where s.SkillTypeID = in_oldSkillTypeID
			and !exists(select * from skills_new sn where sn.CharacterID = c.ID and sn.SkillTypeID = in_newSkillTypeID)
		order by c.ID;

-- transfer skill values
update skills_new sn
	join skills s
		on sn.CharacterID = s.CharacterID
		and sn.SkillTypeID = in_newSkillTypeID
		and s.SkillTypeID = in_oldSkillTypeID
	set sn.SkillAmount = (sn.SkillAmount + s.SkillAmount);

-- empty old skill values
update skills
	set SkillAmount = 0
	where SkillTypeID = in_oldSkillTypeID;

-- allocate child skills, if our skill has value >= 30
insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
	select sn.CharacterID, stn.ID, 0 as newSkillAmount, 1 as newLockStatus
	from skill_type_new stn
	join skills_new sn on sn.SkillTypeID = stn.Parent
	where stn.Parent = in_newSkillTypeID
		and sn.SkillAmount >= 30*skillAmountMult
		and !exists(select * from skills_new sn2 where sn2.CharacterID = sn.CharacterID and sn2.SkillTypeID = stn.ID);

-- cap skill values at 100
update skills_new
	set SkillAmount = 100*10000000
	where SkillAmount > 100*10000000;

END;


DROP PROCEDURE IF EXISTS _transferSkillToSkillChainLimit;
CREATE PROCEDURE _transferSkillToSkillChainLimit(
	IN `in_oldSkillTypeID` INT UNSIGNED,
	IN `in_newBaseSkillTypeID` INT UNSIGNED,
	IN `in_skillAmountLimit` INT UNSIGNED
)
BEGIN

declare skillAmountMult INT UNSIGNED DEFAULT 10000000;
declare skillAmountLimit INT UNSIGNED DEFAULT least(greatest(in_skillAmountLimit, 30), 100); -- clamp skill amount limit at 100
declare newBaseSkillTypeID INT UNSIGNED DEFAULT in_newBaseSkillTypeID; -- currently used parent skill in skill chain

if(in_skillAmountLimit < 30 or in_skillAmountLimit > 100) then
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'in_skillAmountLimit should be between 30 and 100';
end if;

while newBaseSkillTypeID is not null do
	-- allocate needed skill with 0 values at first.
	-- don't use "insert ... select on duplicate key update" here - it is not so safe for replication.
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select c.ID, newBaseSkillTypeID as SkillTypeID, 0 as newSkillAmount, 1 as newLockStatus
			from `character` c
			join skills s on s.CharacterID = c.ID
			where s.SkillTypeID = in_oldSkillTypeID
				and s.SkillAmount > 0
				and !exists(select * from skills_new sn where sn.CharacterID = c.ID and sn.SkillTypeID = newBaseSkillTypeID)
			order by c.ID;

	-- create temporary table to hold transferred skill amount
	drop temporary table if exists `tmp_transfer_skill_chain_amount_diff`;
	create temporary table `tmp_transfer_skill_chain_amount_diff` (
		CharacterID INT UNSIGNED NOT NULL,
		OldSkillID INT UNSIGNED NOT NULL,
		NewSkillID INT UNSIGNED NOT NULL,
		SkillAmountDiff INT UNSIGNED NOT NULL
	) engine=memory;

	-- calc and remember skill amount which we can transfer to current base skill
	insert into tmp_transfer_skill_chain_amount_diff (CharacterID, OldSkillID, NewSkillID, SkillAmountDiff)
		select s.CharacterID, s.SkillTypeID, sn.SkillTypeID,
			least(
				s.SkillAmount,
				(skillAmountLimit*skillAmountMult - sn.SkillAmount),
				(
					_getMaxSkillValue(
						ifnull(
							(
								select sn1.SkillAmount
								from skills_new sn1
								join skill_type_new stn_parent on stn_parent.Parent = sn1.SkillTypeID
								where stn_parent.ID = sn.SkillTypeID
									and sn1.CharacterID = s.CharacterID
							),
							100*skillAmountMult
						)
					) - sn.SkillAmount
				)
			) as skillAmountDiff
		from skills s
		join skills_new sn
			on sn.CharacterID = s.CharacterID
			and sn.SkillTypeID = newBaseSkillTypeID
			and s.SkillTypeID = in_oldSkillTypeID
		where sn.SkillAmount < skillAmountLimit*skillAmountMult
			and s.SkillAmount > 0;

	-- transfer skill values into current base skill according to limit
	update skills_new sn
		join tmp_transfer_skill_chain_amount_diff sd
			on sn.CharacterID = sd.CharacterID
			and sn.SkillTypeID = sd.NewSkillID
		set sn.SkillAmount = (sn.SkillAmount + sd.SkillAmountDiff);

	-- update old skill values
	update skills s
		join tmp_transfer_skill_chain_amount_diff sd
			on s.CharacterID = sd.CharacterID
			and s.SkillTypeID = sd.OldSkillID
		set s.SkillAmount = (s.SkillAmount - sd.SkillAmountDiff);

	drop temporary table `tmp_transfer_skill_chain_amount_diff`;

	-- allocate child skills, if our skill has value >= 30
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select sn.CharacterID, stn.ID, 0 as newSkillAmount, 1 as newLockStatus
		from skill_type_new stn
		join skills_new sn on sn.SkillTypeID = stn.Parent
		where stn.Parent = newBaseSkillTypeID
			and sn.SkillAmount >= 30*skillAmountMult
			and !exists(select * from skills_new sn2 where sn2.CharacterID = sn.CharacterID and sn2.SkillTypeID = stn.ID);

	-- go to the first child skill in current skill chain
	set newBaseSkillTypeID = (select min(ID) from skill_type_new where Parent = newBaseSkillTypeID);
end while;

-- cap skill values at 100
update skills_new
	set SkillAmount = 100*10000000
	where SkillAmount > 100*10000000;

END;

DROP FUNCTION IF EXISTS `f_treeQualityToTreeHealth`;
CREATE FUNCTION `f_treeQualityToTreeHealth`(
	`quality` FLOAT
) RETURNS int unsigned
	DETERMINISTIC
BEGIN
	if (quality = 0) then
		return 3; -- Stump
	elseif (quality < 33) then
		return 0; -- Ill
	elseif (quality < 66) then
		return 1; -- Normal
	else
		return 2; -- Great
	end if;
END;

DROP PROCEDURE IF EXISTS `p_compactForestPatches`;
CREATE PROCEDURE `p_compactForestPatches`()
BEGIN
	delete from forest_patch;
	update terrain_blocks set ForestVersion = default;

	-- insert each tree as 'Add' change
	insert into forest_patch
		(`TerID`, `Version`, `Action`, `GeoDataID`, `SubcellMask`, `TreeType`, `TreeHealth`, `AddTime`)
		select f_terIDFromGeoID(f.GeoDataID) as terID,
			0, -- temporary version. We will update it later
			1, -- Action == Add
			f.GeoDataID,
			f.SubcellMask,
			f.TreeType,
			f_treeQualityToTreeHealth(f.Quality),
			f.AgeTime
		from forest f
		order by TerID, ID;

	-- use user-defined variables to ranking forest versions grouped by TerID
	set @currTerID = 0;
	set @forestVer = 1;

	update forest_patch fp
		join
		(
			-- use 'least()' workaround to reset both @currTerID and @forestVer variables when we moved to next terID while iterating over ordered patches
			select ID, (@forestVer := if(@currTerID != TerID, least(@currTerID := TerID, 1), @forestVer) + 1) as ver
			from forest_patch
			order by TerID, ID
		) as fp_ver on fp_ver.ID = fp.ID
		set Version = fp_ver.ver;

	set @currTerID = 0;
	set @forestVer = 0;

	update terrain_blocks tb set tb.ForestVersion = (select ifnull(max(fp.`Version`), default(tb.ForestVersion)) from forest_patch fp where TerID = tb.ID);
END;

-- tree age conversion
-- Implementation of new conversion steps should look like this:
-- 1. Populate temporary table 'tmp_new_tree_ages' (pre-declared below) with new age settings
-- 2. call _p_convertForestToNewAgeSettings() procedure
-- 3. increment value of 'forest' field in '_data_version' table

DROP FUNCTION IF EXISTS _countNewTreeAgeEquation;
DROP FUNCTION IF EXISTS _countNewTreeAge;
DROP PROCEDURE IF EXISTS _p_convertForestToNewAgeSettings;

drop temporary table if exists `tmp_old_tree_ages`;
create temporary table `tmp_old_tree_ages` (
	TreeType tinyint unsigned not null,
	YoungAge int unsigned,
	MatureAge int unsigned
) engine=memory;
-- tree age settings that were valid before any conversions
insert into tmp_old_tree_ages
(TreeType, YoungAge, MatureAge)
values
(0, 7,  14),
(1, 7,  14),
(2, 7,  14),
(3, 7,  14),
(4, 10, 20),
(5, 9,  18),
(6, 7,  14),
(7, 9,  28),
(8, 7,  14);

-- this temporary table should be populated with relevant new age settings
-- before the call to _countNewTreeAge()
drop temporary table if exists `tmp_new_tree_ages`;
create temporary table `tmp_new_tree_ages` (
	TreeType tinyint unsigned not null,
	YoungAge int unsigned,
	MatureAge int unsigned
) engine=memory;

-- internal function for usage inside _countNewTreeAge(), do not call this
-- by yourself, use `_p_convertForestToNewAgeSettings`() instead
CREATE FUNCTION `_countNewTreeAgeEquation` (
	`in_oldAge` INT UNSIGNED,
	`in_oldLeftBorder` INT UNSIGNED,
	`in_oldRightBorder` INT UNSIGNED,
	`in_newLeftBorder` INT UNSIGNED,
	`in_newRightBorder` INT UNSIGNED
)
	RETURNS INT UNSIGNED
BEGIN
	IF (in_oldRightBorder - in_oldLeftBorder) = 0 THEN
		RETURN 0;
	ELSE
		RETURN in_newLeftBorder
			+ (in_oldAge - in_oldLeftBorder) / (in_oldRightBorder - in_oldLeftBorder)
				* (in_newRightBorder - in_newLeftBorder);
	END IF;
END;

-- internal function for usage inside _countNewTreeAge(), do not call this
-- by yourself, use `_p_convertForestToNewAgeSettings`() instead
--
-- converts old tree age to a value that matches the new tree age settings
-- in such a way that tree stays on the same point of the "age scale" as before
-- (i.e. if a tree of a type T was considered new-born for ages from
-- 0 to 10 days before conversion and from 0 to 20 after conversion, a specific
-- tree of type T of old age 5 will have old age 10, old age 6 will have new age
-- 12 and so on)
--
-- IMPORTANT: this function retrieves old and new age settings from two
-- temporary tables: 'tmp_old_tree_ages' and 'tmp_new_tree_ages'. Ensure that
-- these tables contain valid data before you call this function.
--
-- The usage pattern of tree conversion
CREATE FUNCTION `_countNewTreeAge` (
	`in_treeType` TINYINT UNSIGNED,
	`in_oldAge` INT UNSIGNED
)
	RETURNS INT UNSIGNED
BEGIN
	declare oldYoungAge, oldMatureAge int unsigned default 0;
	declare newYoungAge, newMatureAge int unsigned default 0;

	select ifnull(YoungAge, 0) into oldYoungAge from tmp_old_tree_ages where TreeType = in_treeType;
	select ifnull(MatureAge, 0) into oldMatureAge from tmp_old_tree_ages where TreeType = in_treeType;
	select ifnull(YoungAge, 0) into newYoungAge from tmp_new_tree_ages where TreeType = in_treeType;
	select ifnull(MatureAge, 0) into newMatureAge from tmp_new_tree_ages where TreeType = in_treeType;

	IF in_oldAge <= oldYoungAge THEN
		RETURN _countNewTreeAgeEquation(
			in_oldAge,
			0, oldYoungAge,
			0, newYoungAge);
	ELSEIF in_oldAge <= oldMatureAge THEN
		RETURN _countNewTreeAgeEquation(
			in_oldAge,
			oldYoungAge + 1, oldMatureAge,
			newYoungAge + 1, newMatureAge);
	ELSE
		RETURN _countNewTreeAgeEquation(
			LEAST(in_oldAge, oldMatureAge + 100),
			oldMatureAge + 1, oldMatureAge + 100,
			newMatureAge + 1, newMatureAge + 100);
	END IF;
END;

-- To correctly perform age conversion, do the following:
-- 1. Populate temporary table 'tmp_new_tree_ages' with new age settings
-- 2. call _p_convertForestToNewAgeSettings() procedure
-- 3. increment value of 'forest' field in '_data_version' table
CREATE PROCEDURE `_p_convertForestToNewAgeSettings`()
BEGIN
	UPDATE `forest` SET `AgeTime` = _countNewTreeAge(TreeType, AgeTime);
	call p_compactForestPatches();

	TRUNCATE table tmp_old_tree_ages;
	insert into tmp_old_tree_ages
	(TreeType, YoungAge, MatureAge)
	select TreeType, YoungAge, MatureAge from tmp_new_tree_ages;

	TRUNCATE table tmp_new_tree_ages;
END;

DROP FUNCTION IF EXISTS f_getSubjectIDByRole;
CREATE FUNCTION `f_getSubjectIDByRole`(
	`inGuildRoleID` INT UNSIGNED
)
	returns INT UNSIGNED
BEGIN
	declare subjID INT UNSIGNED default NULL;

	select ID from claim_subjects where GuildRoleID = inGuildRoleID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set GuildRoleID = inGuildRoleID;
		set subjID = LAST_INSERT_ID();
	end if;
	
	return subjID;
END;

DROP FUNCTION IF EXISTS f_getSubjectIDByStanding;
CREATE FUNCTION `f_getSubjectIDByStanding`(
	`inStandingTypeID` INT UNSIGNED
)
	returns INT UNSIGNED
BEGIN
	declare subjID INT UNSIGNED default NULL;

	select ID from claim_subjects where StandingTypeID = inStandingTypeID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set StandingTypeID = inStandingTypeID;
		set subjID = LAST_INSERT_ID();
	end if;

	return subjID;
END;

-- Splits stacks of item with Quantity more than MaxStackSize
DROP PROCEDURE IF EXISTS p_splitItemStacksByMaxSize;
CREATE PROCEDURE p_splitItemStacksByMaxSize(
	`in_objTypeID` INT UNSIGNED
)
	COMMENT 'Splits stacks of item with Quantity more than MaxStackSize'
BEGIN
	declare oldItemId, newItemId, oldFeatureID, newFeatureID, curStackSize, maxStackSize INT UNSIGNED default NULL;
	declare hasEffects TINYINT UNSIGNED default NULL;

	declare cursorDone TINYINT UNSIGNED default FALSE;
	declare cur cursor for
	(
		select i.ID, i.FeatureID, f.has_effects, i.Quantity, ot.MaxStackSize
		from items i
		join objects_types ot on ot.ID = i.ObjectTypeID -- and ot.MaxStackSize > 1 and ot.IsMovableObject = 0 and ot.IsUnmovableobject = 0
		left join features f on f.ID = i.FeatureID
		where i.Quantity > ot.MaxStackSize and i.ObjectTypeID = in_objTypeID
	);
	declare continue handler for not found set cursorDone = TRUE;
	
	-- we don't work with stacks having blueprints
	if(exists(
		select *
		from items i
		join objects_types ot on ot.ID = i.ObjectTypeID
		join features f on f.ID = i.FeatureID and f.BlueprintID is not null
		where i.Quantity > ot.MaxStackSize
	)) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'p_splitItemStacksByMaxSize can''t handle stacked items having BlueprintID features';
	end if;
	
	-- iterate over all overflowed stacks
	open cur;
	read_loop: loop
		fetch cur into oldItemId, oldFeatureID, hasEffects, curStackSize, maxStackSize;
		if(cursorDone) then
			leave read_loop;
		end if;
		
		-- iterate while current stack is big enough to split
		while(curStackSize > maxStackSize) do
			-- create new stack
			insert into items(ContainerID, ObjectTypeID, Quality, Quantity, Durability, CreatedDurability)
				select ContainerID, ObjectTypeID, Quality, maxStackSize, Durability, CreatedDurability
				from items 
				where ID = oldItemId;
			set newItemId = LAST_INSERT_ID();
			
			-- reduce old stack
			set curStackSize = (curStackSize - maxStackSize);
			update items 
				set Quantity = curStackSize
				where ID = oldItemId;
			
			if(oldFeatureID is not null) then
				-- copy effects
				if(ifnull(hasEffects, 0) > 0) then
					insert into item_effects (ItemID, EffectID, Magnitude)
						select newItemId, EffectID, Magnitude
						from item_effects
						where ItemID = oldItemId;
				end if;
			
				-- copy features
				insert into features (CustomtextID, CreatedRegionID, BlueprintID, HorseHP, has_effects)
					select CustomtextID, CreatedRegionID, BlueprintID, HorseHP, hasEffects
					from features
					where ID = oldFeatureID;
				set newFeatureID = LAST_INSERT_ID();
				
				update items set FeatureID = newFeatureID where ID = newItemId;
			end if;
		end while;
	end loop;
	close cur;
END;

DROP PROCEDURE IF EXISTS _updateScript;
/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER' */;
CREATE PROCEDURE _updateScript()
BEGIN

-- 0.2.12.0
-- guilds & claims
if(!sf_isConstraintExists('character', 'FK_character_guild_roles')) then
	CREATE TABLE IF NOT EXISTS `guild_roles` (
		`ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
		`Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	INSERT INTO `guild_roles` (`ID`, `Name`) VALUES
		(1, 'Leader'),
		(2, 'Minor leader'),
		(3, '1st tier member'),
		(4, '2nd tier member'),
		(5, '3rd tier member'),
		(6, 'Normal member'),
		(7, 'Recruit');

	CREATE TABLE IF NOT EXISTS `guild_types` (
		`ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
		`GuildLevel` int(11) NOT NULL,
		`Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
		`MessageID` int(10) unsigned NOT NULL,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	INSERT INTO `guild_types` (`ID`, `GuildLevel`, `Name`, `MessageID`) VALUES
		(1, 0, 'Band', 680),
		(2, 1, 'Order', 681),
		(3, 2, 'Country', 682),
		(4, 3, 'Kingdom', 683);

	CREATE TABLE IF NOT EXISTS `guild_standing_types` (
		`ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
		`Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	INSERT INTO `guild_standing_types` (`ID`, `Name`) VALUES
		(1, 'War'),
		(2, 'Hostile'),
		(3, 'Neutral'),
		(4, 'Friendly'),
		(5, 'Ally');

	CREATE TABLE IF NOT EXISTS `deleted_character_info` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`ExCharID` int(10) unsigned NOT NULL,
		`CharName` varchar(9) COLLATE utf8_unicode_ci NOT NULL,
		`CharLastName` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
		`DeletedTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `deleted_guild_info` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`ExGuildID` int(10) unsigned NOT NULL,
		`GuildName` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
		`GuildTag` varchar(4) COLLATE utf8_unicode_ci NOT NULL,
		`DeletedTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `guilds` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`Name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
		`GuildTypeID` tinyint(3) unsigned NOT NULL,
		`IsActive` tinyint(3) unsigned NOT NULL DEFAULT '1',
		`GuildCharter` varchar(10000) COLLATE utf8_unicode_ci DEFAULT NULL,
		`GuildTag` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
		`CreateTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		`DeleteTimestamp` timestamp NULL DEFAULT NULL,
		PRIMARY KEY (`ID`),
		UNIQUE KEY `UNQ_Name` (`Name`),
		UNIQUE KEY `UNQ_GuildTag` (`GuildTag`),
		KEY `IDX_IsActive` (`IsActive`),
		KEY `FK_guilds_guild_types` (`GuildTypeID`),
		CONSTRAINT `FK_guilds_guild_types` FOREIGN KEY (`GuildTypeID`) REFERENCES `guild_types` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `guild_standings` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`GuildID1` int(10) unsigned NOT NULL,
		`GuildID2` int(10) unsigned NOT NULL,
		`StandingTypeID` tinyint(3) unsigned NOT NULL,
		PRIMARY KEY (`ID`),
		UNIQUE KEY `UNQ_GuildID1_GuildID2` (`GuildID1`,`GuildID2`),
		KEY `FK_guild_standings_guild_standing_types` (`StandingTypeID`),
		KEY `IDX_GuildID2_GuildID1` (`GuildID2`,`GuildID1`),
		CONSTRAINT `FK_guild_standings_guilds1` FOREIGN KEY (`GuildID1`) REFERENCES `guilds` (`ID`),
		CONSTRAINT `FK_guild_standings_guilds2` FOREIGN KEY (`GuildID2`) REFERENCES `guilds` (`ID`),
		CONSTRAINT `FK_guild_standings_guild_standing_types` FOREIGN KEY (`StandingTypeID`) REFERENCES `guild_standing_types` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `guild_type_role_msgs` (
		`ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
		`GuildTypeID` tinyint(3) unsigned NOT NULL,
		`GuildRoleID` tinyint(3) unsigned NOT NULL,
		`MessageID` int(10) unsigned NOT NULL,
		PRIMARY KEY (`ID`),
		KEY `FK_guild_type_role_msgs_guild_roles` (`GuildRoleID`),
		KEY `FK_guild_type_role_msgs_guild_types` (`GuildTypeID`),
		CONSTRAINT `FK_guild_type_role_msgs_guild_roles` FOREIGN KEY (`GuildRoleID`) REFERENCES `guild_roles` (`ID`),
		CONSTRAINT `FK_guild_type_role_msgs_guild_types` FOREIGN KEY (`GuildTypeID`) REFERENCES `guild_types` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	INSERT INTO `guild_type_role_msgs` (`ID`, `GuildTypeID`, `GuildRoleID`, `MessageID`) VALUES
		(1, 2, 1, 620),
		(2, 2, 2, 622),
		(3, 2, 3, 624),
		(4, 2, 4, 626),
		(5, 2, 5, 628),
		(6, 2, 6, 630),
		(7, 2, 7, 632),
		(8, 3, 1, 634),
		(9, 3, 2, 636),
		(10, 3, 3, 638),
		(11, 3, 4, 640),
		(12, 3, 5, 642),
		(13, 3, 6, 644),
		(14, 3, 7, 646),
		(15, 4, 1, 634),
		(16, 4, 2, 636),
		(17, 4, 3, 638),
		(18, 4, 4, 640),
		(19, 4, 5, 642),
		(20, 4, 6, 648),
		(21, 4, 7, 650);

	CREATE TABLE IF NOT EXISTS `guild_lands` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`GuildID` int(10) unsigned NOT NULL,
		`Name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
		`CenterGeoID` int(10) unsigned NOT NULL,
		`Radius` int(10) unsigned NOT NULL,
		`LandType` int(10) unsigned NOT NULL COMMENT '1=Core, 2=Suburbia',
		PRIMARY KEY (`ID`),
		KEY `FK_guild_lands_guilds` (`GuildID`),
		CONSTRAINT `FK_guild_lands_guilds` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `personal_lands` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`CharID` int(10) unsigned NOT NULL,
		`Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
		`GeoID1` int(10) unsigned NOT NULL,
		`GeoID2` int(10) unsigned NOT NULL,
		`IsTemp` tinyint(3) unsigned NOT NULL DEFAULT '0',
		PRIMARY KEY (`ID`),
		KEY `FK_guild_lands_character` (`CharID`),
		CONSTRAINT `FK_guild_lands_character` FOREIGN KEY (`CharID`) REFERENCES `character` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `claims` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`GuildLandID` int(10) unsigned DEFAULT NULL,
		`PersonalLandID` int(10) unsigned DEFAULT NULL,
		`SupportPoints` int(11) NOT NULL,
		PRIMARY KEY (`ID`),
		UNIQUE KEY `UNQ_GuildLandID` (`GuildLandID`),
		UNIQUE KEY `UNQ_PersonalLandID` (`PersonalLandID`),
		CONSTRAINT `FK_claims_guild_lands` FOREIGN KEY (`GuildLandID`) REFERENCES `guild_lands` (`ID`),
		CONSTRAINT `FK_claims_personal_lands` FOREIGN KEY (`PersonalLandID`) REFERENCES `personal_lands` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `unmovable_objects_claims` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`UnmovableObjectID` int(10) unsigned NOT NULL,
		`ClaimID` int(10) unsigned NOT NULL,
		PRIMARY KEY (`ID`),
		UNIQUE KEY `UNQ_UnmovableObjectID` (`UnmovableObjectID`),
		KEY `FK_unmovable_objects_claims_claims` (`ClaimID`),
		CONSTRAINT `FK_unmovable_objects_claims_claims` FOREIGN KEY (`ClaimID`) REFERENCES `claims` (`ID`),
		CONSTRAINT `FK_unmovable_objects_claims_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `claim_subjects` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`CharID` int(10) unsigned DEFAULT NULL,
		`GuildRoleID` tinyint(3) unsigned DEFAULT NULL,
		`GuildID` int(10) unsigned DEFAULT NULL,
		`StandingTypeID` tinyint(3) unsigned DEFAULT NULL,
		PRIMARY KEY (`ID`),
		UNIQUE KEY `UNQ_FK_claim_subjects_character` (`CharID`),
		UNIQUE KEY `UNQ_FK_claim_subjects_guild_roles` (`GuildRoleID`),
		UNIQUE KEY `UNQ_FK_claim_subjects_guilds` (`GuildID`),
		UNIQUE KEY `UNQ_FK_claim_subjects_standing_types` (`StandingTypeID`),
		CONSTRAINT `FK_claim_subjects_character` FOREIGN KEY (`CharID`) REFERENCES `character` (`ID`),
		CONSTRAINT `FK_claim_subjects_guilds` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`),
		CONSTRAINT `FK_claim_subjects_guild_roles` FOREIGN KEY (`GuildRoleID`) REFERENCES `guild_roles` (`ID`),
		CONSTRAINT `FK_claim_subjects_standing_types` FOREIGN KEY (`StandingTypeID`) REFERENCES `guild_standing_types` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `claim_rules_unmovable` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`UnmovableClaimID` int(10) unsigned NOT NULL,
		`ClaimSubjectID` int(10) unsigned NOT NULL,
		`CanUse` tinyint(3) unsigned NOT NULL DEFAULT '0',
		`CanDestroy` tinyint(3) unsigned NOT NULL DEFAULT '0',
		PRIMARY KEY (`ID`),
		KEY `FK_claim_rules_unmovable_unmovable_objects_claims` (`UnmovableClaimID`),
		KEY `FK_claim_rules_unmovable_claim_subjects` (`ClaimSubjectID`),
		CONSTRAINT `FK_claim_rules_unmovable_claim_subjects` FOREIGN KEY (`ClaimSubjectID`) REFERENCES `claim_subjects` (`ID`),
		CONSTRAINT `FK_claim_rules_unmovable_unmovable_objects_claims` FOREIGN KEY (`UnmovableClaimID`) REFERENCES `unmovable_objects_claims` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `claim_rules` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`ClaimID` int(10) unsigned NOT NULL,
		`ClaimSubjectID` int(10) unsigned NOT NULL,
		`CanEnter` tinyint(3) unsigned NOT NULL DEFAULT '0',
		`CanBuild` tinyint(3) unsigned NOT NULL DEFAULT '0',
		`CanClaim` tinyint(3) unsigned NOT NULL DEFAULT '0',
		`CanUse` tinyint(3) unsigned NOT NULL DEFAULT '0',
		`CanDestroy` tinyint(3) unsigned NOT NULL DEFAULT '0',
		PRIMARY KEY (`ID`),
		UNIQUE KEY `UNQ_ClaimID_ClaimSubjectID` (`ClaimID`,`ClaimSubjectID`),
		KEY `FK_claim_rules_claims` (`ClaimID`),
		KEY `FK_claim_rules_claim_subjects` (`ClaimSubjectID`),
		CONSTRAINT `FK_claim_rules_claims` FOREIGN KEY (`ClaimID`) REFERENCES `claims` (`ID`),
		CONSTRAINT `FK_claim_rules_claim_subjects` FOREIGN KEY (`ClaimSubjectID`) REFERENCES `claim_subjects` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `guild_actions_queue` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`TicketID` bigint(20) unsigned NOT NULL COMMENT 'Unique number for identifying query',
		`ActionType` enum('guild_create','guild_destroy','guild_change_level','player_invite_to_guild','player_joined_guild','player_left_guild','player_new_guild_role','guild_change_standing') COLLATE utf8_unicode_ci NOT NULL COMMENT '"guild_create" - Create a guild, "guild_destroy" - Destroy a guild, "guild_change_level" - Change guild level, "player_invite_to_guild" - Player invited to guild, "player_joined_guild" - Player joined a guild, "player_left_guild" - Player left or kicked from guild, "player_new_guild_role" - Player has been promoted or demoted, "guild_change_standing" - Guild has changed its standing',
		`ProducerCharID` int(10) unsigned NOT NULL,
		`GuildID` int(10) unsigned DEFAULT NULL,
		`CharID` int(10) unsigned DEFAULT NULL,
		`GuildName` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
		`GuildTag` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
		`GuildCharter` varchar(10000) COLLATE utf8_unicode_ci DEFAULT NULL,
		`GuildTypeID` tinyint(3) unsigned DEFAULT NULL,
		`CharIsKicked` tinyint(3) unsigned NOT NULL DEFAULT '0',
		`CharGuildRoleID` tinyint(3) unsigned DEFAULT NULL,
		`OtherGuildID` int(10) unsigned DEFAULT NULL,
		`StandingTypeID` tinyint(3) unsigned DEFAULT NULL,
		`AddedTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		`OwnerConnectionID` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'For internal processing',
		`OwnedTimestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'For internal processing. Updates with OwnerConnectionID',
		PRIMARY KEY (`ID`),
		KEY `IDX_OwnerConnectionID_OwnedTime` (`OwnerConnectionID`,`OwnedTimestamp`),
		KEY `FK_guild_actions_queue_character1` (`ProducerCharID`),
		KEY `FK_guild_actions_queue_character2` (`CharID`),
		KEY `FK_guild_actions_queue_guilds1` (`GuildID`),
		KEY `FK_guild_actions_queue_guilds2` (`OtherGuildID`),
		KEY `FK_guild_actions_queue_guild_types` (`GuildTypeID`),
		KEY `FK_guild_actions_queue_guild_roles` (`CharGuildRoleID`),
		KEY `FK_guild_actions_queue_guild_standing_types` (`StandingTypeID`),
		CONSTRAINT `FK_guild_actions_queue_character1` FOREIGN KEY (`ProducerCharID`) REFERENCES `character` (`ID`),
		CONSTRAINT `FK_guild_actions_queue_character2` FOREIGN KEY (`CharID`) REFERENCES `character` (`ID`),
		CONSTRAINT `FK_guild_actions_queue_guilds1` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`),
		CONSTRAINT `FK_guild_actions_queue_guilds2` FOREIGN KEY (`OtherGuildID`) REFERENCES `guilds` (`ID`),
		CONSTRAINT `FK_guild_actions_queue_guild_roles` FOREIGN KEY (`CharGuildRoleID`) REFERENCES `guild_roles` (`ID`),
		CONSTRAINT `FK_guild_actions_queue_guild_standing_types` FOREIGN KEY (`StandingTypeID`) REFERENCES `guild_standing_types` (`ID`),
		CONSTRAINT `FK_guild_actions_queue_guild_types` FOREIGN KEY (`GuildTypeID`) REFERENCES `guild_types` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `guild_actions_processed` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`TicketID` bigint(20) unsigned NOT NULL COMMENT 'Unique number for identifying query',
		`ActionType` enum('guild_create','guild_destroy','guild_change_level','player_invite_to_guild','player_joined_guild','player_left_guild','player_new_guild_role','guild_change_standing') COLLATE utf8_unicode_ci NOT NULL COMMENT '"guild_create" - Create a guild, "guild_destroy" - Destroy a guild, "guild_change_level" - Change guild level, "player_invite_to_guild" - Player invited to guild, "player_joined_guild" - Player joined a guild, "player_left_guild" - Player left or kicked from guild, "player_new_guild_role" - Player has been promoted or demoted, "guild_change_standing" - Guild has changed its standing',
		`ProcessedStatus` enum('failed','processed','user_accepted','user_declined') COLLATE utf8_unicode_ci NOT NULL,
		`ProducerCharID` int(10) unsigned DEFAULT NULL COMMENT 'character.ID',
		`ProducerCharDeletedID` int(10) unsigned DEFAULT NULL COMMENT 'deleted_character_info.ID',
		`GuildID` int(10) unsigned DEFAULT NULL COMMENT 'guilds.ID',
		`GuildDeletedID` int(10) unsigned DEFAULT NULL COMMENT 'deleted_guild_info.ID',
		`CharID` int(10) unsigned DEFAULT NULL COMMENT 'character.ID',
		`CharDeletedID` int(10) unsigned DEFAULT NULL COMMENT 'deleted_character_info.ID',
		`GuildName` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
		`GuildTag` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
		`GuildCharter` varchar(10000) COLLATE utf8_unicode_ci DEFAULT NULL,
		`GuildTypeID` tinyint(3) unsigned DEFAULT NULL COMMENT 'guild_types.ID',
		`CharIsKicked` tinyint(3) unsigned NOT NULL DEFAULT '0',
		`CharGuildRoleID` tinyint(3) unsigned DEFAULT NULL COMMENT 'guild_roles.ID',
		`OtherGuildID` int(10) unsigned DEFAULT NULL COMMENT 'guilds.ID',
		`OtherGuildDeletedID` int(10) unsigned DEFAULT NULL COMMENT 'deleted_guild_info.ID',
		`StandingTypeID` tinyint(3) unsigned DEFAULT NULL COMMENT 'guild_standing_types',
		`ProcessedTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		PRIMARY KEY (`ID`),
		UNIQUE KEY `UNQ_TicketID` (`TicketID`),
		KEY `FK_guild_actions_processed_character1` (`ProducerCharID`),
		CONSTRAINT `FK_guild_actions_processed_character1` FOREIGN KEY (`ProducerCharID`) REFERENCES `character` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	ALTER TABLE `character`
		ADD COLUMN `GuildID` INT UNSIGNED NULL AFTER `appearance`,
		ADD COLUMN `GuildRoleID` TINYINT UNSIGNED NULL AFTER `GuildID`,
		ADD INDEX `FK_GuildID` (`GuildID`),
		ADD INDEX `FK_character_guild_roles` (`GuildRoleID`),
		ADD CONSTRAINT `FK_GuildID` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`),
		ADD CONSTRAINT `FK_character_guild_roles` FOREIGN KEY (`GuildRoleID`) REFERENCES `guild_roles` (`ID`);
end if;

if(!sf_isIndexExists('claim_rules_unmovable', 'UNQ_UnmovableClaimID_ClaimSubjectID')) then
	ALTER TABLE claim_rules_unmovable
		ADD UNIQUE INDEX `UNQ_UnmovableClaimID_ClaimSubjectID` (`UnmovableClaimID`, `ClaimSubjectID`);
end if;

-- add base prices
if(!sf_isColumnExists('objects_types', 'BasePrice')) then
	ALTER TABLE objects_types
		ADD COLUMN `BasePrice` int unsigned NULL DEFAULT NULL COMMENT 'BasePrice for Q=50 item in 0.01*copper coins' AFTER `Description`;
end if;

-- deleted_guild_info.GuildName and deleted_guild_info.GuildTag is nullable now
ALTER TABLE deleted_guild_info
	CHANGE COLUMN `GuildName` `GuildName` VARCHAR(45) NULL,
	CHANGE COLUMN `GuildTag` `GuildTag` VARCHAR(4) NULL;

-- set some default durability to objects which created without any durability
update movable_objects set Durability = 5000, CreatedDurability = 5000 where CreatedDurability = 0 and IsComplete > 0;
update unmovable_objects set Durability = 5000, CreatedDurability = 5000 where CreatedDurability = 0 and IsComplete > 0;


if(!sf_isColumnExists('stables_logs', 'EventTime')) then
	-- `EventTime` column instead of `Time` in stables_logs table
	ALTER TABLE stables_logs
		ADD COLUMN `EventTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `UnmovableObjectID`;

	UPDATE stables_logs set `EventTime` = FROM_UNIXTIME(`Time`);

	ALTER TABLE stables_logs
		DROP COLUMN `Time`;

	-- objects_types.ID instead of objects_types.Name in stables_logs.Param1 column
	update stables_logs s set s.Param1 = ifnull(
		(select ID from objects_types o where o.Name = s.Param1 and ifnull(o.FaceImage, '') != '' limit 1), s.Param1
	);
end if;

-- drop unused animal_drop_items table
if(sf_isTableExists('animal_drop_items')) then
	drop table animal_drop_items;
end if;

-- update column comment
ALTER TABLE objects_patch
	CHANGE COLUMN `Action` `Action` tinyint(3) unsigned NOT NULL COMMENT '1=Create; 2=Delete; 3=CompleteChange; 4=RotateChange';

drop table if exists day_version;

if(!sf_isColumnExists('terrain_blocks', 'CachedClientGeoDatSize')) then
	ALTER TABLE terrain_blocks
		ADD COLUMN `CachedGeoVersion` INT UNSIGNED NULL,
		ADD COLUMN `CachedTerCRC` INT UNSIGNED NULL,
		ADD COLUMN `CachedServerGeoIdxCRC` INT UNSIGNED NULL,
		ADD COLUMN `CachedServerGeoDatCRC` INT UNSIGNED NULL,
		ADD COLUMN `CachedClientGeoIdxCRC` INT UNSIGNED NULL,
		ADD COLUMN `CachedClientGeoDatCRC` INT UNSIGNED NULL,
		ADD COLUMN `PackedTerCRC` INT UNSIGNED NULL,
		ADD COLUMN `PackedClientGeoIdxCRC` INT UNSIGNED NULL,
		ADD COLUMN `PackedClientGeoDatCRC` INT UNSIGNED NULL,
		ADD COLUMN `CachedClientGeoIdxSize` INT UNSIGNED NULL,
		ADD COLUMN `CachedClientGeoDatSize` INT UNSIGNED NULL;
end if;

if(!sf_isTableExists('nav_mesh_cache_ter_versions')) then
	CREATE TABLE `nav_mesh_cache` (
		-- TODO: (for MMO) PK should also include worldID
		`ServerID` smallint unsigned NOT NULL,
		`FileCRC` int unsigned NOT NULL,
		`FileSize` int unsigned NOT NULL,
		`FileTimestamp` int unsigned NOT NULL,
		PRIMARY KEY (`ServerID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE `nav_mesh_cache_ter_versions` (
		`ServerID` smallint unsigned NOT NULL,
		`TerID` int unsigned NOT NULL,
		`ObjectsVersion` int unsigned NOT NULL,
		`ForestVersion` int unsigned NOT NULL,
		`GeoVersion` int unsigned NOT NULL,
		PRIMARY KEY (`ServerID`, `TerID`),
		UNIQUE KEY `UNQ_TerID` (`TerID`),
		CONSTRAINT `FK_nav_mesh_cache_ter_versions_terrain_blocks` FOREIGN KEY (`TerID`) REFERENCES `terrain_blocks` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
end if;

-- Riding Horses
if(!sf_isTableExists('horses')) then
	CREATE TABLE `horses` (
		`ID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
		`ObjectTypeID` INT(10) UNSIGNED NOT NULL,
		`Quality` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
		`HP` INT(11) NOT NULL DEFAULT '1000000' COMMENT '6 digits after point',
		`GeoID` INT(10) UNSIGNED NOT NULL,
		`GeoAlt` SMALLINT(5) UNSIGNED NOT NULL,
		`OffsetX` SMALLINT(6) NOT NULL COMMENT 'ingame millimeters',
		`OffsetY` SMALLINT(6) NOT NULL COMMENT 'ingame millimeters',
		`TurnAngle` SMALLINT(6) NOT NULL COMMENT 'rotation angle',
		`MountedCharacterID` INT(10) UNSIGNED NULL DEFAULT NULL,
		`OwnerID` INT(10) UNSIGNED NULL DEFAULT NULL,
		`DroppedTime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
		PRIMARY KEY (`ID`),
		UNIQUE INDEX `UNQ_MountedCharacterID` (`MountedCharacterID`),
		INDEX `FK_horses_character` (`ObjectTypeID`),
		INDEX `FK_horses_character2` (`OwnerID`),
		CONSTRAINT `FK_horses_character` FOREIGN KEY (`MountedCharacterID`) REFERENCES `character` (`ID`),
		CONSTRAINT `FK_horses_character2` FOREIGN KEY (`OwnerID`) REFERENCES `character` (`ID`),
		CONSTRAINT `FK_horses_objects_types` FOREIGN KEY (`ObjectTypeID`) REFERENCES `objects_types` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
end if;

if(!sf_isTableExists('horses_server_id_ranges')) then
	-- remove auto_increment from table (assume that PK named ID and it is UINT)
	ALTER TABLE `horses`
		ALTER `ID` DROP DEFAULT;
	ALTER TABLE `horses`
		CHANGE COLUMN ID ID INT UNSIGNED NOT NULL FIRST;

	-- should be accessed only using p_issueIdRange_horses
	CREATE TABLE `horses_server_id_ranges` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`ServerID` int(10) unsigned NOT NULL,
		`RangeStartID` int(10) unsigned NOT NULL,
		`RangeEndID` int(10) unsigned NOT NULL,
		PRIMARY KEY (`ID`),
		KEY `IDX_RangeEndID` (`RangeEndID`), -- for max() operation
		KEY `IDX_ServerID` (`ServerID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='horses ID ranges assigned to servers. Should be accessed only by using p_issueIdRange_horses';

	-- dummy table for locking from p_issueIdRange_horses, using like a mutex
	CREATE TABLE `horses_server_id_ranges_lock` (
		`ID` tinyint unsigned NOT NULL,
		`IsLocked` tinyint unsigned NOT NULL,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Dummy table for locking from p_issueIdRange_horses. Do not store actual data, using only for internal needs';
end if;

if(!sf_isColumnExists('effects', 'PlayerEffectID')) then
	ALTER TABLE `effects`
		ADD COLUMN `PlayerEffectID` tinyint unsigned NULL DEFAULT NULL AFTER `ResultPotionID`;
end if;

-- character_effects can store not only "Bed Rest" effect now
if(!sf_isColumnExists('character_effects', 'PlayerEffectID')) then
	-- cleanup character_effects table
	DELETE FROM character_effects WHERE DurationLeft = 0;

	-- remove unique index from character_effects.CharacterID
	ALTER TABLE character_effects
		DROP FOREIGN KEY `FK_character_effects_character`,
		DROP INDEX `FK_character_effects_character`;
	ALTER TABLE character_effects
		ADD INDEX `FK_character_effects_character` (`CharacterID`),
		ADD CONSTRAINT `FK_character_effects_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`);

	-- add PlayerEffectID column and set all existing rows to Bed Rest effect
	ALTER TABLE character_effects
		ADD COLUMN `PlayerEffectID` TINYINT UNSIGNED NOT NULL DEFAULT '51' /*Bed Rest*/ AFTER `ID`;

	-- remove default Bed Rest from character_effects.PlayerEffectID
	ALTER TABLE character_effects
		ALTER `PlayerEffectID` DROP DEFAULT;

	ALTER TABLE character_effects
		COMMENT='Stores player''s effects';
end if;

-- add new equipment slots (14, 15)
if(!exists(select * from equipment_slots where Slot = 15)) then
	-- preallocate equipment slots for all exists users
	insert ignore equipment_slots (CharacterID, Slot)
		select c.ID, t.slot
		from `character` c
		cross join (
			select 1 as slot union all
			select 2 union all
			select 3 union all
			select 4 union all
			select 5 union all
			select 6 union all
			select 7 union all
			select 8 union all
			select 9 union all
			select 10 union all
			select 11 union all
			select 12 union all
			select 13 union all
			select 14 union all
			select 15
		) as t;

	-- reorganize table according to new data within unique index (by copying data into new table and rename it)
	-- new table is match to current equipment_slots table stucture except indexes and constraints, which will added later
	CREATE TABLE `equipment_slots_new` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`CharacterID` INT UNSIGNED NOT NULL,
		`Slot` TINYINT UNSIGNED NOT NULL COMMENT 'Valid slots: 1-13',
		`ItemID` INT UNSIGNED NULL DEFAULT NULL,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	insert into equipment_slots_new (CharacterID, Slot, ItemID)
		select s.CharacterID, s.Slot, s.ItemID
		from equipment_slots s
		order by CharacterID ASC, Slot ASC;

	rename table equipment_slots to equipment_slots_old, equipment_slots_new to equipment_slots;
	drop table equipment_slots_old;

	-- add indexes and constraints to just renamed equipment_slots_new table
	ALTER TABLE equipment_slots
		ADD UNIQUE INDEX `UNQ_equipment_slots_CharacterID_Slot` (`CharacterID`, `Slot`),
		-- ADD INDEX `FK_equipment_slots_character` (`CharacterID`), -- redundant index
		ADD INDEX `FK_equipment_slots_items` (`ItemID`),
		ADD CONSTRAINT `FK_equipment_slots_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`),
		ADD CONSTRAINT `FK_equipment_slots_items` FOREIGN KEY (`ItemID`) REFERENCES `items` (`ID`);
end if;

if(!sf_isColumnExists('horses', 'OffsetZ')) then
	ALTER TABLE `horses`
		ADD COLUMN `OffsetZ` INT(10) NOT NULL COMMENT 'ingame millimeters' AFTER `OffsetY`;
end if;

if(!sf_isTableExists('server_uuid')) then
 CREATE TABLE IF NOT EXISTS `server_uuid` (
  `ID` tinyint unsigned NOT NULL,
  `Uuid` char(36) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

 insert into server_uuid (`ID`, `Uuid`)
 values (1, UUID());
end if;

-- reset max items quality to 100
update items set quality = 100 where quality > 100;

if(!sf_isColumnExists('character', 'RallyObjectID')) then
	ALTER TABLE `character`
		ADD COLUMN `RallyObjectID` INT(10) UNSIGNED NULL DEFAULT NULL AFTER `BindedObjectID`;
end if;

if(!sf_isColumnExists('character', 'LastTimeUsedTransmuteIntoGold')) then
	ALTER TABLE `character`
		ADD COLUMN `LastTimeUsedTransmuteIntoGold` INT(10) UNSIGNED NOT NULL DEFAULT '0'
			AFTER `LastTimeUsedPraiseYourGodAbility`;
end if;


if(!sf_isConstraintExists('character', 'FK_character_unmovable_objects2')) then
	ALTER TABLE `character`
		ADD CONSTRAINT `FK_character_unmovable_objects2` FOREIGN KEY (`RallyObjectID`) REFERENCES `unmovable_objects` (`ID`);
end if;


if(!sf_isColumnExists('horses', 'Durability')) then
	ALTER TABLE `horses`
		ADD COLUMN `Durability` SMALLINT(10) UNSIGNED NOT NULL DEFAULT '100' COMMENT '2 digits after point' AFTER `DroppedTime`;
	ALTER TABLE `horses`
		ADD COLUMN `CreatedDurability` SMALLINT(10) UNSIGNED NOT NULL DEFAULT '100' COMMENT '2 digits after point' AFTER `Durability`;
end if;


if(!sf_isColumnExists('recipe', 'Autorepeat')) then
	ALTER TABLE `recipe`
		ADD COLUMN `Autorepeat` TINYINT UNSIGNED NOT NULL DEFAULT '0' COMMENT 'bool' AFTER `Quantity`;
end if;


if(sf_isColumnExists('recipe', 'CreatingDuration')) then
ALTER TABLE `recipe`
	DROP COLUMN `CreatingDuration`;
end if;


-- fix old default appearance
UPDATE `character` SET `appearance`=0x01010000000000000000 WHERE  `appearance`=0x313032;

if(!sf_isTableExists('stables_data')) then
	CREATE TABLE IF NOT EXISTS `stables_data` (
		`ID` int unsigned NOT NULL AUTO_INCREMENT,
		`UnmovableObjectID` int unsigned NOT NULL,
		`FoodConsumeRatio` FLOAT NOT NULL DEFAULT '0.0',
		`DungMeter` FLOAT NOT NULL DEFAULT '0.0',
		`HarvestAmount` FLOAT NOT NULL DEFAULT '0.0',
		`FoodLeft` FLOAT NOT NULL DEFAULT '0.0',
		`FoodQuality` FLOAT NOT NULL DEFAULT '0.0',
		`DungQuantity` FLOAT NOT NULL DEFAULT '0.0',
		`DungQuality` FLOAT NOT NULL DEFAULT '0.0',
		`Starving` TINYINT NOT NULL DEFAULT '0',
		`Dirty` TINYINT NOT NULL DEFAULT '0',
		PRIMARY KEY (`ID`),
		UNIQUE KEY `FK_stables_data_UnmovableObjectID` (`UnmovableObjectID`),
		CONSTRAINT `FK_stables_data_UnmovableObjectID` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
end if;

if(!sf_isTableExists('heraldries')) then
	CREATE TABLE heraldic_charges (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`SymbolIndex` TINYINT UNSIGNED NOT NULL,
		`ColorIndex` TINYINT UNSIGNED NOT NULL,
		`Position` ENUM('top_left', 'top_center', 'top_right', 'middle_left', 'true_center', 'middle_right', 'bottom_left', 'bottom_center', 'bottom_right') NOT NULL,
		`Size` ENUM('small', 'medium', 'large') NOT NULL,
		PRIMARY KEY (`ID`),
		UNIQUE KEY `UNQ_SymbolIndex_ColorIndex_Position_Size` (`SymbolIndex`,`ColorIndex`,`Position`,`Size`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE heraldries (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`BackgroundIndex` TINYINT UNSIGNED NOT NULL,
		`BackgroundColorIndex1` TINYINT UNSIGNED NOT NULL,
		`BackgroundColorIndex2` TINYINT UNSIGNED NOT NULL,
		`ChargeID1` INT UNSIGNED NOT NULL,
		`ChargeID2` INT UNSIGNED NULL COMMENT 'One charge is optional',
		PRIMARY KEY (`ID`),
		-- UNIQUE KEY `UNQ_Background_Charges` (`BackgroundIndex`,`BackgroundColorIndex1`,`BackgroundColorIndex2`,`ChargeID1`,`ChargeID2`), -- null field is not unique
		CONSTRAINT `FK_heraldries_heraldic_charges1` FOREIGN KEY (`ChargeID1`) REFERENCES `heraldic_charges` (`ID`),
		CONSTRAINT `FK_heraldries_heraldic_charges2` FOREIGN KEY (`ChargeID2`) REFERENCES `heraldic_charges` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	ALTER TABLE guilds
		ADD COLUMN `HeraldryID` INT UNSIGNED NULL AFTER `GuildTag`,
		ADD UNIQUE INDEX `FK_guilds_heraldries` (`HeraldryID`),
		ADD CONSTRAINT `FK_guilds_heraldries` FOREIGN KEY (`HeraldryID`) REFERENCES `heraldries` (`ID`);
end if;

-- shift equipment slots: 14->15, 15->16. Add new equipment slots 14
if(!exists(select * from equipment_slots where Slot = 16)) then
	-- delete index, so we dont got duplicates on UNQ_equipment_slots_CharacterID_Slot below
	ALTER TABLE equipment_slots
		DROP FOREIGN KEY `FK_equipment_slots_character`,
		DROP INDEX `UNQ_equipment_slots_CharacterID_Slot`;

	-- shift slots: 14->15, 15->16
	update equipment_slots
		set Slot = (Slot + 1)
		where Slot = 14 or Slot = 15;

	-- bring unique index back - needed for proper preallocate of slots
	ALTER TABLE equipment_slots
		ADD UNIQUE INDEX `UNQ_equipment_slots_CharacterID_Slot` (`CharacterID`, `Slot`);

	-- preallocate equipment slots for all exists users
	insert ignore equipment_slots (CharacterID, Slot)
		select c.ID, t.slot
		from `character` c
		cross join (
			select 1 as slot union all
			select 2 union all
			select 3 union all
			select 4 union all
			select 5 union all
			select 6 union all
			select 7 union all
			select 8 union all
			select 9 union all
			select 10 union all
			select 11 union all
			select 12 union all
			select 13 union all
			select 14 union all -- new slot
			select 15 union all
			select 16
		) as t;

	-- reorganize table according to new data within unique index (by copying data into new table and rename it)
	-- new table is match to current equipment_slots table stucture except indexes and constraints, which will added later
	CREATE TABLE `equipment_slots_new` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`CharacterID` INT UNSIGNED NOT NULL,
		`Slot` TINYINT UNSIGNED NOT NULL COMMENT 'Valid slots: 1-16',
		`ItemID` INT UNSIGNED NULL DEFAULT NULL,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	insert into equipment_slots_new (CharacterID, Slot, ItemID)
		select s.CharacterID, s.Slot, s.ItemID
		from equipment_slots s
		order by CharacterID ASC, Slot ASC;

	rename table equipment_slots to equipment_slots_old, equipment_slots_new to equipment_slots;
	drop table equipment_slots_old;

	-- add indexes and constraints to just renamed equipment_slots_new table
	ALTER TABLE equipment_slots
		ADD UNIQUE INDEX `UNQ_equipment_slots_CharacterID_Slot` (`CharacterID`, `Slot`),
		-- ADD INDEX `FK_equipment_slots_character` (`CharacterID`), -- redundant index
		ADD INDEX `FK_equipment_slots_items` (`ItemID`),
		ADD CONSTRAINT `FK_equipment_slots_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`),
		ADD CONSTRAINT `FK_equipment_slots_items` FOREIGN KEY (`ItemID`) REFERENCES `items` (`ID`);
end if;

-- make heraldries.ChargeID1 NULL-able
ALTER TABLE heraldries
	CHANGE COLUMN `ChargeID1` `ChargeID1` INT UNSIGNED NULL, -- make nullable
	CHANGE COLUMN `ChargeID2` `ChargeID2` INT UNSIGNED NULL; -- remove comment


-- update skill tree
if(exists(select * from skill_type where ID = 46)) then
	-- define new skills
	DROP TABLE IF EXISTS `skill_type_new`;
	CREATE TABLE `skill_type_new` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`Name` VARCHAR(45) NOT NULL COLLATE 'utf8_unicode_ci',
		`Description` VARCHAR(45) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
		`Parent` INT UNSIGNED NULL,
		`Group` TINYINT UNSIGNED NULL,
		`PrimaryStat` CHAR(4) NOT NULL COLLATE 'utf8_unicode_ci',
		`SecondaryStat` CHAR(4) NOT NULL COLLATE 'utf8_unicode_ci',
		`MasterMessageID` INT UNSIGNED NULL DEFAULT '0',
		`GMMessageID` INT UNSIGNED NULL DEFAULT '0',
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	INSERT INTO `skill_type_new` (`ID`, `Name`, `Description`, `Parent`, `Group`, `PrimaryStat`, `SecondaryStat`, `MasterMessageID`, `GMMessageID`) VALUES
		(1, 'Artisan', '', NULL, 1, 'Int', 'Str', 490, 491),
		(2, 'Mining', '', 16, 1, 'Str', 'Con', 492, 493),
		(3, 'Smelting', '', 17, 1, 'Agi', 'Int', 494, 495),
		(4, 'Forging', '', 3, 1, 'Str', 'Con', 496, 497),
		(5, 'Armorsmithing', '', 3, 1, 'Str', 'Agi', 498, 499),
		(6, 'Forestry', '', 21, 1, 'Con', 'Will', 500, 501),
		(7, 'Building Maintain', '', 19, 1, 'Str', 'Con', 502, 503),
		(8, 'Carpentry', '', 1, 1, 'Con', 'Str', 504, 505),
		(9, 'Bowcraft', '', 8, 1, 'Con', 'Will', 506, 507),
		(10, 'Warfare engineering', '', 9, 1, 'Will', 'Int', 508, 509),
		(11, 'Nature\'s lore', '', NULL, 1, 'Int', 'Will', 510, 511),
		(12, 'Gathering', '', 11, 1, 'Will', 'Con', 512, 513),
		(13, 'Brewery', '', 32, 1, 'Agi', 'Int', 514, 515),
		(14, 'Healing', '', 12, 1, 'Int', 'Str', 516, 517),
		(15, 'Alchemy', '', 14, 1, 'Int', 'Agi', 518, 519),
		(16, 'Terraforming', '', 1, 1, 'Con', 'Str', 520, 521),
		(17, 'Construction materials preparation', '', 1, 1, 'Will', 'Agi', 522, 523),
		(18, 'Construction', '', 1, 1, 'Will', 'Agi', 524, 525),
		(19, 'Masonry', '', 18, 1, 'Con', 'Str', 526, 527),
		(20, 'Architecture', '', 19, 1, 'Will', 'Int', 528, 529),
		(21, 'Farming', '', 11, 1, 'Agi', 'Will', 530, 531),
		(22, 'Animal lore', '', 51, 1, 'Int', 'Will', 532, 533),
		(23, 'Procuration', '', 22, 1, 'Str', 'Agi', 534, 535),
		(24, 'Cooking', '', 32, 1, 'Agi', 'Con', 536, 537),
		(25, 'Outfit craft', '', 23, 1, 'Agi', 'Int', 538, 539),
		(26, 'War horse handling', '', 23, 2, 'Int', 'Will', 540, 541),
		(27, 'Chainmail armors', ' ', NULL, 2, 'Will', 'Con', 542, 543),
		(28, 'Mounted fighting mastery', ' ', 39, 2, 'Agi', 'Int', 544, 545),
		(29, 'Lancing', ' ', 28, 2, 'Int', 'Agi', 546, 547),
		(30, 'Heavy horse handling', ' ', 28, 2, 'Int', 'Str', 548, 549),
		(31, 'Precious Prospecting', ' ', 2, 2, 'Will', 'Agi', 550, 551),
		(32, 'Advanced Farming', ' ', 21, 2, 'Will', 'Con', 552, 553),
		(33, 'Spear mastery', ' ', 39, 2, 'Agi', 'Str', 554, 555),
		(34, 'Warrior', ' ', NULL, 2, 'Will', 'Int', 556, 557),
		(35, 'Poleaxes mastery', ' ', 33, 2, 'Con', 'Str', 558, 559),
		(36, 'Blades mastery', ' ', 39, 2, 'Str', 'Int', 560, 561),
		(37, 'Scale armors', ' ', NULL, 2, 'Con', 'Str', 562, 563),
		(38, 'Shield mastery', ' ', 36, 2, 'Int', 'Agi', 564, 565),
		(39, 'Chivalry', ' ', NULL, 2, 'Str', 'Con', 566, 567),
		(40, 'Piercing mastery', ' ', 36, 2, 'Str', 'Agi', 568, 569),
		(41, '2H blades mastery', ' ', 43, 2, 'Con', 'Will', 570, 571),
		(42, 'Plate armors', ' ', NULL, 2, 'Str', 'Con', 572, 573),
		(43, '2H axes mastery', ' ', 34, 2, 'Con', 'Will', 574, 575),
		(44, '2H blunt mastery', ' ', 43, 2, 'Con', 'Str', 576, 577),
		(45, 'War cries', ' ', 44, 2, 'Will', 'Int', 578, 579),
		(48, 'Crossbows mastery', ' ', 34, 2, 'Str', 'Agi', 584, 585),
		(49, 'Bows mastery', ' ', 48, 2, 'Agi', 'Int', 586, 587),
		(50, 'Combat preparation ', ' ', 48, 2, 'Int', 'Will', 588, 589),
		(51, 'Fishing/hunting', '', NULL, 1, 'Str', 'Agi', 590, 591),
		(52, 'Jewelry', '', 2, 1, 'Agi', 'Con', 592, 593),
		(53, 'Arts', '', NULL, 1, 'Con', 'Will', 594, 595),
		(54, 'Piety', '', NULL, 1, 'Will', 'Int', 596, 597),
		(55, 'Mentoring', '', NULL, 1, 'Int', 'Str', 598, 599),
		(56, 'Unit and formation', '', 35, 2, 'Will', 'Str', 600, 601),
		(57, 'Equipment maintain', '', NULL, 2, 'Con', 'Will', 602, 603),
		(58, 'First Aid', '', NULL, 2, 'Int', 'Agi', 604, 605),
		(59, 'Demolition', '', 34, 2, 'Str', 'Con', 606, 607),
		(60, 'Drill', '', NULL, 2, 'Agi', 'Int', 608, 609),
		(61, 'Movement', '', NULL, 3, 'Str', 'Will', 610, 611),
		(62, 'General actions', '', NULL, 3, 'Con', 'Str', 612, 613),
		(63, 'Horseback riding', '', NULL, 3, 'Agi', 'Int', 614, 615),
		(64, 'Swimming', '', NULL, 3, 'Will', 'Agi', 616, 617),
		(65, 'Authority', '', NULL, 3, 'Int', 'Con', 618, 619);

	DROP TABLE IF EXISTS `skills_new`;
	CREATE TABLE `skills_new` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`CharacterID` INT UNSIGNED NOT NULL,
		`SkillTypeID` INT UNSIGNED NOT NULL,
		`SkillAmount` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '7 digits after point',
		`LockStatus` TINYINT NOT NULL DEFAULT 0 COMMENT 'up 1 lock 0 down -1',
		PRIMARY KEY (`ID`),
		UNIQUE INDEX `UNQ_skills_CharacterID_SkillTypeID` (`CharacterID`, `SkillTypeID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


	start transaction;

	-- insert all base skills at first (copy old values)
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select c.ID, stn.ID, ifnull((select max(s.SkillAmount) from skills s where s.CharacterID = c.ID and s.SkillTypeID = stn.ID), 0) as newSkillAmount, 1 as newLockStatus
			from skill_type_new stn
			cross join `character` c
			where stn.Parent is null
			order by c.ID;

	-- empty old base skills values
	update skills
		set SkillAmount = 0
		where SkillTypeID in (select ID from skill_type_new stn where stn.Parent is null);

	-- allocate 1st tier skills for base skills which have value >= 30
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select sn.CharacterID, stn.ID, 0 as newSkillAmount, 1 as newLockStatus
		from skill_type_new stn
		join skills_new sn on sn.SkillTypeID = stn.Parent
		where sn.SkillAmount >= 30*10000000
			and stn.Parent in (select ID from skill_type_new stn where stn.Parent is null);

	-- transfer specific skills (from -> to)
	call _transferSkill(2, 17);
	call _transferSkill(7, 1);
	call _transferSkill(6,  11);
	call _transferSkill(13, 21);
	call _transferSkill(16, 1);
	call _transferSkill(21, 51);
	call _transferSkill(24, 26);
	call _transferSkill(26, 39);
	call _transferSkill(31, 39);
	call _transferSkill(32, 39);
	call _transferSkill(41, 34);
	call _transferSkill(46, 34);
	call _transferSkill(47, 34);
	call _transferSkill(52, 1);
	call _transferSkill(56, 39);

	-- transfer rest skills

	-- allocate rest skill with 0 values
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select s.CharacterID, s.SkillTypeID as SkillTypeID, 0 as newSkillAmount, 1 as newLockStatus
			from skills s
			where s.SkillAmount > 0
				and s.SkillTypeID not in (select SkillTypeID from skills_new sn where sn.CharacterID = s.CharacterID);

	-- transfer rest skill values
	update skills_new sn
		join skills s on sn.CharacterID = s.CharacterID and sn.SkillTypeID = s.SkillTypeID
		set sn.SkillAmount = (sn.SkillAmount + s.SkillAmount)
		where s.SkillAmount > 0;

	-- empty old skill values
	update skills
		set SkillAmount = 0
		where SkillAmount > 0;

	-- allocate child skills, if our skill has value >= 30
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select sn.CharacterID, stn.ID, 0 as newSkillAmount, 1 as newLockStatus
		from skill_type_new stn
		join skills_new sn on sn.SkillTypeID = stn.Parent
		where sn.SkillAmount >= 30*10000000
			and !exists(select * from skills_new sn2 where sn2.CharacterID = sn.CharacterID and sn2.SkillTypeID = stn.ID);

	-- distribute skills with value > 100 to first child skill with value < 100
	-- (we can't use ORDER BY and LIMIT in multiple-table update. Also, we can't use LIMIT in subqueries due to MariaDB compatibility reasons)
	update skills_new sn
		join skill_type_new stn on stn.ID = sn.SkillTypeID
		join (select SkillTypeID, CharacterID, SkillAmount from skills_new) as sn_base
			on sn_base.SkillTypeID = stn.Parent and sn_base.CharacterID = sn.CharacterID
		set sn.SkillAmount = (sn.SkillAmount + (sn_base.SkillAmount - 100*10000000))
		where sn_base.SkillAmount > 100*10000000
			and stn.ID in
			(
				select min(stn2.ID)
				from skill_type_new stn2
				join (select SkillTypeID, CharacterID, SkillAmount from skills_new where SkillAmount < 100*10000000) as sn2
					on sn2.SkillTypeID = stn2.ID
				where stn2.Parent = sn_base.SkillTypeID
					and sn2.CharacterID = sn.CharacterID
			);


	-- after all skills transfer check connectivity between parent/child skills for 36 and 59.

	-- allocate parents at first
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select sn.CharacterID, stn.Parent, 0 as newSkillAmount, 1 as newLockStatus
		from skill_type_new stn
		join skills_new sn on sn.SkillTypeID = stn.ID
		where sn.SkillTypeID in (36, 59)
			and !exists(select * from skills_new sn2 where sn2.CharacterID = sn.CharacterID and sn2.SkillTypeID = stn.Parent);

	-- set parent skill for 36 and 39 skills to value 30 if needed
	update skills_new sn
		join skill_type_new stn on stn.Parent = sn.SkillTypeID
		join (select 36 as ID union select 59) as child_skills
			on child_skills.ID = stn.ID
		set SkillAmount = 30*10000000
		where sn.SkillAmount < 30*10000000;


	-- at the end, cap all skill values at 100 (if any)
	update skills_new
		set SkillAmount = 100*10000000
		where SkillAmount > 100*10000000;

	-- make sure we haven't redundant skills
	delete from skills_new where SkillTypeID in (46, 47);

	commit;

	-- swap tables
	RENAME TABLE skills to skills_old, skills_new to skills,
		skill_type to skill_type_old, skill_type_new to skill_type;

	ALTER TABLE recipe
		DROP FOREIGN KEY `FK_recipe_skill_type`;

	DROP TABLE skills_old, skill_type_old;
	TRUNCATE TABLE skill_raise_logs;

	-- setup constraints
	ALTER TABLE skill_type
		ADD INDEX `FK_skill_type_skill_type` (`Parent`),
		ADD CONSTRAINT `FK_skill_type_skill_type` FOREIGN KEY (`Parent`) REFERENCES `skill_type` (`ID`);

	ALTER TABLE skills
		ADD INDEX `FK_skills_skill_type` (`SkillTypeID`),
		ADD CONSTRAINT `FK_skills_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`),
		ADD CONSTRAINT `FK_skills_skill_type` FOREIGN KEY (`SkillTypeID`) REFERENCES `skill_type` (`ID`);

	ALTER TABLE recipe
		ADD CONSTRAINT `FK_recipe_skill_type` FOREIGN KEY (`SkillTypeID`) REFERENCES `skill_type` (`ID`);
end if; -- end of update skill tree

-- fix for new skill tree: allocate child skills for 34 and 39 base skills, if its value >= 30 (special case for 36 and 59 skills processing above may broke common skill transfer logic in some cases)
insert into skills (CharacterID, SkillTypeID, SkillAmount, LockStatus)
	select s.CharacterID, st.ID, 0 as newSkillAmount, 1 as newLockStatus
	from skill_type st
	join skills s on s.SkillTypeID = st.Parent
	where st.Parent in (34, 39) -- (select st2.Parent from skill_type st2 where st2.ID in (36, 59))
		and s.SkillAmount >= 30*10000000
		and !exists(select * from skills s2 where s2.CharacterID = s.CharacterID and s2.SkillTypeID = st.ID);


-- deleting of skill 60 - Drill:
DELETE from `skills` WHERE SkillTypeID=60;


if(!sf_isColumnExists('stables_data', 'HarvestQuality')) then
	ALTER TABLE `stables_data`
		ADD COLUMN `HarvestQuality` FLOAT NOT NULL DEFAULT '0' AFTER `HarvestAmount`;

	-- calc avg HarvestQuality value
	update stables_data s
	join
	(
		select t.ID, least(greatest((case when t.harvestQuality = 0 then 10 else t.harvestQuality end), 0), 100) as harvestQuality
		from
		(
			select s.ID, s.HarvestAmount, s.DungQuality, ifnull((select avg(Quality) from items where ContainerID = c.ID and ObjectTypeID in (1046, 1050, 1051, 1052)), ifnull(s.DungQuality, 0)) as harvestQuality
			from stables_data s
			join unmovable_objects u on u.ID = s.UnmovableObjectID
			join containers c on c.ID = u.RootContainerID
		) as t
	) as q
	set s.HarvestQuality = q.harvestQuality
	where s.ID = q.ID;
end if;

-- fix MaxStackSize column comment
ALTER TABLE `objects_types`
	CHANGE COLUMN `MaxStackSize` `MaxStackSize` INT UNSIGNED NULL DEFAULT NULL COMMENT 'For unmovable objects stores max amount of bind slots for players' AFTER `Length`;


-- convert centimeters offsets to millimeters
if(sf_isColumnExists('movable_objects', 'OffsetX')) then
 ALTER TABLE `movable_objects`
  ADD COLUMN `OffsetMmX` SMALLINT NULL COMMENT 'ingame millimeters',
  ADD COLUMN `OffsetMmY` SMALLINT NULL COMMENT 'ingame millimeters',
  ADD COLUMN `OffsetMmZ` INT NULL COMMENT 'ingame millimeters';

 update movable_objects set
  OffsetMmX = OffsetX * 10,
  OffsetMmY = OffsetY * 10,
  OffsetMmZ = OffsetZ * 10;

 -- mark new columns as not-nullable
 ALTER TABLE `movable_objects`
  CHANGE COLUMN `OffsetMmX` `OffsetMmX` SMALLINT NOT NULL COMMENT 'ingame millimeters',
  CHANGE COLUMN `OffsetMmY` `OffsetMmY` SMALLINT NOT NULL COMMENT 'ingame millimeters',
  CHANGE COLUMN `OffsetMmZ` `OffsetMmZ` INT NOT NULL COMMENT 'ingame millimeters';

 ALTER TABLE `movable_objects`
  DROP COLUMN OffsetX,
  DROP COLUMN OffsetY,
  DROP COLUMN OffsetZ;

 -- convert horses offsets as well
 update horses set
  OffsetX = OffsetX * 10,
  OffsetY = OffsetY * 10,
  OffsetZ = OffsetZ * 10;

  -- convert patch offsets as well
 update objects_patch set
  OffsetX = OffsetX * 10,
  OffsetY = OffsetY * 10,
  OffsetZ = OffsetZ * 10;

end if;

CREATE TABLE IF NOT EXISTS `working_containers` (
	`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`MovableObjectID` INT UNSIGNED NULL,
	`UnmovableObjectID` INT UNSIGNED NULL,
	`FinishTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`ResultItemID` INT UNSIGNED NULL DEFAULT NULL,
	`InputSkillValue` FLOAT NULL DEFAULT NULL,
	PRIMARY KEY (`ID`),
	UNIQUE INDEX `UNQ_MovableObjectID` (`MovableObjectID`),
	UNIQUE INDEX `UNQ_UnmovableObjectID` (`UnmovableObjectID`),
	CONSTRAINT `FK_working_containers_movable_objects` FOREIGN KEY (`MovableObjectID`) REFERENCES `movable_objects` (`ID`),
	CONSTRAINT `FK_working_containers_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`),
	CONSTRAINT `FK_working_containers_objects_types` FOREIGN KEY (`ResultItemID`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

if(!sf_isColumnExists('guild_actions_queue', 'UnmovableObjectID')) then
	ALTER TABLE `guild_actions_queue`
		ADD COLUMN `UnmovableObjectID` INT UNSIGNED NULL DEFAULT NULL AFTER `StandingTypeID`,
		ADD COLUMN `ClaimID` INT UNSIGNED NULL DEFAULT NULL AFTER `UnmovableObjectID`,
		ADD COLUMN `CanEnter` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `ClaimID`,
		ADD COLUMN `CanBuild` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `CanEnter`,
		ADD COLUMN `CanClaim` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `CanBuild`,
		ADD COLUMN `CanUse` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `CanClaim`,
		ADD COLUMN `CanDestroy` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `CanUse`,
		ADD INDEX `FK_guild_actions_queue_unmovable_objects` (`UnmovableObjectID`),
		ADD INDEX `FK_guild_actions_queue_claims` (`ClaimID`),
		ADD CONSTRAINT `FK_guild_actions_queue_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`),
		ADD CONSTRAINT `FK_guild_actions_queue_claims` FOREIGN KEY (`ClaimID`) REFERENCES `claims` (`ID`);
		
	ALTER TABLE `guild_actions_processed`
		ADD COLUMN `UnmovableObjectID` INT UNSIGNED NULL DEFAULT NULL AFTER `StandingTypeID`,
		ADD COLUMN `ClaimID` INT UNSIGNED NULL DEFAULT NULL AFTER `UnmovableObjectID`,
		ADD COLUMN `CanEnter` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `ClaimID`,
		ADD COLUMN `CanBuild` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `CanEnter`,
		ADD COLUMN `CanClaim` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `CanBuild`,
		ADD COLUMN `CanUse` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `CanClaim`,
		ADD COLUMN `CanDestroy` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `CanUse`;
end if;

if(!sf_isTableExists('guild_invites')) then
	CREATE TABLE IF NOT EXISTS `guild_invites` (
		`ID` int unsigned NOT NULL AUTO_INCREMENT,
		`GuildID` int unsigned NOT NULL,
		`SenderCharID` int unsigned NOT NULL,
		`ReceiverCharID` int unsigned NOT NULL,
		PRIMARY KEY (`ID`),
		KEY `FK_guild_invites_guild` (`GuildID`),
		KEY `FK_guild_invites_sender_char` (`SenderCharID`),
		KEY `FK_guild_invites_receiver_char` (`ReceiverCharID`),
		CONSTRAINT `FK_guild_invites_guild` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`),
		CONSTRAINT `FK_guild_invites_sender_char` FOREIGN KEY (`SenderCharID`) REFERENCES `character` (`ID`),
		CONSTRAINT `FK_guild_invites_receiver_char` FOREIGN KEY (`ReceiverCharID`) REFERENCES `character` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
end if;


-- get rid of old animals
if(sf_isTableExists('animal_breeds_spawn_units')) then
	DROP TABLE animal_breeds_spawn_units;
end if;
if(sf_isTableExists('animal_spawn_patterns')) then
	DROP TABLE animal_spawn_patterns;
end if;
if(sf_isTableExists('animal_breeds')) then
	DROP TABLE animal_breeds;
end if;
if(sf_isTableExists('passability_map_cache_ter_versions')) then
	DROP TABLE passability_map_cache_ter_versions;
end if;
if(sf_isTableExists('passability_map_cache')) then
	DROP TABLE passability_map_cache;
end if;
-- new character state - CraftPerformMove
UPDATE `effects` SET `PlayerEffectID` = 65 WHERE `ID` = 5;

-- expand forest_patch.AddTime to store age info for Add operation. Plus actual tree types list
ALTER TABLE `forest_patch`
	CHANGE COLUMN `AddTime` `AddTime` INT UNSIGNED NULL COMMENT 'Used in Add and GrowAll operations',
	CHANGE COLUMN `TreeType` `TreeType` TINYINT UNSIGNED NULL COMMENT '0=Apple; 1=Birch; 2=Elm; 3=Spruce; 4=Pine; 5=Maple; 6=Mulberry; 7=Oak; 8=Willow;';

-- new table for tracking data changes
if (!sf_isTableExists('_data_version')) then
	CREATE TABLE `_data_version` (
		`TableName` VARCHAR(128) NOT NULL,
		`Value` INT UNSIGNED NOT NULL,
		PRIMARY KEY (`TableName`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
end if;

-- populate guild action list
ALTER TABLE guild_actions_queue
	CHANGE COLUMN `ActionType` `ActionType` ENUM(
		'guild_create',
		'guild_destroy',
		'player_invite_to_guild',
		'player_invite_cancelled',
		'player_invite_accepted',
		'player_invite_declined',
		'player_left_guild',
		'player_guild_kicked',
		'player_new_guild_role',
		'guild_change_standing',
		'monument_built',
		'monument_destroyed',
		'set_claim_char_rule',
		'set_claim_role_rule',
		'set_claim_guild_rule',
		'set_claim_standing_rule',
		'set_unmovable_char_rule',
		'set_unmovable_role_rule',
		'set_unmovable_guild_rule',
		'set_unmovable_standing_rule',
		'remove_unmovable_char_rule',
		'remove_unmovable_role_rule',
		'remove_unmovable_guild_rule',
		'remove_unmovable_standing_rule',
		'set_guild_heraldry',
		'guild_rename',
		'remove_claim_char_rule',
		'remove_claim_role_rule',
		'remove_claim_guild_rule',
		'remove_claim_standing_rule'
	) NOT NULL;

delete from `guild_actions_processed` where ActionType = 'monument_change_level';
delete from `guild_actions_processed` where ActionType = 'update_claim_objects';
delete from `guild_actions_processed` where ActionType = 'personal_land_created';
delete from `guild_actions_processed` where ActionType = 'personal_land_removed';
delete from `guild_actions_processed` where ActionType = 'admin_land_created';
delete from `guild_actions_processed` where ActionType = 'admin_land_removed';

ALTER TABLE guild_actions_processed
	CHANGE COLUMN `ActionType` `ActionType` ENUM(
		'guild_create',
		'guild_destroy',
		'player_invite_to_guild',
		'player_invite_cancelled',
		'player_invite_accepted',
		'player_invite_declined',
		'player_left_guild',
		'player_guild_kicked',
		'player_new_guild_role',
		'guild_change_standing',
		'monument_built',
		'monument_destroyed',
		'set_claim_char_rule',
		'set_claim_role_rule',
		'set_claim_guild_rule',
		'set_claim_standing_rule',
		'set_unmovable_char_rule',
		'set_unmovable_role_rule',
		'set_unmovable_guild_rule',
		'set_unmovable_standing_rule',
		'remove_unmovable_char_rule',
		'remove_unmovable_role_rule',
		'remove_unmovable_guild_rule',
		'remove_unmovable_standing_rule',
		'set_guild_heraldry',
		'guild_rename',
		'remove_claim_char_rule',
		'remove_claim_role_rule',
		'remove_claim_guild_rule',
		'remove_claim_standing_rule'
	) NOT NULL;

-- move SupportPoints from claims to lands
if(sf_isColumnExists('claims', 'SupportPoints')) then
	alter table guild_lands
		add column `SupportPoints` INT NULL;
	alter table personal_lands
		add column `SupportPoints` INT NULL;
	
	-- skip data moving in MMO - consider no real data yet

	alter table claims
		drop column SupportPoints;
end if;

-- add support for heraldry guild actions
if(!sf_isColumnExists('guild_actions_processed', 'HeraldryID')) then
	alter table guild_actions_queue
		add column `HeraldryID` INT UNSIGNED NULL AFTER `ClaimID`,
		add index `FK_guild_actions_queue_heraldries` (`HeraldryID`),
		add constraint `FK_guild_actions_queue_heraldries` FOREIGN KEY (`HeraldryID`) REFERENCES `heraldries` (`ID`);
		
	alter table guild_actions_processed
		add column `HeraldryID` INT UNSIGNED NULL AFTER `ClaimID`;
end if;

-- drop guild_types.GuildLevel as not used
if(sf_isColumnExists('guild_types', 'GuildLevel')) then
	ALTER TABLE `guild_types`
		DROP COLUMN `GuildLevel`;
end if;


-- tree age conversion
if (ifnull((select Value from _data_version where TableName = 'forest'), 0) = 0) then
	insert into tmp_new_tree_ages
	(TreeType, YoungAge, MatureAge)
	values
	(0,  210, 315),
	(1,  210, 315),
	(2,  210, 315),
	(3,  210, 315),
	(4,  210, 315),
	(5,  210, 315),
	(6,  210, 315),
	(7,  210, 315),
	(8,  210, 315),
	(9,  210, 315),
	(10, 210, 315),
	(11, 210, 315);

	-- First two conversion steps differ from the instructions for
	-- `_p_convertForestToNewAgeSettings`() for historical reasons. Essentially
	-- they are just two parts of that procedure, separated in two separate steps.
	--
	-- `_p_convertForestToNewAgeSettings`() procedure that correctly implements the
	-- conversion was created only after first and second conversion steps were
	-- added to this update script.
	--
	-- Value of 'forest' field in '_data_version' table was incremented to 1 by the
	-- first step. At this stage forest state became incorrect, but the game was
	-- released to public. Second step fixed this, incremented data version to 2.
	-- This state was also released to public.
	--
	-- The fact that there were two different 'data versions' released to the public
	-- means that first two steps may not be converted to a single one that uses
	-- `_p_convertForestToNewAgeSettings`()

	UPDATE `forest` SET `AgeTime` = _countNewTreeAge(TreeType, AgeTime);

	TRUNCATE table tmp_old_tree_ages;
	insert into tmp_old_tree_ages
	(TreeType, YoungAge, MatureAge)
	select TreeType, YoungAge, MatureAge from tmp_new_tree_ages;

	TRUNCATE table tmp_new_tree_ages;

	replace into _data_version set TableName = 'forest', Value = 1;
end if;

if (ifnull((select Value from _data_version where TableName = 'forest'), 0) = 1) then
	call p_compactForestPatches();
	update _data_version set Value = 2 where TableName = 'forest';
end if;

if (ifnull((select Value from _data_version where TableName = 'forest'), 0) = 2) then
	insert into tmp_new_tree_ages
	(TreeType, YoungAge, MatureAge)
	values
	(0,  50,  100),
	(1,  40,  100),
	(2,  80,  160),
	(3,  40,  80),
	(4,  60,  100),
	(5,  60,  95),
	(6,  60,  120),
	(7,  100, 180),
	(8,  60,  120),
	(9,  50,  100),
	(10, 100, 200),
	(11, 110, 220);

	call _p_convertForestToNewAgeSettings();

	update _data_version set Value = 3 where TableName = 'forest';
end if;

if(!sf_isColumnExists('character', 'OffsetMmX')) then
	ALTER TABLE `character`
		ADD COLUMN `OffsetMmX` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT 'in millimeters from the center of GeoID' AFTER `GeoAlt`,
		ADD COLUMN `OffsetMmY` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT 'in millimeters from the center of GeoID' AFTER `OffsetMmX`,
		ADD COLUMN `OffsetMmZ` TINYINT(3) NOT NULL DEFAULT '0' COMMENT 'in millimeters from the GeoAlt' AFTER `OffsetMmY`;
end if;

INSERT IGNORE INTO `effects` (`ID`, `Effect_name`) VALUES (20, 'Poison Duration');


-- regions / blueprints
if(!sf_isColumnExists('terrain_blocks', 'RegionID')) then
	CREATE TABLE IF NOT EXISTS `regions` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`NameMessageID` INT UNSIGNED NOT NULL,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	-- fill regions
	INSERT INTO `regions` (`ID`, `NameMessageID`) VALUES
		(12, 2434),
		(13, 2450),
		(14, 2451);

	CREATE TABLE IF NOT EXISTS `blueprints` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`RecipeID` INT UNSIGNED NOT NULL,
		PRIMARY KEY (`ID`),
		KEY `FK_blueprints_recipe` (`RecipeID`),
		CONSTRAINT `FK_blueprints_recipe` FOREIGN KEY (`RecipeID`) REFERENCES `recipe` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `blueprint_requirements` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`BlueprintID` INT UNSIGNED NOT NULL,
		`RecipeRequirementID` INT UNSIGNED NOT NULL,
		`RegionID` INT UNSIGNED NOT NULL,
		PRIMARY KEY (`ID`),
		KEY `FK_blueprint_requirements_blueprints` (`BlueprintID`),
		KEY `FK_blueprint_requirements_recipe_requirement` (`RecipeRequirementID`),
		KEY `FK_blueprint_requirements_regions` (`RegionID`),
		CONSTRAINT `FK_blueprint_requirements_blueprints` FOREIGN KEY (`BlueprintID`) REFERENCES `blueprints` (`ID`),
		CONSTRAINT `FK_blueprint_requirements_recipe_requirement` FOREIGN KEY (`RecipeRequirementID`) REFERENCES `recipe_requirement` (`ID`),
		CONSTRAINT `FK_blueprint_requirements_regions` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `character_blueprints` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`CharID` INT UNSIGNED NOT NULL,
		`BlueprintID` INT UNSIGNED NOT NULL,
		PRIMARY KEY (`ID`),
		KEY `FK_character_blueprints_character` (`CharID`),
		UNIQUE KEY `FK_character_blueprints_blueprints` (`BlueprintID`),
		CONSTRAINT `FK_character_blueprints_character` FOREIGN KEY (`CharID`) REFERENCES `character` (`ID`),
		CONSTRAINT `FK_character_blueprints_blueprints` FOREIGN KEY (`BlueprintID`) REFERENCES `blueprints` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	CREATE TABLE IF NOT EXISTS `recipe_possible_blueprints` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`RecipeID` INT UNSIGNED NOT NULL,
		`BaseRecipeID` INT UNSIGNED NOT NULL,
		PRIMARY KEY (`ID`),
		KEY `FK_recipe_possible_blueprints_recipe` (`RecipeID`),
		KEY `FK_recipe_possible_blueprints_baserecipe` (`BaseRecipeID`),
		CONSTRAINT `FK_recipe_possible_blueprints_recipe` FOREIGN KEY (`RecipeID`) REFERENCES `recipe` (`ID`),
		CONSTRAINT `FK_recipe_possible_blueprints_baserecipe` FOREIGN KEY (`BaseRecipeID`) REFERENCES `recipe` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	ALTER TABLE `recipe`
		ADD COLUMN `IsBlueprint` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'bool' AFTER `Autorepeat`;

	ALTER TABLE `recipe_requirement`
		ADD COLUMN `IsRegionItemRequired` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'bool' AFTER `Quantity`;

	ALTER TABLE `features`
		ADD COLUMN `CreatedRegionID` INT UNSIGNED NULL COMMENT 'Region of item''s origin' AFTER `CustomtextID`,
		ADD COLUMN `BlueprintID` INT UNSIGNED NULL COMMENT 'ID of actual blueprint for blueprint items' AFTER `CreatedRegionID`,
		ADD KEY `FK_features_regions` (`CreatedRegionID`),
		ADD UNIQUE KEY `FK_features_blueprints` (`BlueprintID`),
		ADD CONSTRAINT `FK_features_regions` FOREIGN KEY (`CreatedRegionID`) REFERENCES `regions` (`ID`),
		ADD CONSTRAINT `FK_features_blueprints` FOREIGN KEY (`BlueprintID`) REFERENCES `blueprints` (`ID`);

	ALTER TABLE `terrain_blocks`
		ADD COLUMN `RegionID` INT UNSIGNED NULL AFTER `ID`,
		ADD KEY `FK_terrain_blocks_regions` (`RegionID`),
		ADD CONSTRAINT `FK_terrain_blocks_regions` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`ID`);

	-- assign terrains to regions
	update terrain_blocks set RegionID = 12 where ID in (442, 443, 444, 447, 450);
	update terrain_blocks set RegionID = 13 where ID in (445, 446);
	update terrain_blocks set RegionID = 14 where ID in (448, 449);

	-- make `terrain_blocks.RegionID` not null
	ALTER TABLE `terrain_blocks`
		CHANGE COLUMN `RegionID` `RegionID` INT UNSIGNED NOT NULL AFTER `ID`;
end if;


if(!sf_isColumnExists('features', 'HorseHP')) then
ALTER TABLE `features`
	ADD COLUMN `HorseHP` INT(11) NULL COMMENT '6 digits after point' AFTER `BlueprintID`;
end if;

-- add gender-related guild role messages
if(!sf_isColumnExists('guild_type_role_msgs', 'Gender')) then
	-- insert Band messages
	insert into guild_type_role_msgs set MessageID = 632, GuildTypeID = 1, GuildRoleID = 1;
	insert into guild_type_role_msgs set MessageID = 630, GuildTypeID = 1, GuildRoleID = 2;
	insert into guild_type_role_msgs set MessageID = 628, GuildTypeID = 1, GuildRoleID = 3;
	insert into guild_type_role_msgs set MessageID = 626, GuildTypeID = 1, GuildRoleID = 4;
	insert into guild_type_role_msgs set MessageID = 624, GuildTypeID = 1, GuildRoleID = 5;
	insert into guild_type_role_msgs set MessageID = 622, GuildTypeID = 1, GuildRoleID = 6;
	insert into guild_type_role_msgs set MessageID = 620, GuildTypeID = 1, GuildRoleID = 7;
	
	-- update Order, Country and Kingdom messages
	update guild_type_role_msgs set MessageID = 632 where GuildTypeID = 2 and GuildRoleID = 1;
	update guild_type_role_msgs set MessageID = 630 where GuildTypeID = 2 and GuildRoleID = 2;
	update guild_type_role_msgs set MessageID = 628 where GuildTypeID = 2 and GuildRoleID = 3;
	update guild_type_role_msgs set MessageID = 626 where GuildTypeID = 2 and GuildRoleID = 4;
	update guild_type_role_msgs set MessageID = 624 where GuildTypeID = 2 and GuildRoleID = 5;
	update guild_type_role_msgs set MessageID = 622 where GuildTypeID = 2 and GuildRoleID = 6;
	update guild_type_role_msgs set MessageID = 620 where GuildTypeID = 2 and GuildRoleID = 7;
	update guild_type_role_msgs set MessageID = 646 where GuildTypeID = 3 and GuildRoleID = 1;
	update guild_type_role_msgs set MessageID = 644 where GuildTypeID = 3 and GuildRoleID = 2;
	update guild_type_role_msgs set MessageID = 642 where GuildTypeID = 3 and GuildRoleID = 3;
	update guild_type_role_msgs set MessageID = 640 where GuildTypeID = 3 and GuildRoleID = 4;
	update guild_type_role_msgs set MessageID = 638 where GuildTypeID = 3 and GuildRoleID = 5;
	update guild_type_role_msgs set MessageID = 636 where GuildTypeID = 3 and GuildRoleID = 6;
	update guild_type_role_msgs set MessageID = 634 where GuildTypeID = 3 and GuildRoleID = 7;
	update guild_type_role_msgs set MessageID = 650 where GuildTypeID = 4 and GuildRoleID = 1;
	update guild_type_role_msgs set MessageID = 648 where GuildTypeID = 4 and GuildRoleID = 2;
	update guild_type_role_msgs set MessageID = 642 where GuildTypeID = 4 and GuildRoleID = 3;
	update guild_type_role_msgs set MessageID = 640 where GuildTypeID = 4 and GuildRoleID = 4;
	update guild_type_role_msgs set MessageID = 638 where GuildTypeID = 4 and GuildRoleID = 5;
	update guild_type_role_msgs set MessageID = 636 where GuildTypeID = 4 and GuildRoleID = 6;
	update guild_type_role_msgs set MessageID = 634 where GuildTypeID = 4 and GuildRoleID = 7;

	-- add gender column
	alter table guild_type_role_msgs
		add column `Gender` ENUM('male', 'female') NULL after `GuildRoleID`;
	
	-- mark all existing messages as 'male'
	update guild_type_role_msgs set Gender = 'male';
	
	-- add 'female' messages (which actually has MessageID+1 ID)
	insert into guild_type_role_msgs
		(GuildTypeID, GuildRoleID, Gender, MessageID)
		select GuildTypeID, GuildRoleID, 'female', MessageID + 1
			from guild_type_role_msgs
			order by GuildTypeID, GuildRoleID; 
	
	-- make gender not null
	alter table guild_type_role_msgs
		change column `Gender` `Gender` ENUM('male', 'female') NOT NULL;
end if;

-- Vassal guild type and role messages
if(not exists(select * from guild_types where ID = 5)) then
	insert into guild_types values(5, "Vassal", 2455);
	
	-- role messages correspond to those of Country
	insert into guild_type_role_msgs
		(GuildTypeID, GuildRoleID, Gender, MessageID)
		select 5, GuildRoleID, Gender, MessageID
			from guild_type_role_msgs where GuildTypeID = 3
			order by Gender, GuildRoleID;
end if;


if (!sf_isTableExists('gm_action_log')) then
    CREATE TABLE `gm_action_log` (
        `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
        `AccountID` INT UNSIGNED NOT NULL,
        `Action` VARCHAR(10000) NOT NULL,
        `ActionTimestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`ID`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
end if;


-- update skill tree again
if(exists(select * from skill_type where ID = 27)
	or exists(select * from skills where SkillTypeID = 27)
) then
	-- define new skills
	DROP TABLE IF EXISTS `skill_type_new`;
	CREATE TABLE `skill_type_new` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`Name` VARCHAR(45) NOT NULL COLLATE 'utf8_unicode_ci',
		`Description` VARCHAR(45) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
		`Parent` INT UNSIGNED NULL,
		`Group` TINYINT UNSIGNED NULL,
		`PrimaryStat` CHAR(4) NOT NULL COLLATE 'utf8_unicode_ci',
		`SecondaryStat` CHAR(4) NOT NULL COLLATE 'utf8_unicode_ci',
		`MasterMessageID` INT UNSIGNED NULL DEFAULT '0',
		`GMMessageID` INT UNSIGNED NULL DEFAULT '0',
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	INSERT INTO `skill_type_new` (`ID`, `Name`, `Description`, `Parent`, `Group`, `PrimaryStat`, `SecondaryStat`, `MasterMessageID`, `GMMessageID`) VALUES
		(1,'Artisan','',NULL,1,'Int','Str',594,595),
		(2,'Mining','',16,1,'Str','Con',492,493),
		(3,'Smelting','',17,1,'Agi','Int',494,495),
		(4,'Forging','',3,1,'Str','Con',496,497),
		(5,'Armorsmithing','',3,1,'Str','Agi',498,499),
		(6,'Forestry','',21,1,'Con','Will',500,501),
		(7,'Building Maintain','',19,1,'Str','Con',502,503),
		(8,'Carpentry','',1,1,'Con','Str',504,505),
		(9,'Bowcraft','',8,1,'Con','Will',506,507),
		(10,'Warfare engineering','',9,1,'Will','Int',508,509),
		(11,'Nature\'s lore','',NULL,1,'Int','Will',510,511),
		(12,'Herbalism','',11,1,'Will','Con',514,515),
		(13,'Brewing','',32,1,'Agi','Int',580,581),
		(14,'Healing','',12,1,'Int','Str',516,517),
		(15,'Alchemy','',14,1,'Int','Agi',518,519),
		(16,'Digging','',1,1,'Con','Str',520,521),
		(17,'Materials Preparation','',1,1,'Will','Agi',522,523),
		(18,'Construction','',1,1,'Will','Agi',524,525),
		(19,'Masonry','',18,1,'Con','Str',526,527),
		(20,'Architecture','',19,1,'Will','Int',528,529),
		(21,'Farming','',11,1,'Agi','Will',530,531),
		(22,'Animal lore','',51,1,'Int','Will',532,533),
		(23,'Procuration','',22,1,'Str','Agi',534,535),
		(24,'Cooking','',32,1,'Agi','Con',536,537),
		(25,'Tailoring','',23,1,'Agi','Int',538,539),
		(26,'Warhorse training','',23,2,'Int','Will',582,583),
		(28,'Cavalryman',' ',NULL,2,'Agi','Int',544,545),
		(29,'Knight',' ',28,2,'Int','Agi',546,547),
		(30,'Lancer',' ',29,2,'Int','Str',548,549),
		(31,'Precious Prospecting',' ',2,2,'Will','Agi',490,491),
		(32,'Advanced Farming',' ',21,2,'Will','Con',552,553),
		(33,'Militia',' ',NULL,2,'Agi','Str',554,555),
		(34,'Spearman',' ',33,2,'Will','Int',556,557),
		(35,'Guard',' ',34,2,'Con','Str',558,559),
		(36,'Footman',' ',NULL,2,'Str','Int',560,561),
		(38,'Swordsman',' ',36,2,'Int','Agi',564,565),
		(40,'Huscarl',' ',38,2,'Str','Agi',568,569),
		(43,'Assaulter',' ',NULL,2,'Con','Will',574,575),
		(44,'Vanguard',' ',43,2,'Con','Str',576,577),
		(45,'Berserk',' ',44,2,'Will','Int',578,579),
		(47,'Slinger',' ',NULL,2,'Str','Agi',582,583),
		(48,'Archer',' ',47,2,'Str','Agi',584,585),
		(49,'Ranger',' ',48,2,'Agi','Int',586,587),
		(51,'Hunting','',NULL,1,'Str','Agi',590,591),
		(52,'Jewelry','',2,1,'Agi','Con',592,593),
		(53,'Arts','',NULL,3,'Con','Will',671,672),
		(54,'Piety','',NULL,3,'Will','Int',596,597),
		(55,'Mentoring','',NULL,3,'Int','Str',598,599),
		(56,'Unit and formation','',NULL,2,'Will','Str',600,601),
		(57,'Equipment maintain','',NULL,2,'Con','Will',602,603),
		(58,'Battle Survival','',NULL,2,'Int','Agi',604,605),
		(59,'Demolition','',NULL,2,'Str','Con',606,607),
		(61,'Movement','',NULL,3,'Str','Will',610,611),
		(62,'General actions','',NULL,3,'Con','Str',612,613),
		(63,'Horseback riding','',NULL,3,'Agi','Int',614,615),
		(64,'Swimming','',NULL,3,'Will','Agi',616,617),
		(65,'Authority','',NULL,3,'Int','Con',618,619);

	-- change recipe's skills from Combat preparation (50) to Archer (48)
	update recipe
		set SkillTypeID = 48
		where ID in (655, 656, 657, 837, 847);

	DROP TABLE IF EXISTS `skills_new`;
	CREATE TABLE `skills_new` (
		`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
		`CharacterID` INT UNSIGNED NOT NULL,
		`SkillTypeID` INT UNSIGNED NOT NULL,
		`SkillAmount` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '7 digits after point',
		`LockStatus` TINYINT NOT NULL DEFAULT 0 COMMENT 'up 1 lock 0 down -1',
		PRIMARY KEY (`ID`),
		UNIQUE INDEX `UNQ_skills_CharacterID_SkillTypeID` (`CharacterID`, `SkillTypeID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	start transaction;

	-- insert all base skills at first
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select c.ID, stn.ID, 0 as newSkillAmount, 1 as newLockStatus
			from skill_type_new stn
			cross join `character` c
			where stn.Parent is null
			order by c.ID, stn.ID;

	-- transfer specific skills (order is important).
	call _transferSkillStraight(28, 28);
	call _transferSkillStraight(29, 29);

	call _transferSkillToSkillChainLimit(30, 29, 30); -- 30 -> 29, 30 (30 max)
	call _transferSkillToSkillChainLimit(30, 29, 60); -- 30 -> 29, 30 (60 max)
	call _transferSkillStraight(30, 30); -- 30 -> 30 (rest)

	call _transferSkillStraight(39, 33);
	call _transferSkillStraight(33, 34);
	call _transferSkillStraight(35, 35);
	call _transferSkillStraight(36, 36);
	call _transferSkillStraight(38, 38);

	call _transferSkillToSkillChainLimit(40, 38, 30); -- 40 -> 38, 40 (30 max)
	call _transferSkillToSkillChainLimit(40, 38, 60); -- 40 -> 38, 40 (60 max)
	call _transferSkillStraight(40, 40); -- 40 -> 40 (rest)

	call _transferSkillToSkillChainLimit(27, 28, 60); -- 27 -> 28, 29, 30 (60 max)

	call _transferSkillToSkillChainLimit(37, 36, 60); -- 37 -> 36, 38, 40 (60 max)

	call _transferSkillStraight(43, 43);
	call _transferSkillStraight(44, 44);

	call _transferSkillToSkillChainLimit(41, 44, 30); -- 41 -> 44, 45 (30 max)
	call _transferSkillToSkillChainLimit(41, 44, 60); -- 41 -> 44, 45 (60 max)

	call _transferSkillStraight(45, 45);

	call _transferSkillToSkillChainLimit(42, 43, 60); -- 42 -> 43, 44, 45 (60 max)

	call _transferSkillStraight(34, 47);
	call _transferSkillStraight(48, 48);
	call _transferSkillStraight(49, 49);

	call _transferSkillToSkillChainLimit(50, 47, 60); -- 50 -> 47, 48, 49 (60 max)

	call _transferSkillStraight(56, 56);
	call _transferSkillStraight(57, 57);
	call _transferSkillStraight(58, 58);
	call _transferSkillStraight(59, 59);

	-- transfer rest skills

	-- allocate rest skill with 0 values
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select s.CharacterID, s.SkillTypeID as SkillTypeID, 0 as newSkillAmount, 1 as newLockStatus
			from skills s
			where s.SkillAmount > 0
				and s.SkillTypeID in (select ID from skill_type_new)
				and s.SkillTypeID not in (select SkillTypeID from skills_new sn where sn.CharacterID = s.CharacterID);

	-- transfer rest skill values
	update skills_new sn
		join skills s on sn.CharacterID = s.CharacterID and sn.SkillTypeID = s.SkillTypeID
		set sn.SkillAmount = (sn.SkillAmount + s.SkillAmount)
		where s.SkillAmount > 0;

	-- allocate child skills, if our skill has value >= 30
	insert into skills_new (CharacterID, SkillTypeID, SkillAmount, LockStatus)
		select sn.CharacterID, stn.ID, 0 as newSkillAmount, 1 as newLockStatus
		from skill_type_new stn
		join skills_new sn on sn.SkillTypeID = stn.Parent
		where sn.SkillAmount >= 30*10000000
			and !exists(select * from skills_new sn2 where sn2.CharacterID = sn.CharacterID and sn2.SkillTypeID = stn.ID);

	-- at the end, cap all skill values at 100 (if any)
	update skills_new
		set SkillAmount = 100*10000000
		where SkillAmount > 100*10000000;

	-- make sure we haven't redundant skills
	delete from skills_new where SkillTypeID not in (
		select ID from skill_type_new
	);

	commit;

	-- swap tables
	RENAME TABLE skills to skills_old, skills_new to skills,
		skill_type to skill_type_old, skill_type_new to skill_type;

	ALTER TABLE recipe
		DROP FOREIGN KEY `FK_recipe_skill_type`;

	DROP TABLE skills_old, skill_type_old;
	TRUNCATE TABLE skill_raise_logs;

	-- setup constraints
	ALTER TABLE skill_type
		ADD INDEX `FK_skill_type_skill_type` (`Parent`),
		ADD CONSTRAINT `FK_skill_type_skill_type` FOREIGN KEY (`Parent`) REFERENCES `skill_type` (`ID`);

	ALTER TABLE skills
		ADD INDEX `FK_skills_skill_type` (`SkillTypeID`),
		ADD CONSTRAINT `FK_skills_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`),
		ADD CONSTRAINT `FK_skills_skill_type` FOREIGN KEY (`SkillTypeID`) REFERENCES `skill_type` (`ID`);

	ALTER TABLE recipe
		ADD CONSTRAINT `FK_recipe_skill_type` FOREIGN KEY (`SkillTypeID`) REFERENCES `skill_type` (`ID`);
end if;


if(sf_isColumnExists('unmovable_objects', 'Slope')) then
	ALTER TABLE `unmovable_objects`
		DROP COLUMN `Slope`;
end if;


if(sf_isColumnExists('objects_patch', 'Slope')) then
	ALTER TABLE `objects_patch`
		DROP COLUMN `Slope`;
end if;

CREATE TABLE IF NOT EXISTS `admin_lands` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL,
  `GeoID1` INT UNSIGNED NOT NULL,
  `GeoID2` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

if(!sf_isColumnExists('claims', 'AdminLandID')) then
	ALTER TABLE `claims` 
		ADD COLUMN `AdminLandID`INT UNSIGNED NULL,
		ADD UNIQUE INDEX `UNQ_AdminLandID` (`AdminLandID`),
		ADD KEY `FK_claims_admin_lands` (`AdminLandID`),
		ADD CONSTRAINT `FK_claims_admin_lands` FOREIGN KEY (`AdminLandID`) REFERENCES `admin_lands` (`ID`);
end if;

if(!sf_isColumnExists('guild_lands', 'LandType')) then
	ALTER TABLE `guild_lands`
		ADD COLUMN `LandType` int(10) unsigned NOT NULL DEFAULT 1 COMMENT '1=Core, 2=Suburbia';
end if;
if(!sf_isColumnExists('movable_objects', 'CarrierHorseID')) then
	ALTER TABLE `movable_objects`
		ADD COLUMN `CarrierHorseID` INT UNSIGNED NULL AFTER `CarrierCharacterID`,
		ADD UNIQUE KEY `FK_carrier_horse_to_horses` (`CarrierHorseID`),
		ADD CONSTRAINT `FK_carrier_horse_to_horses` FOREIGN KEY (`CarrierHorseID`) REFERENCES `horses` (`ID`);
end if;

if(!sf_isColumnExists('movable_objects', 'CarrierMovableID')) then
	ALTER TABLE `movable_objects`
		ADD COLUMN `CarrierMovableID` INT UNSIGNED NULL AFTER `CarrierHorseID`,
		ADD KEY `FK_carrier_movable_to_movables` (`CarrierMovableID`),
		ADD CONSTRAINT `FK_carrier_movable_to_movables` FOREIGN KEY (`CarrierMovableID`) REFERENCES `movable_objects` (`ID`);
end if;

if(!sf_isColumnExists('forest', 'TreePlantMethod')) then
	ALTER TABLE `forest`
		ADD COLUMN `TreePlantMethod` TINYINT UNSIGNED NOT NULL DEFAULT 0 AFTER `TreeType`;
	ALTER TABLE `forest`
		CHANGE COLUMN `TreePlantMethod` `TreePlantMethod` TINYINT UNSIGNED NOT NULL;

	ALTER TABLE `forest_patch`
		ADD COLUMN `TreePlantMethod` TINYINT UNSIGNED NULL AFTER `TreeHealth`;

	UPDATE `forest_patch` SET `TreePlantMethod` = 0 WHERE `Action` = 1;
end if;


-- ID ranges for characters
if(!sf_isTableExists('character_server_id_ranges')) then
	-- remove auto_increment from table (assume that PK named ID and it is UINT)
	SET FOREIGN_KEY_CHECKS=0;
	ALTER TABLE `character`
		ALTER `ID` DROP DEFAULT;
	ALTER TABLE `character`
		CHANGE COLUMN ID ID INT UNSIGNED NOT NULL FIRST;
	SET FOREIGN_KEY_CHECKS=1;

	-- should be accessed only using p_issueIdRange_character
	CREATE TABLE `character_server_id_ranges` (
		`ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`ServerID` int(10) unsigned NOT NULL,
		`RangeStartID` int(10) unsigned NOT NULL,
		`RangeEndID` int(10) unsigned NOT NULL,
		PRIMARY KEY (`ID`),
		-- KEY `IDX_RangeStartID` (`RangeStartID`), -- for order
		KEY `IDX_RangeEndID` (`RangeEndID`), -- for max() operation
		KEY `IDX_ServerID` (`ServerID`)
		-- KEY `FK_character_server_id_ranges_servers` (`ServerID`),
		-- CONSTRAINT `FK_character_server_id_ranges_servers` FOREIGN KEY (`ServerID`) REFERENCES `servers` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='character ID ranges assigned to servers. Should be accessed only by using p_issueIdRange_character';

	-- dummy table for locking from p_issueIdRange_character, using like a mutex
	CREATE TABLE `character_server_id_ranges_lock` (
		`ID` tinyint unsigned NOT NULL,
		`IsLocked` tinyint unsigned NOT NULL,
		PRIMARY KEY (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Dummy table for locking from p_issueIdRange_character. Do not store actual data, using only for internal needs';
end if;

-- use original char ID even for deleted chars
if(sf_isColumnExists('deleted_character_info', 'ExCharID')) then
	-- restore usual ID using in guild action logs
	ALTER TABLE guild_actions_processed
		DROP FOREIGN KEY `FK_guild_actions_processed_character1`;
	
	update guild_actions_processed
		set ProducerCharID = (select ExCharID from deleted_character_info where ID = ProducerCharDeletedID), ProducerCharDeletedID = NULL
		where ProducerCharDeletedID is not NULL;
		
	update guild_actions_processed
		set CharID = (select ExCharID from deleted_character_info where ID = CharDeletedID), CharDeletedID = NULL
		where CharDeletedID is not NULL;

	ALTER TABLE guild_actions_processed
		DROP COLUMN ProducerCharDeletedID,
		DROP COLUMN CharDeletedID;
		
	-- remove auto_increment from deleted_character_info table
	ALTER TABLE `deleted_character_info`
		ALTER `ID` DROP DEFAULT;
	ALTER TABLE `deleted_character_info`
		CHANGE COLUMN ID ID INT UNSIGNED NOT NULL FIRST;

	-- prevent ID collisions from duplicates between `character` and `deleted_character_info` tables
	delete from deleted_character_info where ExCharID in (select ID from `character`);

	-- remove duplicated ExCharID, keep newer ones (yes, we lose some records)
	delete d1 from deleted_character_info d1
	join deleted_character_info d2
	where d2.ID > d1.ID and d2.ExCharID = d1.ExCharID;
	
	-- swap ExCharID and ID columns (temporarily increase ID, so we don't get collisions on next update)
	set @delCharInfoMaxId = (select greatest(max(ID), max(ExCharID)) from deleted_character_info);
	update `deleted_character_info` set ID = (@delCharInfoMaxId + ID);
	update `deleted_character_info` set ID = ExCharID;
	
	-- delete ExCharID
	ALTER TABLE `deleted_character_info`
		DROP COLUMN `ExCharID`;
end if;

-- track account id & original creation date of deleted characters
if (!sf_isColumnExists('deleted_character_info', 'AccountID')) then
	ALTER TABLE `deleted_character_info`
		ADD COLUMN `AccountID` INT UNSIGNED NULL AFTER `ID`,
		ADD COLUMN `CreateTimestamp` TIMESTAMP NULL AFTER `DeletedTimestamp`;
end if;

if(!sf_isColumnExists('equipment_slots', 'SkinID')) then
	ALTER TABLE `equipment_slots`
		ADD COLUMN `SkinID` INT DEFAULT NULL AFTER `ItemID`;
end if;

if (sf_isColumnExists('chars_deathlog', 'Time') and !sf_isColumnTypeMatch('chars_deathlog', 'Time', 'timestamp')) then
	ALTER TABLE `chars_deathlog`
		CHANGE COLUMN `Time` `UnixTime` INT(10) UNSIGNED NOT NULL;
	ALTER TABLE `chars_deathlog`
		ADD COLUMN `Time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `ID`;

	UPDATE `chars_deathlog`
		SET Time = FROM_UNIXTIME(UnixTime);

	ALTER TABLE `chars_deathlog`
		DROP COLUMN `UnixTime`;
end if;

if (sf_isColumnExists('food_eaten', 'Time') and !sf_isColumnTypeMatch('food_eaten', 'Time', 'timestamp')) then
	ALTER TABLE `food_eaten`
		CHANGE COLUMN `Time` `UnixTime` INT(10) UNSIGNED NOT NULL;
	ALTER TABLE `food_eaten`
		ADD COLUMN `Time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `UnixTime`;

	UPDATE `food_eaten`
		SET Time = FROM_UNIXTIME(UnixTime);

	ALTER TABLE `food_eaten`
		DROP COLUMN `UnixTime`;
end if;

if (sf_isIndexExists('food_eaten', 'FK_food_eaten_character')) then
	ALTER TABLE `food_eaten`
		DROP FOREIGN KEY `FK_food_eaten_character`,
		DROP INDEX `FK_food_eaten_character`;
	ALTER TABLE `food_eaten`
		ADD INDEX `IDX_CharID_Time` (`CharID`, `Time`);
end if;

if (!sf_isIndexExists('chars_deathlog', 'IDX_CharID_Time')) then
	ALTER TABLE `chars_deathlog`
		ADD INDEX `IDX_CharID_Time` (`CharID`, `Time`);
end if;

-- heraldry changed timestamp
if(!sf_isColumnExists('guilds', 'HeraldryChangedTimestamp')) then
	ALTER TABLE guilds
		ADD COLUMN `HeraldryChangedTimestamp` TIMESTAMP NULL DEFAULT NULL AFTER `DeleteTimestamp`;
end if;


if (ifnull((select Value from _data_version where TableName = 'claims'), 0) = 0) then
	-- update guild type
	update guilds set GuildTypeID = 3 where GuildTypeID = 1;

	insert ignore into `guild_standings` (GuildID1, GuildID2, StandingTypeID)
	select g1.ID, g2.ID, 1 from guilds g1
	cross join guilds g2
	where g1.ID <> g2.ID;

	insert ignore into claim_rules (ClaimID, ClaimSubjectID, CanEnter, CanBuild , CanClaim, CanUse, CanDestroy)
		select c.ID, subjectId, CanEnter, CanBuild, CanClaim, CanUse, CanDestroy
		from claims c
		cross join( 
			select f_getSubjectIDByRole(1/*Leader*/) as subjectId,       1 as CanEnter, 1 as CanBuild , 1 as CanClaim, 1 as CanUse, 1 as CanDestroy
			union all select f_getSubjectIDByRole(2/*Minor leader*/),    1,1,1,1,1
			union all select f_getSubjectIDByRole(3/*1st tier member*/), 1,1,1,1,1
			union all select f_getSubjectIDByRole(4/*2nd tier member*/), 1,1,1,1,1
			union all select f_getSubjectIDByRole(5/*3rd tier member*/), 1,1,1,1,1
			union all select f_getSubjectIDByRole(6/*Normal member*/),   1,1,1,1,1
			union all select f_getSubjectIDByRole(7/*Recruit*/),         1,1,1,1,0
			union all select f_getSubjectIDByStanding(5/*Ally*/),        1,0,0,0,0
		) as t;

	replace into _data_version set TableName = 'claims', Value = 1;
end if;

-- transform index on FeatureID into unique index
if(!sf_isIndexExists('items', 'UNQ_FeatureID')) then
	ALTER TABLE items
		ADD UNIQUE INDEX `UNQ_FeatureID` (`FeatureID`),
		DROP INDEX `FK_ItemsFeaturesID`;
end if;

-- split ammo stucks
if (ifnull((select Value from _data_version where TableName = 'items'), 0) < 2) then
	if(exists(select * from objects_types where ID = 608 )) then 
		update objects_types set MaxStackSize = 5 where ID = 608;
		CALL p_splitItemStacksByMaxSize(608); /* Throwing Knife  */ 
	end if;
	if(exists(select * from objects_types where ID = 609 )) then 
		update objects_types set MaxStackSize = 5 where ID = 609;
		CALL p_splitItemStacksByMaxSize(609); /* Javelin */ 
	end if;
	if(exists(select * from objects_types where ID = 610 )) then 
		update objects_types set MaxStackSize = 3 where ID = 610;
		CALL p_splitItemStacksByMaxSize(610); /* Throwing Axe */ 
	end if;
	if(exists(select * from objects_types where ID = 656 )) then 
		update objects_types set MaxStackSize = 31 where ID = 656;
		CALL p_splitItemStacksByMaxSize(656); /* Bodkin Arrow */ 
	end if;
	if(exists(select * from objects_types where ID = 657 )) then 
		update objects_types set MaxStackSize = 31 where ID = 657;
		CALL p_splitItemStacksByMaxSize(657); /* Broadhead Arrow */ 
	end if;
	if(exists(select * from objects_types where ID = 658 )) then 
		update objects_types set MaxStackSize = 31 where ID = 658;
		CALL p_splitItemStacksByMaxSize(658); /* Fire Arrow */ 
	end if;
	if(exists(select * from objects_types where ID = 659 )) then 
		update objects_types set MaxStackSize = 31 where ID = 659;
		CALL p_splitItemStacksByMaxSize(659); /* Dull Arrow */ 
	end if;
	if(exists(select * from objects_types where ID = 1339 )) then 
		update objects_types set MaxStackSize = 31 where ID = 1339;
		CALL p_splitItemStacksByMaxSize(1339); /* Firework Arrow */ 
	end if;
	if(exists(select * from objects_types where ID = 660 )) then 
		update objects_types set MaxStackSize = 31 where ID = 660;
		CALL p_splitItemStacksByMaxSize(660); /* Arrow */ 
	end if;
	if(exists(select * from objects_types where ID = 662 )) then 
		update objects_types set MaxStackSize = 21 where ID = 662;
		CALL p_splitItemStacksByMaxSize(662); /* Bolt */ 
	end if;
	if(exists(select * from objects_types where ID = 663 )) then 
		update objects_types set MaxStackSize = 21 where ID = 663;
		CALL p_splitItemStacksByMaxSize(663); /* Dull Bolt */ 
	end if;
	if(exists(select * from objects_types where ID = 664 )) then 
		update objects_types set MaxStackSize = 21 where ID = 664;
		CALL p_splitItemStacksByMaxSize(664); /* Heavy Bolt */ 
	end if;
	if(exists(select * from objects_types where ID = 1340 )) then 
		update objects_types set MaxStackSize = 21 where ID = 1340;
		CALL p_splitItemStacksByMaxSize(1340); /* Firework Bolt */ 
	end if;

	replace into _data_version set TableName = 'items', Value = 2;
end if;


if(!sf_isColumnExists('character_effects', 'UpdateTime')) then
	ALTER TABLE `character_effects` ADD COLUMN `UpdateTime` INT(10) UNSIGNED NULL DEFAULT NULL AFTER `DurationLeft`;
end if;

if (!sf_isColumnTypeMatch('character_effects', 'UpdateTime', 'timestamp')) then
	ALTER TABLE `character_effects`
		CHANGE COLUMN `UpdateTime` `UnixTime` INT(10) UNSIGNED NULL DEFAULT NULL;
	ALTER TABLE `character_effects`
		ADD COLUMN `UpdateTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `DurationLeft`;

	UPDATE `character_effects`
		SET UpdateTime = FROM_UNIXTIME(IFNULL(UnixTime, UNIX_TIMESTAMP()));

	ALTER TABLE `character_effects`
		DROP COLUMN `UnixTime`;
end if;

if(!sf_isColumnExists('unmovable_objects', 'CustomNameID')) then
	ALTER TABLE `unmovable_objects`
		ADD COLUMN `CustomNameID` INT(10) UNSIGNED DEFAULT NULL AFTER `OwnerID`,
		ADD INDEX `FK_unmovable_objects_custom_text` (`CustomNameID`),
		ADD CONSTRAINT `FK_unmovable_objects_custom_text` FOREIGN KEY (`CustomNameID`) REFERENCES `custom_texts` (`ID`);
end if;

if(!sf_isColumnExists('movable_objects', 'CustomNameID')) then
	ALTER TABLE `movable_objects`
		ADD COLUMN `CustomNameID` INT(10) UNSIGNED DEFAULT NULL AFTER `OwnerID`,
		ADD INDEX `FK_movable_objects_custom_text` (`CustomNameID`),
		ADD CONSTRAINT `FK_movable_objects_custom_text` FOREIGN KEY (`CustomNameID`) REFERENCES `custom_texts` (`ID`);
end if;

if(!sf_isTableExists('neighbor_regions')) then
	CREATE TABLE IF NOT EXISTS `neighbor_regions` (
		`ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
		`RegionID` INT(10) UNSIGNED NOT NULL,
		`NeighborRegionID` INT(10) UNSIGNED NOT NULL,
		PRIMARY KEY (`ID`),
		CONSTRAINT `FK_neighbor_regions_regions` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`ID`),
		CONSTRAINT `FK_neighbor_regions_regions2` FOREIGN KEY (`NeighborRegionID`) REFERENCES `regions` (`ID`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	INSERT INTO `neighbor_regions` (`ID`, `RegionID`, `NeighborRegionID`) VALUES
	(1,12,13),
	(2,12,14),
	(3,13,12),
	(4,13,14),
	(5,14,12),
	(6,14,13);
end if;


CREATE TABLE IF NOT EXISTS `unmovable_objects_requirements` (
	`ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`UnmovableObjectID` INT(10) UNSIGNED NOT NULL,
	`RecipeRequirementID` INT(10) UNSIGNED NOT NULL,
	`RegionID` INT(10) UNSIGNED NOT NULL,
	PRIMARY KEY (`ID`),
	UNIQUE KEY `UNQ_UnmovableObjectID_RecipeRequirementID` (`UnmovableObjectID`, `RecipeRequirementID`),
	INDEX `FK_unmovable_objects_requirements_regions` (`RegionID`),
	INDEX `FK_unmovable_objects_requirements_recipe_requirements` (`RecipeRequirementID`),
	CONSTRAINT `FK_unmovable_objects_requirements_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`),
	CONSTRAINT `FK_unmovable_objects_requirements_regions` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`ID`),
	CONSTRAINT `FK_unmovable_objects_requirements_recipe_requirements` FOREIGN KEY (`RecipeRequirementID`) REFERENCES `recipe_requirement` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

if (!sf_isColumnExists('recipe', 'ImagePath')) then
    ALTER TABLE `recipe`
        ADD COLUMN `ImagePath` VARCHAR(255) NULL;
end if;

if(sf_isTableExists('titles')) then
	ALTER TABLE `character_titles`
		ADD COLUMN TitleMessageID INT UNSIGNED NULL,
		ADD UNIQUE INDEX `UNQ_CharacterID_TitleMessageID` (`CharacterID`, `TitleMessageID`),
		DROP INDEX FK_character_titles_character;
	
	UPDATE `character_titles`
		SET TitleMessageID = (SELECT TitleMessageID FROM titles WHERE ID = TitleID LIMIT 1);
	
	if(sf_isColumnExists('character_titles', 'TitleID')) then
		ALTER TABLE `character_titles`
			CHANGE COLUMN TitleMessageID TitleMessageID INT UNSIGNED NOT NULL,
			DROP FOREIGN KEY `FK_character_titles_titles`,
			DROP INDEX FK_character_titles_titles,
			DROP COLUMN TitleID; 
	end if;
	
	DROP TABLE `titles`;
end if;

if(!sf_isColumnExists('features', 'HorseStamina')) then
ALTER TABLE `features`
	ADD COLUMN `HorseStamina` INT(11) NULL COMMENT '6 digits after point' AFTER `HorseHP`;
end if;

-- expand index to `version` field
if(sf_isIndexExists('geo_patch', 'FK_geo_patch_terrain_blocks')) then
	ALTER TABLE `geo_patch`
		ADD INDEX `IDX_TerID_Version` (TerID, `Version`),
		DROP INDEX FK_geo_patch_terrain_blocks;
end if;


CREATE TABLE IF NOT EXISTS `outposts` (
	`ID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`UnmovableObjectID` INT(10) UNSIGNED NOT NULL,
	`ProductionObjectTypeID` INT(10) UNSIGNED NULL,
	`SecondaryContainerID` INT(10) UNSIGNED NOT NULL,
	`OwnerGuildID` INT(10) UNSIGNED NULL,
	PRIMARY KEY (`ID`),
	UNIQUE KEY `UNQ_outpost_UnmovableObjectID` (`UnmovableObjectID`),
	KEY `KEY_outpost_ProductionObjectTypeID` (`ProductionObjectTypeID`),
	UNIQUE KEY `UNQ_outpost_SecondaryContainerID` (`SecondaryContainerID`),
	KEY `KEY_outpost_OwnerGuildID` (`OwnerGuildID`),
	CONSTRAINT `FK_outposts_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`),
	CONSTRAINT `FK_outposts_object_types` FOREIGN KEY (`ProductionObjectTypeID`) REFERENCES `objects_types` (`ID`),
	CONSTRAINT `FK_outposts_containers` FOREIGN KEY (`SecondaryContainerID`) REFERENCES `containers` (`ID`),
	CONSTRAINT `FK_outposts_guilds` FOREIGN KEY (`OwnerGuildID`) REFERENCES `guilds` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- sync land types between MMO and YO
if (!exists(select * from _data_version where TableName = 'guild_lands')) then
    update guild_lands
    set LandType = 3;

    alter table guild_lands
    change column `LandType` `LandType` INT UNSIGNED NOT NULL COMMENT '3=Yo, 4=Outpost';

    insert into _data_version
    set TableName = 'guild_lands', `Value` = 1;
end if;

if(!sf_isColumnExists('objects_types', 'AllowExportFromRed')) then
	ALTER TABLE `objects_types`
		ADD COLUMN `AllowExportFromRed` TINYINT UNSIGNED NOT NULL DEFAULT '0'
		COMMENT 'If export of this object type is allowed from red worlds'
		AFTER `OwnerTimeout`;
end if;

if(!sf_isColumnExists('objects_types', 'AllowExportFromGreen')) then
	ALTER TABLE `objects_types`
		ADD COLUMN `AllowExportFromGreen` TINYINT UNSIGNED NOT NULL DEFAULT '0'
		COMMENT 'If export of this object type is allowed from green worlds'
		AFTER `AllowExportFromRed`;
end if;


if(!sf_isColumnExists('admin_lands', 'Priority')) then
ALTER TABLE `admin_lands`
	ADD COLUMN `Priority` INT(11) UNSIGNED NOT NULL DEFAULT 0 AFTER `Name`;
end if;

UPDATE `admin_lands` SET `Name` = 'newbieWholeArea' WHERE `Name` = 'land1';
UPDATE `admin_lands` SET `Name` = 'newbieVillage' WHERE `Name` = 'land2';
UPDATE `admin_lands` SET `Name` = 'newbieQuestCoops' WHERE `Name` = 'land3';
UPDATE `admin_lands` SET `Name` = 'newbieQuestSanctuary' WHERE `Name` = 'land4';
UPDATE `admin_lands` SET `Priority` = 2 WHERE `Name` = 'newbieQuestCoops';

if(!sf_isColumnExists('objects_types', 'IsPremium')) then
ALTER TABLE `objects_types`
	ADD COLUMN `IsPremium` tinyint(1) NOT NULL DEFAULT '0' AFTER `IsDoor`;
end if;

if(!sf_isColumnExists('guilds', 'Derelicted')) then
ALTER TABLE `guilds`
	ADD COLUMN `Derelicted` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'derelicted status' AFTER `GuildTypeID`;
end if;


CREATE TABLE IF NOT EXISTS `quests_progress` (
	`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`CharacterID` INT UNSIGNED NOT NULL,
	`QuestSubjectID` INT UNSIGNED NOT NULL,
	`QuestID` INT UNSIGNED NOT NULL,
	`ConversationID` INT UNSIGNED NOT NULL,
	`NodeID` INT UNSIGNED NOT NULL,
	PRIMARY KEY (`ID`),
	UNIQUE KEY `UNQ_CharSubjQuest` (`CharacterID`,`QuestSubjectID`,`QuestID`),
	CONSTRAINT `FK_quests_progress_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `quests_answers` (
	`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`CharacterID` INT UNSIGNED NOT NULL,
	`QuestID` INT UNSIGNED NOT NULL,
	`AnswerID` INT UNSIGNED NOT NULL,
	`Status` TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (`ID`),
	UNIQUE KEY `UNQ_CharQuestAnswer` (`CharacterID`,`QuestID`,`AnswerID`),
	CONSTRAINT `FK_quests_answers_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `quests_tasks` (
	`ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`CharacterID` INT UNSIGNED NOT NULL,
	`QuestID` INT UNSIGNED NOT NULL,
	`TaskID` INT UNSIGNED NOT NULL,
	`Status` TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (`ID`),
	UNIQUE KEY `UNQ_CharQuestTask` (`CharacterID`,`QuestID`,`TaskID`),
	CONSTRAINT `FK_quests_tasks_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


if(!sf_isColumnExists('character', 'WasInJudgmentHourOnLogout')) then
	ALTER TABLE `character`
		ADD COLUMN `WasInJudgmentHourOnLogout` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 AFTER `DeleteTimestamp`;
end if;



CREATE TABLE IF NOT EXISTS `objects_conversions` (
	`ID` int unsigned NOT NULL AUTO_INCREMENT,
	`ObjectTypeID1` int unsigned NULL DEFAULT NULL,
	`ObjectTypeID2` int unsigned NULL DEFAULT NULL,
	PRIMARY KEY (`ID`),
	UNIQUE KEY `UNQ_objects_conversions_objects_types1` (`ObjectTypeID1`),
	KEY `KEY_objects_conversions_objects_types2` (`ObjectTypeID2`),
	CONSTRAINT `FK_objects_conversions_objects_types1` FOREIGN KEY (`ObjectTypeID1`) REFERENCES `objects_types` (`ID`),
	CONSTRAINT `FK_objects_conversions_objects_types2` FOREIGN KEY (`ObjectTypeID2`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


if(!sf_isColumnExists('movable_objects', 'DroppedItemID')) then
	ALTER TABLE `movable_objects`
		ADD COLUMN `DroppedItemID` INT UNSIGNED NULL AFTER `CarrierHorseID`,
		ADD UNIQUE KEY `UNQ_dropped_item_items` (`DroppedItemID`),
		ADD CONSTRAINT `FK_dropped_item_items` FOREIGN KEY (`DroppedItemID`) REFERENCES `items` (`ID`);
end if;


END; /* end of _updateScript */
/*!40101 SET SQL_MODE=IFNULL(@TEMP_SQL_MODE, '') */;

call _updateScript();
DROP PROCEDURE _updateScript;

drop temporary table `tmp_old_tree_ages`;
drop temporary table `tmp_new_tree_ages`;
DROP FUNCTION IF EXISTS _countNewTreeAgeEquation;
DROP FUNCTION IF EXISTS _countNewTreeAge;
DROP FUNCTION IF EXISTS _p_convertForestToNewAgeSettings;

DROP PROCEDURE _transferSkillToSkillChainLimit;
DROP PROCEDURE _transferSkillStraight;
DROP FUNCTION _getMaxSkillValue;
DROP PROCEDURE _transferSkill;



DROP PROCEDURE IF EXISTS `p_allocate_character_wounds`;
CREATE PROCEDURE `p_allocate_character_wounds`(
	`in_charID` INT UNSIGNED
)
BEGIN

	insert ignore character_wounds (CharacterID, BodyPart, WoundType)
		select in_charID, t.BodyPart, t.WoundType
		from (
			select 0 as BodyPart, 0 as WoundType union all
			select 0, 1 union all
			select 0, 2 union all
			select 0, 3 union all
			select 0, 5 union all
			select 1, 0 union all
			select 1, 1 union all
			select 1, 2 union all
			select 1, 3 union all
			select 1, 5 union all
			select 2, 0 union all
			select 2, 1 union all
			select 2, 2 union all
			select 2, 3 union all
			select 2, 5 union all
			select 3, 0 union all
			select 3, 1 union all
			select 3, 2 union all
			select 3, 3 union all
			select 3, 5 union all
			select 4, 0 union all
			select 4, 1 union all
			select 4, 2 union all
			select 4, 3 union all
			select 4, 5 union all
			select 5, 0 union all
			select 5, 1 union all
			select 5, 2 union all
			select 5, 3 union all
			select 5, 5 union all
			select 6, 0
		) as t;

END;


DROP PROCEDURE IF EXISTS p_completeBuilding;
CREATE PROCEDURE `p_completeBuilding`(
	IN `in_isMovable` TINYINT UNSIGNED,
	IN `in_objectID` INT UNSIGNED,
	IN `in_conteinerID` INT UNSIGNED,
	IN `in_CreatedDurability` SMALLINT UNSIGNED,
	IN `in_Durability` SMALLINT UNSIGNED,
	IN `in_isRecreateContainer` TINYINT UNSIGNED
)
BEGIN
	declare is_container, type_id, new_container_id INT UNSIGNED default NULL;
	declare container_name varchar(45) default NULL;

	if(in_isMovable = 1) then
		SELECT ObjectTypeID FROM movable_objects WHERE ID = in_objectID LIMIT 1 INTO type_id FOR UPDATE;
	else
		SELECT ObjectTypeID FROM unmovable_objects WHERE ID = in_objectID LIMIT 1 INTO type_id FOR UPDATE;
	end if;

	SELECT IsContainer, Name FROM objects_types WHERE ID = type_id LIMIT 1 INTO is_container, container_name;

	if(is_container > 0 AND in_isRecreateContainer = 1) then
		SET new_container_id = f_createRootContainer(container_name);
	end if;

	if(in_isMovable = 1) then
		if (in_isRecreateContainer = 1) then
			UPDATE movable_objects SET
				IsComplete =1,
				RootContainerID = new_container_id,
				Durability =in_Durability,
				CreatedDurability =in_CreatedDurability
			WHERE ID = in_objectID;
		else
			UPDATE movable_objects SET
				IsComplete =1,
				Durability =in_Durability,
				CreatedDurability =in_CreatedDurability
			WHERE ID = in_objectID;
		end if;
	else
		if (in_isRecreateContainer = 1) then
			UPDATE unmovable_objects SET
				IsComplete =1,
				RootContainerID = new_container_id,
				Durability =in_Durability,
				CreatedDurability =in_CreatedDurability
			WHERE ID = in_objectID;
		else
			UPDATE unmovable_objects SET
				IsComplete =1,
				Durability =in_Durability,
				CreatedDurability =in_CreatedDurability
			WHERE ID = in_objectID;
		end if;
	end if;

	if(in_conteinerID > 0 AND in_isRecreateContainer = 1) then
  	   CALL f_deleteContainer(in_conteinerID);
	end if;
END;


DROP FUNCTION IF EXISTS `f_insertNewItemInventory`;
CREATE FUNCTION `f_insertNewItemInventory`(
	`inContainerID` INT UNSIGNED,
	`inItemTypeID` INT UNSIGNED,
	`inQuality` TINYINT UNSIGNED,
	`inQuantity` INT UNSIGNED,
	`inCreatedDurability` SMALLINT UNSIGNED,
	`inDurability` SMALLINT UNSIGNED,
	`inFeatureText` VARCHAR(255),
	`inHaveEffects` TINYINT UNSIGNED,
	`inBlueprintID` INT UNSIGNED,
	`inCreatedRegionID` INT UNSIGNED,
	`inHorseHP` INT UNSIGNED,
	`inHorseStamina` INT UNSIGNED
)
	RETURNS INT UNSIGNED
	NOT DETERMINISTIC
	CONTAINS SQL
BEGIN

	DECLARE customTextID INT UNSIGNED default NULL;
	DECLARE featureID INT UNSIGNED default NULL;

	/* use this code wnen items.ID field close to its upper limit

	start transaction;

	select (i1.id + 1) as free_id
	from items as i1
	left join items as i2 on (i1.id + 1) = i2.id
	where i2.id is null
	limit 1
	into itemID
	for update;

	use itemID for insert below
	*/

	if(LENGTH(IFNULL(inFeatureText, '')) > 0) then
		SET customTextID = f_insertCustomText(inFeatureText);
	end if;

	if(customTextID is not NULL OR inHaveEffects > 0 OR inBlueprintID is not NULL OR inCreatedRegionID is not NULL OR inHorseHP is not NULL OR inHorseStamina is not NULL) then
		INSERT INTO features (`CustomtextID`,`has_effects`,`CreatedRegionID`,`BlueprintID`,`HorseHP`,`HorseStamina`)
			VALUES (customTextID, inHaveEffects,inCreatedRegionID,inBlueprintID,inHorseHP,inHorseStamina);
		SET featureID = LAST_INSERT_ID();
	end if;

	INSERT INTO items(`ContainerID`, `ObjectTypeID`, `Quality`, `Quantity`, `Durability`, `CreatedDurability`, `FeatureID`)
		VALUES(inContainerID, inItemTypeID, inQuality, inQuantity, inDurability, inCreatedDurability, featureID);

	return LAST_INSERT_ID();

	/*commit;*/
END;


DROP PROCEDURE IF EXISTS `p_createMovableObject`;
CREATE PROCEDURE `p_createMovableObject`(
	`in_ID` INT UNSIGNED,
	`in_TypeID` INT UNSIGNED,
	`in_RotateAngle` SMALLINT,
	`in_GeoID` INT UNSIGNED,
	`in_Altitude` SMALLINT UNSIGNED,
	`in_OffsetX` SMALLINT,
	`in_OffsetY` SMALLINT,
	`in_OffsetZ` INT,
	`in_CreatedDurability` SMALLINT UNSIGNED,
	`in_Durability` SMALLINT UNSIGNED,
	`in_IsComplete` TINYINT(1),
	`in_OwnerID` INT UNSIGNED,
	`in_isAlwaysCreateCompleteContainer` TINYINT
)
	MODIFIES SQL DATA
	NOT DETERMINISTIC
BEGIN
	declare is_container, containerObjectID, containerTypeID INT UNSIGNED default NULL;
	declare containerName varchar(45) default NULL;

	if( in_IsComplete || in_isAlwaysCreateCompleteContainer) then
		select IsContainer, Name, ID from objects_types where ID = in_TypeID limit 1
			into is_container, containerName, containerTypeID;
		if( is_container) then
			set containerObjectID =f_createRootContainer( containerName);
		end if;
	else
		set containerObjectID =f_createRootContainer( 'object_inventory');
	end if;

	insert into movable_objects
		(          ID, ObjectTypeID,   RootContainerID,      TurnAngle, GeoDataID,    Altitude,  OffsetMmX,  OffsetMmY,  OffsetMmZ,    CreatedDurability,    Durability,    IsComplete,    OwnerID)
		values (in_ID,    in_TypeID, containerObjectID, in_RotateAngle,  in_GeoID, in_Altitude, in_OffsetX, in_OffsetY, in_OffsetZ, in_CreatedDurability, in_Durability, in_IsComplete, in_OwnerID);

	-- set objID = LAST_INSERT_ID();
	-- update geo_data set MovableObjectsCount = MovableObjectsCount + 1 where ID =in_GeoID;
	-- return objID;
END;


DROP PROCEDURE IF EXISTS `p_dropMovableObject`;
CREATE PROCEDURE `p_dropMovableObject`(
	`objID` INT UNSIGNED,
	`newRotate` SMALLINT,
	`newGeoID` INT UNSIGNED,
	`newAltitude` SMALLINT UNSIGNED,
	`newOffsetX` SMALLINT,
	`newOffsetY` SMALLINT,
	`newOffsetZ` INT
)
    MODIFIES SQL DATA
BEGIN

	/* now we update old geo pos when we lift an object */
	/*
	DECLARE oldGeoID INT UNSIGNED DEFAULT NULL;
	SELECT GeoDataID FROM movable_objects WHERE ID =objID
		LIMIT 1
		INTO oldGeoID
		FOR UPDATE;

	IF( oldGeoID is not null) THEN
		UPDATE geo_data
			SET MovableObjectsCount =MovableObjectsCount -1
		WHERE ID =oldGeoID AND MovableObjectsCount >0;
	END IF;
	*/

/*
	UPDATE geo_data
		SET MovableObjectsCount =MovableObjectsCount +1
	WHERE ID =newGeoID;
*/

	UPDATE movable_objects
	SET
		OffsetMmX =newOffsetX,
		OffsetMmY =newOffsetY,
		OffsetMmZ =newOffsetZ,
		TurnAngle =newRotate,
		GeoDataID =newGeoID,
		Altitude =newAltitude,
		CarrierCharacterID =NULL,
		CarrierHorseID = null,
		CarrierMovableID = null,
		DroppedItemID = NULL
	WHERE ID=objID;
END;


DROP PROCEDURE IF EXISTS `f_deleteContainer`;
CREATE PROCEDURE `f_deleteContainer`(IN `InContainerID` INT UNSIGNED)
	NOT DETERMINISTIC
	CONTAINS SQL
BEGIN
	DECLARE _id INT UNSIGNED default NULL;
	DECLARE _featureID INT UNSIGNED default NULL;
	DECLARE _customtextID INT UNSIGNED default NULL;
	DECLARE done INT DEFAULT FALSE;
	DECLARE cur CURSOR FOR SELECT ID FROM items WHERE ContainerID =InContainerID;
	DECLARE cur2 CURSOR FOR SELECT ID FROM containers WHERE ParentID =InContainerID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done =TRUE;

	SELECT FeatureID FROM containers WHERE ID =InContainerID INTO _featureID;
	DELETE FROM building_items WHERE ContainerID =InContainerID;

	OPEN cur;
	read_loop: LOOP
		FETCH cur INTO _id;
		if done then
			LEAVE read_loop;
	  end if;
		CALL f_deleteItem( _id);
	END LOOP;
	CLOSE cur;

	SET done = FALSE;
	OPEN cur2;
	read_loop2: LOOP
		FETCH cur2 INTO _id;
		if done then
			LEAVE read_loop2;
	  end if;
		CALL f_deleteContainer( _id);
	END LOOP;
	CLOSE cur2;

	DELETE FROM containers WHERE ID =InContainerID;

	if( _featureID is not NULL) then
		SELECT CustomtextID FROM features WHERE ID =_featureID INTO _customtextID;
		DELETE FROM features WHERE `ID`=_featureID;
		if( _customtextID is not NULL) then
			CALL f_removeCustomText( _customtextID);
		end if;
	end if;
END;


DROP FUNCTION IF EXISTS `f_insertCustomText`;
CREATE FUNCTION `f_insertCustomText`(
	inText VARCHAR(255)
) RETURNS INT UNSIGNED
BEGIN
	DECLARE _id INT UNSIGNED DEFAULT NULL;
	if(ifnull(length(inText), 0) = 0) then
        return NULL;
    end if;
	
	SELECT ID FROM custom_texts WHERE Custom_text =inText COLLATE utf8_bin INTO _id;
	if( _id is NULL) then
		INSERT INTO custom_texts (`Custom_text`) VALUES (inText);
		SET _id =LAST_INSERT_ID();
	end if;
	RETURN _id;
END;


DROP PROCEDURE IF EXISTS `f_removeCustomText`;
CREATE PROCEDURE `f_removeCustomText`(
	inID INT UNSIGNED
)
BEGIN
	if(NOT EXISTS(SELECT * FROM features WHERE CustomtextID = inID)) then
		DELETE FROM custom_texts WHERE ID = inID;
	end if;
END;


DROP PROCEDURE IF EXISTS `f_renameContainer`;
CREATE PROCEDURE `f_renameContainer`(
	IN `inContainerID` INT UNSIGNED,
	IN `inText` VARCHAR(255)
)
BEGIN
	DECLARE var_oldCustomTextID, var_newCustomTextID INT UNSIGNED default NULL;
	DECLARE var_featureID INT UNSIGNED default NULL;

	if( LENGTH( IFNULL( inText, '')) > 0) then
		SET var_newCustomTextID =f_insertCustomText( inText);
	end if;

	SELECT FeatureID FROM `containers` WHERE ID =inContainerID INTO var_featureID;
	if( var_featureID is not NULL) then

		SELECT CustomtextID FROM features WHERE ID =var_featureID INTO var_oldCustomTextID;
		if( var_newCustomTextID is not NULL) then
			-- update feature's text
			UPDATE features set `CustomtextID` = var_newCustomTextID WHERE ID = var_featureID;
		else
			-- remove custom text and feature
			UPDATE containers SET `FeatureID` =NULL WHERE ID =inContainerID;
			DELETE FROM features WHERE ID=var_featureID;
		end if;

		if( var_oldCustomTextID is not NULL) then
			CALL f_removeCustomText( var_oldCustomTextID);
		end if;

	elseif( var_newCustomTextID is not NULL) then
		-- create new feature
		INSERT INTO features (`CustomtextID`) VALUES (var_newCustomTextID);
		SET var_featureID =LAST_INSERT_ID();
		UPDATE containers SET `FeatureID` =var_featureID WHERE ID =inContainerID;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteCharacterInventory;
DROP PROCEDURE IF EXISTS p_deleteCharacterBlueprints;
CREATE PROCEDURE `p_deleteCharacterBlueprints`(
	IN `inCharID` INT UNSIGNED
)
BEGIN

	-- blueprints (use temporary table to hold all blueprints related to inCharID)
	drop temporary table if exists `tmp_character_blueprints`;
	create temporary table `tmp_character_blueprints` (
		BlueprintID int unsigned not null
	) engine=memory;

	UPDATE `features` SET `BlueprintID` = NULL WHERE BlueprintID IN (SELECT BlueprintID FROM `character_blueprints` WHERE CharID = inCharID);
	DELETE FROM `blueprint_requirements` WHERE BlueprintID IN (SELECT BlueprintID FROM `character_blueprints` WHERE CharID = inCharID);
	INSERT INTO `tmp_character_blueprints` (BlueprintID)
		SELECT BlueprintID FROM `character_blueprints` WHERE CharID = inCharID;
	DELETE FROM `character_blueprints` WHERE CharID = inCharID;
	DELETE FROM `blueprints` WHERE ID IN (SELECT BlueprintID FROM `tmp_character_blueprints`);

	drop temporary table `tmp_character_blueprints`;

END;

DROP PROCEDURE IF EXISTS p_deleteCharacter;
CREATE PROCEDURE `p_deleteCharacter`(
	IN `inCharID` INT UNSIGNED,
	IN `inAccID` INT UNSIGNED
)
BEGIN
	declare eqContID, invContID, delCharacterID int unsigned default null;
	declare isCharFound tinyint unsigned default 0; -- not found by default

	declare exit handler for sqlexception
	begin
		rollback;
		resignal;
	end;

	select EquipmentContainerID, RootContainerID from `character` where id = inCharID and AccountID = inAccID
		into eqContID, invContID;

	if(eqContID is not null and invContID is not null) then
		set isCharFound = 1; -- found

		START TRANSACTION;

		DELETE FROM skills WHERE CharacterID = inCharID;
		DELETE FROM equipment_slots WHERE CharacterID = inCharID;
		DELETE FROM character_wounds WHERE CharacterID = inCharID;
		DELETE FROM character_titles WHERE CharacterID = inCharID;
		DELETE FROM character_effects WHERE CharacterID = inCharID;
		-- DELETE FROM minigame_results WHERE CharID = inCharID;
		-- DELETE FROM minigame_guestlinks WHERE CharID = inCharID;

		-- personal_lands -> claims -> (claim_rules, unmovable_objects_claims)
		DELETE FROM claim_rules              WHERE ClaimID IN (SELECT ID FROM claims WHERE PersonalLandID IN (SELECT ID FROM personal_lands WHERE CharID = inCharID));
		DELETE FROM claim_rules_unmovable    WHERE UnmovableClaimID IN (SELECT ID FROM unmovable_objects_claims WHERE ClaimID IN (SELECT ID FROM claims WHERE PersonalLandID IN (SELECT ID FROM personal_lands WHERE CharID = inCharID)));
		DELETE FROM unmovable_objects_claims WHERE ClaimID IN (SELECT ID FROM claims WHERE PersonalLandID IN (SELECT ID FROM personal_lands WHERE CharID = inCharID));
		DELETE FROM claims WHERE PersonalLandID IN (SELECT ID FROM personal_lands WHERE CharID = inCharID);
		DELETE FROM personal_lands WHERE CharID = inCharID;

		-- claim_subjects -> (claim_rules, claim_rules_unmovable)
		DELETE FROM claim_rules           WHERE ClaimSubjectID IN (SELECT ID FROM claim_subjects WHERE CharID = inCharID);
		DELETE FROM claim_rules_unmovable WHERE ClaimSubjectID IN (SELECT ID FROM claim_subjects WHERE CharID = inCharID);
		DELETE FROM claim_subjects WHERE CharID = inCharID;

		-- DELETE FROM food_eaten WHERE CharID = inCharID;
		-- DELETE FROM chars_deathlog WHERE CharID = inCharID;
		-- DELETE FROM chars_deathlog WHERE KillerID = inCharID;
		-- DELETE FROM skill_raise_logs WHERE PlayerID = inCharID;

		UPDATE movable_objects SET CarrierCharacterID = NULL WHERE CarrierCharacterID = inCharID;
		UPDATE movable_objects SET OwnerID = NULL, DroppedTime = 0 WHERE OwnerID = inCharID;
		UPDATE unmovable_objects SET OwnerID = NULL, DroppedTime = 0 WHERE OwnerID = inCharID;

		delete from guild_invites where SenderCharID = inCharID or ReceiverCharID = inCharID;
		DELETE FROM guild_actions_queue where ProducerCharID = inCharID or CharID = inCharID;

		call p_deleteCharacterBlueprints(inCharID);
		
		DELETE FROM `quests_progress` WHERE CharacterID = inCharID;
		DELETE FROM `quests_answers` WHERE CharacterID = inCharID;
		DELETE FROM `quests_tasks` WHERE CharacterID = inCharID;
				
		insert into deleted_character_info
			(ID, AccountID, CharName, CharLastName, CreateTimestamp)
			select ID, AccountID, Name, LastName, CreateTimestamp from `character` WHERE ID = inCharID;

		-- char itself
		DELETE FROM `character` WHERE ID = inCharID;

		CALL f_deleteContainer(eqContID);
		CALL f_deleteContainer(invContID);

		COMMIT;
	end if;

	select isCharFound as `found`;

END;


DROP PROCEDURE IF EXISTS `p_addObjectPatch`;
CREATE PROCEDURE `p_addObjectPatch`(
	`in_ChangeID` INT UNSIGNED,
	`in_TerID` INT UNSIGNED,
	`in_Action` TINYINT UNSIGNED,
	`in_ObjectSuperType` TINYINT UNSIGNED,
	`in_ObjectID` INT UNSIGNED,
	`in_GeoDataID` INT UNSIGNED,
	`in_ObjectTypeID` INT UNSIGNED,
	`in_TurnAngle` SMALLINT,
	`in_Altitude` SMALLINT UNSIGNED,
	`in_OffsetX` SMALLINT,
	`in_OffsetY` SMALLINT,
	`in_OffsetZ` INT,
	`in_IsComplete` TINYINT(1) UNSIGNED
)
    MODIFIES SQL DATA
BEGIN

	-- make changes
	insert into objects_patch
		(       `TerID`,   `Version`,  `Action`,  `ObjectSuperType`,  `ObjectID`,  `GeoDataID`,  `ObjectTypeID`,  `TurnAngle`,  `Altitude`,  `OffsetX`,  `OffsetY`,  `OffsetZ`,  `IsComplete`)
		values(in_TerID, in_ChangeID, in_Action, in_ObjectSuperType, in_ObjectID, in_GeoDataID, in_ObjectTypeID, in_TurnAngle, in_Altitude, in_OffsetX, in_OffsetY, in_OffsetZ, in_IsComplete);

	update terrain_blocks
		set ObjectsVersion = in_ChangeID
		where ID = in_TerID and ObjectsVersion < in_ChangeID; -- do not downgrade version

END;


DROP PROCEDURE IF EXISTS `p_createUnmovableObject`;
CREATE PROCEDURE `p_createUnmovableObject`(
	in_ID INT UNSIGNED,
	in_typeID INT UNSIGNED,
	in_rotateAngle SMALLINT,
	in_geoID INT UNSIGNED,
	in_durability SMALLINT UNSIGNED,
	in_isComplete TINYINT UNSIGNED
)
    MODIFIES SQL DATA
BEGIN

	declare is_container, containerObjectID, containerTypeID INT UNSIGNED default NULL;
	declare containerName varchar(45) default NULL;

	if(in_isComplete) then
		select IsContainer, Name, ID from objects_types where ID = in_TypeID limit 1
			into is_container, containerName, containerTypeID;
		if( is_container) then
			set containerObjectID = f_createRootContainer( containerName);
		end if;
	else
		set containerObjectID = f_createRootContainer('object_inventory');
	end if;

	insert into unmovable_objects
		(ID, ObjectTypeID,        GeoDataID, TurnAngle,      RootContainerID,   Durability,    IsComplete)
		values (in_ID, in_typeID, in_geoID,  in_rotateAngle, containerObjectID, in_durability, in_isComplete);

END;


DROP PROCEDURE IF EXISTS p_recreateUnmovableObject;
CREATE PROCEDURE `p_recreateUnmovableObject`(
	IN `inOldObjID` INT UNSIGNED,
	IN `inNewObjID` INT UNSIGNED,
	IN `inNewTypeID` INT UNSIGNED,
	IN `inCreatedDurability` SMALLINT UNSIGNED,
	IN `inDurability` SMALLINT UNSIGNED,
	IN `inCompleted` TINYINT UNSIGNED
)
BEGIN
	DECLARE oldGeoDataID, newContainerID INT UNSIGNED default NULL;
	DECLARE oldTurnAngle SMALLINT default NULL;
	DECLARE newContainerName VARCHAR(45) default NULL;
	declare newObjIsContainer TINYINT default NULL;

	SELECT IsContainer, Name FROM objects_types WHERE ID = inNewTypeID
		INTO newObjIsContainer, newContainerName;

	SELECT GeoDataID, TurnAngle FROM unmovable_objects WHERE ID = inOldObjID
		INTO oldGeoDataID, oldTurnAngle
		FOR UPDATE;

	CALL p_createUnmovableObject(
		inNewObjID,
		inNewTypeID,
		oldTurnAngle,
		oldGeoDataID,
		inCreatedDurability,
		inCompleted);

	update unmovable_objects_claims set UnmovableObjectID = inNewObjID where UnmovableObjectID = inOldObjID;
	
	-- container for incomplete objects already created in p_createUnmovableObject. For completed object we duplicate container-related logic from p_completeBuilding here
	if(newObjIsContainer > 0 and inCompleted > 0) then
		SET newContainerID = f_createRootContainer(newContainerName);

		UPDATE `unmovable_objects` SET
			CreatedDurability =inCreatedDurability,
			Durability =inDurability,
			RootContainerID =newContainerID
			WHERE ID=inNewObjID;
	else
		UPDATE `unmovable_objects` SET
			CreatedDurability =inCreatedDurability,
			Durability =inDurability
			WHERE ID=inNewObjID;
	end if;
	
	CALL p_deleteUnmovableObject( inOldObjID);
END;


DROP FUNCTION IF EXISTS f_createGuild;
CREATE FUNCTION `f_createGuild`(
	`inGuildTypeID` TINYINT UNSIGNED,
	`inGuildName` VARCHAR(45),
	`inGuildTag` VARCHAR(4),
	`inGuildCharter` VARCHAR(10000),
	`inLeaderId` INT UNSIGNED
)
	RETURNS INT UNSIGNED
BEGIN
	DECLARE guildID INT UNSIGNED default NULL;
	
	INSERT INTO guilds (GuildTypeID, Name, GuildCharter, GuildTag)
	values (inGuildTypeID, inGuildName, inGuildCharter, inGuildTag);
	SET guildID = LAST_INSERT_ID();
	
	update `character`
	set GuildID = guildID, GuildRoleID = 1 /*leader*/
	where ID = inLeaderId;

	RETURN guildID;
END;

DROP FUNCTION IF EXISTS f_createGuildClaim;
DROP PROCEDURE IF EXISTS p_createGuildLandsAndClaims;
DROP PROCEDURE IF EXISTS p_createGuildYoLandsAndClaims;
CREATE PROCEDURE `p_createGuildYoLandsAndClaims`(
    `inGuildID` INT UNSIGNED,
    `inCenterGeoID` INT UNSIGNED,
    `inRadius` INT UNSIGNED
)
BEGIN
	declare myLandID INT UNSIGNED default NULL;
	declare myClaimID INT UNSIGNED default NULL;

	-- skip guilds with yo lands
	if(!exists(select * from guild_lands where GuildID = inGuildID and LandType = 3)) then
		-- insert two lands
		insert into guild_lands
		(`GuildID`, `CenterGeoID`, `Radius`, `LandType`)
		values
			(inGuildID, inCenterGeoID, inRadius, 3/*yo*/);
		set myLandID = LAST_INSERT_ID();
		
		-- insert claim for each land
		insert into claims
		(GuildLandID)
			select ID from guild_lands where GuildID = inGuildID and LandType = 3;
		set myClaimID = LAST_INSERT_ID();

		-- insert default rules
		insert into claim_rules (ClaimID, ClaimSubjectID, CanEnter, CanBuild , CanClaim, CanUse, CanDestroy)
			select myClaimID, subjectId, CanEnter, CanBuild, CanClaim, CanUse, CanDestroy
			from guild_lands gl
			join claims c on c.GuildLandID = gl.ID
			cross join( 
				select f_getSubjectIDByRole(1/*Leader*/) as subjectId,       1 as CanEnter, 1 as CanBuild , 1 as CanClaim, 1 as CanUse, 1 as CanDestroy
				union all select f_getSubjectIDByRole(2/*Minor leader*/),    1,1,1,1,1
				union all select f_getSubjectIDByRole(3/*1st tier member*/), 1,1,1,1,1
				union all select f_getSubjectIDByRole(4/*2nd tier member*/), 1,1,1,1,1
				union all select f_getSubjectIDByRole(5/*3rd tier member*/), 1,1,1,1,1
				union all select f_getSubjectIDByRole(6/*Normal member*/),   1,1,1,1,1
				union all select f_getSubjectIDByRole(7/*Recruit*/),         1,1,1,1,0
				union all select f_getSubjectIDByStanding(5/*Ally*/),        1,0,0,0,0
			) as t
			where gl.ID = myLandID;

		-- result
		select LandType, myClaimID as ClaimID, myLandID as GuildLandID
		from guild_lands where ID = myLandID;
	else
		select 0 as LandType, 0 as ClaimID, 0 as GuildLandID;
	end if;
END;

DROP PROCEDURE IF EXISTS p_createOutpostLandAndClaim;
CREATE PROCEDURE `p_createOutpostLandAndClaim`(
    `inGuildID` INT UNSIGNED,
    `inCenterGeoID` INT UNSIGNED,
    `inRadius` INT UNSIGNED
)
BEGIN
	declare myLandID INT UNSIGNED default NULL;
	declare myClaimID INT UNSIGNED default NULL;

	insert into guild_lands
	(`GuildID`, `CenterGeoID`, `Radius`, `LandType`)
	values
		(inGuildID, inCenterGeoID, inRadius, 4/*outpost*/);
	set myLandID = LAST_INSERT_ID();

	-- insert claim for each land
	insert into claims
	(GuildLandID)
		values (myLandID);
	set myClaimID = LAST_INSERT_ID();

	-- insert default rules
	insert into claim_rules (ClaimID, ClaimSubjectID, CanEnter, CanBuild , CanClaim, CanUse, CanDestroy)
		values
			(myClaimID, f_getSubjectIDByRole(1/*Leader*/),          1,1,1,1,1),
			(myClaimID, f_getSubjectIDByRole(2/*Minor leader*/),    1,1,0,1,0),
			(myClaimID, f_getSubjectIDByRole(3/*1st tier member*/), 1,1,0,0,0),
			(myClaimID, f_getSubjectIDByRole(4/*2nd tier member*/), 1,1,0,0,0),
			(myClaimID, f_getSubjectIDByRole(5/*3rd tier member*/), 1,1,0,0,0),
			(myClaimID, f_getSubjectIDByRole(6/*Normal member*/),   1,1,0,0,0),
			(myClaimID, f_getSubjectIDByRole(7/*Recruit*/),         1,0,0,0,0),
			(myClaimID, f_getSubjectIDByStanding(5/*Ally*/),        1,0,0,0,0);

	-- result
	select LandType, myClaimID as ClaimID, myLandID as GuildLandID
	from guild_lands where ID = myLandID;
END;

DROP PROCEDURE IF EXISTS p_createPersonalLandAndClaim_impl;
CREATE PROCEDURE `p_createPersonalLandAndClaim_impl`(
	`inExistingDeletedLandID` INT UNSIGNED,
    `inCharID` INT UNSIGNED,
	`inName` VARCHAR(45),
    `inGeoID1` INT UNSIGNED,
	`inGeoID2` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare claimID INT UNSIGNED default NULL;
	
	if(inExistingDeletedLandID is null) then
		insert into personal_lands
		(`CharID`, `Name`, `GeoID1`, `GeoID2`, `IsTemp`)
		values
		(inCharID, inName, inGeoID1, inGeoID2, 0);
	else
		update personal_lands set
			CharID = inCharID,
			Name = inName,
			GeoID1 = inGeoID1,
			GeoID2 = inGeoID2,
			isTemp = 0
		where ID = inExistingDeletedLandID;
	end if;
	
	insert into claims
	(PersonalLandID)
		select ID from personal_lands where CharID = inCharID;
	set claimID = LAST_INSERT_ID();
		
	select ID from claim_subjects where CharID = inCharID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set CharID = inCharID;
		set subjID = LAST_INSERT_ID();
	end if;
	
	-- insert default rules
	insert into claim_rules
	(ClaimID, ClaimSubjectID, CanEnter, CanBuild , CanClaim, CanUse, CanDestroy)
	values
	(claimID, subjID, 1, 1, 1, 1, 1);

	-- result
	select c.ID as ClaimID, pl.ID as PersonalLandID
	from personal_lands pl
	join claims c on c.PersonalLandID = pl.ID
	where pl.CharID = inCharID;
END;

DROP PROCEDURE IF EXISTS p_createPersonalLandAndClaim;
CREATE PROCEDURE `p_createPersonalLandAndClaim`(
    `inCharID` INT UNSIGNED,
	`inName` VARCHAR(45),
    `inGeoID1` INT UNSIGNED,
	`inGeoID2` INT UNSIGNED
)
BEGIN
	declare landID INT UNSIGNED default NULL;
	declare landStatus INT default NULL;

	select `ID`, `isTemp` from personal_lands where CharID = inCharID into landID, landStatus;
	
	if(landID is null or landStatus = 2) then
		call p_createPersonalLandAndClaim_impl(landID, inCharID, inName, inGeoID1, inGeoID2);
	else
		select 0 as ClaimID, 0 as PersonalLandID;
	end if;
END;

DROP PROCEDURE IF EXISTS p_createAdminLandAndClaim;
CREATE PROCEDURE `p_createAdminLandAndClaim`(
	`inName` VARCHAR(45),
    `inGeoID1` INT UNSIGNED,
	`inGeoID2` INT UNSIGNED,
	`inPriority` INT UNSIGNED
)
BEGIN
	declare landID INT UNSIGNED default NULL;
	declare subjID INT UNSIGNED default NULL;
	declare claimID INT UNSIGNED default NULL;

	insert into admin_lands
	(`Name`, `Priority`, `GeoID1`, `GeoID2`)
	values
	(inName, inPriority, inGeoID1, inGeoID2);
	set landID = LAST_INSERT_ID();
	
	insert into claims
	(AdminLandID)
	values
	(landID);
	set claimID = LAST_INSERT_ID();

	-- result
	select c.ID as ClaimID, al.ID as AdminLandID
	from admin_lands al
	join claims c on c.AdminLandID = al.ID
	where c.ID = claimID;
END;

DROP PROCEDURE IF EXISTS p_queueResizePersonalLand;
CREATE PROCEDURE `p_queueResizePersonalLand`(
    `inCharID` INT UNSIGNED,
	`inName` VARCHAR(45),
    `inGeoID1` INT UNSIGNED,
	`inGeoID2` INT UNSIGNED
)
BEGIN
	declare temporaryLandID INT UNSIGNED default null;
	declare actualLandID INT UNSIGNED default null;
	declare actualClaimID INT UNSIGNED default null;
	select ID into actualLandID from personal_lands where CharID = inCharID and isTemp = 0;
	select ID into temporaryLandID from personal_lands where CharID = inCharID and isTemp = 1;
	select ID into actualClaimID from claims where PersonalLandID = actualLandID;

	if(exists(select * from personal_lands where CharID = inCharID and isTemp = 0)) then
		if(temporaryLandID is null) then
			insert into personal_lands
			(`CharID`, `Name`, `GeoID1`, `GeoID2`, `IsTemp`)
			values
			(inCharID, inName, inGeoID1, inGeoID2, 1);
			set temporaryLandID = LAST_INSERT_ID();
		else
			update personal_lands
			set GeoID1 = inGeoID1, GeoID2 = inGeoID2
			where ID = temporaryLandID;
		end if;

		-- result
		select temporaryLandID as TemporaryPersonalLandID, actualClaimID as ClaimID;
	else
		select 0 as TemporaryPersonalLandID, 0 as ClaimID;
	end if;
END;

DROP PROCEDURE IF EXISTS p_onPersonalLandMaintenance;
CREATE PROCEDURE `p_onPersonalLandMaintenance`(
    `inLandID` INT UNSIGNED,
	`inTemporaryLandID` INT UNSIGNED,
    `inNewSupportPoints` INT UNSIGNED
)
BEGIN
	declare NewGeoID1 INT UNSIGNED default NULL;
	declare NewGeoID2 INT UNSIGNED default NULL;
	
	select GeoID1, GeoID2 into NewGeoID1, NewGeoID2 from personal_lands where ID = inTemporaryLandID and isTemp = 1;
	
	if(exists(select * from personal_lands where ID = inLandID and isTemp = 0)
	and NewGeoID1 is not null and NewGeoID2 is not null) then
		update personal_lands set GeoID1 = NewGeoID1, GeoID2 = NewGeoID2, SupportPoints = inNewSupportPoints where ID = inLandID;
		delete from personal_lands where ID = inTemporaryLandID;
	end if;
END;


DROP PROCEDURE IF EXISTS p_deleteClaim;
DROP PROCEDURE IF EXISTS p_deleteLandAndClaimByClaimId;
CREATE PROCEDURE `p_deleteLandAndClaimByClaimId`(
	IN `inClaimID` INT UNSIGNED
)
BEGIN
	declare delGuildLandID, delPersonalLandID, delAdminLandID int unsigned default NULL;

	delete from claim_rules where ClaimID in (select ID from claims where ID = inClaimID);
	delete from claim_rules_unmovable where UnmovableClaimID in (select ID from unmovable_objects_claims where ClaimID in (select ID from claims where ID = inClaimID));
	delete from unmovable_objects_claims where ClaimID in (select ID from claims where ID = inClaimID);

	select GuildLandID, PersonalLandID, AdminLandID from claims where ID = inClaimID
		into delGuildLandID, delPersonalLandID, delAdminLandID;
	delete from claims where ID = inClaimID;

	if(delGuildLandID is not NULL) then
		delete from guild_lands where ID = delGuildLandID;
	end if;
	if(delPersonalLandID is not NULL) then
		update personal_lands set IsTemp = 2 where ID = delPersonalLandID; -- 2 is Deleted
	end if;
	if(delAdminLandID is not NULL) then
		delete from admin_lands where ID = delAdminLandID;
	end if;

	-- cleanup claim_subjects
	delete from claim_subjects where !exists(select * from claim_rules where ClaimSubjectID = claim_subjects.ID) and
		!exists(select * from claim_rules_unmovable where ClaimSubjectID = claim_subjects.ID);
END;

DROP PROCEDURE IF EXISTS p_deleteGuildLand;
DROP PROCEDURE IF EXISTS p_deleteLandAndClaimByLandId;
CREATE PROCEDURE p_deleteLandAndClaimByLandId(
    IN inGuildLandID INT UNSIGNED
)
BEGIN
    declare delClaimID int unsigned default NULL;

    select ID
    into delClaimID
    from claims
    where GuildLandID = inGuildLandID;

    call p_deleteLandAndClaimByClaimId(delClaimID);
END;

DROP PROCEDURE IF EXISTS p_addClaimSubject;
DROP PROCEDURE IF EXISTS p_addClaimSubject_char;
DROP PROCEDURE IF EXISTS p_setClaimSubject_char;
CREATE PROCEDURE `p_setClaimSubject_char`(
	IN `inClaimID` INT UNSIGNED,
	IN `inCharID` INT UNSIGNED,
	IN `inCanEnter` TINYINT UNSIGNED,
	IN `inCanBuild` TINYINT UNSIGNED,
	IN `inCanClaim` TINYINT UNSIGNED,
	IN `inCanUse` TINYINT UNSIGNED,
	IN `inCanDestroy` TINYINT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;

	select ID from claim_subjects where CharID = inCharID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set CharID = inCharID;
		set subjID = LAST_INSERT_ID();
	end if;

	insert into claim_rules
		(`ClaimID`, `ClaimSubjectID`, `CanEnter`, `CanBuild`, `CanClaim`, `CanUse`, `CanDestroy`)
		values
		(inClaimID, subjID,           inCanEnter, inCanBuild, inCanClaim, inCanUse, inCanDestroy)
		on duplicate key update CanEnter = inCanEnter, CanBuild = inCanBuild, CanClaim = inCanClaim, CanUse = inCanUse, CanDestroy = inCanDestroy;
END;

DROP PROCEDURE IF EXISTS p_addClaimSubject_guild;
DROP PROCEDURE IF EXISTS p_setClaimSubject_guild;
CREATE PROCEDURE `p_setClaimSubject_guild`(
	IN `inClaimID` INT UNSIGNED,
	IN `inGuildID` INT UNSIGNED,
	IN `inCanEnter` TINYINT UNSIGNED,
	IN `inCanBuild` TINYINT UNSIGNED,
	IN `inCanClaim` TINYINT UNSIGNED,
	IN `inCanUse` TINYINT UNSIGNED,
	IN `inCanDestroy` TINYINT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;

	select ID from claim_subjects where GuildID = inGuildID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set GuildID = inGuildID;
		set subjID = LAST_INSERT_ID();
	end if;

	insert into claim_rules
		(`ClaimID`, `ClaimSubjectID`, `CanEnter`, `CanBuild`, `CanClaim`, `CanUse`, `CanDestroy`)
		values
		(inClaimID, subjID,           inCanEnter, inCanBuild, inCanClaim, inCanUse, inCanDestroy)
		on duplicate key update CanEnter = inCanEnter, CanBuild = inCanBuild, CanClaim = inCanClaim, CanUse = inCanUse, CanDestroy = inCanDestroy;
END;

DROP PROCEDURE IF EXISTS p_addClaimSubject_role;
DROP PROCEDURE IF EXISTS p_setClaimSubject_role;
CREATE PROCEDURE `p_setClaimSubject_role`(
	IN `inClaimID` INT UNSIGNED,
	IN `inGuildRoleID` INT UNSIGNED,
	IN `inCanEnter` TINYINT UNSIGNED,
	IN `inCanBuild` TINYINT UNSIGNED,
	IN `inCanClaim` TINYINT UNSIGNED,
	IN `inCanUse` TINYINT UNSIGNED,
	IN `inCanDestroy` TINYINT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;

	select ID from claim_subjects where GuildRoleID = inGuildRoleID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set GuildRoleID = inGuildRoleID;
		set subjID = LAST_INSERT_ID();
	end if;

	insert into claim_rules
		(`ClaimID`, `ClaimSubjectID`, `CanEnter`, `CanBuild`, `CanClaim`, `CanUse`, `CanDestroy`)
		values
		(inClaimID, subjID,           inCanEnter, inCanBuild, inCanClaim, inCanUse, inCanDestroy)
		on duplicate key update CanEnter = inCanEnter, CanBuild = inCanBuild, CanClaim = inCanClaim, CanUse = inCanUse, CanDestroy = inCanDestroy;
END;

DROP PROCEDURE IF EXISTS p_addClaimSubject_standing;
DROP PROCEDURE IF EXISTS p_setClaimSubject_standing;
CREATE PROCEDURE `p_setClaimSubject_standing`(
	IN `inClaimID` INT UNSIGNED,
	IN `inStandingTypeID` INT UNSIGNED,
	IN `inCanEnter` TINYINT UNSIGNED,
	IN `inCanBuild` TINYINT UNSIGNED,
	IN `inCanClaim` TINYINT UNSIGNED,
	IN `inCanUse` TINYINT UNSIGNED,
	IN `inCanDestroy` TINYINT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;

	select ID from claim_subjects where StandingTypeID = inStandingTypeID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set StandingTypeID = inStandingTypeID;
		set subjID = LAST_INSERT_ID();
	end if;

	insert into claim_rules
		(`ClaimID`, `ClaimSubjectID`, `CanEnter`, `CanBuild`, `CanClaim`, `CanUse`, `CanDestroy`)
		values
		(inClaimID, subjID,           inCanEnter, inCanBuild, inCanClaim, inCanUse, inCanDestroy)
		on duplicate key update CanEnter = inCanEnter, CanBuild = inCanBuild, CanClaim = inCanClaim, CanUse = inCanUse, CanDestroy = inCanDestroy;
END;


DROP PROCEDURE IF EXISTS p_addUnmovableSubject_char;
DROP PROCEDURE IF EXISTS p_setUnmovableSubject_char;
CREATE PROCEDURE `p_setUnmovableSubject_char`(
	IN `inUnmovableID` INT UNSIGNED,
	IN `inCharID` INT UNSIGNED,
	IN `inCanUse` TINYINT UNSIGNED,
	IN `inCanDestroy` TINYINT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare unmovableClaimID INT UNSIGNED default NULL;

	select ID from claim_subjects where CharID = inCharID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set CharID = inCharID;
		set subjID = LAST_INSERT_ID();
	end if;
	
	select ID from `unmovable_objects_claims` where UnmovableObjectID = inUnmovableID 
	into unmovableClaimID;

	insert into claim_rules_unmovable
		(`UnmovableClaimID`, `ClaimSubjectID`, `CanUse`, `CanDestroy`)
		values
		(unmovableClaimID, subjID            , inCanUse, inCanDestroy)
		on duplicate key update CanUse = inCanUse, CanDestroy = inCanDestroy;
END;

DROP PROCEDURE IF EXISTS p_addUnmovableSubject_guild;
DROP PROCEDURE IF EXISTS p_setUnmovableSubject_guild;
CREATE PROCEDURE `p_setUnmovableSubject_guild`(
	IN `inUnmovableID` INT UNSIGNED,
	IN `inGuildID` INT UNSIGNED,
	IN `inCanUse` TINYINT UNSIGNED,
	IN `inCanDestroy` TINYINT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare unmovableClaimID INT UNSIGNED default NULL;

	select ID from claim_subjects where GuildID = inGuildID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set GuildID = inGuildID;
		set subjID = LAST_INSERT_ID();
	end if;

	select ID from `unmovable_objects_claims` where UnmovableObjectID = inUnmovableID 
	into unmovableClaimID;

	insert into claim_rules_unmovable
		(`UnmovableClaimID`, `ClaimSubjectID`, `CanUse`, `CanDestroy`)
		values
		(unmovableClaimID, subjID            , inCanUse, inCanDestroy)
		on duplicate key update CanUse = inCanUse, CanDestroy = inCanDestroy;
END;

DROP PROCEDURE IF EXISTS p_addUnmovableSubject_role;
DROP PROCEDURE IF EXISTS p_setUnmovableSubject_role;
CREATE PROCEDURE `p_setUnmovableSubject_role`(
	IN `inUnmovableID` INT UNSIGNED,
	IN `inGuildRoleID` INT UNSIGNED,
	IN `inCanUse` TINYINT UNSIGNED,
	IN `inCanDestroy` TINYINT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare unmovableClaimID INT UNSIGNED default NULL;
	
	select ID from claim_subjects where GuildRoleID = inGuildRoleID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set GuildRoleID = inGuildRoleID;
		set subjID = LAST_INSERT_ID();
	end if;

	select ID from `unmovable_objects_claims` where UnmovableObjectID = inUnmovableID 
	into unmovableClaimID;

	insert into claim_rules_unmovable
		(`UnmovableClaimID`, `ClaimSubjectID`, `CanUse`, `CanDestroy`)
		values
		(unmovableClaimID, subjID            , inCanUse, inCanDestroy)
		on duplicate key update CanUse = inCanUse, CanDestroy = inCanDestroy;
END;

DROP PROCEDURE IF EXISTS p_addUnmovableSubject_standing;
DROP PROCEDURE IF EXISTS p_setUnmovableSubject_standing;
CREATE PROCEDURE `p_setUnmovableSubject_standing`(
	IN `inUnmovableID` INT UNSIGNED,
	IN `inStandingTypeID` INT UNSIGNED,
	IN `inCanUse` TINYINT UNSIGNED,
	IN `inCanDestroy` TINYINT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare unmovableClaimID INT UNSIGNED default NULL;

	select ID from claim_subjects where StandingTypeID = inStandingTypeID into subjID;
	if(subjID is NULL) then
		insert into claim_subjects set StandingTypeID = inStandingTypeID;
		set subjID = LAST_INSERT_ID();
	end if;

	select ID from `unmovable_objects_claims` where UnmovableObjectID = inUnmovableID 
	into unmovableClaimID;

	insert into claim_rules_unmovable
		(`UnmovableClaimID`, `ClaimSubjectID`, `CanUse`, `CanDestroy`)
		values
		(unmovableClaimID, subjID            , inCanUse, inCanDestroy)
		on duplicate key update CanUse = inCanUse, CanDestroy = inCanDestroy;
END;

DROP PROCEDURE IF EXISTS p_changeGuildLeader;
CREATE PROCEDURE `p_changeGuildLeader`(
	IN `inGuildID` INT UNSIGNED,
	IN `inNewLeaderID` INT UNSIGNED
)
BEGIN
	update `character` set GuildID = inGuildID, GuildRoleID = 1/*Leader*/ where ID = inNewLeaderID;
	update `character` set GuildRoleID = 6/*Normal member*/ where GuildID = inGuildID and ID != inNewLeaderID;
END;


DROP PROCEDURE IF EXISTS p_deleteClaimSubject_char;
CREATE PROCEDURE `p_deleteClaimSubject_char`(
	`inClaimID` INT UNSIGNED,
	`inCharID` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	select ID from claim_subjects where CharID = inCharID into subjID;

	if(subjID is not NULL) then
		delete from claim_rules where ClaimID = inClaimID and ClaimSubjectID = subjID;

		if(!exists(select * from claim_rules where ClaimSubjectID = subjID) and
			!exists(select * from claim_rules_unmovable where ClaimSubjectID = subjID)
		) then
			delete from claim_subjects where CharID = inCharID;
		end if;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteClaimSubject_guild;
CREATE PROCEDURE `p_deleteClaimSubject_guild`(
	`inClaimID` INT UNSIGNED,
	`inGuildID` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	select ID from claim_subjects where GuildID = inGuildID into subjID;

	if(subjID is not NULL) then
		delete from claim_rules where ClaimID = inClaimID and ClaimSubjectID = subjID;

		if(!exists(select * from claim_rules where ClaimSubjectID = subjID) and
			!exists(select * from claim_rules_unmovable where ClaimSubjectID = subjID)
		) then
			delete from claim_subjects where GuildID = inGuildID;
		end if;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteClaimSubject_role;
CREATE PROCEDURE `p_deleteClaimSubject_role`(
	`inClaimID` INT UNSIGNED,
	`inGuildRoleID` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	select ID from claim_subjects where GuildRoleID = inGuildRoleID into subjID;

	if(subjID is not NULL) then
		delete from claim_rules where ClaimID = inClaimID and ClaimSubjectID = subjID;

		if(!exists(select * from claim_rules where ClaimSubjectID = subjID) and
			!exists(select * from claim_rules_unmovable where ClaimSubjectID = subjID)
		) then
			delete from claim_subjects where GuildRoleID = inGuildRoleID;
		end if;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteClaimSubject_standing;
CREATE PROCEDURE `p_deleteClaimSubject_standing`(
	`inClaimID` INT UNSIGNED,
	`inStandingTypeID` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	select ID from claim_subjects where StandingTypeID = inStandingTypeID into subjID;

	if(subjID is not NULL) then
		delete from claim_rules where ClaimID = inClaimID and ClaimSubjectID = subjID;

		if(!exists(select * from claim_rules where ClaimSubjectID = subjID) and
			!exists(select * from claim_rules_unmovable where ClaimSubjectID = subjID)
		) then
			delete from claim_subjects where StandingTypeID = inStandingTypeID;
		end if;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteUnmovableSubject_char;
CREATE PROCEDURE `p_deleteUnmovableSubject_char`(
	`inUnmovableID` INT UNSIGNED,
	`inCharID` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare uClaimID int unsigned default NULL;
	
	select ID from claim_subjects where CharID = inCharID into subjID;
	select ID from unmovable_objects_claims where UnmovableObjectID = inUnmovableID into uClaimID;

	if(subjID is not NULL) then
		delete from claim_rules_unmovable where UnmovableClaimID = uClaimID and ClaimSubjectID = subjID;

		if(!exists(select * from claim_rules where ClaimSubjectID = subjID) and
			!exists(select * from claim_rules_unmovable where ClaimSubjectID = subjID)
		) then
			delete from claim_subjects where CharID = inCharID;
		end if;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteUnmovableSubject_guild;
CREATE PROCEDURE `p_deleteUnmovableSubject_guild`(
	`inUnmovableID` INT UNSIGNED,
	`inGuildID` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare uClaimID int unsigned default NULL;

	select ID from claim_subjects where GuildID = inGuildID into subjID;
	select ID from unmovable_objects_claims where UnmovableObjectID = inUnmovableID into uClaimID;

	if(subjID is not NULL) then
		delete from claim_rules_unmovable where UnmovableClaimID = uClaimID and ClaimSubjectID = subjID;

		if(!exists(select * from claim_rules where ClaimSubjectID = subjID) and
			!exists(select * from claim_rules_unmovable where ClaimSubjectID = subjID)
		) then
			delete from claim_subjects where GuildID = inGuildID;
		end if;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteUnmovableSubject_role;
CREATE PROCEDURE `p_deleteUnmovableSubject_role`(
	`inUnmovableID` INT UNSIGNED,
	`inGuildRoleID` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare uClaimID int unsigned default NULL;
	
	select ID from claim_subjects where GuildRoleID = inGuildRoleID into subjID;
	select ID from unmovable_objects_claims where UnmovableObjectID = inUnmovableID into uClaimID;

	if(subjID is not NULL) then
		delete from claim_rules_unmovable where UnmovableClaimID = uClaimID and ClaimSubjectID = subjID;

		if(!exists(select * from claim_rules where ClaimSubjectID = subjID) and
			!exists(select * from claim_rules_unmovable where ClaimSubjectID = subjID)
		) then
			delete from claim_subjects where GuildRoleID = inGuildRoleID;
		end if;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteUnmovableSubject_standing;
CREATE PROCEDURE `p_deleteUnmovableSubject_standing`(
	`inUnmovableID` INT UNSIGNED,
	`inStandingTypeID` INT UNSIGNED
)
BEGIN
	declare subjID INT UNSIGNED default NULL;
	declare uClaimID int unsigned default NULL;
	
	select ID from claim_subjects where StandingTypeID = inStandingTypeID into subjID;
	select ID from unmovable_objects_claims where UnmovableObjectID = inUnmovableID into uClaimID;
	
	if(subjID is not NULL) then
		delete from claim_rules_unmovable where UnmovableClaimID = uClaimID and ClaimSubjectID = subjID;

		if(!exists(select * from claim_rules where ClaimSubjectID = subjID) and
			!exists(select * from claim_rules_unmovable where ClaimSubjectID = subjID)
		) then
			delete from claim_subjects where StandingTypeID = inStandingTypeID;
		end if;
	end if;
END;

DROP PROCEDURE IF EXISTS p_deleteGuild;
CREATE PROCEDURE `p_deleteGuild`(
	IN `inGuildID` INT UNSIGNED
)
BEGIN
	declare delGuildID int unsigned default NULL;

	declare exit handler for sqlexception
	begin
		rollback;
		resignal;
	end;

	start transaction;

	update `character` set GuildID = NULL, GuildRoleID = NULL where GuildID = inGuildID;

	UPDATE `outposts` SET OwnerGuildID = NULL WHERE OwnerGuildID = inGuildID;

	delete from claim_rules where ClaimSubjectID in (select ID from claim_subjects where GuildID = inGuildID)
		or ClaimID in (select ID from claims where GuildLandID in (select ID from guild_lands where GuildID = inGuildID));
	delete from claim_rules_unmovable where ClaimSubjectID in (select ID from claim_subjects where GuildID = inGuildID)
		or UnmovableClaimID in (select ID from unmovable_objects_claims where ClaimID in (select ID from claims where GuildLandID in (select ID from guild_lands where GuildID = inGuildID)));
	delete from unmovable_objects_claims where ClaimID in (select ID from claims where GuildLandID in (select ID from guild_lands where GuildID = inGuildID));
	delete from claim_subjects where GuildID = inGuildID;
	delete from claims where GuildLandID in (select ID from guild_lands where GuildID = inGuildID);
	delete from guild_lands where GuildID = inGuildID;
	delete from guild_standings where GuildID1 = inGuildID or GuildID2 = inGuildID;
	delete from guild_invites where GuildID = inGuildID;

	insert into deleted_guild_info
		(ExGuildID, GuildName, GuildTag)
		select ID, Name, GuildTag from guilds WHERE ID = inGuildID;
	set delGuildID = LAST_INSERT_ID();

	delete from guild_actions_queue where GuildID = inGuildID or OtherGuildID = inGuildID;
	update guild_actions_processed set GuildDeletedID = delGuildID, GuildID = NULL where GuildID = inGuildID;
	update guild_actions_processed set OtherGuildDeletedID = delGuildID, OtherGuildID = NULL where OtherGuildID = inGuildID;

	delete from guilds where ID = inGuildID;

	-- cleanup claim_subjects
	delete from claim_subjects where !exists(select * from claim_rules where ClaimSubjectID = claim_subjects.ID) and
		!exists(select * from claim_rules_unmovable where ClaimSubjectID = claim_subjects.ID);

	commit;

END;

DROP PROCEDURE IF EXISTS p_setUnmovableCustomName;
CREATE PROCEDURE `p_setUnmovableCustomName`(
	IN `inObjID` INT UNSIGNED,
	IN `inCustomName` VARCHAR(255)
)
BEGIN
	DECLARE customTextID INT UNSIGNED default NULL;

	if(CHAR_LENGTH(IFNULL(inCustomName, '')) > 0) then
		SET customTextID = f_insertCustomText(inCustomName);
	end if;
	
	update `unmovable_objects` set CustomNameID = customTextID where ID = inObjID;
END;

DROP PROCEDURE IF EXISTS p_setMovableCustomName;
CREATE PROCEDURE `p_setMovableCustomName`(
	IN `inObjID` INT UNSIGNED,
	IN `inCustomName` VARCHAR(255)
)
BEGIN
	DECLARE customTextID INT UNSIGNED default NULL;

	if(CHAR_LENGTH(IFNULL(inCustomName, '')) > 0) then
		SET customTextID = f_insertCustomText(inCustomName);
	end if;

	update `movable_objects` set CustomNameID = customTextID where ID = inObjID;
END;

-- access to horses IDs. Empty result set means error
DROP PROCEDURE IF EXISTS `p_issueIdRange_horses`;
CREATE PROCEDURE `p_issueIdRange_horses`
(
	in_serverID INT UNSIGNED,
	in_idCount INT UNSIGNED,
	in_isForce TINYINT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Return horses IDs which available for concrete server to insert'
BEGIN

declare rangeID, startID, endID, currFreeIdCount, currMaxUsedId, maxUsedId int unsigned default 0;
declare maxIssuedId int unsigned default NULL;
declare errorFlag, cursorDone tinyint unsigned default FALSE;

declare rangeCursor cursor for
(
	select ID, RangeStartID, RangeEndID
	from `horses_server_id_ranges`
	where ServerID = in_serverID
	order by RangeStartID -- ordering for consecutive ID using
	for update
);
declare continue handler for not found set cursorDone = TRUE;

-- mysql does not stop procedure execution on errors, so do it manually
declare continue handler for sqlexception
begin
	-- "leave this_sp;" can't be called here, so use flag
	set errorFlag = TRUE;
end;

start transaction;

-- We using the horses_server_id_ranges_lock table like a mutex - lock it at transaction start,
-- and release it on commit/rollback. This ugly solution provides us a 100% deadlock protection when
-- this procedure runs simultaneously from several sessions.
-- If you don't care about deadlocks, you can simply skip this insert - all locking logic below
-- still provide data consistent and prevent any range intersections (but don't save you from deadlocks)
insert into `horses_server_id_ranges_lock` (ID, IsLocked) values (1, 1)
	on duplicate key update IsLocked=1;

-- Get max issued ID before we delete any range.
-- This operation give us currently maximum claimed ID with blocking from same queries and
-- from inserting into the gap just before max(RangeEndID) and after max(RangeEndID)
select max(RangeEndID)
	into maxIssuedId
	from `horses_server_id_ranges`
	for update;

-- parse existing ranges when we are not forced to insert new range
if(in_isForce = 0) then
	open rangeCursor;

	-- get max used id from all ranges and block these ranges from inserts
	range_loop: loop
		fetch rangeCursor into rangeID, startID, endID;
		if(cursorDone) then
			leave range_loop;
		end if;

		select max(ID)
			into currMaxUsedId
			from `horses`
			where ID >= startID and ID <= endID
			for update;

		if(ifnull(currMaxUsedId, 0) > maxUsedId) then
			set maxUsedId = currMaxUsedId;
		end if;
	end loop;
	close rangeCursor;

	-- re-use cursor for iterate thru all exists server ranges again and check it to exceed maxUsedId
	set cursorDone = FALSE;
	open rangeCursor;
	range_loop: loop
		fetch rangeCursor into rangeID, startID, endID;
		if(cursorDone) then
			leave range_loop;
		end if;

		-- at first validate range
		if(startID > endID) then
			-- delete invalid range
			delete from `horses_server_id_ranges`
				where ID = rangeID;
		else
			-- range is valid
			if(maxUsedId < startID) then
				-- range have no any used ids
				set currFreeIdCount = (currFreeIdCount + (endID - startID) + 1);
			elseif(maxUsedId >= startID and maxUsedId < endID) then
				-- range have some used ids
				set currFreeIdCount = (currFreeIdCount + (endID - maxUsedId));
				update `horses_server_id_ranges`
					set RangeStartID = (maxUsedId + 1)
						-- , RangeEndID = endID
					where ID = rangeID;
			else -- if(maxUsedId >= endID) then
				-- range is full or maxUsedId is out of range bounds
				delete from `horses_server_id_ranges`
					where ID = rangeID;
			end if;
		end if;

	end loop;

	close rangeCursor;
end if;

if(currFreeIdCount < in_idCount or in_isForce > 0) then
	-- reserve new ID range

	-- compatibility with old auto_increment IDs
	if(maxIssuedId is null) then
		select max(ID)
			into maxIssuedId
			from `horses`
			for update;
	end if;

	-- We reserve new range with full size of in_idCount. This save us from inserting small ranges
	-- each time this procedure called
	set startID = (ifnull(maxIssuedId, 0) + 1);
	set endID = (startID + in_idCount - 1);

	-- remember new range
	insert into `horses_server_id_ranges`
		(ServerID, RangeStartID, RangeEndID)
		values (in_serverID, startID, endID);
end if;

-- return result
if(!errorFlag) then
	select RangeStartID, RangeEndID
		from `horses_server_id_ranges`
		where ServerID = in_serverID
		order by RangeStartID;

	commit;
else -- in case of error
	rollback;
end if;

END;


-- mark ID as used. Call it each time you are going to insert new ID into horses
DROP PROCEDURE IF EXISTS `p_occupyId_horses`;
CREATE PROCEDURE `p_occupyId_horses`
(
	in_serverID INT UNSIGNED,
	in_id INT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Modifies horses ID ranges for concrete server so given ID will never be used again'
BEGIN

update horses_server_id_ranges
set RangeStartID = (in_id + 1)
where ServerID = in_serverID and
	in_id >= RangeStartID and in_id <= RangeEndID;

END;


-- check consistent of horses_server_id_ranges
DROP PROCEDURE IF EXISTS `p_dbg_checkIdRangeConsistant_horses`;
DROP PROCEDURE IF EXISTS `p_dbg_checkIdRangeConsistent_horses`;
CREATE PROCEDURE `p_dbg_checkIdRangeConsistent_horses` ()
	LANGUAGE SQL
	NOT DETERMINISTIC
	COMMENT 'Check consistent of content of horses_server_id_ranges table. OK when no rows returned, else shows range intersections'
BEGIN

select * from `horses_server_id_ranges` r1
where exists (
	select * from `horses_server_id_ranges` r2 where r2.ID != r1.ID
	and (
		(r1.RangeEndID between r2.RangeStartID and r2.RangeEndID) or
		(r1.RangeStartID between r2.RangeStartID and r2.RangeEndID) or
		(r1.RangeStartID <= r2.RangeStartID and r1.RangeEndID >= r2.RangeEndID)
	)
);

END;

DROP FUNCTION IF EXISTS f_dayEnd;
DROP FUNCTION IF EXISTS f_dayNumber;
DROP FUNCTION IF EXISTS f_dayStart;


DROP PROCEDURE IF EXISTS `p_createHorseObject`;
CREATE PROCEDURE `p_createHorseObject`(
	`in_ID` INT UNSIGNED,
	`in_TypeID` INT UNSIGNED,
	`in_Quality` TINYINT UNSIGNED,
	`in_HP` INT,
	`in_GeoID` INT UNSIGNED,
	`in_Altitude` SMALLINT UNSIGNED,
	`in_OffsetX` SMALLINT,
	`in_OffsetY` SMALLINT,
	`in_OffsetZ` INT,
	`in_TurnAngle` SMALLINT,
	`in_MountedCharacterID` INT UNSIGNED,
	`in_OwnerID` INT UNSIGNED,
	`inCreatedDurability` SMALLINT UNSIGNED,
	`inDurability` SMALLINT UNSIGNED
)
	MODIFIES SQL DATA
	NOT DETERMINISTIC
BEGIN
	insert into horses
		(          ID, ObjectTypeID, Quality,    HP,    GeoID,    GeoAlt,      OffsetX,    OffsetY,    OffsetZ,    TurnAngle,    MountedCharacterID,    OwnerID,    CreatedDurability,   Durability  )
		values (in_ID,    in_TypeID, in_Quality, in_HP, in_GeoID, in_Altitude, in_OffsetX, in_OffsetY, in_OffsetZ, in_TurnAngle, in_MountedCharacterID, in_OwnerID, inCreatedDurability, inDurability);
END;


DROP PROCEDURE IF EXISTS p_deleteHorseObject;
CREATE PROCEDURE `p_deleteHorseObject`(
	IN `inID` INT UNSIGNED
)
BEGIN
	update `movable_objects` set CarrierHorseID = null where CarrierHorseID = inID;

	DELETE FROM horses WHERE ID = inID;
END;

DROP PROCEDURE IF EXISTS `f_deleteItem`;
CREATE PROCEDURE `f_deleteItem`(inItemID INT UNSIGNED)
BEGIN

	DECLARE _featureID INT UNSIGNED default NULL;
	DECLARE _blueprintID INT UNSIGNED default NULL;
	DECLARE _movableID INT UNSIGNED default NULL;

	SELECT FeatureID FROM items WHERE ID = inItemID INTO _featureID;
	-- DELETE FROM equipment_slots WHERE ItemID = inItemID;
	UPDATE equipment_slots set ItemID = NULL WHERE ItemID = inItemID;
	DELETE FROM item_effects WHERE ItemID = inItemID;
	DELETE FROM stables_pens WHERE ItemID = inItemID;

	SELECT ID FROM movable_objects WHERE DroppedItemID = inItemID INTO _movableID;
	if( _movableID is not NULL) then
		UPDATE movable_objects SET DroppedItemID = NULL WHERE ID = _movableID;
		CALL p_deleteMovableObject(_movableID);
	end if;

	DELETE FROM items WHERE ID = inItemID;

	if( _featureID is not NULL) then
		SELECT BlueprintID FROM features WHERE ID =_featureID INTO _blueprintID;
		DELETE FROM features WHERE `ID`=_featureID;
		if(_blueprintID is not NULL) then
			DELETE FROM `character_blueprints` WHERE BlueprintID=_blueprintID;
			DELETE FROM `blueprint_requirements` WHERE BlueprintID=_blueprintID;
			DELETE FROM `blueprints` WHERE ID=_blueprintID;
		end if;
	end if;

END;

DROP PROCEDURE IF EXISTS `p_allocate_equipment_slots`;
CREATE PROCEDURE `p_allocate_equipment_slots` (
	`in_charID` INT UNSIGNED
)
BEGIN

	insert ignore equipment_slots (CharacterID, Slot)
		select in_charID, t.slot
		from (
			select 1 as slot union all
			select 2 union all
			select 3 union all
			select 4 union all
			select 5 union all
			select 6 union all
			select 7 union all
			select 8 union all
			select 9 union all
			select 10 union all
			select 11 union all
			select 12 union all
			select 13 union all
			select 14 union all
			select 15 union all
			select 16
		) as t;

END;

DROP FUNCTION IF EXISTS `f_getServerUUID`;
CREATE FUNCTION `f_getServerUUID`()
 RETURNS char(36)
 DETERMINISTIC
BEGIN
 DECLARE s_uuid char(36) DEFAULT NULL;
 SELECT `Uuid` FROM server_uuid WHERE ID = 1 into s_uuid;
 RETURN s_uuid;
END;


-- access to movable_objects IDs. Empty result set means error
DROP PROCEDURE IF EXISTS `p_issueIdRange_movable_objects`;
CREATE PROCEDURE `p_issueIdRange_movable_objects`
(
	in_serverID INT UNSIGNED,
	in_idCount INT UNSIGNED,
	in_isForce TINYINT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Return movable_objects IDs which available for concrete server to insert'
BEGIN

declare rangeID, startID, endID, currFreeIdCount, currMaxUsedId, maxUsedId int unsigned default 0;
declare maxIssuedId int unsigned default NULL;
declare errorFlag, cursorDone tinyint unsigned default FALSE;

declare rangeCursor cursor for
(
	select ID, RangeStartID, RangeEndID
	from `movable_objects_server_id_ranges`
	where ServerID = in_serverID
	order by RangeStartID -- ordering for consecutive ID using
	for update
);
declare continue handler for not found set cursorDone = TRUE;

-- mysql does not stop procedure execution on errors, so do it manually
declare continue handler for sqlexception
begin
	-- "leave this_sp;" can't be called here, so use flag
	set errorFlag = TRUE;
end;

start transaction;

-- We using the movable_objects_server_id_ranges_lock table like a mutex - lock it at transaction start,
-- and release it on commit/rollback. This ugly solution provides us a 100% deadlock protection when
-- this procedure runs simultaneously from several sessions.
-- If you don't care about deadlocks, you can simply skip this insert - all locking logic below
-- still provide data consistent and prevent any range intersections (but don't save you from deadlocks)
insert into `movable_objects_server_id_ranges_lock` (ID, IsLocked) values (1, 1)
	on duplicate key update IsLocked=1;

-- Get max issued ID before we delete any range.
-- This operation give us currently maximum claimed ID with blocking from same queries and
-- from inserting into the gap just before max(RangeEndID) and after max(RangeEndID)
select max(RangeEndID)
	into maxIssuedId
	from `movable_objects_server_id_ranges`
	for update;

-- parse existing ranges when we are not forced to insert new range
if(in_isForce = 0) then
	open rangeCursor;

	-- get max used id from all ranges and block these ranges from inserts
	range_loop: loop
		fetch rangeCursor into rangeID, startID, endID;
		if(cursorDone) then
			leave range_loop;
		end if;

		select max(ID)
			into currMaxUsedId
			from `movable_objects`
			where ID >= startID and ID <= endID
			for update;

		if(ifnull(currMaxUsedId, 0) > maxUsedId) then
			set maxUsedId = currMaxUsedId;
		end if;
	end loop;
	close rangeCursor;

	-- re-use cursor for iterate thru all exists server ranges again and check it to exceed maxUsedId
	set cursorDone = FALSE;
	open rangeCursor;
	range_loop: loop
		fetch rangeCursor into rangeID, startID, endID;
		if(cursorDone) then
			leave range_loop;
		end if;

		-- at first validate range
		if(startID > endID) then
			-- delete invalid range
			delete from `movable_objects_server_id_ranges`
				where ID = rangeID;
		else
			-- range is valid
			if(maxUsedId < startID) then
				-- range have no any used ids
				set currFreeIdCount = (currFreeIdCount + (endID - startID) + 1);
			elseif(maxUsedId >= startID and maxUsedId < endID) then
				-- range have some used ids
				set currFreeIdCount = (currFreeIdCount + (endID - maxUsedId));
				update `movable_objects_server_id_ranges`
					set RangeStartID = (maxUsedId + 1)
						-- , RangeEndID = endID
					where ID = rangeID;
			else -- if(maxUsedId >= endID) then
				-- range is full or maxUsedId is out of range bounds
				delete from `movable_objects_server_id_ranges`
					where ID = rangeID;
			end if;
		end if;

	end loop;

	close rangeCursor;
end if;

if(currFreeIdCount < in_idCount or in_isForce > 0) then
	-- reserve new ID range

	-- compatibility with old auto_increment IDs
	if(maxIssuedId is null) then
		select max(ID)
			into maxIssuedId
			from `movable_objects`
			for update;
	end if;

	-- We reserve new range with full size of in_idCount. This save us from inserting small ranges
	-- each time this procedure called
	set startID = (ifnull(maxIssuedId, 0) + 1);
	set endID = (startID + in_idCount - 1);

	-- remember new range
	insert into `movable_objects_server_id_ranges`
		(ServerID, RangeStartID, RangeEndID)
		values (in_serverID, startID, endID);
end if;

-- return result
if(!errorFlag) then
	select RangeStartID, RangeEndID
		from `movable_objects_server_id_ranges`
		where ServerID = in_serverID
		order by RangeStartID;

	commit;
else -- in case of error
	rollback;
end if;

END;

-- mark ID as used. Call it each time you are going to insert new ID into movable_objects
DROP PROCEDURE IF EXISTS `p_occupyId_movable_objects`;
CREATE PROCEDURE `p_occupyId_movable_objects`
(
	in_serverID INT UNSIGNED,
	in_id INT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Modifies movable_objects ID ranges for concrete server so given ID will never be used again'
BEGIN

update movable_objects_server_id_ranges
set RangeStartID = (in_id + 1)
where ServerID = in_serverID and
	in_id >= RangeStartID and in_id <= RangeEndID;

END;


-- access to unmovable_objects IDs. Empty result set means error
DROP PROCEDURE IF EXISTS `p_issueIdRange_unmovable_objects`;
CREATE PROCEDURE `p_issueIdRange_unmovable_objects`
(
	in_serverID INT UNSIGNED,
	in_idCount INT UNSIGNED,
	in_isForce TINYINT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Return unmovable_objects IDs which available for concrete server to insert'
BEGIN

declare rangeID, startID, endID, currFreeIdCount, currMaxUsedId, maxUsedId int unsigned default 0;
declare maxIssuedId int unsigned default NULL;
declare errorFlag, cursorDone tinyint unsigned default FALSE;

declare rangeCursor cursor for
(
	select ID, RangeStartID, RangeEndID
	from `unmovable_objects_server_id_ranges`
	where ServerID = in_serverID
	order by RangeStartID -- ordering for consecutive ID using
	for update
);
declare continue handler for not found set cursorDone = TRUE;

-- mysql does not stop procedure execution on errors, so do it manually
declare continue handler for sqlexception
begin
	-- "leave this_sp;" can't be called here, so use flag
	set errorFlag = TRUE;
end;

start transaction;

-- We using the unmovable_objects_server_id_ranges_lock table like a mutex - lock it at transaction start,
-- and release it on commit/rollback. This ugly solution provides us a 100% deadlock protection when
-- this procedure runs simultaneously from several sessions.
-- If you don't care about deadlocks, you can simply skip this insert - all locking logic below
-- still provide data consistent and prevent any range intersections (but don't save you from deadlocks)
insert into `unmovable_objects_server_id_ranges_lock` (ID, IsLocked) values (1, 1)
	on duplicate key update IsLocked=1;

-- Get max issued ID before we delete any range.
-- This operation give us currently maximum claimed ID with blocking from same queries and
-- from inserting into the gap just before max(RangeEndID) and after max(RangeEndID)
select max(RangeEndID)
	into maxIssuedId
	from `unmovable_objects_server_id_ranges`
	for update;

-- parse existing ranges when we are not forced to insert new range
if(in_isForce = 0) then
	open rangeCursor;

	-- get max used id from all ranges and block these ranges from inserts
	range_loop: loop
		fetch rangeCursor into rangeID, startID, endID;
		if(cursorDone) then
			leave range_loop;
		end if;

		select max(ID)
			into currMaxUsedId
			from `unmovable_objects`
			where ID >= startID and ID <= endID
			for update;

		if(ifnull(currMaxUsedId, 0) > maxUsedId) then
			set maxUsedId = currMaxUsedId;
		end if;
	end loop;
	close rangeCursor;

	-- re-use cursor for iterate thru all exists server ranges again and check it to exceed maxUsedId
	set cursorDone = FALSE;
	open rangeCursor;
	range_loop: loop
		fetch rangeCursor into rangeID, startID, endID;
		if(cursorDone) then
			leave range_loop;
		end if;

		-- at first validate range
		if(startID > endID) then
			-- delete invalid range
			delete from `unmovable_objects_server_id_ranges`
				where ID = rangeID;
		else
			-- range is valid
			if(maxUsedId < startID) then
				-- range have no any used ids
				set currFreeIdCount = (currFreeIdCount + (endID - startID) + 1);
			elseif(maxUsedId >= startID and maxUsedId < endID) then
				-- range have some used ids
				set currFreeIdCount = (currFreeIdCount + (endID - maxUsedId));
				update `unmovable_objects_server_id_ranges`
					set RangeStartID = (maxUsedId + 1)
						-- , RangeEndID = endID
					where ID = rangeID;
			else -- if(maxUsedId >= endID) then
				-- range is full or maxUsedId is out of range bounds
				delete from `unmovable_objects_server_id_ranges`
					where ID = rangeID;
			end if;
		end if;

	end loop;

	close rangeCursor;
end if;

if(currFreeIdCount < in_idCount or in_isForce > 0) then
	-- reserve new ID range

	-- compatibility with old auto_increment IDs
	if(maxIssuedId is null) then
		select max(ID)
			into maxIssuedId
			from `unmovable_objects`
			for update;
	end if;

	-- We reserve new range with full size of in_idCount. This save us from inserting small ranges
	-- each time this procedure called
	set startID = (ifnull(maxIssuedId, 0) + 1);
	set endID = (startID + in_idCount - 1);

	-- remember new range
	insert into `unmovable_objects_server_id_ranges`
		(ServerID, RangeStartID, RangeEndID)
		values (in_serverID, startID, endID);
end if;

-- return result
if(!errorFlag) then
	select RangeStartID, RangeEndID
		from `unmovable_objects_server_id_ranges`
		where ServerID = in_serverID
		order by RangeStartID;

	commit;
else -- in case of error
	rollback;
end if;

END;


-- mark ID as used. Call it each time you are going to insert new ID into unmovable_objects
DROP PROCEDURE IF EXISTS `p_occupyId_unmovable_objects`;
CREATE PROCEDURE `p_occupyId_unmovable_objects`
(
	in_serverID INT UNSIGNED,
	in_id INT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Modifies unmovable_objects ID ranges for concrete server so given ID will never be used again'
BEGIN

update unmovable_objects_server_id_ranges
set RangeStartID = (in_id + 1)
where ServerID = in_serverID and
	in_id >= RangeStartID and in_id <= RangeEndID;

END;


DROP PROCEDURE IF EXISTS `sp_checkForeignKeys`;
CREATE PROCEDURE `sp_checkForeignKeys`(
	`in_TableName` varchar(128),
	`in_StoreDetailedResult` tinyint unsigned, -- 1/0
	`in_ClearOldResults` tinyint unsigned -- 1/0
)
	COMMENT 'Check consistency of foreign keys which references to/from in_TableName table. Return 1 when data is consistent. If check failed, return 0 and write mistatch rows info into _invalid_foreign_keys table (when in_StoreDetailedResult parameter is 1)'
BEGIN

	declare table_name_var varchar(64) default NULL;
	declare column_name_var varchar(64) default NULL;
	declare constraint_name_var varchar(128) default NULL;
	declare referenced_table_name_var varchar(64) default NULL;
	declare referenced_column_name_var varchar(64) default NULL;

	declare checkResult tinyint unsigned default TRUE;
	declare cursorDone tinyint unsigned default FALSE;

	declare fk_cur cursor for
	(
		select `TABLE_NAME`, `COLUMN_NAME`, `CONSTRAINT_NAME`, `REFERENCED_TABLE_NAME`, `REFERENCED_COLUMN_NAME`
		from `information_schema`.`KEY_COLUMN_USAGE`
		where `TABLE_SCHEMA` = database()
			-- and `CONSTRAINT_SCHEMA` = database()
			and `REFERENCED_TABLE_SCHEMA` = database()
			and (`TABLE_NAME` = in_TableName collate utf8_unicode_ci or `REFERENCED_TABLE_NAME` = in_TableName collate utf8_unicode_ci) -- check both: references to our table, and references of our table to other ones
	);
	declare continue handler for not found set cursorDone = TRUE;

	-- recreate table if we need to store results
	if(in_StoreDetailedResult > 0) then
		if(!sf_isTableExists('_invalid_foreign_keys')) then
			create table _invalid_foreign_keys(
				`ID` int unsigned NOT NULL AUTO_INCREMENT,
				`TableName` varchar(64) NOT NULL,
				`ColumnName` varchar(64) NOT NULL,
				`ConstraintName` varchar(128) NOT NULL,
				`ReferencedTableName` varchar(64) NOT NULL,
				`ReferencedColumnName` varchar(64) NOT NULL,
				`InvalidKeyCount` int unsigned NOT NULL,
				`InvalidKeySql` varchar(2048) NOT NULL,
				PRIMARY KEY (`ID`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
		elseif(in_ClearOldResults > 0) then
			truncate table _invalid_foreign_keys;
		end if;
	end if;

	-- iterate thru all FKs
	open fk_cur;
	fk_loop: loop
		fetch fk_cur into
			table_name_var,
			column_name_var,
			constraint_name_var,
			referenced_table_name_var,
			referenced_column_name_var;

		if(cursorDone) then
			leave fk_loop;
		end if;

		-- check if referred table have all values form referring table
		set @from_qs = concat('FROM `', table_name_var, '` AS REFERRING ',
			'LEFT JOIN `', referenced_table_name_var, '` AS REFERRED ',
			'ON (REFERRING.`', column_name_var, '` = REFERRED.`', referenced_column_name_var, '`) ',
			'WHERE REFERRING.`', column_name_var, '` IS NOT NULL ',
			'AND REFERRED.`', referenced_column_name_var, '` IS NULL');

		set @qs = concat('SELECT COUNT(*) ', @from_qs, ' INTO @invalid_key_count;');

		prepare fk_stmt from @qs;
		execute fk_stmt;

		if(@invalid_key_count > 0) then
			-- if FK mismatches found, change result status
			set checkResult = FALSE;

			-- remember failed FK
			if(in_StoreDetailedResult > 0) then
				insert into _invalid_foreign_keys
				set
					TableName = table_name_var,
					ColumnName = column_name_var,
					ConstraintName = constraint_name_var,
					ReferencedTableName = referenced_table_name_var,
					ReferencedColumnName = referenced_column_name_var,
					InvalidKeyCount = @invalid_key_count,
					InvalidKeySql = CONCAT('SELECT REFERRING.`', column_name_var, '` AS "Invalid: ', column_name_var, '", REFERRING.* ', @from_qs, ';');
			end if;
		end if;

		deallocate prepare fk_stmt;
	end loop;

	select checkResult as `FK_Valid`;
END;

-- check consistent of movable_objects_server_id_ranges
DROP PROCEDURE IF EXISTS `p_dbg_checkIdRangeConsistant_movable_objects`;
DROP PROCEDURE IF EXISTS `p_dbg_checkIdRangeConsistent_movable_objects`;
CREATE PROCEDURE `p_dbg_checkIdRangeConsistent_movable_objects`()
    COMMENT 'Check consistent of content of movable_objects_server_id_ranges table. OK when no rows returned, else shows range intersections'
BEGIN

	select * from `movable_objects_server_id_ranges` r1
	where exists (
		select * from `movable_objects_server_id_ranges` r2 where r2.ID != r1.ID
		and (
			(r1.RangeEndID between r2.RangeStartID and r2.RangeEndID) or
			(r1.RangeStartID between r2.RangeStartID and r2.RangeEndID) or
			(r1.RangeStartID <= r2.RangeStartID and r1.RangeEndID >= r2.RangeEndID)
		)
	);

END;

-- check consistent of unmovable_objects_server_id_ranges
DROP PROCEDURE IF EXISTS `p_dbg_checkIdRangeConsistant_unmovable_objects`;
DROP PROCEDURE IF EXISTS `p_dbg_checkIdRangeConsistent_unmovable_objects`;
CREATE PROCEDURE `p_dbg_checkIdRangeConsistant_unmovable_objects`()
    COMMENT 'Check consistant of content of unmovable_objects_server_id_ranges table. OK when no rows returned, else shows range intersections'
BEGIN

	select * from `unmovable_objects_server_id_ranges` r1
	where exists (
		select * from `unmovable_objects_server_id_ranges` r2 where r2.ID != r1.ID
		and (
			(r1.RangeEndID between r2.RangeStartID and r2.RangeEndID) or
			(r1.RangeStartID between r2.RangeStartID and r2.RangeEndID) or
			(r1.RangeStartID <= r2.RangeStartID and r1.RangeEndID >= r2.RangeEndID)
		)
	);

END;


DROP PROCEDURE IF EXISTS p_deleteUnmovableObject;
CREATE PROCEDURE `p_deleteUnmovableObject`(
	in_ID INT UNSIGNED
)
BEGIN
	declare cID int unsigned default null;
	declare scID int unsigned default null;

	select RootContainerID
		from unmovable_objects
		where ID = in_ID
		into cID
		for update;

	select SecondaryContainerID
		from `outposts`
		where UnmovableObjectID = in_ID
		into scID
		for update;

	-- delete object
	DELETE FROM stables_logs WHERE UnmovableObjectID = in_ID;
	DELETE FROM stables_pens WHERE UnmovableObjectID = in_ID;
	DELETE FROM stables_data WHERE UnmovableObjectID = in_ID;
	UPDATE `character` SET BindedObjectID=null WHERE BindedObjectID = in_ID;
	UPDATE `character` SET RallyObjectID=null WHERE RallyObjectID = in_ID;
	DELETE FROM `working_containers` WHERE UnmovableObjectID = in_ID;
	DELETE FROM `unmovable_objects_requirements` WHERE UnmovableObjectID = in_ID;
	Delete from claim_rules_unmovable where UnmovableClaimID in (select ID from unmovable_objects_claims where UnmovableObjectID = in_ID);
	DELETE FROM unmovable_objects_claims WHERE UnmovableObjectID = in_ID;
	DELETE FROM `outposts` WHERE UnmovableObjectID = in_ID;
	DELETE FROM unmovable_objects WHERE ID = in_ID;

	-- delete containers
	if(cID is not null) then
		CALL f_deleteContainer(cID);
	end if;

	if(scID is not null) then
		CALL f_deleteContainer(scID);
	end if;
END;


DROP FUNCTION IF EXISTS `f_addGeoPatch`;
CREATE FUNCTION `f_addGeoPatch`(
	`in_VersionID` INT UNSIGNED, -- 0 for first change
	`in_ChangeIdx` INT UNSIGNED, -- starts from 1
	`in_IsServerOnly` TINYINT UNSIGNED,
	`in_TerID` INT UNSIGNED,
	`in_Action` TINYINT UNSIGNED,
	`in_GeoDataID` INT UNSIGNED,
	`in_Altitude` SMALLINT UNSIGNED,
	`in_Substance` TINYINT UNSIGNED,
	`in_LevelFlags` TINYINT UNSIGNED,
	`in_Quantity` SMALLINT UNSIGNED,
	`in_Quality` TINYINT UNSIGNED
) RETURNS INT UNSIGNED
	MODIFIES SQL DATA
	NOT DETERMINISTIC
BEGIN

	declare versionID, dummyTerID INT UNSIGNED default NULL;

	if(in_ChangeIdx = 1) then
		/* get current objects version for this terrain (only for first change) */
		select GeoVersion, ID from terrain_blocks
			where ID = in_TerID limit 1
			into versionID, dummyTerID
			for update;

		/* check terrain */
		if(dummyTerID is null) then
			return NULL;
		end if;

		/* increment version if this is initial change */
		set versionID = (ifnull(versionID, 0) + 1);

		/* update version for first change */
		update terrain_blocks
			set GeoVersion = versionID
			where ID = in_TerID;
	else
		set versionID = in_VersionID;
	end if;

	/* insert geo data */
	insert into geo_patch
		(     `TerID`,  `Version`, `ChangeIndex`, `IsServerOnly`,  `Action`,  `GeoDataID`,  `Altitude`,  `Substance`,  `LevelFlags`,  `Quantity`,  `Quality`)
		values(in_TerID, versionID, in_ChangeIdx,  in_IsServerOnly, in_Action, in_GeoDataID, in_Altitude, in_Substance, in_LevelFlags, in_Quantity, in_Quality);

	return versionID;

END;

DROP PROCEDURE IF EXISTS p_addHeraldry;
CREATE PROCEDURE `p_addHeraldry`(
	`in_BackgroundIndex` TINYINT UNSIGNED,
	`in_BackgroundColorIndex1` TINYINT UNSIGNED,
	`in_BackgroundColorIndex2` TINYINT UNSIGNED,

	`inCharge1_isValid` TINYINT UNSIGNED,
	`inCharge1_SymbolIndex` TINYINT UNSIGNED,
	`inCharge1_ColorIndex` TINYINT UNSIGNED,
	`inCharge1_Position` VARCHAR(64),
	`inCharge1_Size` VARCHAR(64),

	`inCharge2_isValid` TINYINT UNSIGNED,
	`inCharge2_SymbolIndex` TINYINT UNSIGNED,
	`inCharge2_ColorIndex` TINYINT UNSIGNED,
	`inCharge2_Position` VARCHAR(64),
	`inCharge2_Size` VARCHAR(64)
)
	COMMENT 'Return NULL when error occured, 0 when heraldry duplicate found, new heraldries.ID otherwise.'
BEGIN
	declare newChargeID1, newChargeID2 int unsigned default null;
	declare newHeraldryID int unsigned default 0;
	declare duplicateHeraldryID int unsigned default null;

	declare exit handler for sqlexception
	begin
		rollback;
		resignal;
	end;

	start transaction;

	-- try to find existing charges at first
	if(inCharge1_isValid > 0) then
		set newChargeID1 = (select ID
			from heraldic_charges
			where SymbolIndex = inCharge1_SymbolIndex
				and ColorIndex = inCharge1_ColorIndex
				and Position = inCharge1_Position
				and Size = inCharge1_Size
			limit 1);

		if(newChargeID1 is null) then
			-- insert new charge1
			insert into heraldic_charges
				(SymbolIndex, ColorIndex, Position, Size)
				values (inCharge1_SymbolIndex, inCharge1_ColorIndex, inCharge1_Position, inCharge1_Size);
			set newChargeID1 = LAST_INSERT_ID();
		end if;
	end if;

	if(inCharge2_isValid > 0) then
		set newChargeID2 = (select ID
			from heraldic_charges
			where SymbolIndex = inCharge2_SymbolIndex
				and ColorIndex = inCharge2_ColorIndex
				and Position = inCharge2_Position
				and Size = inCharge2_Size);

		if(newChargeID2 is null) then
			-- insert new charge2
			insert into heraldic_charges
				(SymbolIndex, ColorIndex, Position, Size)
				values (inCharge2_SymbolIndex, inCharge2_ColorIndex, inCharge2_Position, inCharge2_Size);
			set newChargeID2 = LAST_INSERT_ID();
		end if;
	end if;

	-- check if charges are not the same
	if((newChargeID1 != newChargeID2) or (newChargeID1 is null or newChargeID2 is null)) then
		-- check heraldry uniqueness with all charges variations
		if(newChargeID1 is null and newChargeID2 is null) then
			-- when both charges is not set
			set duplicateHeraldryID = (
				select ID from heraldries
				where BackgroundIndex = in_BackgroundIndex
					and BackgroundColorIndex1 = in_BackgroundColorIndex1
					and BackgroundColorIndex2 = in_BackgroundColorIndex2
					and ChargeID1 is null
					and ChargeID2 is null
				limit 1
			);
		elseif(newChargeID1 is null or newChargeID2 is null) then
			-- when one charge is not set
			set duplicateHeraldryID = (
				select ID from heraldries
				where BackgroundIndex = in_BackgroundIndex
					and BackgroundColorIndex1 = in_BackgroundColorIndex1
					and BackgroundColorIndex2 = in_BackgroundColorIndex2
					and
					(
						(ChargeID1 is null and (ChargeID2 = newChargeID1 or ChargeID2 = newChargeID2))
						or
						(ChargeID2 is null and (ChargeID1 = newChargeID1 or ChargeID1 = newChargeID2))
					)
				limit 1
			);
		else
			-- when both charges are set
			set duplicateHeraldryID = (
				select ID from heraldries
				where BackgroundIndex = in_BackgroundIndex
					and BackgroundColorIndex1 = in_BackgroundColorIndex1
					and BackgroundColorIndex2 = in_BackgroundColorIndex2
					and
					(
						(ChargeID1 = newChargeID1 and ChargeID2 = newChargeID2)
						or
						(ChargeID1 = newChargeID2 and ChargeID2 = newChargeID1)
					)
				limit 1
			);
		end if;

		if(duplicateHeraldryID is null) then
			insert into heraldries
				(BackgroundIndex, BackgroundColorIndex1, BackgroundColorIndex2, ChargeID1, ChargeID2)
				values (in_BackgroundIndex, in_BackgroundColorIndex1, in_BackgroundColorIndex2, newChargeID1, newChargeID2);

			set newHeraldryID = LAST_INSERT_ID();
		end if;
	end if;

	if(newHeraldryID > 0) then
		commit;
	else
		rollback;
	end if;

  select newHeraldryID as `ID`, ifnull(duplicateHeraldryID, 0) as `DuplicateHeraldryID`;
END;

DROP FUNCTION IF EXISTS `f_addForestPatch`;
CREATE FUNCTION `f_addForestPatch`(
	`in_TerID` INT UNSIGNED,
	`in_Action` TINYINT UNSIGNED,
	`in_GeoDataID` INT UNSIGNED,
	`in_SubcellMask` TINYINT UNSIGNED,
	`in_TreeType` TINYINT UNSIGNED,
	`in_TreeHealth` TINYINT UNSIGNED,
	`in_TreePlantMethod` TINYINT UNSIGNED,
	`in_AddTime` INT UNSIGNED
) RETURNS int(10) unsigned
	MODIFIES SQL DATA
BEGIN

	declare versionID, dummyTerID INT UNSIGNED default NULL;

	/* get current objects version for this terrain */
	select ForestVersion, ID from terrain_blocks
		where ID = in_TerID limit 1
		into versionID, dummyTerID
		for update;

	/* check terrain */
	if(dummyTerID is null) then
		return NULL;
	end if;

	/* increment version */
	set versionID = (ifnull(versionID, 0) + 1);

	/* make changes */
	insert into forest_patch
		(     `TerID`,  `Version`, `Action`,  `GeoDataID`,  `SubcellMask`,   `TreeType`, `TreeHealth`,  `TreePlantMethod`,  `AddTime`)
		values(in_TerID, versionID, in_Action, in_GeoDataID, in_SubcellMask, in_TreeType, in_TreeHealth, in_TreePlantMethod, in_AddTime);

	update terrain_blocks
		set ForestVersion = versionID
		where ID = in_TerID;

	return versionID;

END;

DROP PROCEDURE IF EXISTS f_deleteMovableObject;
DROP PROCEDURE IF EXISTS p_deleteMovableObject;
CREATE PROCEDURE `p_deleteMovableObject`(
	IN `inID` INT UNSIGNED
)
BEGIN
	DECLARE _id INT UNSIGNED default NULL;
	declare cID INT UNSIGNED DEFAULT NULL;
	DECLARE done INT DEFAULT FALSE;
	DECLARE cur CURSOR FOR SELECT ID FROM movable_objects WHERE CarrierMovableID = inID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN cur;
	read_loop: LOOP
		FETCH cur INTO _id;
		if done then
			LEAVE read_loop;
		end if;
		CALL p_deleteMovableObject(_id);
	END LOOP;
	CLOSE cur;
	
	SELECT RootContainerID FROM movable_objects WHERE ID = inID INTO cID FOR UPDATE;

	DELETE FROM `working_containers` WHERE MovableObjectID = inID;

	DELETE FROM movable_objects WHERE ID = inID;

	if(cID is not null) then
		CALL f_deleteContainer( cID);
	end if;

END;

DROP PROCEDURE IF EXISTS p_transferMovableObjItems;
CREATE PROCEDURE `p_transferMovableObjItems`(
	IN `in_sourceMovableObjID` INT UNSIGNED,
	IN `in_targetUnmovableObjID` INT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Moves inventory items from movable object to unmovable object'
BEGIN

	declare var_sourceContID, var_targetContID INT UNSIGNED default NULL;

	select RootContainerID into var_sourceContID from movable_objects where ID = in_sourceMovableObjID;
	select RootContainerID into var_targetContID from unmovable_objects where ID = in_targetUnmovableObjID;

	if(var_sourceContID is not null and var_targetContID is not null) then
		-- move non-stackable items with 80% probability
		update items i
		join objects_types ot on ot.ID = i.ObjectTypeID and ot.MaxStackSize <= 1
		set i.ContainerID = var_targetContID
		where i.ContainerID = var_sourceContID
			and rand() <= 0.8;

		-- move stackable items with loss of 0.2 quantity
		update items i
		join objects_types ot on ot.ID = i.ObjectTypeID and ot.MaxStackSize > 1
		set i.ContainerID = var_targetContID,
			i.Quantity = floor(i.Quantity * 0.8)
		where i.ContainerID = var_sourceContID
			and floor(i.Quantity * 0.8) > 0;

		-- move containers with 80% probability
		update containers c
		set c.ParentID = var_targetContID
		where c.ParentID = var_sourceContID
			and rand() <= 0.8;
	end if;

END;


DROP PROCEDURE IF EXISTS `p_linkBlueprintToCharacter`;
CREATE PROCEDURE `p_linkBlueprintToCharacter`(
	`in_blueprintID` INT UNSIGNED,
	`in_charID` INT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	SQL SECURITY DEFINER
	COMMENT 'Learns blueprint'
BEGIN
	-- we can't delete item here due to de-sync between `items` table and GS inventory info
	UPDATE `features` SET `BlueprintID`=NULL WHERE `BlueprintID`=in_blueprintID;
	INSERT INTO `character_blueprints` (`CharID`,`BlueprintID`) VALUES (in_charID,in_blueprintID);
END;

UPDATE `effects` SET `PlayerEffectID`=65 WHERE  `ID`=5;


DROP PROCEDURE IF EXISTS `p_deleteBlueprint`;
CREATE PROCEDURE `p_deleteBlueprint`(
	`in_blueprintID` INT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	SQL SECURITY DEFINER
BEGIN
	UPDATE `features` SET `BlueprintID`=NULL WHERE `BlueprintID`=in_blueprintID;
	DELETE FROM `character_blueprints` WHERE BlueprintID=in_blueprintID;
	DELETE FROM `blueprint_requirements` WHERE BlueprintID=in_blueprintID;
	DELETE FROM `blueprints` WHERE ID=in_blueprintID;
END;

DROP FUNCTION IF EXISTS `f_createForestItem`;
CREATE FUNCTION `f_createForestItem`(
	`in_geoID` INT UNSIGNED,
	`in_treeFamily` TINYINT UNSIGNED,
	`in_treePlantMethod` TINYINT UNSIGNED,
	`in_subcellMask` TINYINT UNSIGNED,
	`in_ageTime` INT UNSIGNED,
	`in_quality` FLOAT
) RETURNS INT UNSIGNED
	MODIFIES SQL DATA
BEGIN
	insert into forest
		(`GeoDataID`,     `TreeType`,    `TreePlantMethod`,  `SubcellMask`,  `AgeTime`,  Quality)
		values (in_geoID, in_treeFamily, in_treePlantMethod, in_subcellMask, in_ageTime, in_quality);

	return in_geoID;
END;


DROP FUNCTION IF EXISTS `f_genUniqueU64`;
CREATE FUNCTION `f_genUniqueU64`()
	RETURNS BIGINT UNSIGNED
	NOT DETERMINISTIC
	CONTAINS SQL
BEGIN


	/*
	The UUID_SHORT() return value which constructed this way: 
	  (server_id & 255) << 56
	+ (server_startup_time_in_seconds << 24)
	+ incremented_variable++;
	
	We use 3-byte incremented_variable from it and add 4-byte unix_timestamp.
	So we have 16777215 unique numbers per second.
	*/
	
	return ((UUID_SHORT() & 0x00FFFFFF) << 32 | unix_timestamp());

END;

-- functions to produce guild actions by billing ("fb_*")
DROP FUNCTION IF EXISTS `fb_createGuild`;
CREATE FUNCTION `fb_createGuild`(
	in_producerCharID INT UNSIGNED,
	in_guildName VARCHAR(45),
	in_guildTag VARCHAR(4),
	in_guildCharter VARCHAR(10000)
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "guild_create" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- user should not be in guild
	if(exists(select * from `character` where ID = in_producerCharID and GuildID is not null)) then
		return 0;
	end if;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildName, GuildTag, GuildCharter)
	values('guild_create', ticket, in_producerCharID, in_guildName, in_guildTag, (case when (trim(ifnull(in_guildCharter, '')) = '') then NULL else in_guildCharter end));
			
	return ticket;

END;

DROP FUNCTION IF EXISTS `fb_renameGuild`;
CREATE FUNCTION `fb_renameGuild`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildName VARCHAR(45),
	in_guildTag VARCHAR(4)
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "guild_rename" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, GuildName, GuildTag)
	values('guild_rename', ticket, in_producerCharID, in_guildID, in_guildName, in_guildTag);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS `fb_destroyGuild`;
CREATE FUNCTION `fb_destroyGuild`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "guild_destroy" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(!exists(
		select *
		from `character`
		where ID = in_producerCharID
			and GuildID = in_guildID
			and GuildRoleID = 1 /*Leader*/)
	) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID)
	values('guild_destroy', ticket, in_producerCharID, in_guildID);
			
	return ticket;
	
END;

DROP FUNCTION IF EXISTS `fb_inviteCharToGuild`;
CREATE FUNCTION `fb_inviteCharToGuild`(
	in_producerCharID INT UNSIGNED,
	in_targetCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "player_invite_to_guild" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;
	
	-- prevent self-invite
	if(in_producerCharID = in_targetCharID) then
		return 0;
	end if;
	
	-- check if char already in some guild
	if(exists(select * from `character` where ID = in_targetCharID and GuildID is not null)) then
		return 0;
	end if;
	
	-- check if char already have invite to this guild
	if(exists(select * from guild_invites where GuildID = in_guildID and ReceiverCharID = in_targetCharID)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, CharID)
	values('player_invite_to_guild', ticket, in_producerCharID, in_guildID, in_targetCharID);
			
	return ticket;
	
END;

DROP FUNCTION IF EXISTS `fb_cancelInvitationToGuild`;
CREATE FUNCTION `fb_cancelInvitationToGuild`(
	in_producerCharID INT UNSIGNED,
	in_targetCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "player_invite_cancelled" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;
	
	-- prevent self-invite
	if(in_producerCharID = in_targetCharID) then
		return 0;
	end if;

	-- check char rights
	if(!exists(select * from `character` where ID = in_producerCharID and GuildID = in_guildID
		and (GuildRoleID = 1 /*Leader*/ or GuildRoleID = 2 /*Minor leader*/))
	) then
		return 0;
	end if;
	
	-- check if char have invite to this guild
	if(!exists(select * from guild_invites where GuildID = in_guildID and ReceiverCharID = in_targetCharID)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, CharID)
	values('player_invite_cancelled', ticket, in_producerCharID, in_guildID, in_targetCharID);
			
	return ticket;
	
END;

DROP FUNCTION IF EXISTS `fb_acceptGuildInvite`;
CREATE FUNCTION `fb_acceptGuildInvite`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "player_invite_accepted" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;
	
	-- check if char have been invited
	if(!exists(select * from guild_invites where GuildID = in_guildID and ReceiverCharID = in_producerCharID)) then
		return 0;
	end if;
	
	-- check if char not assigned to any guild
	if(exists(select * from `character` where ID = in_producerCharID and GuildID is not null)) then
		return 0;
	end if;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID)
	values('player_invite_accepted', ticket, in_producerCharID, in_guildID);
			
	return ticket;
	
END;

DROP FUNCTION IF EXISTS `fb_declineGuildInvite`;
CREATE FUNCTION `fb_declineGuildInvite`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "player_invite_declined" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;
	
	-- check if char have been invited
	if(!exists(select * from guild_invites where GuildID = in_guildID and ReceiverCharID = in_producerCharID)) then
		return 0;
	end if;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID)
	values('player_invite_declined', ticket, in_producerCharID, in_guildID);
			
	return ticket;
	
END;

DROP FUNCTION IF EXISTS `fb_leaveGuild`;
CREATE FUNCTION `fb_leaveGuild`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "player_left_guild" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check if char assigned to this guild
	if(!exists(select * from `character` where ID = in_producerCharID and GuildID = in_guildID)) then
		return 0;
	end if;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID)
	values('player_left_guild', ticket, in_producerCharID, in_guildID);
			
	return ticket;
	
END;

DROP FUNCTION IF EXISTS `fb_kickFromGuild`;
CREATE FUNCTION `fb_kickFromGuild`(
	in_producerCharID INT UNSIGNED,
	in_targetCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "player_guild_kicked" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;
	
	-- prevent self-kick
	if(in_producerCharID = in_targetCharID) then
		return 0;
	end if;
	
	-- check char rights
	if(!exists(select * from `character` where ID=in_producerCharID and GuildID=in_guildID
		and (GuildRoleID = 1 /*Leader*/ or GuildRoleID = 2 /* Minor Leader */))
	) then
		return 0;
	end if;
	
	-- check if char in this guild
	if(!exists(select * from `character` where ID=in_targetCharID and GuildID=in_guildID)) then
		return 0;
	end if;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, CharID, CharIsKicked)
	values('player_guild_kicked', ticket, in_producerCharID, in_guildID, in_targetCharID, 1);
			
	return ticket;
	
END;

DROP FUNCTION IF EXISTS `fb_monumentDestroyed`;
DROP PROCEDURE IF EXISTS `p_onMonumentDestroyed`;
CREATE PROCEDURE `p_onMonumentDestroyed`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	COMMENT 'Register "monument_destroyed" action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID)
	values('monument_destroyed', ticket, in_producerCharID, in_guildID);
	
END;

DROP PROCEDURE IF EXISTS `p_onPersonalLandRemoved`;
DROP PROCEDURE IF EXISTS `p_onAdminLandRemoved`;
DROP PROCEDURE IF EXISTS `p_onPersonalLandCreated`;
DROP PROCEDURE IF EXISTS `p_onAdminLandCreated`;

DROP PROCEDURE IF EXISTS `p_onMonumentCreated`;
CREATE PROCEDURE `p_onMonumentCreated`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED
)
	COMMENT 'Register "monument_built" action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID)
	values('monument_built', ticket, in_producerCharID, in_guildID);
	
END;

DROP FUNCTION IF EXISTS `fb_setGuildStanding`;
CREATE FUNCTION `fb_setGuildStanding`(
	in_producerCharID INT UNSIGNED,
	in_producerGuildID INT UNSIGNED,
	in_targetGuildID INT UNSIGNED,
	in_standingTypeID TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "guild_change_standing" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- prevent self-referencing
	if(in_producerGuildID = in_targetGuildID) then
		return 0;
	end if;

	-- check char rights
	if(!exists(select * from `character` where ID = in_producerCharID and GuildID = in_producerGuildID
		and (GuildRoleID = 1 /*Leader*/ or GuildRoleID = 2 /*Minor leader*/))
	) then
		return 0;
	end if;
	
	-- check guilds rangs
	if(!exists(select * from guilds where ID = in_producerGuildID and GuildTypeID > 2 /*Order*/)
		or !exists(select * from guilds where ID = in_targetGuildID and GuildTypeID > 2 /*Order*/)
	) then
		return 0;
	end if;
	
	-- check if these guilds already have this standing
	if(exists(
		select * from guild_standings
		where GuildID1 = in_producerGuildID and GuildID2 = in_targetGuildID and StandingTypeID = in_standingTypeID)
	) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, OtherGuildID, StandingTypeID)
	values('guild_change_standing', ticket, in_producerCharID, in_producerGuildID, in_targetGuildID, in_standingTypeID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS `fb_setCharGuildRole`;
CREATE FUNCTION `fb_setCharGuildRole`(
	in_producerCharID INT UNSIGNED,
	in_targetCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildRoleID TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "player_new_guild_role" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- prevent self-change
	if(in_producerCharID = in_targetCharID) then
		return 0;
	end if;

	-- check char rights
	if(!exists(select * from `character` where ID = in_producerCharID and GuildID = in_guildID
		and (GuildRoleID = 1 /*Leader*/ or GuildRoleID = 2 /* Minor Leader */))
	) then
		return 0;
	end if;

	-- check if char in this guild
	if(!exists(select * from `character` where ID = in_targetCharID and GuildID = in_guildID)) then
		return 0;
	end if;
	
	-- check if char already has this role
	if(exists(select * from `character` where ID = in_targetCharID and GuildID = in_guildID and GuildRoleID = in_guildRoleID)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, CharID, CharGuildRoleID)
	values('player_new_guild_role', ticket, in_producerCharID, in_guildID, in_targetCharID, in_guildRoleID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS `fb_getActionProcessStatus`;
CREATE FUNCTION `fb_getActionProcessStatus`(
	in_producerCharID INT UNSIGNED,
	in_actionTicketID BIGINT UNSIGNED
)
	RETURNS TINYINT UNSIGNED
	READS SQL DATA
	COMMENT 'Return int-representation of process status of guild action (0 if unprocessed). See guild_actions_processed.ProcessedStatus for whole list of statuses'
BEGIN

	return ifnull((select (ProcessedStatus+0) /*convert enum to int*/ from guild_actions_processed where TicketID = in_actionTicketID and ProducerCharID = in_producerCharID), 0);
	
END;

DROP PROCEDURE IF EXISTS pb_getCharGuildInvites;
CREATE PROCEDURE pb_getCharGuildInvites(
	IN `in_receiverCharID` INT UNSIGNED
)
BEGIN
	select g.ID, g.Name, g.GuildTag 
	from guild_invites gi
	join guilds g on g.ID = gi.GuildID 
	where gi.ReceiverCharID = in_receiverCharID
	order by g.Name;
END;

DROP PROCEDURE IF EXISTS pb_getGuildStandings;
CREATE PROCEDURE pb_getGuildStandings(
	IN `in_guildID` INT UNSIGNED
)
BEGIN
	select g_their.ID, g_their.Name, g_their.GuildTag, g_their.GuildTypeID, gs_their.StandingTypeID as TheirStanding, gs_our.StandingTypeID as OurStanding
	from guilds g_our
	cross join guilds g_their on g_our.ID != g_their.ID and g_their.IsActive = 1 and g_their.GuildTypeID > 2 /*Order*/
	left join guild_standings gs_their on gs_their.GuildID1 = g_their.ID and gs_their.GuildID2 = g_our.ID
	left join guild_standings gs_our on gs_our.GuildID1 = g_our.ID and gs_our.GuildID2 = g_their.ID
	where g_our.ID = in_guildID and g_our.IsActive = 1
		-- and g_our.GuildTypeID > 2 /*Order*/ 
	order by g_their.Name;
END;

DROP PROCEDURE IF EXISTS pb_getGuilds;
CREATE PROCEDURE pb_getGuilds()
BEGIN
	select g.ID, g.Name, g.GuildTag, gt.Name as GuildType, gt.ID as GuildTypeID, g.CreateTimestamp as CreateDate,
		(select count(*) from `character` where GuildID = g.ID and IsActive = 1) as MembersCount
	from guilds g
	join guild_types gt on gt.ID = g.GuildTypeID
	where g.IsActive = 1
	order by g.Name;
END;

DROP PROCEDURE IF EXISTS pb_getGuild;
CREATE PROCEDURE pb_getGuild(
	IN `in_guildID` INT UNSIGNED
)
BEGIN
	select g.ID, g.Name, g.GuildTag, g.GuildCharter, gt.ID as GuildTypeID, gt.Name as GuildType
	from guilds g
	join guild_types gt on g.GuildTypeID = gt.ID
	where g.ID = in_guildID;
END;

DROP PROCEDURE IF EXISTS pb_getGuildClaimAccessRights;
CREATE PROCEDURE pb_getGuildClaimAccessRights(
	IN `in_guildID` INT UNSIGNED,
	IN `in_guildLandType` INT UNSIGNED
)
BEGIN
	select cr.ID, cr.CanEnter, cr.CanBuild, cr.CanClaim, cr.CanUse, cr.CanDestroy,
		case
			when ch.ID is not null then concat(ch.Name, ' ', ch.LastName)
			when gr.ID is not null then gr.Name
			when g.ID is not null then concat(g.Name, ' (', g.GuildTag, ')')
			when st.ID is not null then st.Name
		end as `User`,
		case
			when ch.ID is not null then 'char' -- 1
			when gr.ID is not null then 'guild_role' -- 2
			when g.ID is not null then 'guild' -- 3
			when st.ID is not null then 'guild_standing' -- 4
		end as UserType
	from guild_lands gl
	join claims cl on cl.GuildLandID = gl.ID and cl.PersonalLandID is null
	join claim_rules cr on cr.ClaimID = cl.ID
	join claim_subjects cs on cs.ID = cr.ClaimSubjectID
	left join `character` ch on ch.ID = cs.CharID
	left join guild_roles gr on gr.ID = cs.GuildRoleID
	left join guilds g on g.ID = cs.GuildID
	left join guild_standing_types st on st.ID = cs.StandingTypeID
	where gl.GuildID = in_guildID
		and gl.LandType = in_guildLandType
	order by UserType, ch.Name, g.Name, gr.ID, st.ID desc;
END;

DROP PROCEDURE IF EXISTS pb_getGuildMembersRanks;
CREATE PROCEDURE pb_getGuildMembersRanks(
	IN `in_guildID` INT UNSIGNED
)
BEGIN
	select c.ID, concat(c.Name, ' ', c.LastName) as Name, c.GuildRoleID as Rank
	FROM `character` c
	WHERE c.GuildID = in_guildID AND c.IsActive = 1
	order by c.GuildRoleID, c.Name;
END;

DROP PROCEDURE IF EXISTS pb_getGuildPendingInvitations;
CREATE PROCEDURE pb_getGuildPendingInvitations(
	IN `in_guildID` INT UNSIGNED
)
BEGIN
	select gi.ID, gi.ReceiverCharID, gi.SenderCharID,
		concat(rc.Name, ' ', rc.LastName) as Name,
		concat(sc.Name, ' ', sc.LastName) as InvitedBy
	from guild_invites gi
	join `character` rc on rc.ID = gi.ReceiverCharID
	join `character` sc on sc.ID = gi.SenderCharID
	where gi.GuildID = in_guildID
	order by rc.Name;
END;

DROP FUNCTION IF EXISTS fb_updateClaimRules;
CREATE FUNCTION fb_updateClaimRules(
	in_producerCharID INT UNSIGNED,
	in_targetClaimRuleID INT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_char_rule" or "set_claim_role_rule" or "set_claim_guild_rule" or "set_claim_standing_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare targetClaimID, subj_CharID, subj_GuildID int unsigned default null;
	declare subj_GuildRoleID, subj_StandingTypeID tinyint unsigned default null;
	
	-- check if current rules are same
	if(exists(select * from claim_rules where ID = in_targetClaimRuleID and CanEnter=in_canEnter and CanBuild=in_canBuild and CanClaim=in_canClaim and CanUse=in_canUse and CanDestroy=in_canDestroy)) then
		return 0;
	end if;
	
	-- choose rule's subject
	select ClaimID, CharID, GuildRoleID, GuildID, StandingTypeID
	into targetClaimID, subj_CharID, subj_GuildRoleID, subj_GuildID, subj_StandingTypeID
	from claim_rules cr
	join claim_subjects cs on cs.ID = cr.ClaimSubjectID
	where cr.ID = in_targetClaimRuleID;
	
	return case
		when subj_CharID is not null then fb_setClaimRuleChar(in_producerCharID, targetClaimID, subj_CharID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy)
		when subj_GuildRoleID is not null then fb_setClaimRuleGuildRole(in_producerCharID, targetClaimID, subj_GuildRoleID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy)
		when subj_GuildID is not null then fb_setClaimRuleGuild(in_producerCharID, targetClaimID, subj_GuildID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy)
		when subj_StandingTypeID is not null then fb_setClaimRuleGuildStanding(in_producerCharID, targetClaimID, subj_StandingTypeID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy)
		else 0
	end;

END;


DROP FUNCTION IF EXISTS fb_updateUnmovableRules;
CREATE FUNCTION fb_updateUnmovableRules(
	in_producerCharID INT UNSIGNED,
	in_targetUnmovableRuleID INT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_unmovable_char_rule" or "set_unmovable_role_rule" or "set_unmovable_guild_rule" or "set_unmovable_standing_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare targetUnmovableID, targetClaimID, subj_CharID, subj_GuildID int unsigned default null;
	declare subj_GuildRoleID, subj_StandingTypeID tinyint unsigned default null;
	
	-- check if current rules are same
	if(exists(select * from claim_rules_unmovable where ID = in_targetUnmovableRuleID and CanUse=in_canUse and CanDestroy=in_canDestroy)) then
		return 0;
	end if;
	
	-- choose rule's subject
	select uoc.UnmovableObjectID, uoc.ClaimID, CharID, GuildRoleID, GuildID, StandingTypeID
	into targetUnmovableID, targetClaimID, subj_CharID, subj_GuildRoleID, subj_GuildID, subj_StandingTypeID
	from claim_rules_unmovable cru
	join claim_subjects cs on cs.ID = cru.ClaimSubjectID
	join unmovable_objects_claims uoc on uoc.ID = cru.UnmovableClaimID
	where cru.ID = in_targetUnmovableRuleID;
	
	return case
		when subj_CharID is not null then fb_setUnmovableRuleChar(in_producerCharID, targetClaimID, targetUnmovableID, subj_CharID, in_canUse, in_canDestroy)
		when subj_GuildRoleID is not null then fb_setUnmovableRuleGuildRole(in_producerCharID, targetClaimID, targetUnmovableID, subj_GuildRoleID, in_canUse, in_canDestroy)
		when subj_GuildID is not null then fb_setUnmovableRuleGuild(in_producerCharID, targetClaimID, targetUnmovableID, subj_GuildID, in_canUse, in_canDestroy)
		when subj_StandingTypeID is not null then fb_setUnmovableRuleGuildStanding(in_producerCharID, targetClaimID, targetUnmovableID, subj_StandingTypeID, in_canUse, in_canDestroy)
		else 0
	end;
	
END;


DROP FUNCTION IF EXISTS fb_removeClaimRule;
CREATE FUNCTION fb_removeClaimRule(
	in_producerCharID INT UNSIGNED,
	in_targetClaimRuleID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_claim_*_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare targetClaimID, subj_CharID, subj_GuildID int unsigned default null;
	declare subj_GuildRoleID, subj_StandingTypeID tinyint unsigned default null;
	
	-- check exists rule
	if(!exists(select * from claim_rules where ID = in_targetClaimRuleID)) then
		return 0;
	end if;
	
	-- choose rule's subject
	select ClaimID, CharID, GuildRoleID, GuildID, StandingTypeID
	into targetClaimID, subj_CharID, subj_GuildRoleID, subj_GuildID, subj_StandingTypeID
	from claim_rules cr
	join claim_subjects cs on cs.ID = cr.ClaimSubjectID
	where cr.ID = in_targetClaimRuleID;
	
	return case
		when subj_CharID is not null then fb_removeClaimRuleChar(in_producerCharID, targetClaimID, subj_CharID)
		when subj_GuildRoleID is not null then fb_removeClaimRuleGuildRole(in_producerCharID, targetClaimID, subj_GuildRoleID)
		when subj_GuildID is not null then fb_removeClaimRuleGuild(in_producerCharID, targetClaimID, subj_GuildID)
		when subj_StandingTypeID is not null then fb_removeClaimRuleGuildStanding(in_producerCharID, targetClaimID, subj_StandingTypeID)
		else 0
	end;

END;

DROP FUNCTION IF EXISTS fb_removeUnmovableRule;
CREATE FUNCTION fb_removeUnmovableRule(
    in_producerCharID INT UNSIGNED,
    in_targetUnmovableRuleID INT UNSIGNED
)
	RETURNS bigint(20) unsigned
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	SQL SECURITY DEFINER
	COMMENT 'Dispatch call to "remove_unmovable..." action. Return action ticket ID if succeeded or return 0 if cant register action'
BEGIN

    declare targetUnmovableID, targetClaimID int unsigned default null;
    declare subj_CharID, subj_GuildID int unsigned default null;
    declare subj_GuildRoleID, subj_StandingTypeID tinyint unsigned default null;

    -- check exists rule
    if(!exists(select * from claim_rules_unmovable where ID = in_targetUnmovableRuleID)) then
        return 0;
    end if;

    -- choose unmovable and claim
    select UnmovableObjectID, ClaimID
    into targetUnmovableID, targetClaimID
    from unmovable_objects_claims uoc
    join claim_rules_unmovable cru on cru.UnmovableClaimID = uoc.ID
    where cru.ID = in_targetUnmovableRuleID;

    -- choose rule's subject
    select cs.CharID, cs.GuildRoleID, cs.GuildID, cs.StandingTypeID
    into subj_CharID, subj_GuildRoleID, subj_GuildID, subj_StandingTypeID
    from claim_rules_unmovable cru
    join claim_subjects cs on cs.ID = cru.ClaimSubjectID
    where cru.ID = in_targetUnmovableRuleID;

    return case
        when subj_CharID is not null then fb_removeUnmovableRuleChar(in_producerCharID, targetClaimID, targetUnmovableID, subj_CharID)
        when subj_GuildRoleID is not null then fb_removeUnmovableRuleGuildRole(in_producerCharID, targetClaimID, targetUnmovableID, subj_GuildRoleID)
        when subj_GuildID is not null then fb_removeUnmovableRuleGuild(in_producerCharID, targetClaimID, targetUnmovableID, subj_GuildID)
        when subj_StandingTypeID is not null then fb_removeUnmovableRuleGuildStanding(in_producerCharID, targetClaimID, targetUnmovableID, subj_StandingTypeID)
        else 0
    end;

END;

DROP FUNCTION IF EXISTS fb_setClaimRuleChar;
CREATE FUNCTION fb_setClaimRuleChar(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_targetCharID INT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_char_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
		and !exists(
			select *
			from claims cl
			join admin_lands al on al.ID = cl.AdminLandID
			where cl.ID = in_claimID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(exists(
		select *
		from claim_subjects cs
		join claim_rules cr on cr.ClaimSubjectID = cs.ID
		where cr.ClaimID = in_claimID
			and cs.CharID = in_targetCharID
			and cr.CanEnter=in_canEnter and cr.CanBuild=in_canBuild and cr.CanClaim=in_canClaim and cr.CanUse=in_canUse and cr.CanDestroy=in_canDestroy
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, CharID, ClaimID, CanEnter, CanBuild, CanClaim, CanUse, CanDestroy)
	values('set_claim_char_rule', ticket, in_producerCharID, in_targetCharID, in_claimID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);
			
	return ticket;

END;


DROP FUNCTION IF EXISTS fb_removeClaimRuleChar;
CREATE FUNCTION fb_removeClaimRuleChar(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_targetCharID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_claim_char_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
		and !exists(
			select *
			from claims cl
			join admin_lands al on al.ID = cl.AdminLandID
			where cl.ID = in_claimID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(!exists(
		select *
		from claim_subjects cs
		join claim_rules cr on cr.ClaimSubjectID = cs.ID
		where cr.ClaimID = in_claimID
			and cs.CharID = in_targetCharID
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, CharID, ClaimID)
	values('remove_claim_char_rule', ticket, in_producerCharID, in_targetCharID, in_claimID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_setClaimRuleCharByGuildId;
CREATE FUNCTION fb_setClaimRuleCharByGuildId(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildLandType INT UNSIGNED,
	in_targetCharID INT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_char_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare targetClaimID int unsigned default NULL;

	select c.ID
	into targetClaimID
	from guild_lands gl
	join claims c on c.GuildLandID = gl.ID and c.PersonalLandID is null
	where gl.GuildID = in_guildID and gl.LandType = in_guildLandType
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;
	
	return fb_setClaimRuleChar(in_producerCharID, targetClaimID, in_targetCharID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS fb_setClaimRuleGuildRole;
CREATE FUNCTION fb_setClaimRuleGuildRole(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_targetGuildRoleID TINYINT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_role_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
		and !exists(
			select *
			from claims cl
			join admin_lands al on al.ID = cl.AdminLandID
			where cl.ID = in_claimID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(exists(
		select *
		from claim_subjects cs
		join claim_rules cr on cr.ClaimSubjectID = cs.ID
		where cr.ClaimID = in_claimID
			and cs.GuildRoleID = in_targetGuildRoleID
			and cr.CanEnter=in_canEnter and cr.CanBuild=in_canBuild and cr.CanClaim=in_canClaim and cr.CanUse=in_canUse and cr.CanDestroy=in_canDestroy
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, CharGuildRoleID, ClaimID, CanEnter, CanBuild, CanClaim, CanUse, CanDestroy)
	values('set_claim_role_rule', ticket, in_producerCharID, in_targetGuildRoleID, in_claimID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_removeClaimRuleGuildRole;
CREATE FUNCTION fb_removeClaimRuleGuildRole(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_targetGuildRoleID TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_claim_role_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
		and !exists(
			select *
			from claims cl
			join admin_lands al on al.ID = cl.AdminLandID
			where cl.ID = in_claimID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(!exists(
		select *
		from claim_subjects cs
		join claim_rules cr on cr.ClaimSubjectID = cs.ID
		where cr.ClaimID = in_claimID
			and cs.GuildRoleID = in_targetGuildRoleID
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, CharGuildRoleID, ClaimID)
	values('remove_claim_role_rule', ticket, in_producerCharID, in_targetGuildRoleID, in_claimID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_setClaimRuleGuildRoleByGuildId;
CREATE FUNCTION fb_setClaimRuleGuildRoleByGuildId(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildLandType INT UNSIGNED,
	in_targetGuildRoleID TINYINT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_role_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare targetClaimID int unsigned default NULL;

	select c.ID
	into targetClaimID
	from guild_lands gl
	join claims c on c.GuildLandID = gl.ID and c.PersonalLandID is null
	where gl.GuildID = in_guildID and gl.LandType = in_guildLandType
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;
	
	return fb_setClaimRuleGuildRole(in_producerCharID, targetClaimID, in_targetGuildRoleID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS fb_setClaimRuleGuild;
CREATE FUNCTION fb_setClaimRuleGuild(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_targetGuildID INT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_guild_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
		and !exists(
			select *
			from claims cl
			join admin_lands al on al.ID = cl.AdminLandID
			where cl.ID = in_claimID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(exists(
		select *
		from claim_subjects cs
		join claim_rules cr on cr.ClaimSubjectID = cs.ID
		where cr.ClaimID = in_claimID
			and cs.GuildID = in_targetGuildID
			and cr.CanEnter=in_canEnter and cr.CanBuild=in_canBuild and cr.CanClaim=in_canClaim and cr.CanUse=in_canUse and cr.CanDestroy=in_canDestroy
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, ClaimID, CanEnter, CanBuild, CanClaim, CanUse, CanDestroy)
	values('set_claim_guild_rule', ticket, in_producerCharID, in_targetGuildID, in_claimID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_removeClaimRuleGuild;
CREATE FUNCTION fb_removeClaimRuleGuild(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_targetGuildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_claim_guild_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
		and !exists(
			select *
			from claims cl
			join admin_lands al on al.ID = cl.AdminLandID
			where cl.ID = in_claimID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(!exists(
		select *
		from claim_subjects cs
		join claim_rules cr on cr.ClaimSubjectID = cs.ID
		where cr.ClaimID = in_claimID
			and cs.GuildID = in_targetGuildID
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, ClaimID)
	values('remove_claim_guild_rule', ticket, in_producerCharID, in_targetGuildID, in_claimID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_setClaimRuleGuildByGuildId;
CREATE FUNCTION fb_setClaimRuleGuildByGuildId(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildLandType INT UNSIGNED,
	in_targetGuildID INT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_guild_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare targetClaimID int unsigned default NULL;

	select c.ID
	into targetClaimID
	from guild_lands gl
	join claims c on c.GuildLandID = gl.ID and c.PersonalLandID is null
	where gl.GuildID = in_guildID and gl.LandType = in_guildLandType
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;
	
	return fb_setClaimRuleGuild(in_producerCharID, targetClaimID, in_targetGuildID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS fb_setClaimRuleGuildStanding;
CREATE FUNCTION fb_setClaimRuleGuildStanding(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_targetGuildStandingID TINYINT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_standing_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
		and !exists(
			select *
			from claims cl
			join admin_lands al on al.ID = cl.AdminLandID
			where cl.ID = in_claimID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(exists(
		select *
		from claim_subjects cs
		join claim_rules cr on cr.ClaimSubjectID = cs.ID
		where cr.ClaimID = in_claimID
			and cs.StandingTypeID = in_targetGuildStandingID
			and cr.CanEnter=in_canEnter and cr.CanBuild=in_canBuild and cr.CanClaim=in_canClaim and cr.CanUse=in_canUse and cr.CanDestroy=in_canDestroy
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, StandingTypeID, ClaimID, CanEnter, CanBuild, CanClaim, CanUse, CanDestroy)
	values('set_claim_standing_rule', ticket, in_producerCharID, in_targetGuildStandingID, in_claimID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_removeClaimRuleGuildStanding;
CREATE FUNCTION fb_removeClaimRuleGuildStanding(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_targetGuildStandingID TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_claim_standing_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
		and !exists(
			select *
			from claims cl
			join admin_lands al on al.ID = cl.AdminLandID
			where cl.ID = in_claimID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(!exists(
		select *
		from claim_subjects cs
		join claim_rules cr on cr.ClaimSubjectID = cs.ID
		where cr.ClaimID = in_claimID
			and cs.StandingTypeID = in_targetGuildStandingID
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, StandingTypeID, ClaimID)
	values('remove_claim_standing_rule', ticket, in_producerCharID, in_targetGuildStandingID, in_claimID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_setClaimRuleGuildStandingByGuildId;
CREATE FUNCTION fb_setClaimRuleGuildStandingByGuildId(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildLandType INT UNSIGNED,
	in_targetGuildStandingID TINYINT UNSIGNED,
	in_canEnter TINYINT UNSIGNED,
	in_canBuild TINYINT UNSIGNED,
	in_canClaim TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_claim_standing_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare targetClaimID int unsigned default NULL;

	select c.ID
	into targetClaimID
	from guild_lands gl
	join claims c on c.GuildLandID = gl.ID and c.PersonalLandID is null
	where gl.GuildID = in_guildID and gl.LandType = in_guildLandType
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;
	
	return fb_setClaimRuleGuildStanding(in_producerCharID, targetClaimID, in_targetGuildStandingID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS `fb_setOutpostRuleChar`;
CREATE FUNCTION `fb_setOutpostRuleChar`(
	`in_producerCharID` INT UNSIGNED,
	`in_guildID` INT UNSIGNED,
	`in_outpostID` INT UNSIGNED,
	`in_targetCharID` INT UNSIGNED,
	`in_canEnter` TINYINT UNSIGNED,
	`in_canBuild` TINYINT UNSIGNED,
	`in_canClaim` TINYINT UNSIGNED,
	`in_canUse` TINYINT UNSIGNED,
	`in_canDestroy` TINYINT UNSIGNED
)
RETURNS bigint(20) unsigned
LANGUAGE SQL
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY DEFINER
COMMENT 'Register "set_claim_char_rule" action. Return action ticket ID if succeeded or return 0 if cant register action'
BEGIN

	declare targetClaimID int unsigned default NULL;

	select uoc.ClaimID
	into targetClaimID
	from outposts op
	join unmovable_objects_claims uoc on uoc.UnmovableObjectID = op.UnmovableObjectID
	where op.OwnerGuildID = in_guildID and op.ID = in_outpostID
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;

	return fb_setClaimRuleChar(in_producerCharID, targetClaimID, in_targetCharID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);
END;

DROP FUNCTION IF EXISTS `fb_setOutpostRuleGuild`;
CREATE FUNCTION `fb_setOutpostRuleGuild`(
	`in_producerCharID` INT UNSIGNED,
	`in_guildID` INT UNSIGNED,
	`in_outpostID` INT UNSIGNED,
	`in_targetGuildID` INT UNSIGNED,
	`in_canEnter` TINYINT UNSIGNED,
	`in_canBuild` TINYINT UNSIGNED,
	`in_canClaim` TINYINT UNSIGNED,
	`in_canUse` TINYINT UNSIGNED,
	`in_canDestroy` TINYINT UNSIGNED

)
RETURNS bigint(20) unsigned
LANGUAGE SQL
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY DEFINER
COMMENT 'Register "set_claim_guild_rule" action. Return action ticket ID if succeeded or return 0 if cant register action'
BEGIN

	declare targetClaimID int unsigned default NULL;

	select uoc.ClaimID
	into targetClaimID
	from outposts op
	join unmovable_objects_claims uoc on uoc.UnmovableObjectID = op.UnmovableObjectID
	where op.OwnerGuildID = in_guildID and op.ID = in_outpostID
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;

	return fb_setClaimRuleGuild(in_producerCharID, targetClaimID, in_targetGuildID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS `fb_setOutpostRuleGuildRole`;
CREATE FUNCTION `fb_setOutpostRuleGuildRole`(
	`in_producerCharID` INT UNSIGNED,
	`in_guildID` INT UNSIGNED,
	`in_outpostID` INT UNSIGNED,
	`in_targetGuildRoleID` TINYINT UNSIGNED,
	`in_canEnter` TINYINT UNSIGNED,
	`in_canBuild` TINYINT UNSIGNED,
	`in_canClaim` TINYINT UNSIGNED,
	`in_canUse` TINYINT UNSIGNED,
	`in_canDestroy` TINYINT UNSIGNED

)
RETURNS bigint(20) unsigned
LANGUAGE SQL
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY DEFINER
COMMENT 'Register "set_claim_role_rule" action. Return action ticket ID if succeeded or return 0 if cant register action'
BEGIN

	declare targetClaimID int unsigned default NULL;

	select uoc.ClaimID
	into targetClaimID
	from outposts op
	join unmovable_objects_claims uoc on uoc.UnmovableObjectID = op.UnmovableObjectID
	where op.OwnerGuildID = in_guildID and op.ID = in_outpostID
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;

	return fb_setClaimRuleGuildRole(in_producerCharID, targetClaimID, in_targetGuildRoleID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);

END;


DROP FUNCTION IF EXISTS `fb_setOutpostRuleGuildStanding`;
CREATE FUNCTION `fb_setOutpostRuleGuildStanding`(
	`in_producerCharID` INT UNSIGNED,
	`in_guildID` INT UNSIGNED,
	`in_outpostID` INT UNSIGNED,
	`in_targetGuildStandingID` TINYINT UNSIGNED,
	`in_canEnter` TINYINT UNSIGNED,
	`in_canBuild` TINYINT UNSIGNED,
	`in_canClaim` TINYINT UNSIGNED,
	`in_canUse` TINYINT UNSIGNED,
	`in_canDestroy` TINYINT UNSIGNED
)
RETURNS bigint(20) unsigned
LANGUAGE SQL
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY DEFINER
COMMENT 'Register "set_claim_standing_rule" action. Return action ticket ID if succeeded or return 0 if cant register action'
BEGIN

	declare targetClaimID int unsigned default NULL;

	select uoc.ClaimID
	into targetClaimID
	from outposts op
	join unmovable_objects_claims uoc on uoc.UnmovableObjectID = op.UnmovableObjectID
	where op.OwnerGuildID = in_guildID and op.ID = in_outpostID
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;

	return fb_setClaimRuleGuildStanding(in_producerCharID, targetClaimID, in_targetGuildStandingID, in_canEnter, in_canBuild, in_canClaim, in_canUse, in_canDestroy);

END;


DROP FUNCTION IF EXISTS `fb_updateGuildCharter`;
CREATE FUNCTION `fb_updateGuildCharter`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildCharter VARCHAR(10000)
)
	RETURNS TINYINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Modify guild''s charter. Return 1 if succeeded or 0 if not'
BEGIN

	-- check char rights
	if(!exists(select * from `character` where ID = in_producerCharID and GuildID = in_guildID
		and GuildRoleID = 1 /*Leader*/)
	) then
		return 0;
	end if;
	
	-- check if guild exists at all
	if(!exists(select * from guilds where ID = in_guildID)) then
		return 0;
	end if;
	
	-- check if current charter is same
	if(exists(select * from guilds where ID = in_guildID and GuildCharter = in_guildCharter)) then
		return 0;
	end if;
	
	-- modify charter
	update guilds set GuildCharter = in_guildCharter where ID = in_guildID;
			
	return 1;
	
END;

DROP FUNCTION IF EXISTS fb_setUnmovableRuleChar;
CREATE FUNCTION fb_setUnmovableRuleChar(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetCharID INT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_unmovable_char_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
	) then
		return 0;
	end if;
	
	-- check if unmovable actually belongs to the given claim
	if(!exists(
		select *
		from unmovable_objects_claims
		where ClaimID = in_claimID and UnmovableObjectID = in_unmovableID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(exists(
		select *
		from claim_subjects cs
		inner join claim_rules_unmovable cr on cr.ClaimSubjectID = cs.ID
		inner join unmovable_objects_claims uoc on uoc.ID = cr.UnmovableClaimID
		where uoc.ClaimID = in_claimID
			and uoc.UnmovableObjectID = in_unmovableID
			and cs.CharID = in_targetCharID
			and cr.CanUse=in_canUse and cr.CanDestroy=in_canDestroy
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, CharID, UnmovableObjectID, CanUse, CanDestroy)
	values('set_unmovable_char_rule', ticket, in_producerCharID, in_targetCharID, in_unmovableID, in_canUse, in_canDestroy);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_setUnmovableRuleGuildRole;
CREATE FUNCTION fb_setUnmovableRuleGuildRole(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildRoleID TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_unmovable_role_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
	) then
		return 0;
	end if;
	
	-- check if unmovable actually belongs to the given claim
	if(!exists(
		select *
		from unmovable_objects_claims
		where ClaimID = in_claimID and UnmovableObjectID = in_unmovableID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(exists(
		select *
		from claim_subjects cs
		inner join claim_rules_unmovable cr on cr.ClaimSubjectID = cs.ID
		inner join unmovable_objects_claims uoc on uoc.ID = cr.UnmovableClaimID
		where uoc.ClaimID = in_claimID
			and uoc.UnmovableObjectID = in_unmovableID
			and cs.GuildRoleID = in_targetGuildRoleID
			and cr.CanUse=in_canUse and cr.CanDestroy=in_canDestroy
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, CharGuildRoleID, UnmovableObjectID, CanUse, CanDestroy)
	values('set_unmovable_role_rule', ticket, in_producerCharID, in_targetGuildRoleID, in_unmovableID, in_canUse, in_canDestroy);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_setUnmovableRuleGuild;
CREATE FUNCTION fb_setUnmovableRuleGuild(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildID INT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_unmovable_guild_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
	) then
		return 0;
	end if;
	
	-- check if unmovable actually belongs to the given claim
	if(!exists(
		select *
		from unmovable_objects_claims
		where ClaimID = in_claimID and UnmovableObjectID = in_unmovableID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(exists(
		select *
		from claim_subjects cs
		inner join claim_rules_unmovable cr on cr.ClaimSubjectID = cs.ID
		inner join unmovable_objects_claims uoc on uoc.ID = cr.UnmovableClaimID
		where uoc.ClaimID = in_claimID
			and uoc.UnmovableObjectID = in_unmovableID
			and cs.GuildID = in_targetGuildID
			and cr.CanUse=in_canUse and cr.CanDestroy=in_canDestroy
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, UnmovableObjectID, CanUse, CanDestroy)
	values('set_unmovable_guild_rule', ticket, in_producerCharID, in_targetGuildID, in_unmovableID, in_canUse, in_canDestroy);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_setUnmovableRuleGuildStanding;
CREATE FUNCTION fb_setUnmovableRuleGuildStanding(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildStandingID TINYINT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "set_unmovable_standing_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
	) then
		return 0;
	end if;
	
	-- check if unmovable actually belongs to the given claim
	if(!exists(
		select *
		from unmovable_objects_claims
		where ClaimID = in_claimID and UnmovableObjectID = in_unmovableID
		)
	) then
		return 0;
	end if;
	
	-- check if current rules are same
	if(exists(
		select *
		from claim_subjects cs
		inner join claim_rules_unmovable cr on cr.ClaimSubjectID = cs.ID
		inner join unmovable_objects_claims uoc on uoc.ID = cr.UnmovableClaimID
		where uoc.ClaimID = in_claimID
			and uoc.UnmovableObjectID = in_unmovableID
			and cs.StandingTypeID = in_targetGuildStandingID
			and cr.CanUse=in_canUse and cr.CanDestroy=in_canDestroy
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, StandingTypeID, UnmovableObjectID, CanUse, CanDestroy)
	values('set_unmovable_standing_rule', ticket, in_producerCharID, in_targetGuildStandingID, in_unmovableID, in_canUse, in_canDestroy);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_setUnmovableRuleCharByGuildId;
CREATE FUNCTION fb_setUnmovableRuleCharByGuildId(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildLandType INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetCharID INT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
BEGIN

	declare targetClaimID int unsigned default NULL;
	declare targetUnmovableID int unsigned default NULL;

	select uoc.ClaimID
	into targetClaimID
	from unmovable_objects_claims as uoc
	where uoc.ID = in_unmovableID
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;

	select UnmovableObjectID
	into targetUnmovableID
	from unmovable_objects_claims
	WHERE ID = in_unmovableID
	limit 1;

	if(targetUnmovableID is null) then
		return 0;
	end if;

	return fb_setUnmovableRuleChar(in_producerCharID, targetClaimID, targetUnmovableID, in_targetCharId, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS fb_setUnmovableRuleGuildByGuildId;
CREATE FUNCTION fb_setUnmovableRuleGuildByGuildId(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildLandType INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildId INT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
BEGIN

	declare targetClaimID int unsigned default NULL;
	declare targetUnmovableID int unsigned default NULL;

	select uoc.ClaimID
	into targetClaimID
	from unmovable_objects_claims as uoc
	where uoc.ID = in_unmovableID
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;

	select UnmovableObjectID
	into targetUnmovableID
	from unmovable_objects_claims
	WHERE ID = in_unmovableID
	limit 1;

	if(targetUnmovableID is null) then
		return 0;
	end if;

	return fb_setUnmovableRuleGuild(in_producerCharID, targetClaimID, targetUnmovableID, in_targetGuildId, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS fb_setUnmovableRuleGuildRoleByGuildId;
CREATE FUNCTION fb_setUnmovableRuleGuildRoleByGuildId(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildLandType INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildRoleID INT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
BEGIN

	declare targetClaimID int unsigned default NULL;
	declare targetUnmovableID int unsigned default NULL;

	select uoc.ClaimID
	into targetClaimID
	from unmovable_objects_claims as uoc
	where uoc.ID = in_unmovableID
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;

	select UnmovableObjectID
	into targetUnmovableID
	from unmovable_objects_claims
	WHERE ID = in_unmovableID
	limit 1;

	if(targetUnmovableID is null) then
		return 0;
	end if;

	return fb_setUnmovableRuleGuildRole(in_producerCharID, targetClaimID, targetUnmovableID, in_targetGuildRoleID, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS fb_setUnmovableRuleGuildStandingByGuildId;
CREATE FUNCTION fb_setUnmovableRuleGuildStandingByGuildId(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_guildLandType INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildStandingID INT UNSIGNED,
	in_canUse TINYINT UNSIGNED,
	in_canDestroy TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
BEGIN

	declare targetClaimID int unsigned default NULL;
	declare targetUnmovableID int unsigned default NULL;

	select uoc.ClaimID
	into targetClaimID
	from unmovable_objects_claims as uoc
	where uoc.ID = in_unmovableID
	limit 1;

	if(targetClaimID is null) then
		return 0;
	end if;

	select UnmovableObjectID
	into targetUnmovableID
	from unmovable_objects_claims
	WHERE ID = in_unmovableID
	limit 1;

	if(targetUnmovableID is null) then
		return 0;
	end if;

	return fb_setUnmovableRuleGuildStanding(in_producerCharID, targetClaimID, targetUnmovableID, in_targetGuildStandingID, in_canUse, in_canDestroy);

END;

DROP FUNCTION IF EXISTS fb_removeUnmovableRuleChar;
CREATE FUNCTION fb_removeUnmovableRuleChar(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetCharID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_unmovable_char_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
	) then
		return 0;
	end if;
	
	-- check if unmovable actually belongs to the given claim
	if(!exists(
		select *
		from unmovable_objects_claims
		where ClaimID = in_claimID and UnmovableObjectID = in_unmovableID
		)
	) then
		return 0;
	end if;
	
	-- check if current rule exists
	if(!exists(
		select *
		from claim_subjects cs
		inner join claim_rules_unmovable cr on cr.ClaimSubjectID = cs.ID
		inner join unmovable_objects_claims uoc on uoc.ID = cr.UnmovableClaimID
		where uoc.ClaimID = in_claimID
			and uoc.UnmovableObjectID = in_unmovableID
			and cs.CharID = in_targetCharID
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, CharID, UnmovableObjectID)
	values('remove_unmovable_char_rule', ticket, in_producerCharID, in_targetCharID, in_unmovableID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_removeUnmovableRuleGuildRole;
CREATE FUNCTION fb_removeUnmovableRuleGuildRole(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildRoleID TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_unmovable_role_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
	) then
		return 0;
	end if;
	
	-- check if unmovable actually belongs to the given claim
	if(!exists(
		select *
		from unmovable_objects_claims
		where ClaimID = in_claimID and UnmovableObjectID = in_unmovableID
		)
	) then
		return 0;
	end if;
	
	-- check if current rule exists
	if(!exists(
		select *
		from claim_subjects cs
		inner join claim_rules_unmovable cr on cr.ClaimSubjectID = cs.ID
		inner join unmovable_objects_claims uoc on uoc.ID = cr.UnmovableClaimID
		where uoc.ClaimID = in_claimID
			and uoc.UnmovableObjectID = in_unmovableID
			and cs.GuildRoleID = in_targetGuildRoleID
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, CharGuildRoleID, UnmovableObjectID)
	values('remove_unmovable_role_rule', ticket, in_producerCharID, in_targetGuildRoleID, in_unmovableID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_removeUnmovableRuleGuild;
CREATE FUNCTION fb_removeUnmovableRuleGuild(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildID INT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_unmovable_guild_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
	) then
		return 0;
	end if;
	
	-- check if unmovable actually belongs to the given claim
	if(!exists(
		select *
		from unmovable_objects_claims
		where ClaimID = in_claimID and UnmovableObjectID = in_unmovableID
		)
	) then
		return 0;
	end if;
	
	-- check if current rule exists
	if(!exists(
		select *
		from claim_subjects cs
		inner join claim_rules_unmovable cr on cr.ClaimSubjectID = cs.ID
		inner join unmovable_objects_claims uoc on uoc.ID = cr.UnmovableClaimID
		where uoc.ClaimID = in_claimID
			and uoc.UnmovableObjectID = in_unmovableID
			and cs.GuildID = in_targetGuildID
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, UnmovableObjectID)
	values('remove_unmovable_guild_rule', ticket, in_producerCharID, in_targetGuildID, in_unmovableID);
			
	return ticket;

END;

DROP FUNCTION IF EXISTS fb_removeUnmovableRuleGuildStanding;
CREATE FUNCTION fb_removeUnmovableRuleGuildStanding(
	in_producerCharID INT UNSIGNED,
	in_claimID INT UNSIGNED,
	in_unmovableID INT UNSIGNED,
	in_targetGuildStandingID TINYINT UNSIGNED
)
	RETURNS BIGINT UNSIGNED
	MODIFIES SQL DATA
	COMMENT 'Register "remove_unmovable_standing_rule" action. Return action ticket ID if succeeded or return 0 if can''t register action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- check char rights
	if(
		!exists( -- producer should be leader of guild claim
			select *
			from claims cl
			join guild_lands gl on gl.ID = cl.GuildLandID
			join guilds g on g.ID = gl.GuildID and g.IsActive = 1
			join `character` ch on ch.GuildID = g.ID
			where cl.ID = in_claimID and cl.PersonalLandID is null
				and ch.ID = in_producerCharID
				and (ch.GuildRoleID = 1 /*Leader*/ or ch.GuildRoleID = 2 /* Minor Leader*/)
		)
		and !exists( -- or producer should be owner of personal claim
			select *
			from claims cl
			join personal_lands pl on pl.ID = cl.PersonalLandID
			where cl.ID = in_claimID and cl.GuildLandID is null
				and pl.CharID = in_producerCharID
		)
	) then
		return 0;
	end if;
	
	-- check if unmovable actually belongs to the given claim
	if(!exists(
		select *
		from unmovable_objects_claims
		where ClaimID = in_claimID and UnmovableObjectID = in_unmovableID
		)
	) then
		return 0;
	end if;
	
	-- check if current rule exists
	if(!exists(
		select *
		from claim_subjects cs
		inner join claim_rules_unmovable cr on cr.ClaimSubjectID = cs.ID
		inner join unmovable_objects_claims uoc on uoc.ID = cr.UnmovableClaimID
		where uoc.ClaimID = in_claimID
			and uoc.UnmovableObjectID = in_unmovableID
			and cs.StandingTypeID = in_targetGuildStandingID
	)) then
		return 0;
	end if;
	
	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, StandingTypeID, UnmovableObjectID)
	values('remove_unmovable_standing_rule', ticket, in_producerCharID, in_targetGuildStandingID, in_unmovableID);
			
	return ticket;

END;

DROP PROCEDURE IF EXISTS `p_deleteUnmovableClaim`;
CREATE PROCEDURE `p_deleteUnmovableClaim`(
	in_unmovableObjectID INT UNSIGNED
)
	COMMENT 'Register "set_guild_heraldry" action'
BEGIN
	declare unmovableObjectClaimID int unsigned default 0;
	
	select ID
	into unmovableObjectClaimID 
	from `unmovable_objects_claims`
	where UnmovableObjectID = in_unmovableObjectID;
	
	delete from `claim_rules_unmovable` where UnmovableClaimID = unmovableObjectClaimID;
	delete from `unmovable_objects_claims` where ID = unmovableObjectClaimID;
END;

DROP PROCEDURE IF EXISTS `p_onNewGuildHeraldry`;
CREATE PROCEDURE `p_onNewGuildHeraldry`(
	in_producerCharID INT UNSIGNED,
	in_guildID INT UNSIGNED,
	in_heraldryID INT UNSIGNED
)
	COMMENT 'Register "set_guild_heraldry" action'
BEGIN

	declare ticket bigint unsigned default 0;

	-- register action
	set ticket = f_genUniqueU64();
	
	insert into guild_actions_queue (ActionType, TicketID, ProducerCharID, GuildID, HeraldryID)
	values('set_guild_heraldry', ticket, in_producerCharID, in_guildID, in_heraldryID);
	
END;

-- access to character IDs. Empty result set means error
DROP PROCEDURE IF EXISTS `p_issueIdRange_character`;
CREATE PROCEDURE `p_issueIdRange_character`
(
	in_serverID INT UNSIGNED,
	in_idCount INT UNSIGNED,
	in_isForce TINYINT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Return character IDs which available for concrete server to insert'
BEGIN

declare rangeID, startID, endID, currFreeIdCount, currMaxUsedId, maxUsedId int unsigned default 0;
declare maxIssuedId int unsigned default NULL;
declare errorFlag, cursorDone tinyint unsigned default FALSE;

declare rangeCursor cursor for
(
	select ID, RangeStartID, RangeEndID
	from `character_server_id_ranges`
	where ServerID = in_serverID
	order by RangeStartID -- ordering for consecutive ID using
	for update
);
declare continue handler for not found set cursorDone = TRUE;

-- mysql does not stop procedure execution on errors, so do it manually
declare continue handler for sqlexception
begin
	-- "leave this_sp;" can't be called here, so use flag
	set errorFlag = TRUE;
end;

start transaction;

-- We using the character_server_id_ranges_lock table like a mutex - lock it at transaction start,
-- and release it on commit/rollback. This ugly solution provides us a 100% deadlock protection when
-- this procedure runs simultaneously from several sessions.
-- If you don't care about deadlocks, you can simply skip this insert - all locking logic below
-- still provide data consistent and prevent any range intersections (but don't save you from deadlocks)
insert into `character_server_id_ranges_lock` (ID, IsLocked) values (1, 1)
	on duplicate key update IsLocked=1;

-- Get max issued ID before we delete any range.
-- This operation give us currently maximum claimed ID with blocking from same queries and
-- from inserting into the gap just before max(RangeEndID) and after max(RangeEndID)
select max(RangeEndID)
	into maxIssuedId
	from `character_server_id_ranges`
	for update;
	
-- parse existing ranges when we are not forced to insert new range
if(in_isForce = 0) then
	open rangeCursor;

	-- get max used id from all ranges and block these ranges from inserts
	range_loop: loop
		fetch rangeCursor into rangeID, startID, endID;
		if(cursorDone) then
			leave range_loop;
		end if;
		
		select max(ID)
			into currMaxUsedId
			from `character`
			where ID >= startID and ID <= endID
			for update;

		if(ifnull(currMaxUsedId, 0) > maxUsedId) then
			set maxUsedId = currMaxUsedId;
		end if;
	end loop;
	close rangeCursor;

	-- re-use cursor for iterate thru all exists server ranges again and check it to exceed maxUsedId
	set cursorDone = FALSE;
	open rangeCursor;
	range_loop: loop
		fetch rangeCursor into rangeID, startID, endID;
		if(cursorDone) then
			leave range_loop;
		end if;

		-- at first validate range
		if(startID > endID) then
			-- delete invalid range
			delete from `character_server_id_ranges`
				where ID = rangeID;
		else
			-- range is valid
			if(maxUsedId < startID) then
				-- range have no any used ids
				set currFreeIdCount = (currFreeIdCount + (endID - startID) + 1);
			elseif(maxUsedId >= startID and maxUsedId < endID) then
				-- range have some used ids
				set currFreeIdCount = (currFreeIdCount + (endID - maxUsedId));
				update `character_server_id_ranges`
					set RangeStartID = (maxUsedId + 1)
						-- , RangeEndID = endID
					where ID = rangeID;
			else -- if(maxUsedId >= endID) then
				-- range is full or maxUsedId is out of range bounds
				delete from `character_server_id_ranges`
					where ID = rangeID;
			end if;
		end if;

	end loop;

	close rangeCursor;
end if;

if(currFreeIdCount < in_idCount or in_isForce > 0) then
	-- reserve new ID range
		
	-- compatibility with old auto_increment IDs
	if(maxIssuedId is null) then
		select max(ID)
			into maxIssuedId
			from `character`
			for update;
	end if;

	-- We reserve new range with full size of in_idCount. This save us from inserting small ranges
	-- each time this procedure called
	set startID = (ifnull(maxIssuedId, 0) + 1);
	set endID = (startID + in_idCount - 1);
		
	-- remember new range
	insert into `character_server_id_ranges`
		(ServerID, RangeStartID, RangeEndID)
		values (in_serverID, startID, endID);
end if;

-- return result
if(!errorFlag) then
	select RangeStartID, RangeEndID
		from `character_server_id_ranges`
		where ServerID = in_serverID
		order by RangeStartID;
	
	commit;
else -- in case of error
	rollback;
end if;

END;

-- check consistent of character_server_id_ranges
DROP PROCEDURE IF EXISTS `p_dbg_checkIdRangeConsistent_character`;
CREATE PROCEDURE `p_dbg_checkIdRangeConsistent_character` ()
	LANGUAGE SQL
	NOT DETERMINISTIC
	COMMENT 'Check consistent of content of character_server_id_ranges table. OK when no rows returned, else shows range intersections'
BEGIN

select * from `character_server_id_ranges` r1
where exists (
	select * from `character_server_id_ranges` r2 where r2.ID != r1.ID 
	and (
		(r1.RangeEndID between r2.RangeStartID and r2.RangeEndID) or
		(r1.RangeStartID between r2.RangeStartID and r2.RangeEndID) or
		(r1.RangeStartID <= r2.RangeStartID and r1.RangeEndID >= r2.RangeEndID)
	)
);

END;

-- mark ID as used. Call it each time you are going to insert new ID into character
DROP PROCEDURE IF EXISTS `p_occupyId_character`;
CREATE PROCEDURE `p_occupyId_character`
(
	in_serverID INT UNSIGNED,
	in_id INT UNSIGNED
)
	LANGUAGE SQL
	NOT DETERMINISTIC
	MODIFIES SQL DATA
	COMMENT 'Modifies character ID ranges for concrete server so given ID will never be used again'
BEGIN

update character_server_id_ranges
set RangeStartID = (in_id + 1)
where ServerID = in_serverID and
	in_id >= RangeStartID and in_id <= RangeEndID;

END;


-- WARNING: run this line last!
UPDATE `_patch_execute_status` SET `Value` = 1;
