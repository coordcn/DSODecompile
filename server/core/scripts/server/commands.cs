function serverCmdNetSimulateLag(%client, %msDelay, %packetLossPercent)
{
    if (%client.isAdmin)
    {
        %client.setSimulatedNetParams(%packetLossPercent / 100, %msDelay);
    }
}
function GameConnection::updateCameraSettings(%this)
{
    if (!%this.Player.isInFlyingCameraMode())
    {
        return;
    }
    hack("Calling:", %this.Player, %this.cameraSpeed, %this.cameraNewtonMode, %this.cameraNewtonRotation);
    %this.Player.updateCameraSettings(%this.cameraSpeed, %this.cameraNewtonMode, %this.cameraNewtonRotation);
}
function serverCmdSetCameraSpeed(%client, %speed)
{
    if (!%client.isGM())
    {
        return;
    }
    echo("Client" SPC %client SPC "charId" SPC %client.getCharacterId() SPC "requested to update camera speed to" SPC %speed);
    %client.cameraSpeed = %speed;
    %client.updateCameraSettings();
    %client.forceUpdateControl();
    if (isObject(%client.PathCamera))
    {
        %charId = %client.getCharacterId();
        if (isObject($pathCamPath[%charId].adjustingObject))
        {
        }/* 3 | 314 */
        else
        {
        }
        %obj = $pathCamPath[%charId].getObject($pathCamPath[%charId].currentPoint);
        %obj.speed = %speed;
        if (%obj.speed > 1000)
        {
            %obj.speed = 1000;
        }
        %client.pc_updateCurrentPoint(1);
    }
}/* 1 | 397 */
function serverCmdDropPlayerAtCamera(%client)
{
    %m = "[" @ %client SPC %client.netAddress SPC %client.getCharacterId() @ "]:";
    if (!%client.isGM())
    {
        warn(%m, "Not allowed for non-GM!");
        return;
    }
    if ((getSimTime() - %client.lastCameraJump) < 500)
    {
        warn(%m, "Too fast camera-switching!");
        return;
    }
    if (!%client.Player.isInFlyingCameraMode())
    {
        warn(%m, "Not in camera mode!");
        return;
    }
    %client.lastCameraJump = getSimTime();
    %client.ignorePos = 0;
    %client.Player.setCameraMode(0);
    %client.forceUpdateControl();
}
function serverCmdDropCameraAtPlayer(%client)
{
    %m = "[" @ %client SPC %client.netAddress SPC %client.getCharacterId() @ "]:";
    if (!%client.isGM())
    {
        warn(%m, "Not allowed for non-GM!");
        return;
    }
    if ((getSimTime() - %client.lastCameraJump) < 500)
    {
        warn(%m, "Too fast camera-switching!");
        return;
    }
    %player = %client.getControlObject();
    if (%player.isInFlyingCameraMode())
    {
        warn(%m, "Already in camera mode!");
        return;
    }
    if (%player.isWarstance())
    {
        warn(%m, "Can\'t switch to camera while in War Stance mode!");
        %client.cmSendClientMessage(898);
        return;
    }
    %i = 4;
    while (%i < 8)
    {
        if ((%player.getMountedImage(%i) && (%player.getMountedImage(%i) != 583)) && (%player.getMountedImage(%i) != 584))
        {
            error(%m, "Can\'t switch to the camera while carrying an object.", %i, %player.getMountedImage(%i).getName());
            %client.cmSendClientMessage(899);
            return;
        }
        %i = %i + 1;
    }
    %player.finishDismount();
    %client.lastCameraJump = getSimTime();
    %client.ignorePos = 1;
    %player.setCameraMode(1);
    %client.updateCameraSettings();
    %client.forceUpdateControl();
}
function GameConnection::updateCamera(%this)
{
    %charId = %this.getCharacterId();
    if (!isObject($pathCamPath[%charId]))
    {
        $pathCamPath[%charId] = new SimGroup("")
        {
        };
        MissionCleanup.add($pathCamPath[%charId]);
    }
}
function getRot()
{
    %a = 1;
    %b = 1;
    %x = 0;
    %y = 0;
    %z = 1;
    %w = getRandomF(0, 6.28319);
    return %x SPC %y SPC %z SPC %w;
}
function PathCamera::onNode(%this, %node)
{
    hack("This:", %this, "Node:", %node);
}
function dd()
{
    exec("core/scripts/server/commands.cs");
    go();
}
function go()
{
    %pos = "0 0 1200";
    %tr0 = VectorAdd(%pos, getRandom(-100, 100) SPC getRandom(-100, 100) SPC getRandom(0, 100)) SPC "0 0 1 0";
    %tr1 = VectorAdd(%pos, getRandom(-100, 100) SPC getRandom(-100, 100) SPC getRandom(0, 100)) SPC "0 0 1 1.50809";
    %tr2 = VectorAdd(%pos, getRandom(-100, 100) SPC getRandom(-100, 100) SPC getRandom(0, 100)) SPC "0 0 1 3.14";
    %tr3 = VectorAdd(%pos, getRandom(-100, 100) SPC getRandom(-100, 100) SPC getRandom(0, 100)) SPC "0 0 -1 1.52775";
    %tr4 = VectorAdd(%pos, getRandom(-100, 100) SPC getRandom(-100, 100) SPC getRandom(0, 100)) SPC getRot();
    %tr5 = VectorAdd(%pos, getRandom(-100, 100) SPC getRandom(-100, 100) SPC getRandom(0, 100)) SPC getRot();
    %tr6 = VectorAdd(%pos, getRandom(-100, 100) SPC getRandom(-100, 100) SPC getRandom(0, 100)) SPC getRot();
    %i = 0;
    while (%i < 7)
    {
        %tr[%i] = VectorAdd(%pos, getRandom(-100, 100) SPC getRandom(-100, 100) SPC getRandom(-40, 80)) SPC getRot();
        %i = %i + 1;
    }
    hack(%tr0);
    hack(%tr5);
    $cam.reset(0);
    $sp = 50;
    $cam.pushBack(%tr0, $sp, "Normal", "Spline");
    $cam.popFront();
    $cam.pushBack(%tr1, $sp, "Normal", "Spline");
    $cam.pushBack(%tr2, 10, "Normal", "Spline");
    $cam.pushBack(%tr3, $sp, "Normal", "Spline");
    $cam.pushBack(%tr4, $sp, "Normal", "Spline");
    $cam.pushBack(%tr5, $sp, "Normal", "Spline");
    $cam.pushBack(%tr6, $sp, "Normal", "Spline");
    $cam.setPosition(0);
}
function stop()
{
    $cam.setState("stop");
}
function serverCmdSetCameraNewton(%client)
{
    %m = "[" @ %client SPC %client.netAddress SPC %client.getCharacterId() @ "]:";
    %client.cameraNewtonMode = !%client.cameraNewtonMode;
    hack(%m, "Setting camera newtonMode to:", %client.cameraNewtonMode);
    %client.updateCameraSettings();
    %client.forceUpdateControl();
}
function serverCmdSetCameraNewtonDamped(%client)
{
    %m = "[" @ %client SPC %client.netAddress SPC %client.getCharacterId() @ "]:";
    %client.cameraNewtonRotation = !%client.cameraNewtonRotation;
    hack(%m, "Setting camera newtonRotation to:", %client.cameraNewtonRotation);
    %client.updateCameraSettings();
    %client.forceUpdateControl();
}
function serverCmdSetCameraFly(%client)
{
    %m = "[" @ %client SPC %client.netAddress SPC %client.getCharacterId() @ "]:";
    if (!%client.Player.isInFlyingCameraMode())
    {
        warn(%m, "Not in camera mode!");
        return;
    }
    hack(%m, "Setting camera to regular mode");
    %client.cameraNewtonMode = 0;
    %client.cameraNewtonRotation = 0;
    %client.updateCameraSettings();
    %client.forceUpdateControl();
}
function serverCmdSetCameraPos(%client, %transform)
{
    %m = "[" @ %client SPC %client.netAddress SPC %client.getCharacterId() @ "]:";
    if (!%client.isGM())
    {
        error(%m, "not allowed for non-GM!");
        return;
    }
    if (!%client.Player.isInFlyingCameraMode())
    {
        return;
    }
    %client.Player.setTransform(%transform);
    %client.forceUpdateControl();
}
function serverCmdTakeCameraPos(%client)
{
    %m = "[" @ %client SPC %client.netAddress SPC %client.getCharacterId() @ "]:";
    if (!%client.isGM())
    {
        error(%m, "not allowed for non-GM!");
        return;
    }
    commandToClient(%client, 'takeCameraPos', %client.Player.getEyeTransform());
}
function serverCmdCheckServerGameMode(%client)
{
    if (isColonizationGameMode() && isColonizationQuestComplete())
    {
        %client.cmSendClientMessage(690);
    }
}
function serverCmdPathCam(%client, %cmd, %a1)
{
    if (!%client.isGM())
    {
        error("not GM:" @ %client SPC %client.netAddress SPC %client.getCharacterId());
        return;
    }
    if (!isObject(%client.Camera) && !isObject(%client.PathCamera))
    {
        error("can\'t perform command, no camera exists!", isObject(%client.Camera), isObject(%client.PathCamera));
        return;
    }
    hack(%client, %cmd, %a1);
    if (%cmd $= "getPos")
    {
    }
    else
    {
        if (%cmd $= "setPos")
        {
        }
        else
        {
            if (%cmd $= "resetPath")
            {
                %client.pc_resetPath(%a1);
            }
            else
            {
                if (%cmd $= "addPoint")
                {
                    %client.pc_addPoint(%a1);
                }
                else
                {
                    if (%cmd $= "addCurrentAsPoint")
                    {
                        %client.pc_addCurrentAsPoint(%a1);
                    }
                    else
                    {
                        if (%cmd $= "followPath")
                        {
                            %client.pc_followPath(%a1);
                        }
                        else
                        {
                            if (%cmd $= "stopFly")
                            {
                                %client.pc_stopFly(%a1);
                            }
                            else
                            {
                                if (%cmd $= "forwardFly")
                                {
                                    %client.pc_forwardFly(%a1);
                                }
                                else
                                {
                                    if (%cmd $= "backwardFly")
                                    {
                                        %client.pc_backwardFly(%a1);
                                    }
                                    else
                                    {
                                        if (%cmd $= "jumpPoint")
                                        {
                                            %client.pc_jumpPoint(%a1);
                                        }
                                        else
                                        {
                                            if (%cmd $= "jumpNextPoint")
                                            {
                                                %client.pc_jumpNextPoint(%a1);
                                            }
                                            else
                                            {
                                                if (%cmd $= "jumpPrevPoint")
                                                {
                                                    %client.pc_jumpPrevPoint(%a1);
                                                }
                                                else
                                                {
                                                    if (%cmd $= "adjustCurrentPoint")
                                                    {
                                                        %client.pc_adjustCurrentPoint(%a1);
                                                    }
                                                    else
                                                    {
                                                        if (%cmd $= "updateCurrentPoint")
                                                        {
                                                            %client.pc_updateCurrentPoint(%a1);
                                                        }
                                                        else
                                                        {
                                                            if (%cmd $= "dumpPath")
                                                            {
                                                                %client.pc_dumpPath(%a1);
                                                            }
                                                            else
                                                            {
                                                                if (%cmd $= "loadPath")
                                                                {
                                                                    %client.pc_loadPath(%a1);
                                                                }
                                                                else
                                                                {
                                                                    if (%cmd $= "pathPoint")
                                                                    {
                                                                        %client.pc_pathPoint(%a1);
                                                                    }
                                                                    else
                                                                    {
                                                                        if (%cmd $= "pathFinish")
                                                                        {
                                                                            %client.pc_pathFinish(%a1);
                                                                        }
                                                                        else
                                                                        {
                                                                            if (%cmd $= "incSpeed")
                                                                            {
                                                                                %client.pc_incSpeed(%a1);
                                                                            }
                                                                            else
                                                                            {
                                                                                if (%cmd $= "decSpeed")
                                                                                {
                                                                                    %client.pc_decSpeed(%a1);
                                                                                }
                                                                                else
                                                                                {
                                                                                    if (%cmd $= "startStopRecordingPath")
                                                                                    {
                                                                                        %client.pc_startStopRecordingPath(%a1);
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
function GameConnection::pc_resetPath(%this)
{
    %charId = %this.getCharacterId();
    $pathCamPath[%charId].clear();
    $pathCamPath[%charId].currentPoint = -1;
    if (isObject(%this.PathCamera))
    {
        %this.PathCamera.reset(0);
        %this.PathCamera.pushBack(%this.PathCamera.getTransform(), 0, "Normal", "Spline");
        %this.PathCamera.popFront();
        %this.PathCamera.setPosition(0);
        %this.PathCamera.setState("stop");
    }
    if (%this.Player.getObjectMount() != %this.Camera)
    {
        %this.Camera.mountObject(%this.Player, 1, "0 0 0 0 0 0 0");
        %this.Player.setControlObject(%this.Camera);
    }
}
function GameConnection::pc_addPoint(%this, %a1)
{
    %this.pc_pathPoint(%a1);
}
function GameConnection::pc_addCurrentAsPoint(%this)
{
    %this.pc_pathPoint(%this.getControlObject().getControlObject().getTransform() SPC %this.cameraSpeed);
}
function GameConnection::pc_followPath(%this)
{
    %charId = %this.getCharacterId();
    if ($pathCamPath[%charId].getCount() < 2)
    {
        return;
    }
    $pathCamPath[%charId].currentPoint = 0;
    if (isObject(%this.PathCamera))
    {
        if (%this.Player.getObjectMount() != %this.PathCamera)
        {
            %this.PathCamera.mountObject(%this.Player, 1, "0 0 0 0 0 0 0");
            %this.Player.setControlObject(%this.PathCamera);
        }
        %this.PathCamera.setPosition(0);
        %this.PathCamera.setState("forward");
        %this.PathCamera.setTarget($pathCamPath[%charId].getCount() - 1);
    }
    %this.Camera.setTransform($pathCamPath[%charId].getObject($pathCamPath[%charId].currentPoint).transform);
}
function GameConnection::pc_stopFly(%this)
{
    %charId = %this.getCharacterId();
    if (!isObject(%this.PathCamera))
    {
        return;
    }
    if (%this.Player.getObjectMount() == %this.PathCamera)
    {
        %this.Camera.mountObject(%this.Player, 1, "0 0 0 0 0 0 0");
        %this.Player.setControlObject(%this.Camera);
    }
    else
    {
        %this.PathCamera.mountObject(%this.Player, 1, "0 0 0 0 0 0 0");
        %this.Player.setControlObject(%this.PathCamera);
    }
    %this.PathCamera.setState("stop");
}
function GameConnection::pc_forwardFly(%this)
{
    %charId = %this.getCharacterId();
    if (!isObject(%this.PathCamera))
    {
        return;
    }
    if (%this.Player.getObjectMount() != %this.PathCamera)
    {
        %this.PathCamera.mountObject(%this.Player, 1, "0 0 0 0 0 0 0");
        %this.Player.setControlObject(%this.PathCamera);
    }
    %this.PathCamera.setState("forward");
}
function GameConnection::pc_backwardFly(%this)
{
    %charId = %this.getCharacterId();
    if (!isObject(%this.PathCamera))
    {
        return;
    }
    if (%this.Player.getObjectMount() != %this.PathCamera)
    {
        %this.PathCamera.mountObject(%this.Player, 1, "0 0 0 0 0 0 0");
        %this.Player.setControlObject(%this.PathCamera);
    }
    %this.PathCamera.setState("backward");
}
function GameConnection::pc_jumpPoint(%this, %a1)
{
    %charId = %this.getCharacterId();
    if ((%a1 < 0) && (%a1 >= $pathCamPath[%charId].getCount()))
    {
        return;
    }
    $pathCamPath[%charId].currentPoint = %a1;
    hack(%a1);
    %this.PathCamera.setPosition($pathCamPath[%charId].currentPoint);
    %this.Camera.setTransform($pathCamPath[%charId].getObject($pathCamPath[%charId].currentPoint).transform);
}
function GameConnection::pc_jumpNextPoint(%this)
{
    %charId = %this.getCharacterId();
    if (!$pathCamPath[%charId].getCount())
    {
        return;
    }
    $pathCamPath[%charId].currentPoint = $pathCamPath[%charId].currentPoint + 1;
    if ($pathCamPath[%charId].currentPoint >= $pathCamPath[%charId].getCount())
    {
        $pathCamPath[%charId].currentPoint = 0;
    }
    %this.pc_jumpPoint($pathCamPath[%charId].currentPoint);
}
function GameConnection::pc_jumpPrevPoint(%this)
{
    %charId = %this.getCharacterId();
    if (!$pathCamPath[%charId].getCount())
    {
        return;
    }
    $pathCamPath[%charId].currentPoint = $pathCamPath[%charId].currentPoint - 1;
    if ($pathCamPath[%charId].currentPoint < 0)
    {
        $pathCamPath[%charId].currentPoint = $pathCamPath[%charId].getCount() - 1;
    }
    %this.pc_jumpPoint($pathCamPath[%charId].currentPoint);
}
function GameConnection::pc_adjustCurrentPoint(%this)
{
    %charId = %this.getCharacterId();
    $pathCamPath[%charId].adjustingPoint = $pathCamPath[%charId].currentPoint;
    $pathCamPath[%charId].adjustingObject = $pathCamPath[%charId].getObject($pathCamPath[%charId].currentPoint);
}
function GameConnection::pc_updateCurrentPoint(%this, %skipSwitch)
{
    %charId = %this.getCharacterId();
    %obj = $pathCamPath[%charId].adjustingObject;
    %obj.transform = %this.getControlObject().getControlObject().getTransform();
    %obj = $pathCamPath[%charId].getObject(%i);
    %tr = %obj.transform;
    %sp = %obj.speed;
    %this.PathCamera.updateKnot($pathCamPath[%charId].adjustingPoint, %tr, %sp, "Normal", "Spline");
    if (!%skipSwitch)
    {
        $pathCamPath[%charId].adjustingObject = "";
        $pathCamPath[%charId].adjustingPoint = "";
        if (%this.Player.getObjectMount() != %this.Camera)
        {
            %this.Camera.mountObject(%this.Player, 1, "0 0 0 0 0 0 0");
            %this.Player.setControlObject(%this.Camera);
        }
    }
}
function GameConnection::pc_incSpeed(%this, %inc)
{
    %charId = %this.getCharacterId();
    if (isObject($pathCamPath[%charId].adjustingObject))
    {
    }/* 3 | 5158 */
    else
    {
    }
    %obj = $pathCamPath[%charId].getObject($pathCamPath[%charId].currentPoint);
    %obj.speed = %obj.speed + %inc;
    if (%obj.speed > 1000)
    {
        %obj.speed = 1000;
    }
    serverCmdSetCameraSpeed(%this, %obj.speed);
    %this.pc_updateCurrentPoint(1);
}/* 1 | 5259 */
function GameConnection::pc_decSpeed(%this, %dec)
{
    %charId = %this.getCharacterId();
    if (isObject($pathCamPath[%charId].adjustingObject))
    {
    }/* 3 | 5319 */
    else
    {
    }
    %obj = $pathCamPath[%charId].getObject($pathCamPath[%charId].currentPoint);
    %obj.speed = %obj.speed - %dec;
    if (%obj.speed < 1)
    {
        %obj.speed = 1;
    }
    %this.pc_updateCurrentPoint();
}/* 1 | 5399 */
function GameConnection::pc_startStopRecordingPath(%this)
{
    if (!%this.schPcRecordingSession)
    {
        %this.pcRecording = 1;
        %this.pc_resetPath();
        %this.pc__recordCurrentPoint();
    }
    else
    {
        cancel(%this.schPcRecordingSession);
        %this.schPcRecordingSession = "";
        %this.pc_pathPoint(%this.getControlObject().getControlObject().getTransform() SPC VectorLen(%this.getControlObject().getControlObject().getVelocity()));
    }
}
function GameConnection::pc__recordCurrentPoint(%this)
{
    %this.pc_pathPoint(%this.getControlObject().getControlObject().getTransform() SPC VectorLen(%this.getControlObject().getControlObject().getVelocity()));
    %this.schPcRecordingSession = %this.schedule(1000, pc__recordCurrentPoint);
}
function GameConnection::pc_dumpPath(%this)
{
    %charId = %this.getCharacterId();
    %i = 0;
    while (%i < $pathCamPath[%charId].getCount())
    {
        %obj = $pathCamPath[%charId].getObject(%i);
        %tr = %obj.transform;
        %sp = %obj.speed;
        commandToClient(%this, 'PathCam', "savePoint", %tr SPC %sp);
        %i = %i + 1;
    }
    commandToClient(%this, 'PathCam', "dumpFinish");
}
function GameConnection::pc_loadPath(%this)
{
    %charId = %this.getCharacterId();
    if (!isObject($pathCamPath[%charId]))
    {
        $pathCamPath[%charId] = new SimGroup("")
        {
        };
        $pathCamPath[%charId].currentPoint = -1;
        MissionCleanup.add($pathCamPath[%charId]);
    }
    else
    {
        $pathCamPath[%charId].clear();
        $pathCamPath[%charId].currentPoint = -1;
    }
}
function GameConnection::pc_pathPoint(%this, %a1)
{
    %charId = %this.getCharacterId();
    %obj = new SimObject("")
    {
    };
    %obj.transform = getWords(%a1, 0, 6);
    %obj.speed = getWord(%a1, 7);
    $pathCamPath[%charId].add(%obj);
}
function GameConnection::pc_pathFinish(%this)
{
    %charId = %this.getCharacterId();
    %obj = $pathCamPath[%charId].getObject(0);
    %this.PathCamera.setTransform(%obj.transform);
    %this.PathCamera.reset(0);
    %i = 0;
    while (%i < $pathCamPath[%charId].getCount())
    {
        %obj = $pathCamPath[%charId].getObject(%i);
        %tr = %obj.transform;
        %sp = %obj.speed;
        %this.PathCamera.pushBack(%tr, %sp, "Normal", "Spline");
        %i = %i + 1;
    }
    %this.PathCamera.popFront();
    $pathCamPath[%charId].currentPoint = 0;
}
