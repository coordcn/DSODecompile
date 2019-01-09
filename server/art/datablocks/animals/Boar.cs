datablock AnimalData(BoarData : DefaultPlayerData)
{
    .id = 117;
    .animalTypeId = 757;
    .footprintTexture = "art/Textures/AnimalFootprints/Boar_fs.png";
    .footprintTextureLinearSize = 0.5;
    .footprintGap = 0.7;
    .footprintTrackWidth = 0.35;
    .shapeFile = "art/models/3d/mobiles/wildanimals/boar.dts";
    .soundFilesPrefix = "boar";
    .behavior = "data/ai/cmAiBoar.xml";
    .boundingBox = "1.2 3 1.7";
    .runSurfaceAngle = 50;
    .maxHP = 200;
    .bodyRadius = 2.7;
    .rawCorpseObjectTypeID = 917;
    .skinnedCorpseObjectTypeID = 930;
    .WeaponData = "Boar_Tusk";
    .weaponWeight = 10;
    .powerHitStartingDistance = 1.7;
    .powerHitDamagingDistance = 1.9;
    .powerHitDamagingSector = 90;
    .powerHitMinSpeed = 15;
    .powerHitMaxSpeed = 25;
    .fastHitStartingDistance = 1.6;
    .fastHitDamagingDistance = 1.7;
    .fastHitDamagingSector = 90;
    .fastHitMinSpeed = 5;
    .fastHitMaxSpeed = 10;
    .walkAnimationSpeed = 1.76;
    .runAnimationSpeed = 1.06;
    .walkSpeed = 2;
    .runSpeed = 7;
    .animalType = "Predator";
};

