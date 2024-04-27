exports.onExecutePostLogin = async (event, api) => {
  // only enforce for NameOfTheAppWithWhiteList
  // bypass this rule for all other apps
  if(event.client.client_id !== 'Ivee5RoyvPB8PcUdiLZqPnGZSmixkK5N'){
    return
  }
  const namespace = 'https://cloudnativedays.jp/';

  // Access should only be granted to verified users.
  if (!event.user.email || !event.user.email_verified) {
    return api.access.deny('Access denied.');
  }

  const groups = event.user.user_metadata['groups'];
  const whitelist = [ 'admin', 'dreamkast-core', 'broadcast-core', 'creators', 'general' ]; // authorized groups

  const userHasAccess = whitelist.some((allowed) => groups.includes(allowed));
  if (!userHasAccess) {
    return api.access.deny('Access denied.');
  }
}
