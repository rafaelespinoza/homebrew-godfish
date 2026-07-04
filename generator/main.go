package main

import (
	"context"
	"embed"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"io/fs"
	"log/slog"
	"os"
	"path/filepath"
	"strings"

	"github.com/rafaelespinoza/homebrew-godfish/internal"
)

// parameters are the input flags to this command.
type parameters struct {
	Outdir     string
	ReleaseTag *string
	LogLevel   string
}

var arguments parameters

func init() {
	const defaultOutdir = "Formula/"

	flag.StringVar(&arguments.Outdir, "outdir", filepath.Clean(defaultOutdir), "output directory to place generated formula files")
	arguments.ReleaseTag = flag.String("tag", "", "which release tag to source from; if empty, latest is assumed")
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
	if t := arguments.ReleaseTag; t != nil && *t == "" {
		arguments.ReleaseTag = nil
	}

	slogHandler := newSlogHandler(arguments.LogLevel)
	slog.SetDefault(slog.New(slogHandler))

	err := chooseRunSubcmd(context.Background(), flag.CommandLine, arguments, os.Stdin, os.Stdout)
	if err != nil {
		slog.Error("running command", slog.Any("error", err))
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

func chooseRunSubcmd(ctx context.Context, f *flag.FlagSet, p parameters, r io.Reader, w io.Writer) error {
	subcmd := strings.ToLower(f.Arg(0))
	slog.DebugContext(ctx, "from chooseRunSubcmd",
		slog.String("subcmd", subcmd),
		slog.Any("p", p),
		slog.Any("flag_args", f.Args()),
	)
	switch subcmd {
	case "fetch-generate", "fg":
		subFS, err := loadTemplatesSubdir()
		if err != nil {
			return err
		}
		return internal.FetchReleaseGenerateFormulae(ctx, p.ReleaseTag, subFS, p.Outdir)
	case "fetch-release", "fetch", "f":
		return fetchRelease(ctx, w, p.ReleaseTag)
	case "generate-formulae", "generate-formula", "generate", "gen", "g":
		subFS, err := loadTemplatesSubdir()
		if err != nil {
			return err
		}
		return generateFormulae(r, subFS, p.Outdir)
	default:
		f.Usage()
		return nil
	}
}

//go:embed templates/*.tmpl
var templateDirFS embed.FS

func loadTemplatesSubdir() (fs.FS, error) {
	subFS, err := fs.Sub(templateDirFS, "templates")
	if err != nil {
		return nil, fmt.Errorf("loading fs subdir: %w", err)
	}
	return subFS, nil
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

func generateFormulae(r io.Reader, templateDirFS fs.FS, outputDir string) error {
	var releaseData internal.GithubRelease
	if err := json.NewDecoder(r).Decode(&releaseData); err != nil {
		return fmt.Errorf("decoding JSON release data: %w", err)
	}
	return internal.MakeFormulaeFiles(templateDirFS, outputDir, &releaseData)
}
