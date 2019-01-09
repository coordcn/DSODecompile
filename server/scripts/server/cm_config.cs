$cm_config::DB::keepConnection = 1;
$cm_config::Server::TerrainXCount = 3;
$cm_config::Server::TerrainYCount = 3;
$cm_config::Server::ServerXCount = 1;
$cm_config::Server::ServerYCount = 1;
$cm_config::Server::TerrainSkipCount = 441;
$cm_config::Server::ServerSkipCount = 0;
$cm_config::Terrain::AllowedTunnelNearness = 2;
$cm_config::Terrain::HeightAdjustRaise = 0.2;
$cm_config::Terrain::HeightAdjustLower = -0.2;
$cm_config::Terrain::DigAdjust = 1;
$cm_config::Terrain::MaxAltitudeDiffBeforeFall = 8;
$cm_config::Terrain::SlopeFlattenDiff = 1;
$cm_config::Terrain::HeightRaiseTime = 1000;
$cm_config::Terrain::HeightLowerTime = 1000;
$cm_config::Terrain::DigTime = 1000;
$cm_config::Terrain::FlattenTime = 1000;
$cm_config::Terrain::SlopeFlattenTime = 1000;
$cm_config::Terrain::ClaimRenderDistance = 800;
$cm_config::Building::IterationTime = 5000;
$cm_config::Building::MaxIterationQuantity = 100;
$cm_config::Geo::QuantityPerLevel = 3000;
$cm_config::Geo::QuantityMass = 0.01;
$cm_config::Geo::QuantityMassMining = 0.01;
$cm_config::Geo::QuantityDamagePerDig = 60000;
$cm_config::Geo::QuantityDamagePerLower = 3000;
$cm_config::Geo::TunnellingRockRatio = 0.5;
$cm_config::Geo::TimberIntersectPercentForArm = 50;
$cm_config::Geo::LightTimberWidth = 0.3;
$cm_config::Geo::HeavyTimberWidth = 0.4;
$cm_config::Geo::TunnelBaseDecayResource = 8;
$cm_config::Geo::LightTimberDefaultDecayResource = 10;
$cm_config::Geo::TunnelDecayValue = 1;
$cm_config::Geo::LightTimberDecayValue = 1;
$cm_config::Geo::HeavyTimberDecayValue = 1;
$cm_config::SkillRaise::GlobalMult = 20;
$cm_config::Wounds::DurationMult = 1;
$cm_config::ObserveTerrain::RadiusX = 11;
$cm_config::ObserveTerrain::RadiusY = 11;
$craftworkTickMs = 60000;
$TrainingField::mTrainFoodConsumption = 0.2;
$Stable::stableTickMs = 3600000;
$Stable::BreedingPairPen = 0.025;
$Stable::BreedingNonpair = 0.02;
$Stable::BreedingPairFree = 0.04;
$Ability::GMAbilityDuration = 1000;
$Ability::GMChancePercent = 0;
$Ability::YOMinigameDuration = 5000;
$Ability::AbilityDurationGlobalMultiplier = 1;
$cm_config::hungerIdleLossPerSecond = 0.0025;
function cm_config_CalcPlayerDmgByHit(%hitSpeed, %hitNodeName, %hitBoxName, %groupDmgLevel, %chargeTime)
{
    %node_mul = 0;
    %box_mul = 0;
    if (%hitNodeName $= "Slashing")
    {
        %node_mul = 1.7;
    }
    else
    {
        if (%hitNodeName $= "Piercing")
        {
            %node_mul = 2;
        }
        else
        {
            if (%hitNodeName $= "Blunt")
            {
                %node_mul = 1.1;
            }
            else
            {
                %hitNodeName = "Unknown";
            }
        }
    }
    if (%hitBoxName $= "Shield")
    {
        %box_mul = 0;
    }
    else
    {
        if (%hitBoxName $= "Head")
        {
            %box_mul = 10;
        }
        else
        {
            if (%hitBoxName $= "Torso")
            {
                %box_mul = 8;
            }
            else
            {
                if (%hitBoxName $= "RightArm")
                {
                    %box_mul = 3.8;
                }
                else
                {
                    if (%hitBoxName $= "RightForearm")
                    {
                        %box_mul = 2.1;
                    }
                    else
                    {
                        if (%hitBoxName $= "LeftArm")
                        {
                            %box_mul = 3.2;
                        }
                        else
                        {
                            if (%hitBoxName $= "LeftForearm")
                            {
                                %box_mul = 2;
                            }
                            else
                            {
                                if (%hitBoxName $= "RightThigh")
                                {
                                    %box_mul = 4;
                                }
                                else
                                {
                                    if (%hitBoxName $= "RightShin")
                                    {
                                        %box_mul = 3.3;
                                    }
                                    else
                                    {
                                        if (%hitBoxName $= "LeftThigh")
                                        {
                                            %box_mul = 4;
                                        }
                                        else
                                        {
                                            if (%hitBoxName $= "LeftShin")
                                            {
                                                %box_mul = 3.3;
                                            }
                                            else
                                            {
                                                %hitBoxName = "Unknown";
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    %ret = ((((%hitSpeed / 30) * %node_mul) * %box_mul) * %groupDmgLevel) + %chargeTime;
    echo("DMG_CALC speed=" @ %hitSpeed @ " hitbox=" @ %hitBoxName @ " hit=" @ %hitNodeName @ " dmgLevel=" @ %groupDmgLevel @ " chrgTime=" @ %chargeTime @ "sec, ret=" @ %ret);
    return %ret;
}
$hit_scale = 1;
$hit_scale_wait = 0.01;
function cm_config_CalcPlayerHitTimeScale(%lvl)
{
    return $hit_scale;
}
function cm_config_CalcPlayerPostHitTimeScale(%lvl)
{
    return $hit_scale_wait;
}
$cm_config::Criminals::DamagedSomeone = -2;
$cm_config::Criminals::KnockedOutSomeone = -3;
$cm_config::Criminals::KilledSomeone = -10;
$cm_config::Criminals::LootedSomeone = -3;
$cm_config::Criminals::TrespassedSomething = -1;
$cm_config::SkillLoss::Default = 1;
$cm_config::SkillLoss::Bad = 1.5;
$cm_config::SkillLoss::Evil = 6;
$cm_config::Claims::guildLevel1RadiusTown = 20;
$cm_config::Claims::guildLevel1RadiusCountry = 20;
$cm_config::Claims::guildLevel2RadiusTown = 30;
$cm_config::Claims::guildLevel2RadiusCountry = 30;
$cm_config::Claims::guildLevel3RadiusTown = 50;
$cm_config::Claims::guildLevel3RadiusCountry = 50;
$cm_config::Claims::guildLevel4RadiusTown = 100;
$cm_config::Claims::guildLevel4RadiusCountry = 100;
$cm_config::Claims::guildLevel1MinSacrificeBasePrice = 1;
$cm_config::Claims::guildLevel2MinSacrificeBasePrice = 10;
$cm_config::Claims::guildLevel3MinSacrificeBasePrice = 50;
$cm_config::Claims::guildLevel4MinSacrificeBasePrice = 100;
$cm_config::Claims::GuildCellPrice = 1;
$cm_config::Claims::MonumentGrowth = 0.05;
$cm_config::Decay::HorsesDecayTimeMinutes = 0;
$cm_config::JudgementHour::headPrice = 100;
$cm_config::SiegeDamage::destructible = 0.002;
$cm_config::DropPosition::AllowedPenetration = 0.05;
$cm_config::DropPosition::LockedHeightOver = 0.2;
$cm_config::Knockouts::yieldKnockoutInterval = 3;
$cm_config::Potions::maxPotionAmount = 3;
$cm_config::Potions::maxPoisonWeaponAmount = 3;
$cm_config::HorseTrainingTimeSec = 300;
$sHorseTrembleConst = 0.003;
$cm_config::TrainingField::ProbabilityOfRoyalHorsePCT = 3;
$cm_config::WindMillChurnRate = 2;
$cm_config::Animals::AnimalMaxHeightHit = 2;
$cm_config::WorkingContainerBaseTimeMs = 3600000;
$cm_config::FireAbility::FireTimeMinutes = 60;
$Guilds::GuildUpdateTypeToOrderMemberCount = 1;
$cm_config::HomecomingDrop = 0;
$cm_config::Guilds::HeraldryChangingCooldownSec = 86400;
$cm_config::OutpostClaimDurationMin = 10;
$RepairAbility::SmallRepairKitPrice = 1;
$RepairAbility::MediumRepairKitPrice = 10;
$RepairAbility::LargeRepairKitPrice = 100;

