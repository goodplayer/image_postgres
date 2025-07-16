package utils

import (
	"io/fs"
	"os"
	"strings"
)

func FindFileBySuffix(suffix string) ([]string, error) {
	var list []string
	err := fs.WalkDir(os.DirFS("."), ".", func(path string, d fs.DirEntry, e error) error {
		if e != nil {
			return e
		}
		if strings.HasSuffix(path, suffix) {
			list = append(list, path)
		}
		return nil
	})
	if err != nil {
		return nil, err
	} else {
		return list, nil
	}
}
