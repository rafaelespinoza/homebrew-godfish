// Package internal implements functionality for generating formula templates.
package internal

import (
	"context"
	"fmt"
	"log/slog"
)

func GenerateFormulae(ctx context.Context, templateDir, outdir, releaseTag string) error {
	var tag *string
	if releaseTag != "" {
		tag = &releaseTag
	}
	releaseData, err := fetchGithubRelease(ctx, tag)
	if err != nil {
		return fmt.Errorf("fetching gh release: %w", err)
	}
	slog.DebugContext(ctx, "got release data", slog.Any("release", releaseData))
	if err = makeFormulaeFiles(templateDir, outdir, releaseData); err == nil {
		slog.Info("ok, see results at directory", slog.String("directory", outdir))
	}
	return err
}
