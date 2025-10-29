package main

// GreetService is a service for greeting
type GreetService struct{}

// Greet accepts a name and creates a greeting
func (g *GreetService) Greet(name string) string {
	return "Hello " + name + "!"
}
