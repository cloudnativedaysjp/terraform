exports.onExecutePostLogin = async (event, api) =>  {
  const namespace = 'https://cloudnativedays.jp/';
  const assignedRoles = (event.authorization || {}).roles;
  api.accessToken.setCustomClaim(namespace + 'roles', assignedRoles)
  api.idToken.setCustomClaim(namespace + 'roles', assignedRoles)
}
