package manager

import (
	"fmt"
	"github.com/liferay/liferay-portal/cloud/operator/internal/utils"
	"testing"
)

func TestCreateManager(t *testing.T) {
	t.Run("Should throw error if config is invalid", func(t *testing.T) {
		expectedError := "config is not a valid *utils.Config"
		type invalidEnv struct {
			invalid string
		}
		_, err := CreateManager(&invalidEnv{})
		if err.Error() != expectedError {
			t.Errorf("Actual error: [%v] | Expected error: [%v]", err, expectedError)
		}
	})

	t.Run("Should throw error if unable to parse envs", func(t *testing.T) {
		if _, err := CreateManager("invalid"); err == nil {
			t.Error("Expected to throw error")
		}
	})

	t.Run("Should create manager", func(t *testing.T) {
		cfg := utils.Config{}
		mgr, err := CreateManager(&cfg)
		if err != nil {
			t.Errorf("Unable to create manager: [%v]", err)
		}

		fmt.Println(mgr)
	})
}