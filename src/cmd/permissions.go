package cmd

import (
	"errors"
	"os"
	"path/filepath"
	"runtime"

	"github.com/ilhm18/spoty/src/utils"
)

func checkSpotifyWriteAccess() {
	if runtime.GOOS != "darwin" {
		return
	}

	if err := checkDirectoryWritable(filepath.Dir(appDestPath)); err != nil {
		spotifyWriteError(err)
	}
}

func checkDirectoryWritable(path string) error {
	probe, err := os.MkdirTemp(path, ".hamspot-write-test-")
	if err != nil {
		return err
	}
	writeErr := os.WriteFile(filepath.Join(probe, "test"), []byte("hamspot"), 0600)
	cleanupErr := os.RemoveAll(probe)
	return errors.Join(writeErr, cleanupErr)
}

func spotifyWriteError(err error) {
	utils.PrintError("Cannot write to Spotify's application files")
	if runtime.GOOS == "darwin" && errors.Is(err, os.ErrPermission) {
		utils.PrintInfo("Open System Settings > Privacy & Security > App Management and allow the terminal app running Hamspot")
		utils.PrintInfo("Quit and reopen your terminal app, then run Hamspot again")
	}
	utils.Fatal(err)
}
