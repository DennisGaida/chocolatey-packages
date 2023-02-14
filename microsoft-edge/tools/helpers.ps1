function CheckNoDestop([hashtable] $pp) {
	if ($pp['NoDesktopIcon']) {
		Write-Host "Disabling Desktop as requested"
		return 'DONOTCREATEDESKTOPSHORTCUT=true'
	}
}
