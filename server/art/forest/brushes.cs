new SimGroup(ForestBrushGroup)
{
    .canSave = 1;
    .canSaveDynamicFields = 1;
    new ForestBrush("")
    {
        .internalName = "ExampleForestBrush";
        .canSave = 1;
        .canSaveDynamicFields = 1;
        new ForestBrushElement("")
        {
            .internalName = "cmTreeWillowElement";
            .canSave = 1;
            .canSaveDynamicFields = 1;
            .ForestItemData = "cmTreeWillow_0_0";
            .probability = 1;
            .rotationRange = 360;
            .scaleMin = 1;
            .scaleMax = 2;
            .scaleExponent = 0.2;
            .sinkMin = 0;
            .sinkMax = 0.1;
            .sinkRadius = 0.25;
            .slopeMin = 0;
            .slopeMax = 30;
            .elevationMin = -10000;
            .elevationMax = 10000;
            .clumpCountExponent = 1;
            .clumpCountMax = 1;
            .clumpCountMin = 1;
            .clumpRadius = 10;
        };
    };
};

