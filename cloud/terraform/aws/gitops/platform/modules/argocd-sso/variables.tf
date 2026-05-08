variable "argocd_sso_config" {
	type=object({
		custom_values_yaml=optional(string)
		enable_admin_login=optional(bool, true)
		enable_sso=optional(bool, false)
		entity_issuer=optional(string)
		redirect_uri=optional(string)
	})
}
