exports.onExecutePostLogin = async (event, api) =>  {
  const namespace = 'https://cloudnativedays.jp/';
  api.accessToken.setCustomClaim(namespace + 'userinfo', {
    name: event.user.name,
    family_name: event.user.family_name,
    given_name: event.user.given_name,
    nickname: event.user.nickname,
    picture: event.user.picture,
    email: event.user.email,
    email_verified: event.user.email_verified,
    locale: event.user.locale,
  });
}
