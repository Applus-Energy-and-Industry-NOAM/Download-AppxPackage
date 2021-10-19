<#
.SYNOPSIS
Basic Syntax:
.\Download-AppxPackage.ps1 -Uri <URL to Windows Store Application> -Path <Path to store downloaded files>

.EXAMPLE
.\Download-AppxPackage.ps1 -Uri https://www.microsoft.com/en-us/p/microsoft-to-do-lists-tasks-reminders/9nblggh5r558 -Path C:\Temp\MSTodo

#>

[CmdletBinding()]
param (
  [string]$Uri,
  [string]$Path = "."
)
  $StopWatch = [system.diagnostics.stopwatch]::startnew()
  $Path = (Resolve-Path $Path).Path
  
  # Get Urls to download
  Write-Host -ForegroundColor Yellow "Processing $Uri"
  $WebResponse = Invoke-WebRequest -UseBasicParsing -Method 'POST' -Uri 'https://store.rg-adguard.net/api/GetFiles' -Body "type=url&url=$Uri&ring=Retail" -ContentType 'application/x-www-form-urlencoded'
  $LinksMatch = ($WebResponse.Links | where {$_ -like '*.appx*'} |  Select-String -Pattern '(?<=a href=").+(?=" r)').matches.value
    $Files = ($WebResponse.Links | where {$_ -like '*.appx*'} | Select-String -Pattern '(?<=noreferrer">).+(?=</a>)').matches.value
  
  #Create array of links and filenames
  $DownloadLinks = @()
  for($i = 0;$i -lt $LinksMatch.Count; $i++){
    $Array += ,@($LinksMatch[$i],$Files[$i])
  }
  
  #Sort by filename descending
  $Array = $Array | sort-object @{Expression={$_[1]}; Descending=$True}
  $LastFile = "temp123"
  for($i = 0;$i -lt $LinksMatch.Count; $i++){
    $CurrentFile = $Array[$i][1]
    $CurrentUrl = $Array[$i][0]
    "Downloading $Path\$CurrentFile"
    $FilePath = "$Path\$CurrentFile"
    $FileRequest = Invoke-WebRequest -Uri $CurrentUrl -UseBasicParsing #-Method Head
    [System.IO.File]::WriteAllBytes($FilePath, $FileRequest.content)

  }
"Time to process: "+$StopWatch.ElapsedMilliseconds