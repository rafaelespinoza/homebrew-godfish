// Package internal implements functionality for generating formula templates.
package internal

import (
	"context"
	"fmt"
	"io/fs"
	"log/slog"
)

func FetchReleaseGenerateFormulae(ctx context.Context, releaseTag *string, templateDirFS fs.FS, outDir string) error {
	releaseData, err := FetchGithubRelease(ctx, releaseTag)
	if err != nil {
		return fmt.Errorf("fetching gh release: %w", err)
	}
	slog.DebugContext(ctx, "got release data", slog.Any("release", releaseData))
	return MakeFormulaeFiles(templateDirFS, outDir, releaseData)
}
