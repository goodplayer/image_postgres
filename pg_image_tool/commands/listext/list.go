package listext

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"pgimagetool/commands/common"
	"pgimagetool/utils"
)

type ListExtCommand struct {
}

func (l *ListExtCommand) Run() error {
	// list extensions
	list, err := utils.FindFileBySuffix(".desc.json")
	if err != nil {
		return err
	}

	for _, v := range list {
		if desc, err := readMetaFile(v); err != nil {
			return err
		} else {
			fmt.Printf("name:%s category:%s version:%s buildscript:%s load:%s\n",
				desc.Main.Name, desc.Main.Category, desc.Main.Version, desc.Build.Script, strings.Join(desc.Runtime.LibraryNames, ","))
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
