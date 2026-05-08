output "auth_sso_values" {
	value=compact([
		yamlencode({
		configs={
			cm={
				"admin.enabled"=var.argocd_sso_config.enable_admin_login
				"dex.config"=yamlencode({
					connectors =[{
						type="saml"
						id="customer-idp"
						name="customer-idp"
						config={
							caData="$customer-idp-saml:caData"
							emailAttr="email"
							entityIssuer="$customer-idp-saml:entityIssuer"
							groupsAttr="groups"
							redirectURI="$customer-idp-saml:redirectURI"
							ssoURL="$customer-idp-saml:ssoURL"
							usernameAttr="name"
						}
					}]
				})
			}
			rbac={
				"policy.csv"=join("\n", [
					"g, customer-idp:liferay-argocd-role-admin, role:liferay-admin",
					"g, customer-idp:liferay-argocd-role-guest, role:liferay-guest",
					"p, role:liferay-admin, applications, *, */*, allow",
					"p, role:liferay-admin, clusters, *, *, allow",
					"p, role:liferay-admin, projects, *, *, allow",
					"p, role:liferay-admin, repositories, *, *, allow",
					"p, role:liferay-admin, accounts, *, *, allow",
					"p, role:liferay-guest, applications, get, */*, allow",
					"p, role:liferay-guest, clusters, get, *, allow",
					"p, role:liferay-guest, projects, get, *, allow",
					"p, role:liferay-guest, repositories, get, *, allow",
				])
				"policy.default"="role:liferay-guest"
			}
		}
		}),
		var.argocd_sso_config.custom_values_yaml,
	])
}
