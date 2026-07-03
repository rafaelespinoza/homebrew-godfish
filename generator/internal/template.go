package internal

import (
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

func makeFormulaeFiles(templateDir, outdir string, releaseData *githubRelease) error {
	root, err := os.OpenRoot(templateDir)
	if err != nil {
		return fmt.Errorf("opening root: %w", err)
	}
	defer func() {
		if cerr := root.Close(); cerr != nil {
			slog.Error("closing root", slog.Any("error", cerr))
		}
	}()

	funcs := template.FuncMap{
		"bin_name": func(driverName string) string { return "godfish_" + driverName },
	}
	tmpl, err := template.New("root").Funcs(funcs).ParseFS(root.FS(), "*.tmpl.rb")
	if err != nil {
		return fmt.Errorf("parsing driver template fs: %w", err)
	}

	formulae := []templateFormula{
		{ClassName: "GodfishCassandra", Drivers: []string{"cassandra"}},
		{ClassName: "GodfishPostgres", Drivers: []string{"postgres"}},
		{ClassName: "GodfishMysql", Drivers: []string{"mysql"}},
		{ClassName: "GodfishSqlite3", Drivers: []string{"sqlite3"}},
		{ClassName: "GodfishSqlserver", Drivers: []string{"sqlserver"}},
		{ClassName: "Godfish", Drivers: []string{"cassandra", "postgres", "mysql", "sqlite3", "sqlserver"}},
	}

	if err := os.MkdirAll(filepath.Clean(outdir), 0700); err != nil {
		return fmt.Errorf("making outdir: %w", err)
	}
	releaseAssets, err := templatizeReleaseAssets(releaseData.Assets)
	if err != nil {
		return fmt.Errorf("templatizing release assets: %w", err)
	}

	for _, formula := range formulae {
		formula.Version = releaseData.TagName
		formula.ReleaseAssets = *releaseAssets

		var outfileBasename string
		if len(formula.Drivers) == 1 {
			outfileBasename = "godfish_" + formula.Drivers[0] + ".rb"
		} else {
			outfileBasename = "godfish.rb"
		}
		outfile := filepath.Join(outdir, outfileBasename)

		if err = generateFormulaFile(outfile, tmpl, formula); err != nil {
			return fmt.Errorf("generating file (%q): %w", outfileBasename, err)
		}
	}

	return nil
}

func generateFormulaFile(outfile string, tmpl *template.Template, formula templateFormula) error {
	file, err := os.Create(outfile)
	if err != nil {
		return fmt.Errorf("creating file prior to generation: %w", err)
	}
	defer file.Close()

	return tmpl.ExecuteTemplate(file, "formula", formula)
}

type templateFormula struct {
	ClassName     string
	Drivers       []string
	Version       string
	ReleaseAssets templateReleaseAssets
}

type templateReleaseAssets struct {
	MacOSIntel tmplReleaseOnPlatform
	MacOSARM   tmplReleaseOnPlatform
	LinuxIntel tmplReleaseOnPlatform
	LinuxARM   tmplReleaseOnPlatform
	WSLIntel   tmplReleaseOnPlatform
	WSLARM     tmplReleaseOnPlatform
}

func templatizeReleaseAssets(in []githubReleaseAsset) (*templateReleaseAssets, error) {
	var out templateReleaseAssets
	const darwin, linux, windows = "darwin", "linux", "windows"
	const amd64, arm64 = "amd64", "arm64"

	for _, gra := range in {
		sha256, _ := strings.CutPrefix(*gra.Digest, "sha256:")

		if strings.Contains(gra.Name, darwin) {
			if strings.Contains(gra.Name, amd64) {
				out.MacOSIntel = tmplReleaseOnPlatform{URL: gra.BrowserDownloadURL, SHA256: sha256}
			} else if strings.Contains(gra.Name, arm64) {
				out.MacOSARM = tmplReleaseOnPlatform{URL: gra.BrowserDownloadURL, SHA256: sha256}
			} else {
				err := fmt.Errorf("asset name %q did not contain an expected architecture %q", gra.Name, []string{amd64, arm64})
				return nil, err
			}
		} else if strings.Contains(gra.Name, linux) {
			if strings.Contains(gra.Name, amd64) {
				out.LinuxIntel = tmplReleaseOnPlatform{URL: gra.BrowserDownloadURL, SHA256: sha256}
			} else if strings.Contains(gra.Name, arm64) {
				out.LinuxARM = tmplReleaseOnPlatform{URL: gra.BrowserDownloadURL, SHA256: sha256}
			} else {
				err := fmt.Errorf("asset name %q did not contain an expected architecture %q", gra.Name, []string{amd64, arm64})
				return nil, err
			}
		} else if strings.Contains(gra.Name, windows) {
			if strings.Contains(gra.Name, amd64) {
				out.WSLIntel = tmplReleaseOnPlatform{URL: gra.BrowserDownloadURL, SHA256: sha256}
			} else if strings.Contains(gra.Name, arm64) {
				out.WSLARM = tmplReleaseOnPlatform{URL: gra.BrowserDownloadURL, SHA256: sha256}
			} else {
				err := fmt.Errorf("asset name %q did not contain an expected architecture %q", gra.Name, []string{amd64, arm64})
				return nil, err
			}
		} else {
			// Most likely, this is the checksums file. Brew will check these.
			slog.Debug("ignoring asset while templatizing release assets", slog.String("name", gra.Name))
		}
	}

	return &out, nil
}

type tmplReleaseOnPlatform struct {
	URL    string
	SHA256 string

	platform string
	hostArch string
}
