// Package internal implements functionality for generating formula templates.
package internal

import (
	"context"
	"fmt"
	"log/slog"
)

func FetchReleaseGenerateFormulae(ctx context.Context, templateDir, outdir, releaseTag string) error {
	var tag *string
	if releaseTag != "" {
		tag = &releaseTag
	}
	releaseData, err := FetchGithubRelease(ctx, tag)
	if err != nil {
		return fmt.Errorf("fetching gh release: %w", err)
	}
	slog.DebugContext(ctx, "got release data", slog.Any("release", releaseData))
	return MakeFormulaeFiles(templateDir, outdir, releaseData)
}
