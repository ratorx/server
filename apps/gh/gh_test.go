package main

import (
	"context"
	"strings"
	"testing"
)

func TestLookupLatestRelease(t *testing.T) {
	s, err := lookupLatestRelease(context.Background(), releaseLookup{"ratorx", "sshca", "sshca.linux.amd64"})
	if err != nil {
		t.Fatalf("err should be nil: %s", err.Error)
	}

	if !strings.Contains(s.URL, "github.com/ratorx/sshca") {
		t.Errorf("URL does not contain github.com/ratorx/sshca (url is %s)", s.URL)
	}
}