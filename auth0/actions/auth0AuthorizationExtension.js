const axios = require("axios");

exports.onExecutePostLogin = async (event, api) => {
  const namespace = 'https://cloudnativedays.jp/claims/';

  let audience = '';
  audience = audience || (event.request && event.request.query && event.request.query.audience);
  if (audience === 'urn:auth0-authz-api') {
    return api.access.deny('no_end_users');
  }

  audience = audience || (event.request && event.request.body && event.request.body.audience);
  if (audience === 'urn:auth0-authz-api') {
    return api.access.deny('no_end_users');
  }

  let res
  try {
    res = await getPolicy(event)
  } catch (err) {
    console.log('Error from Authorization Extension:', err);
    return api.access.deny('Authorization Extension: ' + err);
  }
  if (res.status !== 200) {
    console.log('Error from Authorization Extension:', res.status, res.data);
    return api.access.deny('Authorization Extension: ', res.status, (res.data && res.data.message) || res.data);
  }

  // set groups as custom claim for authorization by groups
  api.idToken.setCustomClaim(namespace + 'groups', res.data.groups);

  // set groups to user_data for consequent actions
  api.user.setUserMetadata('groups', res.data.groups);
  return
}

async function getPolicy(event) {
  const extensionUrl = "https://dreamkast.us.webtask.run/adf6e2f2b84784b57522e3b19dfc9201";
  return await axios.request({
    method: 'POST',
    url: extensionUrl + "/api/users/" + event.user.user_id + "/policy/" + event.client.client_id,
    headers: {
      "x-api-key": event.secrets.AUTHZ_EXT_API_KEY,
      "content-type": "application/json"
    },
    data: {
      connectionName: event.connection.name || event.user.identities[0].connection.name,
      groups: []
    },
    timeout: 5000
  })
}
