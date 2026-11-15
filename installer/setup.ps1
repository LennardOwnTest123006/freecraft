param([string]$Exe,[string]$Dst,[string]$StrFile,[string]$SysLang,[string]$ArgFile,[string]$ProgFile)
$ErrorActionPreference = 'Stop'
try {
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$S = Get-Content -Raw -Encoding UTF8 -LiteralPath $StrFile | ConvertFrom-Json
$codes = @('en','de','fr','es','it','pt','nl','pl','ru','tr','ja','zh')
$script:L = 'en'
if ($codes -contains $SysLang) { $script:L = $SysLang }
$base = $script:L
function T([string]$k) {
  $v = $S.($script:L).($k)
  if ([string]::IsNullOrEmpty($v)) { $v = $S.en.($k) }
  return $v
}
$installed = Test-Path -LiteralPath (Join-Path $Dst 'bin\FreeCraft.exe')
$unExe = Join-Path $Dst 'Uninstall FreeCraft.exe'
$saves = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'FreeCraft Saves'
# vorhandenen Namen vorbelegen
$preUser = ''; $preDisp = ''
foreach ($c in @((Join-Path $Dst 'minetest.conf'), (Join-Path $saves 'minetest.conf'))) {
  if ((-not $preUser) -and (Test-Path -LiteralPath $c)) {
    foreach ($ln in (Get-Content -LiteralPath $c -Encoding UTF8)) {
      if ($ln -match '^\s*name\s*=\s*(\S.*)$') { $preUser = $Matches[1].Trim() }
      if ($ln -match '^\s*freecraft_display_name\s*=\s*(.+)$') { $preDisp = $Matches[1].Trim() }
    }
  }
}
$f = New-Object System.Windows.Forms.Form
$f.ClientSize = New-Object System.Drawing.Size(600, 440)
$f.FormBorderStyle = 'FixedDialog'; $f.MaximizeBox = $false; $f.MinimizeBox = $true
$f.StartPosition = 'CenterScreen'
$f.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
try { $f.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($Exe) } catch {}

$hdr = New-Object System.Windows.Forms.Panel
$hdr.Dock = 'Top'; $hdr.Height = 70; $hdr.BackColor = [System.Drawing.Color]::FromArgb(11, 16, 32)
$ht = New-Object System.Windows.Forms.Label
$ht.ForeColor = [System.Drawing.Color]::White; $ht.AutoSize = $false
$ht.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$ht.Location = New-Object System.Drawing.Point(20, 16); $ht.Size = New-Object System.Drawing.Size(560, 40)
$hdr.Controls.Add($ht)

$bar = New-Object System.Windows.Forms.Panel
$bar.Dock = 'Bottom'; $bar.Height = 56; $bar.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$bBack = New-Object System.Windows.Forms.Button; $bBack.Size = New-Object System.Drawing.Size(110, 32); $bBack.Location = New-Object System.Drawing.Point(222, 12)
$bNext = New-Object System.Windows.Forms.Button; $bNext.Size = New-Object System.Drawing.Size(130, 32); $bNext.Location = New-Object System.Drawing.Point(340, 12)
$bCancel = New-Object System.Windows.Forms.Button; $bCancel.Size = New-Object System.Drawing.Size(110, 32); $bCancel.Location = New-Object System.Drawing.Point(480, 12)
$bar.Controls.AddRange(@($bBack, $bNext, $bCancel))

function NewPage { $p = New-Object System.Windows.Forms.Panel; $p.Location = New-Object System.Drawing.Point(0, 70); $p.Size = New-Object System.Drawing.Size(600, 314); $p.Visible = $false; return $p }
function Lbl($par, $x, $y, $w, $h) { $l = New-Object System.Windows.Forms.Label; $l.AutoSize = $false; $l.Location = New-Object System.Drawing.Point($x, $y); $l.Size = New-Object System.Drawing.Size($w, $h); $par.Controls.Add($l); return $l }

# Seite 0: Willkommen + Sprache
$p0 = NewPage
$l0a = Lbl $p0 30 20 540 24
$l0a.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$l0b = Lbl $p0 30 50 540 24
$l0c = Lbl $p0 30 96 200 22
$cb = New-Object System.Windows.Forms.ComboBox
$cb.DropDownStyle = 'DropDownList'; $cb.Location = New-Object System.Drawing.Point(30, 120); $cb.Size = New-Object System.Drawing.Size(300, 28)
$null = $cb.Items.Add('x')
foreach ($n in $S.names) { $null = $cb.Items.Add([string]$n) }
$p0.Controls.Add($cb)
$rUpd = New-Object System.Windows.Forms.RadioButton; $rUpd.Location = New-Object System.Drawing.Point(30, 200); $rUpd.Size = New-Object System.Drawing.Size(520, 26); $rUpd.Checked = $true
$rUn = New-Object System.Windows.Forms.RadioButton; $rUn.Location = New-Object System.Drawing.Point(30, 230); $rUn.Size = New-Object System.Drawing.Size(520, 26)
$l0d = Lbl $p0 30 170 540 24
$l0d.Font = New-Object System.Drawing.Font('Segoe UI', 9.5, [System.Drawing.FontStyle]::Bold)
$p0.Controls.AddRange(@($rUpd, $rUn))

# Seite 1: Spieler + Ordner
$p1 = NewPage
$l1h = Lbl $p1 30 14 540 24
$l1h.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$l1u = Lbl $p1 30 48 540 20
$tU = New-Object System.Windows.Forms.TextBox; $tU.Location = New-Object System.Drawing.Point(30, 70); $tU.Size = New-Object System.Drawing.Size(320, 26); $tU.MaxLength = 20; $tU.Text = $preUser
$l1uh = Lbl $p1 30 98 540 20; $l1uh.ForeColor = [System.Drawing.Color]::DimGray
$l1d = Lbl $p1 30 128 540 20
$tD = New-Object System.Windows.Forms.TextBox; $tD.Location = New-Object System.Drawing.Point(30, 150); $tD.Size = New-Object System.Drawing.Size(320, 26); $tD.MaxLength = 32; $tD.Text = $preDisp
$l1dh = Lbl $p1 30 178 540 20; $l1dh.ForeColor = [System.Drawing.Color]::DimGray
$l1f = Lbl $p1 30 214 540 20
$tF = New-Object System.Windows.Forms.TextBox; $tF.Location = New-Object System.Drawing.Point(30, 236); $tF.Size = New-Object System.Drawing.Size(400, 26); $tF.Text = $Dst
$bBr = New-Object System.Windows.Forms.Button; $bBr.Location = New-Object System.Drawing.Point(440, 234); $bBr.Size = New-Object System.Drawing.Size(110, 30)
$p1.Controls.AddRange(@($tU, $tD, $tF, $bBr))

# Seite 2: Fortschritt
$p2 = NewPage
$l2 = Lbl $p2 30 90 540 26
$pb = New-Object System.Windows.Forms.ProgressBar; $pb.Location = New-Object System.Drawing.Point(30, 124); $pb.Size = New-Object System.Drawing.Size(540, 26); $pb.Minimum = 0; $pb.Maximum = 100
$p2.Controls.Add($pb)

# Seite 3: Fertig
$p3 = NewPage
$l3 = Lbl $p3 30 60 540 60
$l3.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$l3r = Lbl $p3 30 120 540 24
$cLaunch = New-Object System.Windows.Forms.CheckBox; $cLaunch.Location = New-Object System.Drawing.Point(30, 160); $cLaunch.Size = New-Object System.Drawing.Size(520, 28); $cLaunch.Checked = $true
$p3.Controls.Add($cLaunch)
$f.Controls.AddRange(@($p0, $p1, $p2, $p3, $bar, $hdr))

$script:page = 0
$script:proc = $null
$script:failed = $false
function Apply {
  $f.Text = T 'title'; $ht.Text = T 'title'
  $l0a.Text = T 'welcome'; $l0b.Text = T 'welcome2'; $l0c.Text = T 'lang'
  $cb.Items[0] = (T 'sysdef') + ' (' + $S.names[[array]::IndexOf($codes, $base)] + ')'
  $l0d.Text = T 'exists'; $rUpd.Text = T 'upd'; $rUn.Text = T 'unins'
  $l1h.Text = T 'acc'; $l1u.Text = T 'user'; $l1uh.Text = T 'userhint'; $l1d.Text = T 'disp'; $l1dh.Text = T 'disphint'; $l1f.Text = T 'dir'; $bBr.Text = T 'browse'
  $l2.Text = T 'installing'
  $cLaunch.Text = T 'launch'
  $bBack.Text = T 'back'; $bCancel.Text = T 'cancel'
  ShowPage
}
function ShowPage {
  $p0.Visible = ($script:page -eq 0); $p1.Visible = ($script:page -eq 1); $p2.Visible = ($script:page -eq 2); $p3.Visible = ($script:page -eq 3)
  $l0d.Visible = $installed; $rUpd.Visible = $installed; $rUn.Visible = $installed
  $bBack.Visible = ($script:page -eq 1)
  switch ($script:page) {
    0 { $bNext.Text = T 'next'; $bNext.Enabled = $true; $bCancel.Visible = $true }
    1 { $bNext.Text = T 'install'; $bNext.Enabled = $true; $bCancel.Visible = $true }
    2 { $bNext.Enabled = $false; $bNext.Text = T 'install'; $bCancel.Visible = $true }
    3 { $bNext.Text = T 'finish'; $bNext.Enabled = $true; $bCancel.Visible = $false }
  }
}
$cb.SelectedIndex = 0
$script:busy = $false
$cb.Add_SelectedIndexChanged({
  if ($script:busy) { return }
  $script:busy = $true
  if ($cb.SelectedIndex -le 0) { $script:L = $base }
  else { $script:L = $codes[$cb.SelectedIndex - 1] }
  $keep = $cb.SelectedIndex
  Apply
  $cb.SelectedIndex = $keep
  $script:busy = $false
})
$bBr.Add_Click({
  $d = New-Object System.Windows.Forms.FolderBrowserDialog
  if ($d.ShowDialog() -eq 'OK') { $tF.Text = (Join-Path $d.SelectedPath 'FreeCraft') }
})
$bBack.Add_Click({ $script:page = 0; ShowPage })
$bCancel.Add_Click({ $f.Close() })
$f.Add_FormClosing({
  if ($script:proc -and -not $script:proc.HasExited) { try { $script:proc.Kill() } catch {} }
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 300
$timer.Add_Tick({
  $txt = ''
  try { $txt = [System.IO.File]::ReadAllText($ProgFile) } catch {}
  if ($txt) {
    $p = $txt.Trim().Split('|')
    $v = 0; [int]::TryParse($p[0], [ref]$v) | Out-Null
    if ($v -ge 0) { $pb.Value = [Math]::Min(100, $v) }
    if ($v -ge 0 -and $p.Length -gt 1) { $l2.Text = T $p[1] }
    if ($v -eq 100) {
      $timer.Stop(); $script:page = 3
      $l3.Text = T 'done'
      $l3r.Text = $(if ($script:restored) { T 'restore' } else { '' })
      ShowPage; return
    }
    if ($v -lt 0) {
      $timer.Stop(); $script:failed = $true
      [System.Windows.Forms.MessageBox]::Show((T 'fail'), (T 'title'), 'OK', 'Error') | Out-Null
      $f.Close(); return
    }
  }
  if ($script:proc -and $script:proc.HasExited -and -not $txt.StartsWith('100')) {
    $timer.Stop()
    [System.Windows.Forms.MessageBox]::Show((T 'fail'), (T 'title'), 'OK', 'Error') | Out-Null
    $f.Close()
  }
})

$bNext.Add_Click({
  if ($script:page -eq 0) {
    if ($installed -and $rUn.Checked) {
      if (Test-Path -LiteralPath $unExe) { Start-Process -FilePath $unExe }
      $f.Close(); return
    }
    $script:page = 1; ShowPage; return
  }
  if ($script:page -eq 1) {
    $u = $tU.Text.Trim(); $d = $tD.Text.Trim()
    if ($u -notmatch '^[A-Za-z0-9_-]{3,20}$') { [System.Windows.Forms.MessageBox]::Show((T 'baduser'), (T 'title'), 'OK', 'Warning') | Out-Null; return }
    if ($d.Length -lt 1 -or $d.Length -gt 32) { [System.Windows.Forms.MessageBox]::Show((T 'baddisp'), (T 'title'), 'OK', 'Warning') | Out-Null; return }
    $script:dstFinal = $tF.Text.Trim().TrimEnd('\')
    $script:restored = (-not (Test-Path -LiteralPath (Join-Path $script:dstFinal 'worlds'))) -and (Test-Path -LiteralPath (Join-Path $saves 'worlds'))
    $obj = @{ Dst = $script:dstFinal; Lang = $script:L; User = $u; Disp = $d; Prog = $ProgFile }
    $json = $obj | ConvertTo-Json
    [System.IO.File]::WriteAllText($ArgFile, $json, (New-Object System.Text.UTF8Encoding($false)))
    Remove-Item -LiteralPath $ProgFile -ErrorAction SilentlyContinue
    $script:page = 2; ShowPage
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Exe; $psi.Arguments = '--worker "' + $ArgFile + '"'
    $psi.UseShellExecute = $false; $psi.CreateNoWindow = $true
    $script:proc = [System.Diagnostics.Process]::Start($psi)
    $timer.Start(); return
  }
  if ($script:page -eq 3) {
    if ($cLaunch.Checked) {
      $v = Join-Path $script:dstFinal 'FreeCraft.vbs'
      if (Test-Path -LiteralPath $v) { Start-Process -FilePath 'wscript.exe' -ArgumentList ('"' + $v + '"') -WorkingDirectory $script:dstFinal }
    }
    $f.Close()
  }
})
Apply
[void]$f.ShowDialog()
} catch {
  [System.Windows.Forms.MessageBox]::Show($_.Exception.Message + "`n" + $_.ScriptStackTrace, 'FreeCraft Setup', 'OK', 'Error') | Out-Null
}
