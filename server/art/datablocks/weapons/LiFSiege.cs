datablock SiegeWeaponStaticShapeData(TrebuchetData)
{
    .id = 340;
    .Object_typeID = 163;
    .shapeFile = "art/models/3d/construction/combatrelated/smalltrebuchet/smalltrebuchet.dts";
    .MaxAccuracy = 2.5;
    .Emax = 2200;
    .BasePrefireAnimTime = 1;
    .BaseRecoilAnimTime = 2;
    .IntNeed = 50;
    .DurabilityPerShot = 100;
};
datablock WeaponData(SiegeStoneAmmoLoaded)
{
    .id = 342;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/whizbang_stone.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .correctMuzzleVector = 0;
    .weaponType = WeaponAmmo;
    .hitGroupType[0] = siege;
    .hitGroupDmgLevel[0] = 1.2;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = 0;
    .FractureMultiplier = 1;
    .StunMultiplier = 1;
};
datablock ExplosiveData(SiegeStoneExplosion)
{
    .id = 660;
    .emitters[0] = Explosion_elements_of_dirt;
    .emittersDuration[0] = 3;
};
datablock ArrowData(SiegeStoneAmmo)
{
    .id = 341;
    .sound = "SiegeFlySound";
    .stuckArrowLifeTime = 5;
    .projectileShape = "art/models/3d-2d/weapons/ammunition/whizbang_stone.dts";
    .upForce = 0;
    .Friction = 0.01;
    .Object_typeID = 1107;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/whizbang_stone.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .correctMuzzleVector = 0;
    .weaponType = WeaponAmmo;
    .loadedAmmo = "SiegeStoneAmmoLoaded";
    .explosionData = "SiegeStoneExplosion";
};
datablock WeaponData(BarrelAmmoLoaded)
{
    .id = 344;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/whizbang_barrel.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .correctMuzzleVector = 0;
    .weaponType = WeaponAmmo;
    .hitGroupType[0] = siege;
    .hitGroupDmgLevel[0] = 0.6;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = 0;
    .FractureMultiplier = 1;
    .StunMultiplier = 1;
    .permanentEmitterNode[0] = "hitpoint0n0";
    .permanentEmitter[0] = big_weapon_smoke;
};
datablock ExplosiveData(BarrelExplosion)
{
    .id = 661;
    .rayNum = 4;
    .radius = 5;
    .hitGroupType[0] = siege;
    .hitGroupDmgLevel[0] = 10;
    .emitters[0] = Explosion_fire;
    .emitters[1] = Explosion_smoke;
    .emitters[2] = Explosion_elements_of_dirt;
    .emittersDuration[0] = 4;
    .emittersDuration[1] = 4;
    .emittersDuration[2] = 4;
    .SoundID = 102;
};
datablock ArrowData(BarrelAmmo)
{
    .id = 343;
    .sound = "SiegeFlySound";
    .stuckArrowLifeTime = 10;
    .projectileShape = "art/models/3d-2d/weapons/ammunition/whizbang_barrel.dts";
    .upForce = 0;
    .Friction = 0.01;
    .Object_typeID = 1106;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/whizbang_barrel.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .correctMuzzleVector = 0;
    .weaponType = WeaponAmmo;
    .loadedAmmo = "BarrelAmmoLoaded";
    .explosionData = "BarrelExplosion";
};
datablock WeaponData(NapthaBarrelAmmoLoaded)
{
    .id = 364;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/whizbang_barrel.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .correctMuzzleVector = 0;
    .weaponType = WeaponAmmo;
    .hitGroupType[0] = siege;
    .hitGroupDmgLevel[0] = 0.3;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = 0;
    .FractureMultiplier = 1;
    .StunMultiplier = 1;
    .permanentEmitterNode[0] = "hitpoint0n0";
    .permanentEmitter[0] = big_weapon_smoke;
};
datablock ExplosiveData(NapthaBarrelExplosion)
{
    .id = 662;
    .rayNum = 8;
    .radius = 12;
    .hitGroupType[0] = siege;
    .hitGroupDmgLevel[0] = 8;
    .emitters[0] = Explosion_fire;
    .emitters[1] = Explosion_smoke;
    .emitters[2] = Explosion_elements_of_dirt;
    .emittersDuration[0] = 4;
    .emittersDuration[1] = 4;
    .emittersDuration[2] = 4;
    .SoundID = 102;
};
datablock ArrowData(NapthaBarrelAmmo)
{
    .id = 363;
    .sound = "SiegeFlySound";
    .stuckArrowLifeTime = 10;
    .projectileShape = "art/models/3d-2d/weapons/ammunition/whizbang_barrel.dts";
    .upForce = 0;
    .Friction = 0.01;
    .Object_typeID = 1123;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/whizbang_barrel.dts";
    .mountPoint = 0;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .correctMuzzleVector = 0;
    .weaponType = WeaponAmmo;
    .loadedAmmo = "NapthaBarrelAmmoLoaded";
    .explosionData = "NapthaBarrelExplosion";
};
datablock WeaponData(CowAmmoLoaded)
{
    .id = 367;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/whizbangcow.dts";
    .mountPoint = 2;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .correctMuzzleVector = 0;
    .weaponType = WeaponAmmo;
    .hitGroupType[0] = siege;
    .hitGroupDmgLevel[0] = 0.01;
    .hitDirection[0] = "";
    .hitDirection[1] = "";
    .hitDirection[2] = "";
    .hitDirection[3] = "";
    .WoundMultiplier = 0;
    .FractureMultiplier = 1;
    .StunMultiplier = 1;
};
datablock ExplosiveData(CowExplosion)
{
    .id = 663;
    .rayNum = 2;
    .radius = 10;
    .hitGroupType[0] = Blunt;
    .hitGroupDmgLevel[0] = 0.01;
    .emitters[0] = cow_blood;
    .emitters[1] = cow_dust;
    .emitters[2] = cow_meat_element;
    .emittersDuration[0] = 4;
    .emittersDuration[1] = 4;
    .emittersDuration[2] = 4;
    .SoundID = 102;
};
datablock ArrowData(CowAmmo)
{
    .id = 366;
    .sound = "AurochsDeathSound";
    .stuckArrowLifeTime = 10;
    .projectileShape = "art/models/3d-2d/weapons/ammunition/whizbangcow.dts";
    .upForce = 0;
    .Friction = 0.01;
    .Object_typeID = 1046;
    .shapeFile = "art/models/3d-2d/weapons/ammunition/whizbangcow.dts";
    .mountPoint = 2;
    .offset = "0 0 0";
    .eyeOffset = "0 0 0";
    .correctMuzzleVector = 0;
    .weaponType = WeaponAmmo;
    .loadedAmmo = "CowAmmoLoaded";
    .explosionData = "CowExplosion";
};

