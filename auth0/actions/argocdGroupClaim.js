exports.onExecutePostLogin = async (event, api) => {
  const namespace = 'https://cloudnativedays.jp/claims/';
  api.idToken.setCustomClaim(namespace + 'groups', event.user.groups);
}
