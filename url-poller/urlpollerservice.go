package main

import (
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"

	"github.com/wailsapp/wails/v3/pkg/application"
)

// State represents state
type State int

const (
	// IdleState is idle
	IdleState State = iota
	// PollingState is polling
	PollingState
)

// URLPollerService manages URL polling
type URLPollerService struct {
	app         *application.App
	mu          sync.Mutex
	pollResults []PollResult
	state       State
	stopChan    chan struct{}
}

// PollResult represents a single poll result
type PollResult struct {
	Timestamp   string `json:"timestamp"`
	StatusCode  int    `json:"statusCode"`
	Success     bool   `json:"success"`
	Error       string `json:"error"`
	BodyPreview string `json:"bodyPreview"`
}

// NewURLPollerService creates a new service
func NewURLPollerService(app *application.App) *URLPollerService {
	service := URLPollerService{}
	service.app = app
	service.state = IdleState
	service.pollResults = make([]PollResult, 0)

	return &service
}

// StartPolling starts polling a URL at the specified duration
func (s *URLPollerService) StartPolling(
	url string,
	durationSeconds int,
) string {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.state == PollingState {
		return "Already polling. Stop current poll first."
	}

	if durationSeconds <= 0 {
		return "Duration must be greater than 0"
	}

	s.state = PollingState
	s.stopChan = make(chan struct{})
	s.pollResults = make([]PollResult, 0)

	go s.pollURL(url, time.Duration(durationSeconds)*time.Second)

	return fmt.Sprintf(
		"Started polling %s every %d seconds",
		url,
		durationSeconds,
	)
}

// StopPolling stops the current polling operation
func (s *URLPollerService) StopPolling() string {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.state == IdleState {
		return "Not currently polling"
	}

	close(s.stopChan)
	s.state = IdleState

	return "Polling stopped"
}

// GetResults returns all poll results
func (s *URLPollerService) GetResults() []PollResult {
	s.mu.Lock()
	defer s.mu.Unlock()

	return s.pollResults
}

// State returns whether polling is currently active
func (s *URLPollerService) State() State {
	s.mu.Lock()
	defer s.mu.Unlock()

	return s.state
}

// pollURL performs the actual polling in a goroutine
func (s *URLPollerService) pollURL(url string, duration time.Duration) {
	ticker := time.NewTicker(duration)
	defer ticker.Stop()

	// Poll immediately on start
	s.performPoll(url)

	for {
		select {
		case <-ticker.C:
			s.performPoll(url)
		case <-s.stopChan:
			return
		}
	}
}

// performPoll performs a single poll operation
func (s *URLPollerService) performPoll(url string) {
	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	resp, err := client.Get(url)

	result := PollResult{
		Timestamp: time.Now().Format(time.RFC3339),
	}

	if err != nil {
		result.Success = false
		result.Error = err.Error()
		result.StatusCode = 0
	} else {
		defer resp.Body.Close()
		result.Success = resp.StatusCode >= 200 && resp.StatusCode < 300
		result.StatusCode = resp.StatusCode

		// Read a preview of the body (first 200 chars)
		body, err := io.ReadAll(io.LimitReader(resp.Body, 200))
		if err != nil {
			result.BodyPreview = ""
		} else {
			result.BodyPreview = string(body)
		}
	}

	s.mu.Lock()
	s.pollResults = append(s.pollResults, result)
	s.mu.Unlock()

	// Emit event to frontend
	if s.app != nil {
		s.app.Event.Emit("pollResult", result)
	}
}
