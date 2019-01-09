datablock AnimalData(AurochsCowData : DefaultPlayerData)
{
    .id = 146;
    .animalTypeId = 761;
    .footprintTexture = "art/Textures/AnimalFootprints/Bull_fs.png";
    .footprintTextureLinearSize = 0.4;
    .footprintGap = 0.7;
    .footprintTrackWidth = 0.4;
    .shapeFile = "art/models/3d/mobiles/wildanimals/aurochscow.dts";
    .soundFilesPrefix = "aurochscow";
    .behavior = "data/ai/cmAiAurochsCow.xml";
    .boundingBox = "2 6.2 3.5";
    .runSurfaceAngle = 50;
    .maxHP = 180;
    .bodyRadius = 4;
    .rawCorpseObjectTypeID = 921;
    .skinnedCorpseObjectTypeID = 934;
    .WeaponData = "Cow_Horns";
    .weaponWeight = 10;
    .powerHitStartingDistance = 2.4;
    .powerHitDamagingDistance = 2.6;
    .powerHitDamagingSector = 90;
    .powerHitMinSpeed = 2;
    .powerHitMaxSpeed = 4;
    .fastHitStartingDistance = 2.4;
    .fastHitDamagingDistance = 2.5;
    .fastHitDamagingSector = 90;
    .fastHitMinSpeed = 1;
    .fastHitMaxSpeed = 3;
    .walkAnimationSpeed = 1.08;
    .runAnimationSpeed = 0.55;
    .walkSpeed = 2;
    .runSpeed = 7;
    .animalType = "Peaceful";
};

