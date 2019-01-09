package yoDbHandling
{
    function cphMyAdmin::prepare(%this, %cb)
    {
        hack("cphMyAdmin::prepare", %this, %cb);
        %this.appName = "MyAdmin";
        %this.appPath = $ChildProcessHelper::mariaAdminPath;
        if (!fileExists(%this.appPath))
        {
            error("Can\'t launch MyAdmin! Missing EXE!");
            return;
        }
        %this.appArgs = "--no-beep --silent -u root -p" @ $ChildProcessHelper::mariaDBPass SPC "--pipe --socket=" @ $ChildProcessHelper::mariaDBPipe;
        %this.onExitCallback = "";
        %this.callbackObject = "";
        %this.redirectStdIO = 1;
        %this.showWindow = 0;
        %this.slashAlias = "";
        %this.cb = %cb;
    }
    function cphMyAdmin::shutdownMariaDB(%this)
    {
        hack("cphMyAdmin::shutdownMariaDB", %this);
        %this.appArgs = "--shutdown_timeout=" @ $ChildProcessHelper::shutdownMariaTimeoutSec @ " shutdown" SPC %this.appArgs;
        %this.executeTimeout = $ChildProcessHelper::shutdownAdminTimeoutSec;
        %this.launchProcess();
    }
    function cphMyAdmin::onLaunched(%this)
    {
        hack("cphMyAdmin::onLaunched", %this);
    }
    function cphMyAdmin::onFinished(%this, %success, %retCode)
    {
        hack("cphMyAdmin::onFinished", %this, %success, %retCode);
        if (!%success)
        {
            error("cphMyAdmin::onFinished() -- Can\'t launch MyAdmin!");
        }
        %this.schedule(0, doQuit);
    }
    function cphMyAdmin::doQuit(%this)
    {
        %this.schedule(0, delete);
        if (!(%this.cb $= ""))
        {
            warn("calling:" SPC %this.cb);
            schedule(0, 0, call, %this.cb);
        }
    }
    function prepAndKillMariaDB(%callback)
    {
        if (!isObject(cphMyAdmin))
        {
            new ChildProcessHelper(cphMyAdmin)
            {
            };
        }
        if (cphMyAdmin.shutdownInitiated)
        {
            error("cphMyAdmin is already running shutdown command!");
            return;
        }
        cphMyAdmin.shutdownInitiated = 1;
        cphMyAdmin.prepare(%callback);
        cphMyAdmin.shutdownMariaDB();
    }
};

activatePackage(yoDbHandling);
package shutdownRequest
{
    function quit()
    {
        error("Quit requested!!!");
        if (!$shuttingDown)
        {
            error("Shutting down!!!");
            $shuttingDown = 1;
            destroyServer();
            schedule(32, 0, quit);
            return;
        }
        if ($shutdownMariaDB && !$tmp::mariaShutDownRequested)
        {
            hack("Shutting down MariaDB!");
            $tmp::mariaShutDownRequested = 1;
            prepAndKillMariaDB("quit");
            return;
        }
        if (isObject(cphMyAdmin))
        {
            return;
        }
        hack("Final shutdown initiated!");
        Parent::quit();
    }
    function quitNoMaintenance()
    {
        $CmMaintenance::performAtQuit = 0;
        quit();
    }
};

activatePackage(shutdownRequest);
function Player::jt(%this, %where)
{
    %firstChar = getSubStr(%where, 0, 1);
    if (%firstChar > 0)
    {
        info("Sending player", %this, %this.client.getAccountId(), %this.client.getCharacterId(), "to GeoId", %where);
        %this.TeleportTo(%where);
        return;
    }
    if (%firstChar $= "t")
    {
        %terId = getSubStr(%where, 1);
        info("Sending player", %this, %this.client.getAccountId(), %this.client.getCharacterId(), "to terrain", %terId);
        %this.jumpToTerrain(%terId);
        return;
    }
}
