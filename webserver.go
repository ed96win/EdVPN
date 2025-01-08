package main

import (
	"fmt"
	"net/http"
)

func main() {
	// Specify the directory to serve files from
	dir := "/var/www/html"

	// Handle requests for the root URL by serving files from the specified directory
	http.Handle("/", http.FileServer(http.Dir(dir)))

	// Start the server on port 8080
	port := ":8080"
	fmt.Printf("Starting server on http://localhost%s...\n", port)
	err := http.ListenAndServe(port, nil)
	if err != nil {
		fmt.Println("Error starting server:", err)
	}
}
