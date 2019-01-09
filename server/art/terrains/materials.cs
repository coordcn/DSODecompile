new SimGroup(TerrainMaterialList)
{
    .canSave = 1;
    .canSaveDynamicFields = 1;
    new TerrainMaterial("")
    {
        .diffuseMap = "art/2D/Terrain/Substances/Soil_Loose/Soil_Loose_diff";
        .diffuseSize = 1;
        .normalMap = "art/2D/Terrain/Substances/Soil_Loose/Soil_Loose_nm";
        .detailMap = "art/2D/Terrain/Substances/Soil_Loose/Soil_Loose_diff";
        .heightMap = "art/2D/Terrain/Substances/Soil_Loose/Soil_Loose_hm";
        .detailSize = 10;
        .detailStrength = 1;
        .detailDistance = 15000;
        .useSideProjection = 0;
        .parallaxScale = 0.06;
        .minHeight = -10000;
        .maxHeight = 10000;
        .minSlope = 0;
        .maxSlope = 90;
        .minAzimuth = 0;
        .maxAzimuth = 360;
        .use360 = 1;
        .probability = 1;
        .proxyColor = "47 42 38 253";
        .internalName = "QuestWheatBig";
        .canSave = 1;
        .canSaveDynamicFields = 1;
        .globalIndex = 88;
    };
};
initGlobalRemapIndex();

