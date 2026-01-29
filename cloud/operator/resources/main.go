package main

import (
	"github.com/liferay/liferay-portal/cloud/operator/internal/manager"
	"github.com/liferay/liferay-portal/cloud/operator/internal/reconciler"
	"github.com/liferay/liferay-portal/cloud/operator/internal/utils"
	utilruntime "k8s.io/apimachinery/pkg/util/runtime"
	clientgoscheme "k8s.io/client-go/kubernetes/scheme"
	"log"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log/zap"
)

func init() {
	utilruntime.Must(clientgoscheme.AddToScheme(utils.Scheme))
}

func main() {
	mgr, err := manager.CreateManager()
	if err != nil {
		log.Fatal(err)
	}

	ctrl.SetLogger(zap.New())

	if err := reconciler.CreateReconciler(mgr); err != nil {
		log.Fatal(err)
	}
}