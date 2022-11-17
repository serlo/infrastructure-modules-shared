const mysql = require('mysql')
const Configuration = require('@ory/kratos-client').Configuration
const V0alpha2Api = require('@ory/kratos-client').V0alpha2Api

const config = {
  kratosHost: `${kratos_host}`,
  db: {
    host: `${database_host}`,
    user: `${database_username}`,
    password: `${database_password}`,
    database: `${database_name}`,
  },
}

const kratos = new V0alpha2Api(
  new Configuration({
    basePath: config.kratosHost,
  })
)

const connection = mysql.createConnection({
  host: config.db.host,
  user: config.db.user,
  password: config.db.password,
  database: config.db.database,
})

connection.connect(async (error) => {
  if (error) throw error
  connection.query('SELECT * FROM user where id = 1 or id = 10 or id = 266 or id = 15473 or id = 26217 or id = 32543 or id = 64900 or id = 73435 or id = 87602 or id = 92258 or id = 169563 or id = 178807 or id = 240298 or id = 252992', async (error, result) => {
    if (error) throw error
    let allIdentities = []
    for (let page = 1; page < result.length / 100 + 1; page++) {
      allIdentities = [
        ...allIdentities,
        ...(await kratos
          .adminListIdentities(100, page)
          .then(({ data }) => data)),
      ]
    }
    if (allIdentities) {
      for (const identity of allIdentities) {
        await kratos.adminDeleteIdentity(identity.id)
      }
    }
    await importUsers(result)
    console.log('Successful Import of Users')
    process.exit(0)
  })
})

async function importUsers(users) {
  for (const legacyUser of users) {
    const user = {
      traits: {
        username: legacyUser.username,
        email: legacyUser.email,
        description: legacyUser.description || '',
      },
      credentials: {
        password: {
          config: {
            password: '123456',
          },
        },
      },
      metadata_public: { legacy_id: legacyUser.id },
      verifiable_addresses: [
        {
          value: legacyUser.email,
          verified: true,
          via: 'email',
          status: 'completed',
        },
      ],
    }
    console.log('Importing user...')
    await kratos.adminCreateIdentity(user)
  }
}
