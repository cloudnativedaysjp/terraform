function addUserInfoClaim(user, context, callback) {
  const namespace = 'https://cloudnativedays.jp/';
  context.accessToken[namespace + 'userinfo'] = {
    name: user.name,
    family_name: user.family_name,
    given_name: user.given_name,
    nickname: user.nickname,
    picture: user.picture,
    email: user.email,
    email_verified: user.email_verified,
    locale: user.locale,
  };
  return callback(null, user, context);
}
