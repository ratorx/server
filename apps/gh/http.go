package main

import (
	"context"
	"net/http"

	"golang.org/x/time/rate"
)

type httpError struct {
	StatusCode int
	Error error
}

func internalError(err error) *httpError {
	return &httpError{StatusCode: http.StatusInternalServerError, Error: err}
}

func badRequest(err error) *httpError {
	return &httpError{StatusCode: http.StatusBadRequest, Error: err}
}

func (h httpError) respond(res http.ResponseWriter) {
	http.Error(res, h.Error.Error(), h.StatusCode)
}

type httpClient struct {
	client *http.Client
	Limiter *rate.Limiter
}

func (h *httpClient) Get(ctx context.Context, url string) (*http.Response, error) {
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}

	err = h.Limiter.Wait(ctx)
	if err != nil {
		return nil, err
	}

	return h.client.Do(req)
}

func newClient(limiter *rate.Limiter) *httpClient {
	return &httpClient{client: &http.Client{}, Limiter: limiter}
}

type httpStatusRecorder struct {
	http.ResponseWriter
	Status int
}

func (r *httpStatusRecorder) WriteHeader(status int) {
	r.Status = status
	r.ResponseWriter.WriteHeader(status)
}