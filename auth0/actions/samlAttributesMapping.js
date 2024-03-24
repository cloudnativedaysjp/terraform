exports.onExecutePostLogin = async (event, api) => {
  // https://community.auth0.com/t/saml-attribute-mapping-in-actions/88673
  api.samlResponse.setAttributes(
    'https://aws.amazon.com/SAML/Attributes/Role',
    'arn:aws:iam::456391925047:role/auth0-admin-role,arn:aws:iam::951887872838:saml-provider/MyAuth0'
  );
  api.samlResponse.setAttributes(
    'https://aws.amazon.com/SAML/Attributes/RoleSessionName',
    event.user.name
  );
}
