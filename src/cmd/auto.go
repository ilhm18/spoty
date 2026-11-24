package cmd

import (
	"os"

	backupstatus "github.com/ilhm18/spoty/src/status/backup"
	spotifystatus "github.com/ilhm18/spoty/src/status/spotify"
)

// Auto checks Spotify state, re-backup and apply if needed, then launch
// Spotify client normally.
func Auto(hamspotVersion string) {
	backupVersion := backupSection.Key("version").MustString("")
	spotStat := spotifystatus.Get(appPath)
	backStat := backupstatus.Get(prefsPath, backupFolder, backupVersion)

	if spotStat.IsBackupable() && (backStat.IsEmpty() || backStat.IsOutdated()) {
		Backup(hamspotVersion, true)
		backupVersion := backupSection.Key("version").MustString("")
		backStat = backupstatus.Get(prefsPath, backupFolder, backupVersion)
	}

	if !backStat.IsBackuped() {
		os.Exit(1)
	}

	if isAppX {
		spotStat = spotifystatus.Get(appDestPath)
	}

	if !spotStat.IsApplied() && backStat.IsBackuped() {
		CheckStates()
		InitSetting()
		Apply(hamspotVersion)
	}
}
