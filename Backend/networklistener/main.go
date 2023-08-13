package main

import (
	"fmt"
)

func listenNetwork(listener NetworkListener) {
	listener.listenNetwork()
}

func main() {
	var networks = [2]NetworkListener{
		{"INCLUDES KEY",
			"0x186d0C9eB1c1f4F837059DD8622f174914548FE1",
			"INCLUDES KEY",
			"0x876DD35DF84213db30d3E35260D6EefdbAE039FD",
		},
		{
			"INCLUDES KEY",
			"0x2dbe1e478BC6f543fd9731f58287100e83185507",
			"INCLUDES KEY",
			"0x876DD35DF84213db30d3E35260D6EefdbAE039FD",
		},
	}

	numJobs := len(networks)
	jobs := make(chan int, numJobs)
	results := make(chan int, numJobs)

	for i := 0; i < len(networks); i++ {
		go listenNetwork(networks[i])
	}

	// Send jobs to the workers
	for i := 1; i <= numJobs; i++ {
		jobs <- i
	}
	close(jobs)

	// Collect the results
	for i := 1; i <= numJobs; i++ {
		result := <-results
		fmt.Println("Received result:", result)
	}
}
