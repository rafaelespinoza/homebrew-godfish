package internal

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"maps"
	"net/http"
	"os"
	"slices"
	"strings"
	"time"
)

type GithubRelease struct {
	TagName string               `json:"tag_name"`
	Assets  []GithubReleaseAsset `json:"assets"`
}

type GithubReleaseAsset struct {
	Name               string    `json:"name"`
	Size               int64     `json:"size"`
	Digest             *string   `json:"digest"`
	BrowserDownloadURL string    `json:"browser_download_url"`
	APIURL             string    `json:"url"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
	ContentType        string    `json:"content_type"`
}

const repoOwner, repoName = "rafaelespinoza", "godfish"

func FetchGithubRelease(ctx context.Context, tag *string) (*GithubRelease, error) {
	httpClient := http.Client{}
	reqURL := "https://api.github.com/repos/" + repoOwner + "/" + repoName + "/releases"
	if tag != nil {
		// https://docs.github.com/en/rest/releases/releases?apiVersion=2026-03-10#get-a-release-by-tag-name
		reqURL += "/tags/" + *tag
	} else {
		// https://docs.github.com/en/rest/releases/releases?apiVersion=2026-03-10#get-the-latest-release
		reqURL += "/latest"
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, reqURL, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/vnd.github+json")
	if token := strings.TrimSpace(os.Getenv("GITHUB_TOKEN")); token != "" {
		req.Header.Set("Authorization", "Bearer: "+token)
	}
	logger := slog.Default().With(
		slog.GroupAttrs("request", slog.String("url", reqURL)),
	)

	logger.DebugContext(ctx, "starting request")
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("requesting release data: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		_, _ = io.Copy(io.Discard, resp.Body)
		return nil, errors.New("release not found")
	} else if resp.StatusCode > 299 {
		rawBody, _ := io.ReadAll(resp.Body)
		headerKeys := slices.Collect(maps.Keys(resp.Header))
		slices.Sort(headerKeys)

		logger.With(
			slog.GroupAttrs("response",
				slog.Int("status_code", resp.StatusCode),
				slog.GroupAttrs("headers",
					slog.String("Content-Type", resp.Header.Get("Content-Type")),
				),
				slog.Any("all_header_keys", headerKeys),
				slog.String("body", string(rawBody)),
			),
		).ErrorContext(ctx, "response error", slog.Any("error", err))
		return nil, fmt.Errorf("unexpected response code (%d): %w", resp.StatusCode, err)
	}

	var release GithubRelease
	if err := json.NewDecoder(resp.Body).Decode(&release); err != nil {
		return nil, fmt.Errorf("decoding release json: %w", err)
	}

	return &release, nil
}
