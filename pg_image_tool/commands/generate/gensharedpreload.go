package generate

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"strings"

	"pgimagetool/commands/common"
	"pgimagetool/utils"
)

type GenerateSharedPreloadLibrariesCommand struct {
}

func (g *GenerateSharedPreloadLibrariesCommand) Run() error {
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

	var result = make(map[string]struct{})
Loop:
	for _, ext := range finalExtNames {
		for _, elem := range listDescs {
			if strings.ToLower(ext) == strings.ToLower(elem.Main.Name) {
				for _, lib := range elem.Runtime.LibraryNames {
					result[lib] = struct{}{}
				}
				continue Loop
			}
		}
		return errors.New("cannot find extension: " + ext)
	}
	var resultList []string
	for key := range result {
		resultList = append(resultList, key)
	}

	if len(resultList) > 0 {
		fmt.Println("Please add the following configure in postgresql.conf:")
		fmt.Printf("shared_preload_libraries = '%s'\n", strings.Join(resultList, ","))
	} else {
		fmt.Println("no need to setup shared_preload_libraries")
	}

	return nil
}
