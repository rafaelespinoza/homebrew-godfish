package main

import (
	"context"
	"flag"
	"fmt"
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
		fmt.Fprintf(flag.CommandLine.Output(), `Usage: %s [options]

Description:
  Generate homebrew formula files for this tap.
  By default, it looks for the latest release and writes the generated Homebrew
  files to %s.

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
	err := internal.GenerateFormulae(ctx, arguments.TemplateDir, arguments.Outdir, arguments.ReleaseTag)
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
