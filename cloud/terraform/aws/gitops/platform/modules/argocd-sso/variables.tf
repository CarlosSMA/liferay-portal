variable "argocd_sso_config" {
	type=object({
		enable_admin_login=optional(bool, true)
		enable_sso=optional(bool, false)
		rbac=optional(object({
			admins=list(string)
		}), { admins=[] })
		redirect_uri=optional(string)
	})
}
