const axios = require("axios");

exports.onExecutePostLogin = async (event, api) => {
  const namespace = 'https://cloudnativedays.jp/';

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
  if (res.statusCode !== 200) {
    console.log('Error from Authorization Extension:', res.body || res.statusCode);
    return api.access.deny('Authorization Extension: ' + ((res.body && (res.body.message || res.body) || res.statusCode)));
  }

  // set as custom claim for authorization by groups at ArgoCD
  api.idToken.setCustomClaim(namespace + 'groups', res.data.groups);
  return
}

// Convert groups to array
function parseGroups(data) {
  if (typeof data === 'string') {
    // split groups represented as string by spaces and/or comma
    return data.replace(/,/g, ' ').replace(/\s+/g, ' ').split(' ');
  }
  return data;
}

async function getPolicy(event) {
  const extensionUrl = "https://dreamkast.us.webtask.run/adf6e2f2b84784b57522e3b19dfc9201";
  return await axios.request({
    method: 'POST',
    url: extensionUrl + "/api/users/" + event.user.user_id + "/policy/" + event.clientID,
    headers: {
      "x-api-key": event.secrets.AUTHZ_EXT_API_KEY,
      "content-type": "application/json"
    },
    data: {
      connectionName: event.connection || event.user.identities[0].connection,
      groups: parseGroups(event.user.groups)
    },
    timeout: 5000
  })
}
