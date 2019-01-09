function pushFront(%list, %token, %delim)
{
    if (!(%list $= ""))
    {
        return %token @ %delim @ %list;
    }
    return %token;
}
function pushBack(%list, %token, %delim)
{
    if (!(%list $= ""))
    {
        return %list @ %delim @ %token;
    }
    return %token;
}
function popFront(%list, %delim)
{
    return nextToken(%list, unused, %delim);
}
function defaultParseArgs()
{
    $i = 1;
    while ($i < $Game::argc)
    {
        $arg = $Game::argv[$i];
        $nextArg = $Game::argv[$i + 1];
        $hasNextArg = ($Game::argc - $i) > 1;
        $logModeSpecified = 0;
        if ($arg $= "-compileAll")
        {
            $compileAll = 1;
            $argUsed[$i] = $argUsed[$i] + 1;
        }
        else
        {
            if ($arg $= "-dbPipeName")
            {
                $argUsed[$i] = $argUsed[$i] + 1;
                if ($hasNextArg)
                {
                    $repairSystemDb = 1;
                    $cm_config::DB::Connect::server = $nextArg;
                    hack("-dbPipeName == " @ $cm_config::DB::Connect::server);
                    $argUsed[$i + 1] = $argUsed[$i + 1] + 1;
                    $i = $i + 1;
                }
            }
            else
            {
                if ($arg $= "-worldID")
                {
                    $argUsed[$i] = $argUsed[$i] + 1;
                    if ($hasNextArg)
                    {
                        $cm_config::worldID = $nextArg;
                        hack("-worldID == " @ $cm_config::worldID);
                        $argUsed[$i + 1] = $argUsed[$i + 1] + 1;
                        $i = $i + 1;
                    }
                }
                else
                {
                    $argUsed[$i] = $argUsed[$i] + 1;
                    if ($userDirs $= "")
                    {
                        $userDirs = $arg;
                    }
                }
            }
        }
        $i = $i + 1;
    }
}
