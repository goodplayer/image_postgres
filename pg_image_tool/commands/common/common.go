package common

type BuildDescFile struct {
	Main struct {
		Name     string   `json:"name"`
		Category string   `json:"category"`
		Version  string   `json:"version"`
		Websites []string `json:"websites"`
	} `json:"main"`
	Build struct {
		Script string `json:"script"`
	} `json:"build"`
	Runtime struct {
		LibraryNames []string `json:"library_names"`
	} `json:"runtime"`
}
