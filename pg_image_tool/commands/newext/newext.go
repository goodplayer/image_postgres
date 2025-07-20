package newext

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"pgimagetool/commands/common"
)

type NewExtCommand struct {
}

func (n *NewExtCommand) Run() error {
	fmt.Println("Create a new extension description files including .desc.json and .sh files")

	ext := new(common.BuildDescFile)
	// read extension name
	for {
		fmt.Println("Extension Name:")
		_, err := fmt.Scanln(&ext.Main.Name)
		if err != nil {
			return err
		}
		ext.Main.Name = strings.TrimSpace(ext.Main.Name)
		if len(ext.Main.Name) == 0 {
			fmt.Println("Extension name should not be empty.")
		}
		break
	}
	// read extension category
	for {
		fmt.Println("Extension category:")
		_, err := fmt.Scanln(&ext.Main.Category)
		if err != nil {
			return err
		}
		ext.Main.Category = strings.TrimSpace(ext.Main.Category)
		if len(ext.Main.Category) == 0 {
			fmt.Println("Extension Category should not be empty.")
		}
		break
	}
	// read extension version
	for {
		fmt.Println("Extension version:")
		_, err := fmt.Scanln(&ext.Main.Version)
		if err != nil {
			return err
		}
		ext.Main.Version = strings.TrimSpace(ext.Main.Version)
		if len(ext.Main.Version) == 0 {
			fmt.Println("Extension version should not be empty.")
		}
		break
	}
	// read extension website
	for {
		fmt.Println("Extension websites:")
		var websiteStr string
		in := bufio.NewReader(os.Stdin)
		line, err := in.ReadString('\n')
		if err != nil {
			return err
		}
		websiteStr = strings.TrimSpace(line)
		websites := strings.Split(websiteStr, " ")
		var finalWebsites []string
		for _, website := range websites {
			website = strings.TrimSpace(website)
			if len(website) > 0 {
				finalWebsites = append(finalWebsites, website)
			}
		}
		ext.Main.Websites = finalWebsites
		if len(ext.Main.Websites) == 0 {
			fmt.Println("Extension version should not be empty.")
		}
		break
	}
	// read extension build debian deps
	for {
		fmt.Println("Extension build debian_deps:")
		var depsString string
		in := bufio.NewReader(os.Stdin)
		line, err := in.ReadString('\n')
		if err != nil {
			return err
		}
		depsString = strings.TrimSpace(line)
		deps := strings.Split(depsString, " ")
		var finalDeps []string
		for _, dep := range deps {
			dep = strings.TrimSpace(dep)
			if len(dep) > 0 {
				finalDeps = append(finalDeps, dep)
			}
		}
		ext.Build.DebianDeps = finalDeps
		break
	}
	// read extension runtime library names
	for {
		fmt.Println("Extension runtime library_names:")
		var libsString string
		in := bufio.NewReader(os.Stdin)
		line, err := in.ReadString('\n')
		if err != nil {
			return err
		}
		libsString = strings.TrimSpace(line)
		libs := strings.Split(libsString, " ")
		var finalLibs []string
		for _, lib := range libs {
			lib = strings.TrimSpace(lib)
			if len(lib) > 0 {
				finalLibs = append(finalLibs, lib)
			}
		}
		ext.Runtime.LibraryNames = finalLibs
		break
	}
	// read extension runtime debian deps
	for {
		fmt.Println("Extension runtime debian_deps:")
		var depsString string
		in := bufio.NewReader(os.Stdin)
		line, err := in.ReadString('\n')
		if err != nil {
			return err
		}
		depsString = strings.TrimSpace(line)
		deps := strings.Split(depsString, " ")
		var finalDeps []string
		for _, dep := range deps {
			dep = strings.TrimSpace(dep)
			if len(dep) > 0 {
				finalDeps = append(finalDeps, dep)
			}
		}
		ext.Runtime.DebianDeps = finalDeps
		break
	}

	var descFileName = "ext_" + ext.Main.Name + ".desc.json"
	var shellScriptFileName = "ext_" + ext.Main.Name + ".sh"
	ext.Build.Script = shellScriptFileName
	const shellScriptContent = "#!/bin/bash\n\n"
	descFileContent, err := json.Marshal(ext)
	if err != nil {
		return err
	}

	// save files
	{
		descFile, err := os.OpenFile(descFileName, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0644)
		if err != nil {
			return err
		}
		defer func(descFile *os.File) {
			_ = descFile.Close()
		}(descFile)
		_, err = descFile.Write(descFileContent)
		if err != nil {
			return err
		}
		ssFile, err := os.OpenFile(shellScriptFileName, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0644)
		if err != nil {
			return err
		}
		defer func(ssFile *os.File) {
			_ = ssFile.Close()
		}(ssFile)
		_, err = ssFile.Write([]byte(shellScriptContent))
		if err != nil {
			return err
		}
	}

	return nil
}
