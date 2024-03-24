exports.onExecutePostLogin = async (event, api) => {
  var namespace = 'https://cloudnativedays.jp/claims/'; // You can set your own namespace, but do not use an Auth0 domain

  context.idToken[namespace + "groups"] = event.user.groups;
  
  callback(null, user, context);
}
