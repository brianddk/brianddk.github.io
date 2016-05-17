[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
function SendKey ([string]$WinHndl, [string]$Keys, [int]$msWait)
{
    [Microsoft.VisualBasic.Interaction]::AppActivate($WinHndl)
    Sleep -Milliseconds $msWait
    [System.Windows.Forms.SendKeys]::SendWait($Keys)
}

function SendToFree42 ([string]$Keys)
{
    SendKey "Free42 Decimal" $Keys 250
}

function SplitMove ([string[]]$move)
{
    $h = @{}
    $h.p2 = $move[2]
    $h.p1 = $move[3]
    $h.p2s = ($h.p2 -split "\.")[1]
    $h.p1s = ($h.p1 -split "\.")[1]
    return $h
}

function LogMove ([string[]]$curr, [string[]]$prev, [string]$log)
{
    if($curr -and $prev)
    {
        $c = SplitMove($curr)
        $p = SplitMove($prev)
        if($c.p1 -eq $p.p1 -and $c.p2 -eq $p.p2)
        {
            Write-Host "Bad Move"
            #Write-Host ($prev | Out-String)
            return $curr
        }
    }
    Write-Host ($prev | Out-String)
    Add-Content $log ($prev | Out-String) -Encoding Ascii
    return $curr
}

SendToFree42 "{F6}"
SendToFree42 "{F1}"
$prevMove = ""
$curMove = ""
$logfile = '.\mancala.log'
Set-Content $logfile "" -Encoding Ascii

while ($true)
{
    $p = (Get-Random) % 6 + 1
    SendToFree42 "$p"
    SendToFree42 "_"
    SendToFree42 "{F4}"
    SendToFree42 "\"
    $curMove = (Get-content "..\print.txt" -Encoding Ascii)[-5..-1]
    $m = SplitMove $curMove
    $prevMove = LogMove $curMove $prevMove $logfile
    if ($status -match "000,000" -or $m.p1s -gt 24 -or $m.p2s -gt 24)
    {
        break
    }
}
$prevMove = LogMove $null $prevMove $logfile
