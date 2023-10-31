*ping-weather.ps1*
================

This PowerShell script continuously shows the current weather conditions (similar to htop, 10 min update interval by default).

Parameters
----------
```powershell
PS> ./ping-weather.ps1 [[-Location] <String>] [[-UpdateInterval] <Int32>] [<CommonParameters>]

-Location <String>
    Specifies the location to use (determined automatically per default)
    
    Required?                    false
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false

-UpdateInterval <Int32>
    
    Required?                    false
    Position?                    2
    Default value                600
    Accept pipeline input?       false
    Accept wildcard characters?  false

[<CommonParameters>]
    This script supports the common parameters: Verbose, Debug, ErrorAction, ErrorVariable, WarningAction, 
    WarningVariable, OutBuffer, PipelineVariable, and OutVariable.
```

Example
-------
```powershell
PS> ./ping-weather
Current weather conditions at Paris (Ile-de-France), updating every 10 min...
🕗10:24 AM UTC  🌡23°C  ☂️0.0mm  💨9km/h from S  ☁️0%  💧41%  ☀️UV6  1020hPa  Sunny

```

Notes
-----
Author: Markus Fleschutz | License: CC0

Related Links
-------------
https://github.com/fleschutz/PowerShell

Script Content
--------------
```powershell
<#
.SYNOPSIS
	Ping the currrent weather conditions
.DESCRIPTION
	This PowerShell script continuously shows the current weather conditions (similar to htop, 10 min update interval by default).
.PARAMETER Location
	Specifies the location to use (determined automatically per default)
.EXAMPLE
	PS> ./ping-weather
	Current weather conditions at Paris (Ile-de-France), updating every 10 min...
	🕗10:24 AM UTC  🌡23°C  ☂️0.0mm  💨9km/h from S  ☁️0%  💧41%  ☀️UV6  1020hPa  Sunny
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

param([string]$Location = "", [int]$UpdateInterval = 600)

try {
	$Weather = (Invoke-WebRequest -URI http://wttr.in/${Location}?format=j1 -userAgent "curl" -useBasicParsing).Content | ConvertFrom-Json
        $Area = $Weather.nearest_area.areaName.value
        $Region = $Weather.nearest_area.region.value
	"Current weather conditions at $Area ($Region), updating every $($UpdateInterval / 60) min..."
	do {
		
		$Description = $Weather.current_condition.WeatherDesc.value
		$TempC = $Weather.current_condition.temp_C
		$PrecipMM = $Weather.current_condition.precipMM
		$WindSpeed = $Weather.current_condition.windspeedKmph
		$WindDir = $Weather.current_condition.winddir16Point
		$Clouds = $Weather.current_condition.cloudcover
		$Humidity = $Weather.current_condition.humidity
		$UV = $Weather.current_condition.uvIndex
		$Visib = $Weather.current_condition.visibility 
		$Pressure = $Weather.current_condition.pressure
		$Time = $Weather.current_condition.observation_time

		"🕗$Time UTC  🌡$($TempC)°C  ☂️$($PrecipMM)mm  💨$($WindSpeed)km/h from $WindDir  ☁️$($Clouds)%  💧$($Humidity)%  ☀️UV$UV  👀$($Visib)km  $($Pressure)hPa  $Description"
		Start-Sleep -s $UpdateInterval
		$Weather = (Invoke-WebRequest -URI http://wttr.in/${Location}?format=j1 -userAgent "curl" -useBasicParsing).Content | ConvertFrom-Json
	} while ($true)
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
```

*(generated by convert-ps2md.ps1 using the comment-based help of ping-weather.ps1 as of 10/19/2023 08:11:41)*