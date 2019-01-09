function ShapeBase::use(%this, %data)
{
    if (%this.getInventory(%data) > 0)
    {
        return %data.onUse(%this);
    }
    return 0;
}
function ShapeBase::throw(%this, %data, %amount)
{
    if (%this.getInventory(%data) > 0)
    {
        %obj = %data.onThrow(%this, %amount);
        if (%obj)
        {
            %this.throwObject(%obj);
            return 1;
        }
    }
    return 0;
}
function ShapeBase::pickup(%this, %obj, %amount)
{
    %data = %obj.getDataBlock();
    if (%amount $= "")
    {
        %amount = %this.maxInventory(%data) - %this.getInventory(%data);
    }
    if (%amount < 0)
    {
        %amount = 0;
    }
    if (%amount)
    {
        return %data.onPickup(%obj, %this, %amount);
    }
    return 0;
}
function ShapeBase::hasInventory(%this, %data)
{
    return %this.inv[%data] > 0;
}
function ShapeBase::hasAmmo(%this, %weapon)
{
    if (%weapon.image.ammo $= "")
    {
        return 1;
    }
    else
    {
        return %this.getInventory(%weapon.image.ammo) > 0;
    }
}
function ShapeBase::maxInventory(%this, %data)
{
    return %this.getDataBlock().maxInv[%data.getName()];
}
function ShapeBase::incInventory(%this, %data, %amount)
{
    %max = %this.maxInventory(%data);
    %total = %this.inv[%data.getName()];
    if (%total < %max)
    {
        if ((%total + %amount) > %max)
        {
            %amount = %max - %total;
        }
        %this.setInventory(%data, %total + %amount);
        return %amount;
    }
    return 0;
}
function ShapeBase::decInventory(%this, %data, %amount)
{
    %total = %this.inv[%data.getName()];
    if (%total > 0)
    {
        if (%total < %amount)
        {
            %amount = %total;
        }
        %this.setInventory(%data, %total - %amount);
        return %amount;
    }
    return 0;
}
function ShapeBase::getInventory(%this, %data)
{
    return %this.inv[%data.getName()];
}
function ShapeBase::setInventory(%this, %data, %value)
{
    if (%value < 0)
    {
        %value = 0;
    }
    else
    {
        %max = %this.maxInventory(%data);
        if (%value > %max)
        {
            %value = %max;
        }
    }
    %name = %data.getName();
    if (%this.inv[%name] != %value)
    {
        %this.inv[%name] = %value;
        %data.onInventory(%this, %value);
        %this.getDataBlock().onInventory(%data, %value);
    }
    return %value;
}
function ShapeBase::clearInventory(%this)
{
}
function ShapeBase::throwObject(%this, %obj)
{
    %throwForce = %this.throwForce;
    if (!%throwForce)
    {
        %throwForce = 20;
    }
    %eye = %this.getEyeVector();
    %vec = VectorScale(%eye, %throwForce);
    %verticalForce = %throwForce / 2;
    %dot = VectorDot("0 0 1", %eye);
    if (%dot < 0)
    {
        %dot = -%dot;
    }
    %vec = VectorAdd(%vec, VectorScale("0 0 " @ %verticalForce, 1 - %dot));
    %vec = VectorAdd(%vec, %this.getVelocity());
    %pos = getBoxCenter(%this.getWorldBox());
    %obj.setTransform(%pos);
    %obj.applyImpulse(%pos, %vec);
    %obj.setCollisionTimeout(%this);
}
function ShapeBase::onInventory(%this, %data, %value)
{
}
function ShapeBaseData::onUse(%this, %user)
{
    echo("ShapeBaseData::onUse");
    return 0;
}
function ShapeBaseData::onThrow(%this, %user, %amount)
{
    return 0;
}
function ShapeBaseData::onPickup(%this, %obj, %user, %amount)
{
    return 0;
}
function ShapeBaseData::onInventory(%this, %user, %value)
{
}
