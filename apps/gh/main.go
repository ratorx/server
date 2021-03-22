package main

import (
	"fmt"
	"log"
	"net/http"
	"regexp"
	"time"
)

var requestURLRegexp = regexp.MustCompile("^.*/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)/([^/]+)$")
var requestTimeout = 5 * time.Second

func parseRequestURL(url string) (releaseLookup, error) {
	matches := requestURLRegexp.FindStringSubmatch(url)
	if len(matches) != 4 {
		return releaseLookup{}, fmt.Errorf("invalid request url")
	}

	return releaseLookup{matches[1], matches[2], matches[3]}, nil
}

func defaultHandler(res http.ResponseWriter, req *http.Request) {
	if req.Method != "GET" {
		badRequest(fmt.Errorf("request method should be GET"))
		return
	}

	rl, err := parseRequestURL(req.URL.Path)
	if err != nil {
		badRequest(fmt.Errorf("invalid request URL")).respond(res)
		return
	}

	a, hErr := lookupLatestRelease(req.Context(), rl)
	if hErr != nil {
		hErr.respond(res)
		return
	}
	
	res.Header().Set("Content-Type", a.ContentType)
	http.Redirect(res, req, a.URL, http.StatusTemporaryRedirect)
}

func logRequests(h http.Handler) http.Handler {
	return http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
		requestor := req.Header.Get("X-Forwarded-For")
		if requestor == "" {
			requestor = req.RemoteAddr
		}
		
		statusReporter := &httpStatusRecorder{ResponseWriter: res}
		h.ServeHTTP(statusReporter, req)

		log.Printf("%s %s %v %s %q", req.Method, req.URL.Path, statusReporter.Status, requestor, req.Header.Get("User-Agent"))
	})
}

func main() {
	log.SetFlags(0)
	srv := &http.Server{
		Addr: ":8080",
		ReadTimeout:       1 * time.Second,
		WriteTimeout:      requestTimeout + time.Second,
		Handler: logRequests(http.TimeoutHandler(http.HandlerFunc(defaultHandler), requestTimeout, "")),
	}
	log.Fatal(srv.ListenAndServe())
}