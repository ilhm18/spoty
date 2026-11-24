package utils

import (
	"errors"
	"net/http"
	"strings"
)

type GithubRelease struct {
	TagName string `json:"tag_name"`
	Message string `json:"message"`
}

func FetchLatestTag() (string, error) {
	res, err := http.Get("https://github.com/ilhm18/spoty/releases/latest")
	if err != nil {
		return "", err
	}
	defer res.Body.Close()

	parts := strings.Split(strings.Trim(res.Request.URL.Path, "/"), "/")
	for i := len(parts) - 1; i >= 0; i-- {
		if parts[i] == "tag" && i+1 < len(parts) {
			tag := strings.TrimPrefix(parts[i+1], "v")
			if tag != "" {
				return tag, nil
			}
		}
	}
	return "", errors.New("could not determine latest Hamspot release tag")
}
