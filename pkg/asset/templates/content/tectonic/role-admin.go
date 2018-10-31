package tectonic

import (
	"os"
	"path/filepath"

	"github.com/openshift/installer/pkg/asset"
	"github.com/openshift/installer/pkg/asset/templates/content"
)

const (
	roleAdminFileName = "role-admin.yaml"
)

var _ asset.WritableAsset = (*RoleAdmin)(nil)

// RoleAdmin  is the variable/constant representing the contents of the respective file
type RoleAdmin struct {
	fileName string
	FileList []*asset.File
}

// Dependencies returns all of the dependencies directly needed by the asset
func (t *RoleAdmin) Dependencies() []asset.Asset {
	return []asset.Asset{}
}

// Name returns the human-friendly name of the asset.
func (t *RoleAdmin) Name() string {
	return "RoleAdmin"
}

// Generate generates the actual files by this asset
func (t *RoleAdmin) Generate(parents asset.Parents) error {
	t.fileName = roleAdminFileName
	data, err := content.GetTectonicTemplate(t.fileName)
	if err != nil {
		return err
	}
	t.FileList = []*asset.File{
		{
			Filename: filepath.Join(content.TemplateDir, t.fileName),
			Data:     []byte(data),
		},
	}
	return nil
}

// Files returns the files generated by the asset.
func (t *RoleAdmin) Files() []*asset.File {
	return t.FileList
}

// Load returns the asset from disk.
func (t *RoleAdmin) Load(f asset.FileFetcher) (bool, error) {
	file, err := f.FetchByName(filepath.Join(content.TemplateDir, roleAdminFileName))
	if err != nil {
		if os.IsNotExist(err) {
			return false, nil
		}
		return false, err
	}
	t.FileList = []*asset.File{file}
	return true, nil
}
