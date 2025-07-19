package installrtdeps

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"

	"pgimagetool/commands/common"
	"pgimagetool/utils"
)

type InstallRuntimeDeps struct{}

func (i *InstallRuntimeDeps) Run() error {
	// invoke every buildscript
	list, err := utils.FindFileBySuffix(".desc.json")
	if err != nil {
		return err
	}

	for _, v := range list {
		if desc, err := readMetaFile(v); err != nil {
			return err
		} else {
			fmt.Println("install runtime deps for extension:", desc.Main.Name)
			// run install deps
			if len(desc.Runtime.DebianDeps) > 0 {
				var args = []string{"install", "-y"}
				for _, v := range desc.Runtime.DebianDeps {
					args = append(args, v)
				}
				cmd := exec.Command("/usr/bin/apt-get", args...)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				if err := cmd.Run(); err != nil {
					fmt.Println("install runtime debian_deps failed: ", err)
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
