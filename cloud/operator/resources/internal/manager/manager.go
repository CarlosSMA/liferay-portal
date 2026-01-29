package manager

import (
	"errors"
	"github.com/caarlos0/env/v11"
	"github.com/liferay/liferay-portal/cloud/operator/internal/utils"
	"k8s.io/apimachinery/pkg/labels"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/cache"
	"sigs.k8s.io/controller-runtime/pkg/healthz"
	metricsserver "sigs.k8s.io/controller-runtime/pkg/metrics/server"
)

func CreateManager(config interface{}) (ctrl.Manager, error) {
	if err := env.Parse(config); err != nil {
		return nil, err
	}

	cf, ok := config.(*utils.Config)
	if !ok {
		return nil, errors.New("config is not a valid *utils.Config")
	}

	mgr, err := ctrl.NewManager(
		ctrl.GetConfigOrDie(),
		ctrl.Options{
			Cache: cache.Options{
				DefaultLabelSelector: labels.SelectorFromSet(
					map[string]string{
						"controller-watched": "yes",
					},
				),
			},
			HealthProbeBindAddress: cf.ProbeAddress,
			Metrics: metricsserver.Options{
				BindAddress: cf.MetricsAddress,
			},
			Scheme: utils.Scheme,
		},
	)
	if err != nil {
		utils.SetupLog.Error(err, "Unable to start manager.")

		return nil, err
	}

	if err := mgr.AddHealthzCheck("healthz", healthz.Ping); err != nil {
		utils.SetupLog.Error(err, "Unable to set up health check.")

		return nil, err
	}

	if err := mgr.AddReadyzCheck("readyz", healthz.Ping); err != nil {
		utils.SetupLog.Error(err, "Unable to set up ready check.")

		return nil, err
	}

	return mgr, nil
}