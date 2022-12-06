const sha1 = require('js-sha1')
const mysql = require('mysql')
const Configuration = require('@ory/client').Configuration
const V0alpha2Api = require('@ory/client').V0alpha2Api

const config = {
  kratosHost: `${kratos_host}`,
  db: {
    host: `${database_host}`,
    user: `${database_username}`,
    password: `${database_password}`,
    database: `${database_name}`,
  },
}

function uniqid(prefix = '', random = false) {
  const sec = Date.now() * 1000 + Math.random() * 1000
  const id = sec.toString(16).replace(/\./g, '').padEnd(14, '0')
  const number = random ? '.' + Math.trunc(Math.random() * 100000000) : ''
  return prefix + id + number
}

class HashService {
  salt_pattern = '1,3,5,9,14,15,20,21,28,30'

  constructor() {
    this.salt_pattern = this.salt_pattern.split(',')
  }

  hashPassword(password, salt = false) {
    if (salt === false) {
      salt = sha1(uniqid(null, true), this.salt_pattern)
    }

    let hash = sha1(salt + password)

    salt = salt.split('')

    password = ''

    let last_offset = 0

    for (const offset of this.salt_pattern) {
      const part = hash.substr(0, offset - last_offset)
      hash = hash.substr(offset - last_offset)

      password += part + salt.shift()

      last_offset = offset
    }

    return password + hash
  }

  findSalt(password) {
    let salt = ''
    for (const [index, offset] of this.salt_pattern.entries()) {
      salt += password.substr(parseInt(offset) + index, 1)
    }

    return salt
  }

  findSha(hashedPassword) {
    let sha = hashedPassword.split('')
    for (const offset of this.salt_pattern) {
      sha.splice(offset, 1)
    }

    return sha.join('')
  }
}

const hashService = new HashService()


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

  let allIdentities = []

  for (let page = 1; true; page++) {
    const data = await kratos
      .adminListIdentities(10, page)
      .then(({ data }) => data)
    if (!data.length) break
    allIdentities = [...allIdentities, ...data]
  }

  if (allIdentities) {
    allIdentities.map(async (identity) => {
      await kratos.adminDeleteIdentity(identity.id)
    })
  }

  connection.query('SELECT * FROM user', async (error, result) => {
    if (error) throw error
    await importUsers(result)
    console.log('Successful Import of Users')
    process.exit(0)
  })
})

async function importUsers(users) {
  for (const legacyUser of users) {
    const passwordSaltBase64 = Buffer.from(
      hashService.findSalt(legacyUser.password)
    ).toString('base64')
    const hashedPasswordBase64 = Buffer.from(
      hashService.findSha(legacyUser.password),
      'hex'
    ).toString('base64')
    const user = {
      traits: {
        username: legacyUser.username,
        email: legacyUser.email,
        description: legacyUser.description || '',
      },
      credentials: {
        password: {
          config: {
            // [p]assword[f]ormat = {SALT}{PASSWORD}
            hashed_password: `$sha1$pf=e1NBTFR9e1BBU1NXT1JEfQ==$${passwordSaltBase64}$${hashedPasswordBase64}`,
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
