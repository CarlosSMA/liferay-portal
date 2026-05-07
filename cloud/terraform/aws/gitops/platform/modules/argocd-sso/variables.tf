variable "argocd_sso_config" {
	type=object({
		custom_values_yaml=optional(string)
		enable_admin_login=optional(bool, true)
		enable_sso=optional(bool, false)
		rbac=optional(object({
			admins=list(string)
		}), { admins=[] })
		redirect_uri=optional(string)
	})
}
