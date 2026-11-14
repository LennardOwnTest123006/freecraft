Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
d = fso.GetParentFolderName(WScript.ScriptFullName)
sh.CurrentDirectory = d
On Error Resume Next
sh.Run "powershell -NoProfile -WindowStyle Hidden -Command ""$ip=(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -match '^(192\.168|10\.|172\.(1[6-9]|2[0-9]|3[01]))'} | Select-Object -First 1).IPAddress; $p='minetest.conf'; $c=@(Get-Content $p | Where-Object {$_ -notmatch '^fc_lan_ip'}); $c+='fc_lan_ip = '+$ip; Set-Content $p $c""", 0, True
On Error GoTo 0
sh.Run """" & d & "\bin\FreeCraft.exe"" --gameid freecraft", 1, False
