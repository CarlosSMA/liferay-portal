package reconciler

import (
	"github.com/liferay/liferay-portal/cloud/operator/internal/controller"
	"github.com/liferay/liferay-portal/cloud/operator/internal/utils"
	ctrl "sigs.k8s.io/controller-runtime"
)

func CreateReconciler(mgr ctrl.Manager) error {
	reconciler := &controller.Reconciler{Client: mgr.GetClient()}

	if err := reconciler.SetupWithManager(mgr); err != nil {
		utils.SetupLog.Error(err, "Unable to create controller.")

		return err
	}

	if err := mgr.Start(ctrl.SetupSignalHandler()); err != nil {
		utils.SetupLog.Error(err, "Unexpected error while running manager.")

		return err
	}

	return nil
}