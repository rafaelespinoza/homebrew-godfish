package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"strings"

	"github.com/rafaelespinoza/homebrew-godfish/internal"
)

var arguments struct {
	TemplateDir string
	Outdir      string
	ReleaseTag  string
	LogLevel    string
}

func init() {
	const defaultOutdir = "Formula/"
	flag.StringVar(&arguments.TemplateDir, "templatedir", filepath.Clean("generator/templates"), "path to directory with templates")
	flag.StringVar(&arguments.Outdir, "outdir", filepath.Clean(defaultOutdir), "output directory to place generated formula files")
	flag.StringVar(&arguments.ReleaseTag, "tag", "", "which release tag to source from; if empty, latest is assumed")
	flag.StringVar(&arguments.LogLevel, "loglevel", "", "logging level")
	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), `Usage: %s [flags] <action>

Description:
	Generate homebrew formula files for this tap.
	By default, it looks for the latest release and writes the generated Homebrew
	files to %s.

Actions:
	fetch-generate, fg
		Get release data from the github API and generate template formula files.

	fetch-release, fetch, f
		Get release data from the github API and write JSON to stdout.

	generate-formulae, generate-formula, generate, gen, g
		Pipe in JSON release data, then generate formula files.

Flags:
`, os.Args[0], defaultOutdir)
		flag.CommandLine.PrintDefaults()
	}
}

func main() {
	flag.Parse()

	slogHandler := newSlogHandler(arguments.LogLevel)
	slog.SetDefault(slog.New(slogHandler))

	ctx := context.Background()
	var err error
	switch cmd := strings.ToLower(flag.Arg(0)); cmd {
	case "fetch-generate", "fg":
		err = internal.FetchReleaseGenerateFormulae(ctx, arguments.TemplateDir, arguments.Outdir, arguments.ReleaseTag)
	case "fetch-release", "fetch", "f":
		var releaseTag *string
		if t := arguments.ReleaseTag; t != "" {
			releaseTag = &t
		}
		err = fetchRelease(ctx, os.Stdout, releaseTag)
	case "generate-formulae", "generate-formula", "generate", "gen", "g":
		err = generateFormulae(arguments.TemplateDir, os.Stdin, arguments.Outdir)
	default:
		slog.Debug("received cmd", slog.String("cmd", cmd), slog.Any("args", flag.Args()))
		flag.Usage()
		return
	}
	if err != nil {
		slog.ErrorContext(ctx, "running command", slog.Any("error", err))
		os.Exit(1)
	}
}

func newSlogHandler(requestedLevel string) slog.Handler {
	var lvl slog.Level
	switch strings.TrimSpace(strings.ToUpper(requestedLevel)) {
	case slog.LevelDebug.String():
		lvl = slog.LevelDebug
	case slog.LevelInfo.String():
		lvl = slog.LevelInfo
	case slog.LevelWarn.String():
		lvl = slog.LevelWarn
	case slog.LevelError.String():
		lvl = slog.LevelError
	}
	return slog.NewJSONHandler(os.Stderr, &slog.HandlerOptions{Level: lvl})
}

func fetchRelease(ctx context.Context, w io.Writer, releaseTag *string) error {
	got, err := internal.FetchGithubRelease(ctx, releaseTag)
	if err != nil {
		return err
	}

	if err = json.NewEncoder(w).Encode(got); err != nil {
		return fmt.Errorf("encoding fetched JSON release: %w", err)
	}
	return nil
}

func generateFormulae(templateDir string, r io.Reader, outputDir string) error {
	var releaseData internal.GithubRelease
	if err := json.NewDecoder(r).Decode(&releaseData); err != nil {
		return fmt.Errorf("decoding JSON release data: %w", err)
	}
	return internal.MakeFormulaeFiles(templateDir, outputDir, &releaseData)
}
