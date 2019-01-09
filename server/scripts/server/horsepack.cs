function InitAIHorses()
{
    echo("InitAIHorses()");
    %groupName = "MissionGroup/HorsePaths";
    %group = nameToID(%groupName);
    if (!isObject(%group))
    {
        echo("HorsePack Error: Could not find HorsePaths sim group!");
        return;
    }
    %pathcount = %group.getCount();
    if (%pathcount < 1)
    {
        echo("HorsePack Error: No paths in HorsePaths sim group!");
        return;
    }
    echo("HorsePack: Found " @ %pathcount @ " paths.");
    %pathindex = 0;
    while (%pathindex < %pathcount)
    {
        %path = %group.getObject(%pathindex);
        %markercount = %path.getCount();
        if (%markercount < 1)
        {
            echo("HorsePack Error: No markers in path!");
        }
        else
        {
            %marker = %path.getObject(0);
            %datablock = %marker.horse;
            echo("HorsePack " @ %datablock);
            %horse = new AIHorse("")
            {
                .dataBlock = %datablock;
                .AIPlayer = 1;
            };
            if (!isObject(%horse))
            {
                echo("HorsePack Error: Failed to create " @ %marker.horse @ " for path " @ %pathindex @ "!");
            }
            else
            {
                echo("HorsePack: Created " @ %marker.horse @ " for path " @ %pathindex @ ".");
                MissionCleanup.add(%horse);
                %horse.setEnergyLevel(1);
                %horse.setShapeName(%marker.HorseName);
                %markerindex = 0;
                while (%markerindex < %markercount)
                {
                    %horse.Marker[%markerindex] = %path.getObject(%markerindex);
                    %markerindex = %markerindex + 1;
                }
                %horse.numMarkers = %markercount;
                %horse.curMarker = 0;
                %marker = %horse.Marker[%horse.curMarker];
                %matrix = %marker.getTransform();
                %moveSpeed = %marker.MoveSpeed;
                %horse.setTransform(%matrix);
                %pos = getWords(%matrix, 0, 2);
                %horse.setAimLocation(%pos);
                %horse.setMoveDestination(%pos);
                if (!(%moveSpeed $= ""))
                {
                    %horse.setMoveSpeed(%moveSpeed);
                }
            }
        }
        %pathindex = %pathindex + 1;
    }
}
function InitHorses()
{
    echo("InitHorses()");
    %groupName = "MissionGroup/HorseDropPoints";
    %group = nameToID(%groupName);
    if (!isObject(%group))
    {
        echo("HorsePack Error: Could not find HorseDropPoints sim group!");
        return;
    }
    %spawnspherecount = %group.getCount();
    if (%spawnspherecount < 1)
    {
        echo("HorsePack Error: No spawn spheres in HorseDropPoints sim group!");
        return;
    }
    echo("HorsePack: Found " @ %spawnspherecount @ " spawn spheres.");
    %spawnsphereindex = 0;
    while (%spawnsphereindex < %spawnspherecount)
    {
        %spawnsphere = %group.getObject(%spawnsphereindex);
        %datablock = %spawnsphere.horse;
        echo("HorsePack" @ %datablock);
        %horse = new AIHorse("")
        {
            .dataBlock = %datablock;
            .AIPlayer = 1;
        };
        if (!isObject(%horse))
        {
            echo("HorsePack Error: Failed to create " @ %datablock @ " for spawn sphere " @ %spawnsphereindex @ "!");
        }
        else
        {
            echo("HorsePack: Created " @ %datablock @ " for spawn sphere " @ %spawnsphereindex @ ".");
            MissionCleanup.add(%horse);
            %horse.setEnergyLevel(1);
            %horse.setTransform(%spawnsphere.getTransform());
            %horse.setShapeName(%spawnsphere.HorseName);
        }
        %spawnsphereindex = %spawnsphereindex + 1;
    }
}
function InitHorsePack()
{
    echo("InitHorsePack()");
    InitAIHorses();
}
