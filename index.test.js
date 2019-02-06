const app = require('./index')
const server = app.listen(8000)
const request = require('supertest').agent(server)

describe('icecream service', function() {
  after(function() {
    server.close()
  })

  it('should say "Welcome to the ice cream service!"', function(done) {
    request
      .get('/')
      .expect(200)
      .expect('{"message":"Welcome to the ice cream service!"}', done)
  })
  it('should return flavor vanilla', function(done) {
    request
      .get('/vanilla')
      .expect(200)
      .expect('{"flavor":"vanilla"}', done)
  })

  it('should return flavor banana', function(done) {
    request
      .get('/banana')
      .expect(200)
      .expect('{"flavor":"banana"}', done)
  })
})
