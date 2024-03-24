exports.onExecutePostLogin = async (event, api) => {
  if(event.client.client_id !== 'ukWrVdyicKKWW7UGqEUQinA2X24Ogxd1'){
    return
  }

  // https://community.auth0.com/t/saml-attribute-mapping-in-actions/88673
  api.samlResponse.setAttributes(
    'https://aws.amazon.com/SAML/Attributes/Role',
    'arn:aws:iam::456391925047:saml-provider/AWSSSO_ec4ab332ffcf9366_DO_NOT_DELETE'
  );
  api.samlResponse.setAttributes(
    'https://aws.amazon.com/SAML/Attributes/RoleSessionName',
    event.user.name
  );
}
