package buildext

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"

	"pgimagetool/commands/common"
	"pgimagetool/utils"
)

type BuildExt struct {
	PgConfig string
}

func (b *BuildExt) Run() error {
	pgConfigPath := b.PgConfig
	fmt.Println("Running buildscripts with pg_config path:", pgConfigPath)

	// invoke every buildscript
	list, err := utils.FindFileBySuffix(".desc.json")
	if err != nil {
		return err
	}

	for _, v := range list {
		if desc, err := readMetaFile(v); err != nil {
			return err
		} else {
			fmt.Println("========>>>> building extension:", desc.Main.Name)
			// run install deps
			if len(desc.Build.DebianDeps) > 0 {
				var args = []string{"install", "-y"}
				for _, v := range desc.Build.DebianDeps {
					args = append(args, v)
				}
				cmd := exec.Command("/usr/bin/apt-get", args...)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				if err := cmd.Run(); err != nil {
					fmt.Println("install debian_deps failed: ", err)
					return err
				}
			}
			// invoke build script
			{
				cmd := exec.Command("/bin/bash", desc.Build.Script, pgConfigPath)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				if err := cmd.Run(); err != nil {
					fmt.Println("build failed: ", err)
					return err
				}
			}
		}
	}

	return nil
}

func readMetaFile(path string) (*common.BuildDescFile, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer func(file *os.File) {
		_ = file.Close()
	}(file)
	data, err := io.ReadAll(file)
	if err != nil {
		return nil, err
	}
	var buildDesc common.BuildDescFile
	if err := json.Unmarshal(data, &buildDesc); err != nil {
		return nil, err
	}
	return &buildDesc, nil
}

type BuildSingleExt struct {
	PgConfig string
	ExtName  string
}

func (b *BuildSingleExt) Run() error {
	pgConfigPath := b.PgConfig
	fmt.Println("Running buildscripts with pg_config path:", pgConfigPath)

	// invoke every buildscript
	list, err := utils.FindFileBySuffix(".desc.json")
	if err != nil {
		return err
	}

	found := false
	for _, v := range list {
		if desc, err := readMetaFile(v); err != nil {
			return err
		} else {
			if desc.Main.Name != b.ExtName {
				continue
			}
			found = true

			fmt.Println("========>>>> building extension:", desc.Main.Name)
			// run install deps
			if len(desc.Build.DebianDeps) > 0 {
				var args = []string{"install", "-y"}
				for _, v := range desc.Build.DebianDeps {
					args = append(args, v)
				}
				cmd := exec.Command("/usr/bin/apt-get", args...)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				if err := cmd.Run(); err != nil {
					fmt.Println("install debian_deps failed: ", err)
					return err
				}
			}
			// invoke build script
			{
				cmd := exec.Command("/bin/bash", desc.Build.Script, pgConfigPath)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				if err := cmd.Run(); err != nil {
					fmt.Println("build failed: ", err)
					return err
				}
			}
		}
	}
	if !found {
		return fmt.Errorf("build single extension not found target extension: %s", b.ExtName)
	}

	return nil
}
