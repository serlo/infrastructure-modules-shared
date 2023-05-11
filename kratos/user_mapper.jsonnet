local claims = std.extVar('claims');

local enshortenUuid(uuid) =
  local uuidWithoutDomain = std.split(uuid, "@")[0];
  std.split(uuidWithoutDomain, '-')[0];

{
  identity: {
    traits: {
      // it would be better to check if email is verified, but it seems that NBP responds with false even for verified ones
      email: claims.email,
      username: enshortenUuid(claims.preferred_username),
      interest: "",
    },
  },
}
