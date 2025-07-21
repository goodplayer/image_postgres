package generate

import (
	"bufio"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"strings"

	"pgimagetool/commands/common"
	"pgimagetool/utils"
)

type GenerateCreateExtensionCommand struct {
}

func (g *GenerateCreateExtensionCommand) Run() error {
	// list extensions
	list, err := utils.FindFileBySuffix(".desc.json")
	if err != nil {
		return err
	}
	var listDescs []*common.BuildDescFile
	for _, v := range list {
		if desc, err := readMetaFile(v); err != nil {
			return err
		} else {
			listDescs = append(listDescs, desc)
		}
	}

	fmt.Println("Extension names:")
	var extNamesStr string
	in := bufio.NewReader(os.Stdin)
	line, err := in.ReadString('\n')
	if err != nil {
		return err
	}
	extNamesStr = strings.TrimSpace(line)
	extNames := strings.Split(extNamesStr, " ")
	var finalExtNames []string
	for _, extName := range extNames {
		extName = strings.TrimSpace(extName)
		if len(extName) > 0 {
			finalExtNames = append(finalExtNames, extName)
		}
	}

	var result []struct {
		Name    string
		ExtList []string
	}
Loop:
	for _, ext := range finalExtNames {
		for _, elem := range listDescs {
			if strings.ToLower(ext) == strings.ToLower(elem.Main.Name) {
				result = append(result, struct {
					Name    string
					ExtList []string
				}{Name: ext, ExtList: elem.Runtime.ExtensionNames})
				continue Loop
			}
		}
		return errors.New("cannot find extension: " + ext)
	}

	builder := new(strings.Builder)
	for _, v := range result {
		builder.WriteString(fmt.Sprintf("-- Extension: %s\n", v.Name))
		for _, elem := range v.ExtList {
			builder.WriteString(fmt.Sprintf("CREATE EXTENSION IF NOT EXISTS %s CASCADE;\n", elem))
		}
	}

	fmt.Println(builder.String())

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
