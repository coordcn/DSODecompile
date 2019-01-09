function ShapeBase::doRaycast(%this, %range, %mask)
{
    %eyeVec = %this.getEyeVector();
    %eyeTrans = %this.getEyeTransform();
    %eyePos = getWord(%eyeTrans, 0) SPC getWord(%eyeTrans, 1) SPC getWord(%eyeTrans, 2);
    %nEyeVec = VectorNormalize(%eyeVec);
    %scEyeVec = VectorScale(%nEyeVec, %range);
    %eyeEnd = VectorAdd(%eyePos, %scEyeVec);
    %searchResult = containerRayCast(%eyePos, %eyeEnd, %mask, %this);
    return %searchResult;
}
function ShapeBase::damage(%this, %sourceObject, %position, %damage, %damageType)
{
    if (isObject(%this))
    {
        %this.getDataBlock().damage(%this, %sourceObject, %position, %damage, %damageType);
    }
}
function ShapeBase::setDamageDt(%this, %damageAmount, %damageType)
{
    if (!(%this.getState() $= "Dead"))
    {
        %this.damage(0, "0 0 0", %damageAmount, %damageType);
        %this.damageSchedule = %this.schedule(50, "setDamageDt", %damageAmount, %damageType);
    }
    else
    {
        %this.damageSchedule = "";
    }
}
function ShapeBase::clearDamageDt(%this)
{
    if (!(%this.damageSchedule $= ""))
    {
        cancel(%this.damageSchedule);
        %this.damageSchedule = "";
    }
}
function ShapeBaseData::damage(%this, %obj, %position, %source, %amount, %damageType)
{
}
