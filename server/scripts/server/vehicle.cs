function VehicleData::onAdd(%this, %obj)
{
    if (%obj.mountable && (%obj.mountable $= ""))
    {
        %this.isMountable(%obj, 1);
    }
    else
    {
        %this.isMountable(%obj, 0);
    }
    if (!(%this.nameTag $= ""))
    {
        %obj.setShapeName(%this.nameTag);
    }
}
function VehicleData::onRemove(%this, %obj)
{
    %i = 0;
    while (%i < %obj.getDataBlock().numMountPoints)
    {
        if (%obj.getMountNodeObject(%i))
        {
            %passenger = %obj.getMountNodeObject(%i);
            %passenger.getDataBlock().doDismount(%passenger, 1);
        }
        %i = %i + 1;
    }
}
function VehicleData::isMountable(%this, %obj, %val)
{
    %obj.mountable = %val;
}
function VehicleData::mountPlayer(%this, %vehicle, %player)
{
    if (isObject(%vehicle) && !((%vehicle.getDamageState() $= "Destroyed")))
    {
        %player.startFade(1000, 0, 1);
        %this.schedule(1000, "setMountVehicle", %vehicle, %player);
        %player.schedule(1500, "startFade", 1000, 0, 0);
    }
}
function VehicleData::setMountVehicle(%this, %vehicle, %player)
{
    if (isObject(%vehicle) && !((%vehicle.getDamageState() $= "Destroyed")))
    {
        %node = %this.findEmptySeat(%vehicle, %player);
        if (%node >= 0)
        {
            %vehicle.mountObject(%player, %node);
            %player.mVehicle = %vehicle;
        }
    }
}
function VehicleData::findEmptySeat(%this, %vehicle, %player)
{
    %i = 0;
    while (%i < %this.numMountPoints)
    {
        %node = %vehicle.getMountNodeObject(%i);
        if (%node == 0)
        {
            return %i;
        }
        %i = %i + 1;
    }
    return -1;
}
function VehicleData::switchSeats(%this, %vehicle, %player)
{
    %i = 0;
    while (%i < %this.numMountPoints)
    {
        %node = %vehicle.getMountNodeObject(%i);
        if ((%node == %player) && (%node > 0))
        {
            continue;
        }
        if (%node == 0)
        {
            return %i;
        }
        %i = %i + 1;
    }
    return -1;
}
