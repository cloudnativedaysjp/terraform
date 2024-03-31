// Copied from https://github.com/auth0-extensions/auth0-account-link-extension/issues/165#issuecomment-1753005657
const request = require("request");
const queryString = require("query-string");
const Promise = require("native-or-bluebird");
const jwt = require("jsonwebtoken");
const axios = require("axios");

exports.onExecutePostLogin = async (event, api) => {
  var LOG_TAG = '[ACTION_ACCOUNT_LINK] ';

  var CONTINUE_PROTOCOL = 'redirect-callback';
  var Auth0ManagementAccessToken = '';

  event.request.query = event.request.query || {};

  var config = {
    endpoints: {
      linking: `https://${event.secrets.AUTH0_DOMAIN}.webtask.run/4cb95bf92ced903b9b84ebedbf5ebffd`,
      userApi: `https://${event.secrets.AUTH0_DOMAIN}.auth0.com/api/v2/users`, 
      usersByEmailApi: `https://${event.secrets.AUTH0_DOMAIN}.auth0.com/api/v2/users-by-email`
    },
    token: {
      clientId: event.secrets.M2M_CLIENT_ID,
      clientSecret: event.secrets.M2M_CLIENT_SECRET,
      issuer: `${event.secrets.AUTH0_DOMAIN}.auth0.com`
    }
  };

  if (event.user.email === undefined) {
    console.log(LOG_TAG, 'Account Link Action: No event.user.email');
    return;
  }

  await createStrategy().then(callbackWithSuccess).catch(callbackWithFailure);

  async function createStrategy() {
    if (shouldLink()) {
      await setManagementAccessToken(true);
      return linkAccounts();
    }

    if (shouldPrompt()) {
      await setManagementAccessToken(false);
      return promptUser();
    }

    return continueAuth();

    function shouldLink() {
      return !!event.request.query.link_account_token;
    }

    function shouldPrompt() {
      return !insideRedirect() && !redirectingToContinue() && firstLogin();

      function insideRedirect() {
        return event.request.query.redirect_uri &&
          event.request.query.redirect_uri.indexOf(config.endpoints.linking) !== -1;
      }

      function firstLogin() {
        return event.stats.logins_count <= 1;
      }

      function redirectingToContinue() {
        return event.protocol === CONTINUE_PROTOCOL;
      }
    }
  }

  async function setManagementAccessToken(shouldLink) {
    if (Auth0ManagementAccessToken !== ''){
      return;
    }

    if (shouldLink) {
      var options = {
        method: 'POST',
        url: `https://${event.secrets.AUTH0_DOMAIN}.auth0.com/oauth/token`,
        headers: {'content-type': 'application/x-www-form-urlencoded'},
        data: new URLSearchParams({
          grant_type: 'client_credentials',
          client_id: event.secrets.APP_CLIENT_ID,
          client_secret: event.secrets.APP_CLIENT_SECRET,
          audience: event.secrets.BASE_URL + "/"
        })
      };
    }
    else {
      var options = {
        method: 'POST',
        url: `https://${event.secrets.AUTH0_DOMAIN}.auth0.com/oauth/token`,
        headers: {'content-type': 'application/x-www-form-urlencoded'},
        data: new URLSearchParams({
          grant_type: 'client_credentials',
          client_id: event.secrets.M2M_CLIENT_ID,
          client_secret: event.secrets.M2M_CLIENT_SECRET,
          audience: event.secrets.BASE_URL + "/"
        })
      };
    }

    try {
      const response = await axios.request(options);
      Auth0ManagementAccessToken = response.data.access_token;
    } catch (error) {
      console.error(LOG_TAG, "axios error:" + error + " for options: " + JSON.stringify(options, null, 2));
      return;
    }
  }

  function verifyToken(token, secret) {
    return new Promise(function(resolve, reject) {
      jwt.verify(token, secret, function(err, decoded) {
        if (err) {
          console.error(LOG_TAG, `verifyToken error: ${err}`);
          return reject(err);
        }

        return resolve(decoded);
      });
    });
  }

  function linkAccounts() {
    var secondAccountToken = event.request.query.link_account_token;

    return verifyToken(secondAccountToken, config.token.clientSecret)
      .then(function(decodedToken) {
        // Redirect early if tokens are mismatched
        if (event.user.email !== decodedToken.email) {
          console.error(LOG_TAG, 'User: ', decodedToken.email, 'tried to link to account ', event.user.email);
          event.redirect = {
            url: buildRedirectUrl(secondAccountToken, event.request.query, 'accountMismatch')
          };

          return event.user;
        }

        var headers = {
          Authorization: 'Bearer ' + Auth0ManagementAccessToken,
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache'
        };

        var getUrl = config.endpoints.userApi+'/'+decodedToken.sub+'?fields=identities';

        return apiCall({
          method: 'GET',
          url: getUrl,
          headers: headers
        })
          .then(function(secondaryUser) {
            var provider = secondaryUser &&
              secondaryUser.identities &&
              secondaryUser.identities[0] &&
              secondaryUser.identities[0].provider;

            var linkUri = config.endpoints.userApi + '/' + event.user.user_id + '/identities';

            return apiCall({
              method: 'POST',
              url: linkUri,
              headers,
              json: { user_id: decodedToken.sub, provider: provider }
            });
          })
          .then(function(_) {
            console.info(LOG_TAG, 'Successfully linked accounts for user: ', event.user.email);
            return _;
          });
      });
  }

  function continueAuth() {
    return Promise.resolve();
  }

  function promptUser() {
    return searchUsersWithSameEmail().then(function transformUsers(users) {
      return users.filter(function(u) {
        return u.user_id !== event.user.user_id;
      }).map(function(user) {
        return {
          userId: user.user_id,
          email: user.email,
          picture: user.picture,
          connections: user.identities.map(function(identity) {
            return identity.connection;
          })
        };
      });
    }).then(function redirectToExtension(targetUsers) {
      if (targetUsers.length > 0) {
        event.redirect = {
          url: buildRedirectUrl(createToken(config.token), event.request.query)
        };
      }
    });
  }

  function callbackWithSuccess(_) {
    if (api.redirect.canRedirect() && event.redirect) {
      api.redirect.sendUserTo(event.redirect.url);
    }

    return;
  }

  function callbackWithFailure(err) {
    console.error(LOG_TAG, err.message, err.stack);
    api.access.deny(err.message);
  }

  function createToken(tokenInfo, targetUsers) {
    var options = {
      expiresIn: '5m',
      audience: tokenInfo.clientId,
      issuer: qualifyDomain(tokenInfo.issuer)
    };

    var userSub = {
      sub: event.user.user_id,
      email: event.user.email,
      base: event.secrets.BASE_URL
    };

    return jwt.sign(userSub, tokenInfo.clientSecret, options);
  }

  function searchUsersWithSameEmail() {
    return apiCall({
      url: config.endpoints.usersByEmailApi,
      qs: {
        email: event.user.email
      }
    });
  }

  // Consider moving this logic out of the rule and into the extension
  function buildRedirectUrl(token, q, errorType) {
    var params = {
      child_token: token,
      audience: q.audience,
      client_id: q.client_id,
      redirect_uri: q.redirect_uri,
      scope: q.scope,
      response_type: q.response_type,
      response_mode: q.response_mode,
      auth0Client: q.auth0Client,
      original_state: q.original_state || q.state,
      nonce: q.nonce,
      error_type: errorType
    };

    return config.endpoints.linking + '?' + queryString.stringify(params);
  }

  function qualifyDomain(domain) {
    return 'https://'+domain+'/';
  }

  function apiCall(options) {
    return new Promise(function(resolve, reject) {
      var reqOptions = Object.assign({
        url: options.url,
        headers: {
          Authorization: 'Bearer ' + Auth0ManagementAccessToken,
          Accept: 'application/json'
        },
        json: true
      }, options);

      request(reqOptions, function handleResponse(err, response, body) {
        if (err) {
          reject(err);
        } else if (response.statusCode < 200 || response.statusCode >= 300) {
          console.error(LOG_TAG, 'API call failed: ', body);
          reject(new Error(body));
        } else {
          resolve(response.body);
        }
      });
    });
  }
};
