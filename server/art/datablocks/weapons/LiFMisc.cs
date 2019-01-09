datablock ExplosiveData(ExplosionBomb_1151)
{
    .id = 347;
    .rayNum = 4;
    .radius = 20;
    .explosionMultiplier = 320;
    .hitGroupType[0] = siege;
    .hitGroupDmgLevel[0] = 20;
    .emitters[0] = Explosion_fire;
    .emitters[1] = Explosion_smoke;
    .emitters[2] = Explosion_elements_of_dirt;
    .emittersDuration[0] = 4;
    .emittersDuration[1] = 4;
    .emittersDuration[2] = 4;
    .SoundID = 102;
};
datablock WeaponData(DefaultWeaponData)
{
    .id = 642;
};
datablock WeaponData(AnimalTrapData)
{
    .id = 637;
    .Object_typeID = 1080;
    .hitGroupType[0] = Slashing;
    .hitGroupDmgLevel[0] = 30;
};

