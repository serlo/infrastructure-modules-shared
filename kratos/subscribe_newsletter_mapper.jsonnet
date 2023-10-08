function(ctx) {
  email_address: if 'optedNewsletterIn' in ctx.identity.traits && ctx.identity.traits.optedNewsletterIn == true then
    ctx.identity.traits.email
  else
    error 'User did not opted newsletter in. Aborting!',
  merge_fields: {
    UNAME: ctx.identity.traits.username,
  },
  status: 'subscribed',
}
