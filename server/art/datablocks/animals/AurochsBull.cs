datablock AnimalData(AurochsBullData : DefaultPlayerData)
{
    .id = 67;
    .animalTypeId = 760;
    .footprintTexture = "art/Textures/AnimalFootprints/Bull_fs.png";
    .footprintTextureLinearSize = 0.4;
    .footprintGap = 0.7;
    .footprintTrackWidth = 0.4;
    .shapeFile = "art/models/3d/mobiles/wildanimals/aurochsbull.dts";
    .soundFilesPrefix = "aurochsbull";
    .behavior = "data/ai/cmAiAurochsBull.xml";
    .boundingBox = "2.5 6 3.5";
    .runSurfaceAngle = 50;
    .maxHP = 250;
    .bodyRadius = 4;
    .rawCorpseObjectTypeID = 920;
    .skinnedCorpseObjectTypeID = 933;
    .WeaponData = "Bull_Horns";
    .weaponWeight = 10;
    .powerHitStartingDistance = 1.7;
    .powerHitDamagingDistance = 1.9;
    .powerHitDamagingSector = 90;
    .powerHitMinSpeed = 2;
    .powerHitMaxSpeed = 8;
    .fastHitStartingDistance = 1.7;
    .fastHitDamagingDistance = 1.8;
    .fastHitDamagingSector = 90;
    .fastHitMinSpeed = 1;
    .fastHitMaxSpeed = 3;
    .walkAnimationSpeed = 1.08;
    .runAnimationSpeed = 0.55;
    .walkSpeed = 3;
    .runSpeed = 7;
    .animalType = "Peaceful";
};

