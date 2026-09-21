package voiceink

// Run from the repository root:
//   go test -v packages/voiceink/voiceink-update_test.go
// Requires nu on PATH. All external commands used by these tests are mocked;
// no app is built, signed, installed, or given/reset permissions.

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

type response struct {
	Out  string
	Err  string
	Code int
}

type fixture struct {
	Responses map[string][]response
	Log       string
}

// The test binary doubles as a strict external-tool stub. Unknown invocations
// fail rather than escaping to a real download, codesign, keychain, or TCC tool.
func TestMain(m *testing.M) {
	if p := os.Getenv("VOICEINK_MOCK_CONFIG"); p != "" {
		var f fixture
		b, err := os.ReadFile(p)
		if err != nil {
			panic(err)
		}
		if err := json.Unmarshal(b, &f); err != nil {
			panic(err)
		}
		key := strings.Join(append([]string{filepath.Base(os.Args[0])}, os.Args[1:]...), "\t")
		prior, _ := os.ReadFile(f.Log)
		n := 0
		for _, line := range strings.Split(string(prior), "\n") {
			if line == key {
				n++
			}
		}
		log, err := os.OpenFile(f.Log, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0600)
		if err != nil {
			panic(err)
		}
		fmt.Fprintln(log, key)
		log.Close()
		rows := f.Responses[key]
		if n >= len(rows) {
			fmt.Fprintln(os.Stderr, "Unexpected invocation:", key)
			os.Exit(97)
		}
		r := rows[n]
		fmt.Fprint(os.Stdout, r.Out)
		fmt.Fprint(os.Stderr, r.Err)
		os.Exit(r.Code)
	}
	os.Exit(m.Run())
}

type harness struct {
	t         *testing.T
	dir       string
	source    string
	responses map[string][]response
}

func newHarness(t *testing.T) *harness {
	t.Helper()
	if _, err := exec.LookPath("nu"); err != nil {
		t.Fatal("nu is required; tests must not silently skip")
	}
	dir, err := filepath.EvalSymlinks(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	self, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}
	for _, tool := range []string{"codesign", "security", "xcrun", "xcodebuild", "xcode-select", "tccutil", "make", "defaults", "osascript", "open", "git", "xattr"} {
		if err := os.Symlink(self, filepath.Join(dir, tool)); err != nil {
			t.Fatal(err)
		}
	}
	// go test sets cwd to this file's directory, including single-file runs.
	source, err := filepath.Abs("voiceink-update.nu")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(source); err != nil {
		t.Fatal(err)
	}
	return &harness{t: t, dir: dir, source: source, responses: map[string][]response{}}
}

func key(tool string, args ...string) string {
	return strings.Join(append([]string{tool}, args...), "\t")
}

func (h *harness) run(body string, wantError string) string {
	h.t.Helper()
	log := filepath.Join(h.dir, "calls")
	config, _ := json.Marshal(fixture{h.responses, log})
	p := filepath.Join(h.dir, "fixture.json")
	if err := os.WriteFile(p, config, 0600); err != nil {
		h.t.Fatal(err)
	}
	// --commands sources the real updater's definitions without invoking main.
	// NIX_BIN_PATHS is normally supplied by default.nix.
	program := fmt.Sprintf("const NIX_BIN_PATHS = []; source '%s'; %s", h.source, body)
	cmd := exec.Command("nu", "--no-config-file", "--commands", program)
	cmd.Env = append(os.Environ(), "PATH="+h.dir, "VOICEINK_MOCK_CONFIG="+p)
	out, err := cmd.CombinedOutput()
	if wantError == "" && err != nil {
		h.t.Fatalf("nu failed: %v\n%s", err, out)
	}
	if wantError != "" && (err == nil || !strings.Contains(string(out), wantError)) {
		h.t.Fatalf("wanted failure containing %q; err=%v\n%s", wantError, err, out)
	}
	calls, _ := os.ReadFile(log)
	// Ensure that every configured invocation really happened, in addition to
	// the helper's unexpected-call check. A no-op implementation must fail.
	for k, rows := range h.responses {
		got := 0
		for _, call := range strings.Split(string(calls), "\n") {
			if call == k {
				got++
			}
		}
		if got != len(rows) {
			h.t.Errorf("%q: got %d calls, want %d", k, got, len(rows))
		}
	}
	for _, call := range strings.Split(strings.TrimSpace(string(calls)), "\n") {
		if call != "" {
			if _, ok := h.responses[call]; !ok {
				h.t.Errorf("unexpected external call: %q", call)
			}
		}
	}
	return string(out)
}

func TestMetalProbe(t *testing.T) {
	failed := response{Err: "cannot execute tool 'metal' due to missing Metal Toolchain", Code: 1}
	for _, tc := range []struct {
		name     string
		probes   []response
		download *response
		wantErr  string
	}{
		{"working compiler skips download", []response{{Out: "Apple metal version test"}}, nil, ""},
		{"shim found but cannot execute downloads and reprobes", []response{failed, {Out: "Apple metal version test"}}, &response{}, ""},
		{"download fails", []response{failed}, &response{Code: 1}, "Could not download"},
		{"successful download but compiler still fails", []response{failed, failed}, &response{}, "Metal still cannot run"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			h := newHarness(t)
			h.responses[key("xcrun", "metal", "--version")] = tc.probes
			// --find is intentionally NOT a permitted invocation. Returning a
			// tool path would not prove its backing compiler can execute.
			if tc.download != nil {
				h.responses[key("xcodebuild", "-downloadComponent", "MetalToolchain")] = []response{*tc.download}
			}
			h.run("ensure-metal-toolchain", tc.wantErr)
		})
	}
}

const bundleID = "com.prakashjoshipax.VoiceInk"

func pinned(cert string) string {
	return `identifier "` + bundleID + `" and certificate leaf = H"` + strings.Repeat(cert, 40) + `"`
}

func signature(hash, requirement, authority string) string {
	return "Identifier=" + bundleID + "\nCDHash=" + strings.Repeat(hash, 40) + "\n" + authority + "\ndesignated => " + requirement + "\n"
}

func (h *harness) app(name, output string, verifyCode, displayCode int) string {
	h.t.Helper()
	path := filepath.Join(h.dir, name+".app")
	if err := os.Mkdir(path, 0700); err != nil {
		h.t.Fatal(err)
	}
	h.responses[key("codesign", "--verify", "--strict", path)] = []response{{Code: verifyCode}}
	if verifyCode == 0 {
		h.responses[key("codesign", "-dvvv", "-r-", path)] = []response{{Err: output, Code: displayCode}}
	}
	return path
}

func TestPermissionPlanAndEffects(t *testing.T) {
	stable := signature("a", pinned("1"), "Authority=VoiceInk Local")
	rebuilt := signature("b", pinned("1"), "Authority=VoiceInk Local")
	changedCert := signature("b", pinned("2"), "Authority=VoiceInk Local")
	adhocA := signature("a", `cdhash H"`+strings.Repeat("a", 40)+`"`, "Signature=adhoc")
	adhocB := signature("b", `cdhash H"`+strings.Repeat("b", 40)+`"`, "Signature=adhoc")
	for _, tc := range []struct {
		name, previous, current   string
		keep, reset, instructions bool
	}{
		{"same certificate changed binary", stable, rebuilt, false, false, false},
		{"same binary and signature", stable, stable, false, false, false},
		{"different certificate same name", stable, changedCert, false, true, true},
		{"changed adhoc signature", adhocA, adhocB, false, true, true},
		{"unchanged adhoc signature", adhocA, adhocA, false, false, false},
		{"adhoc to certificate", adhocA, rebuilt, false, true, true},
		{"certificate to adhoc", stable, adhocB, false, true, true},
		{"first install", "", rebuilt, false, false, true},
		{"explicit override", stable, changedCert, true, false, false},
		{"broad custom requirement is not a pin", stable, signature("b", pinned("1")+" or always", "Authority=VoiceInk Local"), false, true, true},
		{"adhoc metadata cannot claim certificate identity", stable, signature("b", pinned("1"), "Signature=adhoc"), false, true, true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			h := newHarness(t)
			prev := "null"
			if tc.previous != "" {
				prev = fmt.Sprintf("(signature-of '%s')", h.app("previous", tc.previous, 0, 0))
			}
			current := h.app("current", tc.current, 0, 0)
			if tc.reset {
				for _, service := range []string{"Accessibility", "ScreenCapture"} {
					h.responses[key("tccutil", "reset", service, bundleID)] = []response{{}}
				}
			}
			out := h.run(fmt.Sprintf("let plan = (permission-plan %s (signature-of '%s')); apply-permission-plan $plan %t", prev, current, tc.keep), "")
			if strings.Contains(out, "ACTION REQUIRED") != tc.instructions {
				t.Fatalf("incorrect re-grant instructions:\n%s", out)
			}
			if strings.Contains(out, "new ad-hoc signature") {
				t.Fatal("stale ad-hoc claim in output")
			}
		})
	}
}

func TestFailedInspectionStopsBeforePermissionAction(t *testing.T) {
	good := signature("a", pinned("1"), "Authority=VoiceInk Local")
	for _, tc := range []struct {
		name, output, wantErr   string
		verifyCode, displayCode int
	}{
		{"verification failure", good, "Cannot verify signature", 1, 0},
		{"display failure despite plausible output", good, "Cannot inspect signature", 0, 1},
		{"empty output is not a matching empty hash", "", "Incomplete signature", 0, 0},
		{"missing requirement", "Identifier=" + bundleID + "\nCDHash=" + strings.Repeat("a", 40), "Incomplete signature", 0, 0},
		{"wrong bundle", strings.Replace(good, "Identifier="+bundleID, "Identifier=other.app", 1), "Unexpected bundle identifier", 0, 0},
	} {
		for _, failingSide := range []string{"previous", "current"} {
			t.Run(tc.name+"/"+failingSide, func(t *testing.T) {
				h := newHarness(t)
				bad := h.app("invalid", tc.output, tc.verifyCode, tc.displayCode)
				// Only one side needs inspection to fail; no TCC invocation is
				// permitted, including when a caller requests --keep-permissions.
				previous, current := "$known", "$known"
				if failingSide == "previous" {
					previous = fmt.Sprintf("(signature-of '%s')", bad)
				} else {
					current = fmt.Sprintf("(signature-of '%s')", bad)
				}
				body := fmt.Sprintf("let known = {cdhash: 'a', requirement: 'known', certificate_bound: true}; let plan = (permission-plan %s %s); apply-permission-plan $plan true", previous, current)
				h.run(body, tc.wantErr)
			})
		}
	}
}

func TestMissingBuiltApp(t *testing.T) {
	h := newHarness(t)
	h.run("permission-plan null null", "Built app is missing")
}

func TestMainPermissionWiring(t *testing.T) {
	for _, tc := range []struct {
		name        string
		changedCert bool
		failedSide  string
		keep        bool
	}{
		{name: "stable certificate installs without resetting"},
		{name: "changed certificate resets", changedCert: true},
		{name: "keep permissions overrides transition", changedCert: true, keep: true},
		{name: "invalid previous aborts before install", failedSide: "previous"},
		{name: "invalid build aborts before install", failedSide: "current"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			h := newHarness(t)
			cert := "1"
			if tc.changedCert {
				cert = "2"
			}
			prevCode, curCode := 0, 0
			if tc.failedSide == "previous" {
				prevCode = 1
			}
			if tc.failedSide == "current" {
				curCode = 1
			}
			previous := h.app("previous", signature("a", pinned("1"), "Authority=VoiceInk Local"), prevCode, 0)
			current := filepath.Join(h.dir, "current.app")
			if tc.failedSide == "previous" {
				// Evaluation stops before inspecting the new app.
				if err := os.Mkdir(current, 0700); err != nil {
					t.Fatal(err)
				}
			} else {
				current = h.app("current", signature("b", pinned(cert), "Authority=VoiceInk Local"), curCode, 0)
			}
			if err := os.WriteFile(filepath.Join(previous, "marker"), []byte("old"), 0600); err != nil {
				t.Fatal(err)
			}
			if err := os.WriteFile(filepath.Join(current, "marker"), []byte("new"), 0600); err != nil {
				t.Fatal(err)
			}
			xcode := filepath.Join(h.dir, "Xcode.app")
			if err := os.Mkdir(xcode, 0700); err != nil {
				t.Fatal(err)
			}

			b, err := os.ReadFile(h.source)
			if err != nil {
				t.Fatal(err)
			}
			source := string(b)
			// Run the real main control flow, relocating only installation/build/Xcode
			// paths to fixtures and making app liveness deterministic. Every external
			// tool remains a strict mock. Nu's filesystem operations touch only TempDir.
			replacements := map[string]string{
				`const APP_PATH = "/Applications/VoiceInk.app"`: "const APP_PATH = '" + previous + "'",
				`"~/Downloads/VoiceInk.app"`:                    "'" + current + "'",
				`(ps | where name =~ "VoiceInk" | length) > 0`:  "false",
				`$"/tmp/voiceink-`:                              `$"` + h.dir + "/voiceink-",
			}
			for before, after := range replacements {
				if strings.Count(source, before) != 1 {
					t.Fatalf("fixture rewrite no longer matches exactly once: %s", before)
				}
				source = strings.Replace(source, before, after, 1)
			}
			source = strings.ReplaceAll(source, "/Applications/Xcode.app", xcode)
			h.source = filepath.Join(h.dir, "updater.nu")
			if err := os.WriteFile(h.source, []byte(source), 0600); err != nil {
				t.Fatal(err)
			}
			h.responses[key("xcode-select", "-p")] = []response{{Out: xcode + "/Contents/Developer\n"}}
			h.responses[key("xcodebuild", "-runFirstLaunch")] = []response{{}}
			h.responses[key("xcrun", "metal", "--version")] = []response{{Out: "Apple metal version test"}}
			for _, setting := range []string{"IDESkipPackagePluginFingerprintValidatation", "IDESkipMacroFingerprintValidation"} {
				h.responses[key("defaults", "write", "com.apple.dt.Xcode", setting, "-bool", "YES")] = []response{{}}
			}
			h.responses[key("git", "status", "--porcelain")] = []response{{}}
			h.responses[key("git", "pull")] = []response{{}}
			h.responses[key("git", "describe", "--tags", "--always")] = []response{{Out: "test-version\n"}}
			// Deliberately no discoverable identity: actual artifact identity, not
			// the builder's keychain selection, must determine the reset decision.
			h.responses[key("security", "find-identity", "-v", "-p", "codesigning")] = []response{{}}
			h.responses[key("make", "local")] = []response{{}}
			wantErr := ""
			if tc.failedSide != "" {
				wantErr = "Cannot verify signature"
			} else {
				h.responses[key("xattr", "-cr", previous)] = []response{{}}
				if tc.changedCert && !tc.keep {
					for _, service := range []string{"Accessibility", "ScreenCapture"} {
						h.responses[key("tccutil", "reset", service, bundleID)] = []response{{}}
					}
				}
			}
			keep := ""
			if tc.keep {
				keep = " --keep-permissions"
			}
			out := h.run("main --repo '"+h.dir+"'"+keep, wantErr)
			marker, err := os.ReadFile(filepath.Join(previous, "marker"))
			if err != nil {
				t.Fatal(err)
			}
			wantMarker := "new"
			if tc.failedSide != "" {
				wantMarker = "old"
			}
			if string(marker) != wantMarker {
				t.Fatalf("installed marker=%q want=%q", marker, wantMarker)
			}
			_, err = os.Stat(current)
			if (err == nil) != (tc.failedSide != "") {
				t.Fatalf("built artifact survival inconsistent with install: %v", err)
			}
			if strings.Contains(out, "ACTION REQUIRED") != (tc.changedCert && !tc.keep && tc.failedSide == "") {
				t.Fatalf("incorrect main permission instructions:\n%s", out)
			}
		})
	}
}
