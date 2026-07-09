terraform {
	required_providers {
		helm={
			source="hashicorp/helm"
			version="~> 3.1"
		}
		kubernetes={
			source="hashicorp/kubernetes"
			version="~> 2.36"
		}
		time={
			source="hashicorp/time"
			version="~> 0.12"
		}
	}
	required_version=">= 1.10.0"
}
