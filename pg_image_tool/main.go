package main

import (
	"fmt"
	"os"

	"pgimagetool/commands/buildext"
	"pgimagetool/commands/listext"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("No command specified.")
		fmt.Println("Available commands:")
		fmt.Println("  buildext - run build scripts")
		fmt.Println("  listext  - list available build scripts")
		os.Exit(0)
	}
	fmt.Println("run pgimagetool command:", os.Args[1])

	switch os.Args[1] {
	case "buildext":
		be := &buildext.BuildExt{
			PgConfig: os.Args[2],
		}
		if err := be.Run(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	case "listext":
		le := &listext.ListExtCommand{}
		if err := le.Run(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	default:
		fmt.Println("unknown command:", os.Args[1])
		os.Exit(1)
	}

}
