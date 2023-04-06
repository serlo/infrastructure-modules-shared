local claims = std.extVar('claims');
// TODO: delete after tests
// std.trace("claims from nbp: %s" % [claims], claims)

// TODO: complete
local rolesMap = {
  student: 'pupil'
};

{
  identity: {
    traits: {
      // it would be better to check if email is verified, but it seems that NBP respond with false for verified email adresses
      email: claims.email,
      username:  std.split(claims.preferred_username, "@")[0],
      interest: [if 'roll' in claims then rolesMap[claims.roll] else ""],
    },
  },
}