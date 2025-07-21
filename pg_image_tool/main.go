package main

import (
	"fmt"
	"os"

	"pgimagetool/commands/buildext"
	"pgimagetool/commands/generate"
	"pgimagetool/commands/installrtdeps"
	"pgimagetool/commands/listext"
	"pgimagetool/commands/newext"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("No command specified.")
		fmt.Println("Available commands:")
		fmt.Println("  buildext              - run build scripts")
		fmt.Println("  listext               - list available build scripts")
		fmt.Println("  install_runtime_deps  - install runtime dependencies")
		fmt.Println("  new                   - interactive creation of new extension description files")
		fmt.Println("  gen_create_extension  - generate create extension clauses")
		fmt.Println("  gen_shared_preload    - generate shared preload libraries")
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
	case "install_runtime_deps":
		ie := &installrtdeps.InstallRuntimeDeps{}
		if err := ie.Run(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	case "new":
		ne := &newext.NewExtCommand{}
		if err := ne.Run(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	case "gen_create_extension":
		ge := &generate.GenerateCreateExtensionCommand{}
		if err := ge.Run(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	case "gen_shared_preload":
		ge := &generate.GenerateSharedPreloadLibrariesCommand{}
		if err := ge.Run(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	default:
		fmt.Println("unknown command:", os.Args[1])
		os.Exit(1)
	}

}
