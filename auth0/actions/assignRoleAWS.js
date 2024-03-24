function (user, context, callback) {
  if(context.clientID !== 'ukWrVdyicKKWW7UGqEUQinA2X24Ogxd1'){
    return callback(null, user, context);
  }

  user.awsRole = 'arn:aws:iam::456391925047:saml-provider/AWSSSO_ec4ab332ffcf9366_DO_NOT_DELETE';
  user.awsRoleSession = user.name;

  context.samlConfiguration.mappings = {
    'https://aws.amazon.com/SAML/Attributes/Role': 'awsRole',
    'https://aws.amazon.com/SAML/Attributes/RoleSessionName': 'awsRoleSession'
  };

  callback(null, user, context);

}
