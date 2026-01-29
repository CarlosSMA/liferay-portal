package manager

import (
	"github.com/caarlos0/env/v11"
	"github.com/liferay/liferay-portal/cloud/operator/internal/utils"
	"k8s.io/apimachinery/pkg/labels"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/cache"
	"sigs.k8s.io/controller-runtime/pkg/healthz"
	metricsserver "sigs.k8s.io/controller-runtime/pkg/metrics/server"
)

func CreateManager() (ctrl.Manager, error) {
	cfg, err := env.ParseAs[Config]()
	if err != nil {
		return nil, err
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
			HealthProbeBindAddress: cfg.ProbeAddress,
			Metrics: metricsserver.Options{
				BindAddress: cfg.MetricsAddress,
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

type Config struct {
	MetricsAddress string `env:"METRICS_ADDRESS" envDefault:":8080"`
	ProbeAddress   string `env:"PROBE_ADDRESS" envDefault:":8081"`
}