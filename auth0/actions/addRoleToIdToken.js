exports.onExecutePostLogin = async (event, api) =>  {
  const namespace = 'https://cloudnativedays.jp/';
  const assignedRoles = (context.authorization || {}).roles;
  context.accessToken[namespace + 'roles'] = assignedRoles;
  context.idToken[namespace + 'roles'] = assignedRoles;
  return callback(null, user, context);
}
