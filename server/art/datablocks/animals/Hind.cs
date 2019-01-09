datablock AnimalData(HindData : DefaultPlayerData)
{
    .id = 142;
    .animalTypeId = 778;
    .footprintTexture = "art/Textures/AnimalFootprints/Deer_fs.png";
    .footprintTextureLinearSize = 0.4;
    .footprintGap = 0.9;
    .footprintTrackWidth = 0.3;
    .shapeFile = "art/models/3d/mobiles/wildanimals/hind.dts";
    .soundFilesPrefix = "deer";
    .behavior = "data/ai/cmAiHind.xml";
    .boundingBox = "1.5 4 3.5";
    .runSurfaceAngle = 50;
    .maxHP = 120;
    .bodyRadius = 3.3;
    .rawCorpseObjectTypeID = 914;
    .skinnedCorpseObjectTypeID = 927;
    .WeaponData = "Hind_Hoof";
    .weaponWeight = 10;
    .powerHitStartingDistance = 3;
    .powerHitDamagingDistance = 3.2;
    .powerHitDamagingSector = 90;
    .powerHitMinSpeed = 2;
    .powerHitMaxSpeed = 4;
    .fastHitStartingDistance = 3;
    .fastHitDamagingDistance = 3.1;
    .fastHitDamagingSector = 90;
    .fastHitMinSpeed = 1;
    .fastHitMaxSpeed = 3;
    .walkAnimationSpeed = 0.95;
    .runAnimationSpeed = 0.52;
    .walkSpeed = 2;
    .runSpeed = 8;
    .animalType = "Peaceful";
};

