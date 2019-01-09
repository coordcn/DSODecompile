function radiusDamage(%sourceObject, %position, %radius, %damage, %damageType, %impulse)
{
    initContainerRadiusSearch(%position, %radius, $TypeMasks::ShapeBaseObjectType);
    %halfRadius = %radius / 2;
    while (%targetObject = containerSearchNext() != 0)
    {
        %coverage = calcExplosionCoverage(%position, %targetObject, ((($TypeMasks::InteriorObjectType | $TypeMasks::TerrainObjectType) | $TypeMasks::ForceFieldObjectType) | $TypeMasks::StaticTSObjectType) | $TypeMasks::VehicleObjectType);
        if (%coverage == 0)
        {
            continue;
        }
        %dist = containerSearchCurrRadiusDist();
        %distScale = %dist < %halfRadius ? 1 : %halfRadius;
        %targetObject.damage(%sourceObject, %position, (%damage * %coverage) * %distScale, %damageType);
        if (%impulse)
        {
            %impulseVec = VectorSub(%targetObject.getWorldBoxCenter(), %position);
            %impulseVec = VectorNormalize(%impulseVec);
            %impulseVec = VectorScale(%impulseVec, %impulse * %distScale);
            %targetObject.applyImpulse(%position, %impulseVec);
        }
    }
}
