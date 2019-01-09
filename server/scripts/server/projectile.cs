function projectileData::onCollision(%data, %proj, %col, %fade, %pos, %normal)
{
    if (%data.directDamage > 0)
    {
        if (%col.getType() & $TypeMasks::ShapeBaseObjectType)
        {
            %col.damage(%proj.sourceObject, %pos, %data.directDamage, %data.damageType);
        }
    }
}
function projectileData::onExplode(%data, %proj, %position, %mod)
{
    if (%data.damageRadius > 0)
    {
        radiusDamage(%proj.sourceObject, %position, %data.damageRadius, %data.radiusDamage, %data.damageType, %data.areaImpulse);
    }
}
function ArrowData::onCollision(%data, %arrow, %obj, %fade, %pos, %normal)
{
    %obj.OnArrowDamage(%arrow, %data, %pos, %normal);
}
function Player::OnArrowDamage(%this, %arrow, %arrowData, %pos, %normal)
{
    %this.applyDamage(10, %arrow);
}
function SceneObject::OnArrowDamage(%this, %arrow, %arrowData, %pos, %normal)
{
}
function BowImage::OnCharge(%this, %obj, %slot)
{
    %this.ChargeTime = %this.ChargeTime + %this.stateTimeoutValue[8];
    if (%this.ChargeTime > %this.chargeTimeMax)
    {
        %this.ChargeTime = %this.chargeTimeMax;
    }
    %progress = (%this.ChargeTime - %this.chargeTimeMin) / (%this.chargeTimeMax - %this.chargeTimeMin);
    if (%progress < 0)
    {
        %progress = 0;
    }
    if (%progress > 1)
    {
        %progress = 1;
    }
}
function BowImage::onFire(%this, %obj, %slot)
{
    echo("BowImage::OnFire: It works!");
    if (!%this.infiniteAmmo)
    {
        %obj.decInventory(%this.ammo, 1);
    }
    %projectile = %this.arrow;
    %scatter = %this.scatter;
    %objectVelocity = %obj.getVelocity();
    if (VectorLen(%objectVelocity) > 1)
    {
        %scatter = 0.1;
    }
    if (1)
    {
        %vec = %obj.getMuzzleVector(%slot);
        %i = 0;
        while (%i < 3)
        {
            %matrix = %matrix @ (((getRandom() - 0.5) * 2) * 3.14159) * %scatter @ " ";
            %i = %i + 1;
        }
        %mat = MatrixCreateFromEuler(%matrix);
        %muzzleVector = MatrixMulVector(%mat, %vec);
    }
    else
    {
        %muzzleVector = %obj.getMuzzleVector(%slot);
    }
    %vmin = %this.initialVelocityMin;
    %vmax = %this.initialVelocityMax;
    %tmin = %this.chargeTimeMin;
    %tmax = %this.chargeTimeMax;
    %t = %this.ChargeTime;
    if (%t >= %tmin)
    {
        %muzzleVelocity = VectorScale(%muzzleVector, %vmin + ((%vmax - %vmin) * ((%t - %tmin) / (%tmax - %tmin))));
    }
    else
    {
        %muzzleVelocity = VectorScale(%muzzleVector, %vmin);
    }
    %muzzleVelocity = VectorAdd(%muzzleVelocity, %objectVelocity);
    %p = new ArrowProjectile("")
    {
        .dataBlock = %projectile;
        .initialVelocity = %muzzleVelocity;
        .initialPosition = %obj.getMuzzlePoint(%slot);
        .sourceObject = %obj;
        .sourceSlot = %slot;
        .client = %obj.client;
    };
    MissionCleanup.add(%p);
    %this.ChargeTime = 0;
    return %p;
}
function CrossbowImage::onFire(%this, %obj, %slot)
{
    echo("BowImage::OnFire: It works!");
    if (!%this.infiniteAmmo)
    {
        %obj.decInventory(%this.ammo, 1);
    }
    %projectile = %this.arrow;
    if (1)
    {
        %vec = %obj.getMuzzleVector(%slot);
        %i = 0;
        while (%i < 3)
        {
            %matrix = %matrix @ (((getRandom() - 0.5) * 2) * 3.14159) * %this.scatter @ " ";
            %i = %i + 1;
        }
        %mat = MatrixCreateFromEuler(%matrix);
        %muzzleVector = MatrixMulVector(%mat, %vec);
    }
    else
    {
        %muzzleVector = %obj.getMuzzleVector(%slot);
    }
    %vmax = %this.initialVelocityMax;
    %muzzleVelocity = VectorScale(%muzzleVector, %vmax);
    %objectVelocity = %obj.getVelocity();
    %muzzleVelocity = VectorAdd(%muzzleVelocity, %objectVelocity);
    %p = new ArrowProjectile("")
    {
        .dataBlock = %projectile;
        .initialVelocity = %muzzleVelocity;
        .initialPosition = %obj.getMuzzlePoint(%slot);
        .sourceObject = %obj;
        .sourceSlot = %slot;
        .client = %obj.client;
    };
    MissionCleanup.add(%p);
    %this.ChargeTime = 0;
    return %p;
}
