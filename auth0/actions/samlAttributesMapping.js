exports.onExecutePostLogin = async (event, api) => {
  event.user.awsRole = 'arn:aws:iam::456391925047:role/auth0-admin-role,arn:aws:iam::951887872838:saml-provider/MyAuth0';
  event.user.awsRoleSession = event.user.name;
  context.samlConfiguration.mappings = {
    'https://aws.amazon.com/SAML/Attributes/Role': 'awsRole',
    'https://aws.amazon.com/SAML/Attributes/RoleSessionName': 'awsRoleSession'
  };
  callback(null, user, context);
}
