$WeaponSlot = 0;
$ShieldSlot = 1;
function Weapon::onUse(%data, %obj)
{
    echo("Weapon::onUse: " @ %data.image);
    if (%obj.getMountedImage($WeaponSlot) != %data.image.getId())
    {
        %obj.mountImage(%data.image, $WeaponSlot);
        if (%obj.client)
        {
            if (!(%data.description $= ""))
            {
                messageClient(%obj.client, 'MsgWeaponUsed', '%1 selected.', %data.description);
            }
            else
            {
                messageClient(%obj.client, 'MsgWeaponUsed', 'Weapon selected');
            }
        }
    }
}
function Weapon::onPickup(%this, %obj, %shape, %amount)
{
    if (Parent::onPickup(%this, %obj, %shape, %amount))
    {
        if ((%shape.getClassName() $= "Player") && (%shape.getMountedImage($WeaponSlot) == 0))
        {
            %shape.use(%this);
        }
    }
}
function Weapon::onInventory(%this, %obj, %amount)
{
    if (!%amount && (%slot = %obj.getMountSlot(%this.image) != -1))
    {
        %obj.unmountImage(%slot);
    }
}
function WeaponImage::onMount(%this, %obj, %slot)
{
    %currentAmmo = 0;
    %previewImg = "";
    %reticle = %this.item.reticle;
    if (!(%this.ammo $= ""))
    {
        if (%obj.getInventory(%this.ammo))
        {
            %obj.setImageAmmo(%slot, 1);
            %currentAmmo = %obj.getInventory(%this.ammo);
        }
        %previewImg = %this.item.previewImage;
    }
}
function WeaponImage::onUnmount(%this, %obj, %slot)
{
}
function WeaponImage::onFire(%this, %obj, %slot)
{
    if (!%this.infiniteAmmo)
    {
        %obj.decInventory(%this.ammo, 1);
    }
    if (%this.projectileSpread)
    {
        %vec = %obj.getMuzzleVector(%slot);
        %i = 0;
        while (%i < 3)
        {
            %matrix = %matrix @ (((getRandom() - 0.5) * 2) * 3.14159) * %this.projectileSpread @ " ";
            %i = %i + 1;
        }
        %mat = MatrixCreateFromEuler(%matrix);
        %muzzleVector = MatrixMulVector(%mat, %vec);
    }
    else
    {
        %muzzleVector = %obj.getMuzzleVector(%slot);
    }
    %objectVelocity = %obj.getVelocity();
    %muzzleVelocity = VectorAdd(VectorScale(%muzzleVector, %this.projectile.muzzleVelocity), VectorScale(%objectVelocity, %this.projectile.velInheritFactor));
    %p = new %this.projectileType("")
    {
        .dataBlock = %this.projectile;
        .initialVelocity = %muzzleVelocity;
        .initialPosition = %obj.getMuzzlePoint(%slot);
        .sourceObject = %obj;
        .sourceSlot = %slot;
        .client = %obj.client;
    };
    MissionCleanup.add(%p);
    return %p;
}
function WeaponImage::onAltFire(%this, %obj, %slot)
{
    %obj.decInventory(%this.ammo, 1);
    if (%this.altProjectileSpread)
    {
        %vec = %obj.getMuzzleVector(%slot);
        %i = 0;
        while (%i < 3)
        {
            %matrix = %matrix @ (((getRandom() - 0.5) * 2) * 3.14159) * %this.altProjectileSpread @ " ";
            %i = %i + 1;
        }
        %mat = MatrixCreateFromEuler(%matrix);
        %muzzleVector = MatrixMulVector(%mat, %vec);
    }
    else
    {
        %muzzleVector = %obj.getMuzzleVector(%slot);
    }
    %objectVelocity = %obj.getVelocity();
    %muzzleVelocity = VectorAdd(VectorScale(%muzzleVector, %this.altProjectile.muzzleVelocity), VectorScale(%objectVelocity, %this.altProjectile.velInheritFactor));
    %p = new %this.projectileType("")
    {
        .dataBlock = %this.altProjectile;
        .initialVelocity = %muzzleVelocity;
        .initialPosition = %obj.getMuzzlePoint(%slot);
        .sourceObject = %obj;
        .sourceSlot = %slot;
        .client = %obj.client;
    };
    MissionCleanup.add(%p);
    return %p;
}
function WeaponImage::onWetFire(%this, %obj, %slot)
{
    %obj.decInventory(%this.ammo, 1);
    if (%this.wetProjectileSpread)
    {
        %vec = %obj.getMuzzleVector(%slot);
        %i = 0;
        while (%i < 3)
        {
            %matrix = %matrix @ (((getRandom() - 0.5) * 2) * 3.14159) * %this.wetProjectileSpread @ " ";
            %i = %i + 1;
        }
        %mat = MatrixCreateFromEuler(%matrix);
        %muzzleVector = MatrixMulVector(%mat, %vec);
    }
    else
    {
        %muzzleVector = %obj.getMuzzleVector(%slot);
    }
    %objectVelocity = %obj.getVelocity();
    %muzzleVelocity = VectorAdd(VectorScale(%muzzleVector, %this.wetProjectile.muzzleVelocity), VectorScale(%objectVelocity, %this.wetProjectile.velInheritFactor));
    %p = new %this.projectileType("")
    {
        .dataBlock = %this.wetProjectile;
        .initialVelocity = %muzzleVelocity;
        .initialPosition = %obj.getMuzzlePoint(%slot);
        .sourceObject = %obj;
        .sourceSlot = %slot;
        .client = %obj.client;
    };
    MissionCleanup.add(%p);
    return %p;
}
function ammo::onPickup(%this, %obj, %shape, %amount)
{
    if (Parent::onPickup(%this, %obj, %shape, %amount))
    {
    }
}
function ammo::onInventory(%this, %obj, %amount)
{
    %i = 0;
    while (%i < 8)
    {
        if (%image = %obj.getMountedImage(%i) > 0)
        {
            if (isObject(%image.ammo) && (%image.ammo.getId() == %this.getId()))
            {
                %obj.setImageAmmo(%i, %amount != 0);
                %currentAmmo = %obj.getInventory(%this);
                %obj.client.setAmmoAmountHud(%currentAmmo);
            }
        }
        %i = %i + 1;
    }
}
function ShapeBase::cycleWeapon(%this, %direction)
{
    return;
    echo("CycleWeapon: Starting, direction:" @ %direction);
    %slot = 0;
    %lastMounted = %this.getMountedImage($WeaponSlot);
    echo("CycleWeapon: last mounted " @ %lastMounted);
    echo("CycleWeapon: last mounted " @ %lastMounted.item.getName());
    if (%lastMounted != 0)
    {
        %curWeapon = %lastMounted.item.getName();
        %slot = $weaponNameIndex[%curWeapon];
        echo("CycleWeapon: curweapon:" @ %curWeapon @ " in slot " @ %slot);
    }
    %ds = 1;
    if (%direction $= "prev")
    {
        %ds = -1;
    }
    while (1)
    {
        %slot = %slot + %ds;
        if (%slot > $lastWeaponOrderSlot)
        {
            %slot = 0;
        }
        if (%slot < 0)
        {
            %slot = $lastWeaponOrderSlot;
        }
        %curWeap = $weaponOrderIndex[%slot];
        if (!((%curWeap $= "")) && %this.hasInventory(%curWeap))
        {
            continue;
        }
        echo("CycleWeapon: we have not " @ %curWeap @ " =( . ( slot " @ %slot @ " )");
    }
    echo("CycleWeapon: " @ %curWeap @ " is selected. ( slot " @ %slot @ " )");
    %this.use(%curWeap);
}
function WeaponImage::onHit(%this, %target, %sourseObj, %hitSpeed, %hitNodeName, %hitBoxName, %groupDmgLevel, %pos, %chargeTime)
{
    if (!isObject(%target) && !isObject(%sourseObj))
    {
        return 0;
    }
    if (%hitBoxName $= "shield")
    {
        return 0;
    }
    %damage = cm_config_CalcPlayerDmgByHit(%hitSpeed, %hitNodeName, %hitBoxName, %groupDmgLevel, %chargeTime);
    if (%damage <= 0)
    {
        return 0;
    }
    %damageType = %this.item.pickUpName;
    if (%damageType $= "")
    {
        %damageType = "Weapon Hit";
    }
    %target.damage(%sourseObj, %pos, %damage, %damageType);
    return %damage;
}
function serverCmdDebugServerCastRay(%client, %eyePosition, %eyeVector)
{
    %hitbox = %client.getControlObject().debugCastRay(%eyePosition, %eyeVector);
    commandToClient(%client, 'updateServerDebugRaycastHitbox', %hitbox);
}
function serverCmdSetRenderedHitbox(%client, %hitbox)
{
    acceptRenderedHitboxQuery(%client, %hitbox);
}
