package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	var (
		envVar   string
		filePath string
	)
	flag.StringVar(&envVar, "root-env-var", "",
		"Set root page to the content of the environment variable")
	flag.StringVar(&filePath, "root-file", "",
		"Set root page to the content of file")
	flag.Parse()

	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal("Error (query hostname): ", err)
		os.Exit(1)
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Println("Received request for URL:", r.URL)
		if os.Getenv(envVar) != "" {
			fmt.Fprintf(w, "path exists: %s=%s", envVar, os.Getenv(envVar))
		} else if _, err := os.Stat(filePath); err == nil {
			data, err := os.ReadFile(filePath)
			if err != nil {
				fmt.Fprintf(w, "failed reading data from file: %s", err)
			}
			fmt.Fprintf(w, "\n%s", data)
		} else {
			fmt.Fprintf(w, "Hello World from %s!", hostname)
		}
	})
	err = http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("Error (http server): ", err)
	}

}
