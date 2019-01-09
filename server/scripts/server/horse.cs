$CorpseTimeoutValue = 3 * 1000;
$DamageLava = 0.01;
$DamageHotLava = 0.01;
$DamageCrustyLava = 0.01;
$HorseDeathAnim::TorsoFrontFallForward = 1;
$HorseDeathAnim::TorsoFrontFallBack = 2;
$HorseDeathAnim::TorsoBackFallForward = 3;
$HorseDeathAnim::TorsoLeftSpinDeath = 4;
$HorseDeathAnim::TorsoRightSpinDeath = 5;
$HorseDeathAnim::LegsLeftGimp = 6;
$HorseDeathAnim::LegsRightGimp = 7;
$HorseDeathAnim::TorsoBackFallForward = 8;
$HorseDeathAnim::HeadFrontDirect = 9;
$HorseDeathAnim::HeadBackFallForward = 10;
$HorseDeathAnim::ExplosionBlowBack = 11;
function HorseData::create(%data)
{
    %obj = new horse("")
    {
        .dataBlock = %data;
    };
    return %obj;
}
function HorseData::onAdd(%this, %obj)
{
    Parent::onAdd(%this, %obj);
    MissionCleanup.add(%obj);
}
function Steed::onAdd(%this, %obj)
{
    Parent::onAdd(%this, %obj);
    %obj.mountVehicle = 1;
    %obj.setRepairRate(%this.repairRate);
    if (!(%obj.HorseName $= ""))
    {
        %obj.setShapeName(%obj.HorseName);
    }
    if (!(%this.saddle $= ""))
    {
        %obj.mountImage(%this.saddle, 0);
    }
    if (!(%this.headpiece $= ""))
    {
        %obj.mountImage(%this.headpiece, 1);
    }
    if (!(%this.frontpiece $= ""))
    {
        %obj.mountImage(%this.frontpiece, 2);
    }
    if (!(%this.neckpiece $= ""))
    {
        %obj.mountImage(%this.neckpiece, 3);
    }
    if (!(%this.rearpiece $= ""))
    {
        %obj.mountImage(%this.rearpiece, 4);
    }
}
function Steed::onRemove(%this, %obj)
{
    if (%obj.client.horse == %obj)
    {
        %obj.client.horse = 0;
    }
}
function Steed::onNewDataBlock(%this, %obj)
{
}
function Steed::onRearing(%this, %obj)
{
    %obj.playPain();
}
function Steed::onCollision(%this, %obj, %col, %vec, %speed)
{
}
function Steed::onImpact(%this, %obj, %collidedObject, %vec, %vecLen)
{
    if (%collidedObject && (%collidedObject.getType() & $TypeMasks::TerrainObjectType))
    {
        return;
    }
    %obj.damage(0, VectorAdd(%obj.getPosition(), %vec), %vecLen * %this.speedDamageScale, "Impact");
}
function Steed::damage(%this, %obj, %sourceObject, %position, %damage, %damageType)
{
    if (%obj.getState() $= "Dead")
    {
        return;
    }
    %obj.applyDamage(%damage, %obj);
    %location = "Body";
}
function Steed::onDamage(%this, %obj, %delta)
{
}
function Steed::onDisabled(%this, %obj, %state)
{
    %player = %obj.getMountedObject(0);
    if (isObject(%player))
    {
        %obj.unmountObject(%player);
        %player.playDeathAnimation();
        %client = %player.client;
    }
    %obj.playDeathCry();
    %obj.playDeathAnimation();
    %obj.setDamageFlash(0.75);
    %obj.setImageTrigger(0, 0);
    %obj.schedule($CorpseTimeoutValue - 1000, "startFade", 1000, 0, 1);
    %obj.schedule($CorpseTimeoutValue, "delete");
}
function Steed::onLeaveMissionArea(%this, %obj)
{
    %obj.client.onLeaveMissionArea();
}
function Steed::onEnterMissionArea(%this, %obj)
{
    %obj.client.onEnterMissionArea();
}
function Steed::onEnterLiquid(%this, %obj, %coverage, %type)
{
    if (%type == 0)
    {
    }
    else
    {
        if (%type == 1)
        {
        }
        else
        {
            if (%type == 2)
            {
            }
            else
            {
                if (%type == 3)
                {
                }
                else
                {
                    if (%type == 4)
                    {
                        %obj.setDamageDt(%this, $DamageLava, "Lava");
                    }
                    else
                    {
                        if (%type == 5)
                        {
                            %obj.setDamageDt(%this, $DamageHotLava, "Lava");
                        }
                        else
                        {
                            if (%type == 6)
                            {
                                %obj.setDamageDt(%this, $DamageCrustyLava, "Lava");
                            }
                            else
                            {
                                if (%type == 7)
                                {
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
function Steed::onLeaveLiquid(%this, %obj, %type)
{
    %obj.clearDamageDt();
}
function Steed::onTrigger(%this, %obj, %triggerNum, %val)
{
}
function horse::kill(%this, %damageType)
{
    %this.damage(0, %this.getPosition(), 10000, %damageType);
}
function horse::playDeathAnimation(%this)
{
    if (%this.deathIdx = %this.deathIdx + 1 > 11)
    {
        %this.deathIdx = 1;
    }
    %this.setActionThread("Death" @ %this.deathIdx);
}
function horse::playCelAnimation(%this, %anim)
{
    if (!(%this.getState() $= "Dead"))
    {
        %this.setActionThread("cel" @ %anim);
    }
}
function horse::playDeathCry(%this)
{
    %this.playAudio(0, SteedDeathCrySound);
}
function horse::playPain(%this)
{
    %this.playAudio(0, SteedPainCrySound);
}
