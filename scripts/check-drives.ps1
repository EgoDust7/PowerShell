﻿<#
.SYNOPSIS
	Checks the drive space
.DESCRIPTION
	This PowerShell script queries the free space of all drives and prints it.
.PARAMETER minLevel
	Specifies the minimum warning level (10GB by default)
.EXAMPLE
	PS> ./check-drives.ps1
	✅ C: at 49% of 1TB - 512GB free
	✅ D: at 84% of 4TB - 641GB free
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

param([int64]$minLevel = 10GB)

function Bytes2String { param([int64]$number)
        if ($number -lt 1KB) { return "$number bytes" }
        if ($number -lt 1MB) { return '{0:N0}KB' -f ($number / 1KB) }
        if ($number -lt 1GB) { return '{0:N0}MB' -f ($number / 1MB) }
        if ($number -lt 1TB) { return '{0:N0}GB' -f ($number / 1GB) }
        if ($number -lt 1PB) { return '{0:N0}TB' -f ($number / 1TB) }
        return '{0:N0}GB' -f ($number / 1PB)
}

try {
	Write-Progress "Querying drives..."
	$drives = Get-PSDrive -PSProvider FileSystem
	Write-Progress -completed "Done."
	$status = "✅"
	$reply = ""
	foreach($drive in $drives) {
		$details = (Get-PSDrive $drive.Name)
		if ($IsLinux) { $name = $drive.Name } else { $name = $drive.Name + ":" }
		[int64]$free = $details.Free
 		[int64]$used = $details.Used
		[int64]$total = ($used + $free)
		if ($total -eq 0) {
			$reply += "📂$name is empty  "
		} elseif ($free -eq 0) {
			$status = "⚠️"
			$reply += "📂$name is full ($(Bytes2String $total))  "
		} elseif ($free -lt $minLevel) {
			$status = "⚠️"
			$reply += "📂$name is nearly full ($(Bytes2String $free) of $(Bytes2String $total) left)  "
		} else {
			[int64]$percent = ($free * 100) / $total
			$reply += "📂$name has $(Bytes2String $free) of $(Bytes2String $total) left ($percent%)  "
		}
	}
	Write-Host "$status $reply"
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
