[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
function SendKey ($WinHndl, $Keys, $msWait)
{
    [Microsoft.VisualBasic.Interaction]::AppActivate($WinHndl)
    Sleep -Milliseconds $msWait
    [System.Windows.Forms.SendKeys]::SendWait($Keys)
}

function SendToFree42 ($Keys)
{
    SendKey "Free42 Decimal" $Keys 250
}

SendToFree42 "{F6}"
SendToFree42 "{F1}"

while ($true)
{
    $p = (Get-Random) % 6 + 1
    SendToFree42 "$p"
    SendToFree42 "_"
    SendToFree42 "{F4}"
    SendToFree42 "\"
    $status = (Get-content "..\print.txt")[-5..-1]
    $p2 = ($status[2] -split "\.")[1]
    $p1 = ($status[3] -split "\.")[1]
    $status
    if ($status -match "000,000" -or $p1 -gt 24 -or $p2 -gt 24)
    {
        break
    }
}
