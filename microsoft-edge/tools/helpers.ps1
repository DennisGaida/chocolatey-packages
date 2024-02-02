function CheckNoDestop([hashtable] $pp) {
	if ($pp['NoDesktopIcon']) {
		Write-Host "Disabling Desktop icon as requested"
		return 'DONOTCREATEDESKTOPSHORTCUT=true'
	}
}
