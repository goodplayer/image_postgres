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
	fmt.Println("Running buildscripts with pg_config path:", b.PgConfig)

	// invoke every buildscript
	list, err := utils.FindFileBySuffix(".desc.json")
	if err != nil {
		return err
	}

	for _, v := range list {
		if desc, err := readMetaFile(v); err != nil {
			return err
		} else {
			fmt.Println("building extension:", desc.Main.Name)
			cmd := exec.Command("/bin/bash", desc.Build.Script, b.PgConfig)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			if err := cmd.Run(); err != nil {
				fmt.Println("build failed: ", err)
				return err
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
