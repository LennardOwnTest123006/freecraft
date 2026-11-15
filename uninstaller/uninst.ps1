param([string]$Dst,[string]$StrFile,[string]$SysLang)
$ErrorActionPreference = 'Stop'
try {
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$S = Get-Content -Raw -Encoding UTF8 -LiteralPath $StrFile | ConvertFrom-Json
$codes = @('en','de','fr','es','it','pt','nl','pl','ru','tr','ja','zh')
$script:L = 'en'
if ($codes -contains $SysLang) { $script:L = $SysLang }
function T([string]$k) {
  $v = $S.($script:L).($k)
  if ([string]::IsNullOrEmpty($v)) { $v = $S.en.($k) }
  return $v
}
$saves = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'FreeCraft Saves'
$f = New-Object System.Windows.Forms.Form
$f.ClientSize = New-Object System.Drawing.Size(600, 400)
$f.FormBorderStyle = 'FixedDialog'; $f.MaximizeBox = $false
$f.StartPosition = 'CenterScreen'
$f.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$ico = Join-Path $Dst 'freecraft.ico'
try { if (Test-Path -LiteralPath $ico) { $f.Icon = New-Object System.Drawing.Icon($ico) } } catch {}
$hdr = New-Object System.Windows.Forms.Panel
$hdr.Dock = 'Top'; $hdr.Height = 70; $hdr.BackColor = [System.Drawing.Color]::FromArgb(11, 16, 32)
$ht = New-Object System.Windows.Forms.Label
$ht.ForeColor = [System.Drawing.Color]::White; $ht.AutoSize = $false
$ht.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$ht.Location = New-Object System.Drawing.Point(20, 16); $ht.Size = New-Object System.Drawing.Size(560, 40)
$hdr.Controls.Add($ht)
$bar = New-Object System.Windows.Forms.Panel
$bar.Dock = 'Bottom'; $bar.Height = 56; $bar.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$bNext = New-Object System.Windows.Forms.Button; $bNext.Size = New-Object System.Drawing.Size(130, 32); $bNext.Location = New-Object System.Drawing.Point(340, 12)
$bCancel = New-Object System.Windows.Forms.Button; $bCancel.Size = New-Object System.Drawing.Size(110, 32); $bCancel.Location = New-Object System.Drawing.Point(480, 12)
$bar.Controls.AddRange(@($bNext, $bCancel))
function Lbl($x, $y, $w, $h) { $l = New-Object System.Windows.Forms.Label; $l.AutoSize = $false; $l.Location = New-Object System.Drawing.Point($x, $y); $l.Size = New-Object System.Drawing.Size($w, $h); $f.Controls.Add($l); return $l }
$lq = Lbl 30 95 540 50
$lq.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$lg = Lbl 30 160 200 22
$cb = New-Object System.Windows.Forms.ComboBox
$cb.DropDownStyle = 'DropDownList'; $cb.Location = New-Object System.Drawing.Point(30, 184); $cb.Size = New-Object System.Drawing.Size(300, 28)
$null = $cb.Items.Add('x')
foreach ($n in $S.names) { $null = $cb.Items.Add([string]$n) }
$f.Controls.Add($cb)
$cKeep = New-Object System.Windows.Forms.CheckBox; $cKeep.Location = New-Object System.Drawing.Point(30, 240); $cKeep.Size = New-Object System.Drawing.Size(540, 28); $cKeep.Checked = $true
$f.Controls.Add($cKeep)
$lw = Lbl 30 120 540 60
$lw.Visible = $false
$pb = New-Object System.Windows.Forms.ProgressBar; $pb.Location = New-Object System.Drawing.Point(30, 200); $pb.Size = New-Object System.Drawing.Size(540, 24); $pb.Style = 'Marquee'; $pb.Visible = $false
$f.Controls.Add($pb)
$f.Controls.AddRange(@($bar, $hdr))
$script:done = $false
$base = if ($codes -contains $SysLang) { $SysLang } else { 'en' }
function Apply {
  $f.Text = T 'utitle'; $ht.Text = T 'utitle'
  $lq.Text = T 'uq'; $lg.Text = T 'lang'; $cKeep.Text = T 'ukeep'
  $cb.Items[0] = (T 'sysdef') + ' (' + $S.names[[array]::IndexOf($codes, $base)] + ')'
  $bCancel.Text = T 'cancel'
  if ($script:done) { $bNext.Text = T 'finish' } else { $bNext.Text = T 'urem' }
}
$cb.SelectedIndex = 0
$script:busy = $false
$cb.Add_SelectedIndexChanged({
  if ($script:busy) { return }
  $script:busy = $true
  if ($cb.SelectedIndex -le 0) { $script:L = $base } else { $script:L = $codes[$cb.SelectedIndex - 1] }
  $keep = $cb.SelectedIndex
  Apply
  $cb.SelectedIndex = $keep
  $script:busy = $false
})
$bCancel.Add_Click({ $f.Close() })
$bNext.Add_Click({
  if ($script:done) { $f.Close(); return }
  $bNext.Enabled = $false; $bCancel.Visible = $false
  $lq.Visible = $false; $lg.Visible = $false; $cb.Visible = $false; $cKeep.Visible = $false
  $lw.Text = T 'uwork'; $lw.Visible = $true; $pb.Visible = $true
  $f.Refresh(); [System.Windows.Forms.Application]::DoEvents()
  $savedMsg = ''
  Get-Process -Name 'FreeCraft', 'FreeCraft-Server' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 2
  if ($cKeep.Checked) {
    New-Item -ItemType Directory -Force -Path $saves | Out-Null
    foreach ($n in @('worlds', 'client', 'minetest.conf')) {
      $src = Join-Path $Dst $n
      if (Test-Path -LiteralPath $src) { Copy-Item -LiteralPath $src -Destination $saves -Recurse -Force }
    }
    $savedMsg = (T 'usaved') + $saves
  }
  $desk = [Environment]::GetFolderPath('Desktop')
  foreach ($n in @('FreeCraft', 'FreeCraft Server', 'FreeCraft Worlds')) { Remove-Item -LiteralPath (Join-Path $desk ($n + '.lnk')) -Force -ErrorAction SilentlyContinue }
  Remove-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeCraft' -Recurse -Force -ErrorAction SilentlyContinue
  $cmd = '/c ping 127.0.0.1 -n 4 >nul & rmdir /s /q "' + $Dst + '"'
  Start-Process -FilePath 'cmd.exe' -ArgumentList $cmd -WindowStyle Hidden
  $pb.Visible = $false
  $lw.Text = (T 'udone') + "`r`n`r`n" + $savedMsg
  $script:done = $true
  Apply
  $bNext.Enabled = $true
})
Apply
[void]$f.ShowDialog()
} catch {
  [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'FreeCraft', 'OK', 'Error') | Out-Null
}
