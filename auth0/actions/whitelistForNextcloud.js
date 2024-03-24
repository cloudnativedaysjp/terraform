exports.onExecutePostLogin = async (event, api) => {
  // only enforce for NameOfTheAppWithWhiteList
  // bypass this rule for all other apps
  if(context.clientID !== 'Ivee5RoyvPB8PcUdiLZqPnGZSmixkK5N'){
    return callback(null, user, context);
  }

  // Access should only be granted to verified users.
  if (!event.user.email || !event.user.email_verified) {
    return callback(new UnauthorizedError('Access denied.'));
  }

  const whitelist = [ 'admin', 'dreamkast-core', 'broadcast-core', 'creators', 'general' ]; // authorized groups
  const userHasAccess = whitelist.some(function (group) {
    return event.user.groups.includes(group);
  });

  if (!userHasAccess) {
    return callback(new UnauthorizedError('Access denied.'));
  }

  callback(null, user, context);
}
