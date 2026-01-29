package utils

type Config struct {
	MetricsAddress string `env:"METRICS_ADDRESS" envDefault:":8080"`
	ProbeAddress   string `env:"PROBE_ADDRESS" envDefault:":8081"`
}