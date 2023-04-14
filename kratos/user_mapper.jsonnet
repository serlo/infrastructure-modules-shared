local claims = std.extVar('claims');
// TODO: delete after tests
// std.trace("claims from nbp: %s" % [claims], claims)

// TODO: delete, since it will not be given in the id token
local rolesMap = {
  student: 'pupil'
};

local enshortenUuid(uuid) =
  local uuidWithoutDomain = std.split(uuid, "@")[0];
  std.split(uuidWithoutDomain, '-')[0];

{
  identity: {
    traits: {
      // it would be better to check if email is verified, but it seems that NBP responds with false even for verified ones
      email: claims.email,
      username: enshortenUuid(claims.preferred_username),
      interest: if 'role' in claims then rolesMap[claims.role] else "",
    },
  },
}
