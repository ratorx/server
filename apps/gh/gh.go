package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"golang.org/x/time/rate"
)

type asset struct {
	Name string `json:"name"`
	URL string `json:"browser_download_url"`
	ContentType string `json:"content_type"`
}

type release struct {
	Assets []asset `json:"assets"`
}

var defaultClient = newClient(rate.NewLimiter(rate.Every(time.Minute), 60))
const githubReleasesFmt = "https://api.github.com/repos/%s/%s/releases/latest"

type releaseLookup struct {
	repository string
	name string
	asset string
}

func lookupLatestRelease(ctx context.Context, rl releaseLookup) (asset, *httpError) {
	res, err := defaultClient.Get(ctx, fmt.Sprintf(githubReleasesFmt, rl.repository, rl.name))
	if err != nil {
		return asset{}, internalError(err)
	}
	defer res.Body.Close()

	if res.StatusCode == http.StatusNotFound {
		return asset{}, badRequest(fmt.Errorf("invalid repository"))
	} else if res.StatusCode != 200 {
		return asset{}, internalError(fmt.Errorf("unknown status code %v", res.StatusCode))
	}

	var rel release
	err = json.NewDecoder(res.Body).Decode(&rel)
	if err != nil {
		return asset{}, internalError(err)
	}

	for _, a := range rel.Assets {
		if a.Name == rl.asset {
			return a, nil
		}
	}

	return asset{}, badRequest(fmt.Errorf("asset not found"))
}